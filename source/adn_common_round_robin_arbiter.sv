/*

# Purpose
The `adn_common_round_robin_arbiter` module implements a fair, round-robin arbitration scheme to select a single requester from multiple input requests. It ensures that every requester is granted access in a rotating order, preventing starvation and ensuring equitable bandwidth distribution among all input channels.

### Use Case
This module is primarily used in high-performance interconnects, such as:
- **Network-on-Chip (NoC) Routers:** To manage multiple input ports competing for a single output virtual channel.
- **Memory Controllers:** To arbitrate between multiple masters (e.g., CPU, DMA, GPU) requesting access to a shared memory interface.
- **Bus Interconnects:** To ensure fair access to shared peripheral buses where no single master should monopolize the bus bandwidth.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-28 | Motasim Faiyaz  | Initial version                                        |
| 1.0      | 2026-07-28 | Motasim Faiyaz  | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Simplified Logic                                       |
| 1.2      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

Author : Motasim Faiyaz (motasimfaiyaz@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_pmi_nxm_crossbar #(
    parameter int  NUM_MASTERS     = 4,
    parameter int  NUM_SLAVES      = 4,
    parameter int  ADDR_WIDTH      = 32,
    parameter int  DATA_WIDTH      = 32,
    parameter int  NUM_RULES       = 4,
    parameter int  FIFO_DEPTH_LOG2 = 4,
    parameter type pmi_req_t       = logic,
    parameter type pmi_rsp_t       = logic,

    // Derived parameters
    localparam int MID_W = (NUM_MASTERS > 1) ? $clog2(NUM_MASTERS) : 1,
    localparam int SID_W = (NUM_SLAVES > 1) ? $clog2(NUM_SLAVES) : 1,
    // TRACK_W: SID bits + 1 decode-error flag bit
    localparam int TRACK_W = SID_W + 1,
    localparam logic [TRACK_W-1:0] DEC_ERR_SID = TRACK_W'(NUM_SLAVES),

    // Request flat bus: maddr + mwe + mwdata + mstrb + mreq
    localparam int REQ_W         = ADDR_WIDTH + 1 + DATA_WIDTH + (DATA_WIDTH / 8) + 1,
    // Response payload (no mgnt/mack — those are control, not data)
    localparam int RSP_PAYLOAD_W = DATA_WIDTH + 1
) (
    input logic clk_i,
    input logic arst_ni,

    // Master ports (crossbar acts as slave toward these)
    input  pmi_req_t [NUM_MASTERS-1:0] m_req_i,
    output pmi_rsp_t [NUM_MASTERS-1:0] m_rsp_o,

    // Slave ports (crossbar acts as master toward these)
    output pmi_req_t [NUM_SLAVES-1:0] s_req_o,
    input  pmi_rsp_t [NUM_SLAVES-1:0] s_rsp_i,

    // Static address map (tie to constants at SoC level)
    input logic [ADDR_WIDTH-1:0] min_addr_i [NUM_RULES],
    input logic [ADDR_WIDTH-1:0] max_addr_i [NUM_RULES],
    input logic [     SID_W-1:0] slave_map_i[NUM_RULES]
);

  //==========================================================================
  // 1. ADDRESS DECODING
  //==========================================================================
  logic [NUM_MASTERS-1:0][SID_W-1:0] dec_sid;
  logic [NUM_MASTERS-1:0]            dec_found;
  logic [NUM_MASTERS-1:0]            dec_valid_req;  // mreq & found & fifo space
  logic [NUM_MASTERS-1:0]            dec_error_req;  // mreq & !found & fifo space
  logic [NUM_MASTERS-1:0]            track_fifo_ready;
  logic [NUM_MASTERS-1:0]            err_counter_ready;

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : GEN_ADDR_DEC
    adn_common_address_decoder #(
        .ADDR_WIDTH    (ADDR_WIDTH),
        .SLAVE_ID_WIDTH(SID_W),
        .NUM_RULES     (NUM_RULES)
    ) u_addr_dec (
        .addr_i       (m_req_i[i].maddr),
        .min_addr_i   (min_addr_i),
        .max_addr_i   (max_addr_i),
        .slave_id_i   (slave_map_i),
        .slave_index_o(dec_sid[i]),
        .addr_found_o (dec_found[i])
    );

    // Physical request: address hit AND tracker has room
    assign dec_valid_req[i] = m_req_i[i].mreq & dec_found[i] & track_fifo_ready[i];

    // Decode-error request: no hit, tracker + err-counter both have room
    assign dec_error_req[i] = m_req_i[i].mreq & ~dec_found[i]
                                 & track_fifo_ready[i] & err_counter_ready[i];
  end

  // Build per-slave request bitmap: which masters are targeting slave j
  logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] req_to_slave;

  always_comb begin
    req_to_slave = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (dec_valid_req[i]) req_to_slave[dec_sid[i]][i] = 1'b1;
    end
  end

  //==========================================================================
  // 2. SLAVE-SIDE ARBITRATION & MASTER-ID TRACKING
  //
  // BUG-1 FIX: Break the combinatorial loop by registering the last-granted
  // master index (arb_gnt_mid_q) and using THAT to look up resp_fifo_ready.
  // This is safe because:
  //  - A new grant can only occur after the previous one was accepted.
  //  - The "last winner" master is exactly whose resp_fifo[j] slot we must
  //    protect before issuing another grant.
  //==========================================================================
  logic [ NUM_SLAVES-1:0][NUM_MASTERS-1:0] arb_gnt_oh;
  logic [ NUM_SLAVES-1:0][      MID_W-1:0] arb_gnt_mid;
  logic [ NUM_SLAVES-1:0]                  arb_gnt_valid;
  logic [ NUM_SLAVES-1:0]                  mid_fifo_ready;

  // Registered last-granted master index per slave  (BUG-1 FIX)
  logic [ NUM_SLAVES-1:0][      MID_W-1:0] arb_gnt_mid_q;

  // Per-(master,slave) resp FIFO ready (populated in Section 6)
  logic [NUM_MASTERS-1:0][ NUM_SLAVES-1:0] resp_fifo_ready;

  // Look up using REGISTERED index — loop-free
  logic [ NUM_SLAVES-1:0]                  target_resp_fifo_ready;
  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++)
    target_resp_fifo_ready[j] = resp_fifo_ready[arb_gnt_mid_q[j]][j];
  end

  // Head of master-id FIFO per slave  (BUG-2: PIPELINED=0 on mid FIFO)
  logic [NUM_SLAVES-1:0][MID_W-1:0] mid_fifo_head;
  logic [NUM_SLAVES-1:0]            mid_fifo_valid;
  logic [NUM_SLAVES-1:0]            slave_resp_popped;

  for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_SLAVE_ARB

    // allow grant only when:
    //   · slave is ready (s_rsp_i.mgnt)
    //   · mid_fifo has room
    //   · the would-be-winner master's per-slave resp FIFO has room
    //     (uses REGISTERED mid index — no comb loop)
    adn_common_round_robin_arbiter #(
        .NUM_REQ(NUM_MASTERS)
    ) u_rr_arb (
        .clk_i           (clk_i),
        .arst_ni         (arst_ni),
        .allow_req_i     (s_rsp_i[j].mgnt & mid_fifo_ready[j] & target_resp_fifo_ready[j]),
        .req_i           (req_to_slave[j]),
        .gnt_addr_valid_o(arb_gnt_valid[j]),
        .gnt_addr_o      (arb_gnt_mid[j]),
        .gnt_o           (arb_gnt_oh[j])
    );

    // Register the winning master index for next cycle's FIFO-ready check
    always_ff @(posedge clk_i or negedge arst_ni) begin
      if (~arst_ni) arb_gnt_mid_q[j] <= '0;
      else if (arb_gnt_valid[j]) arb_gnt_mid_q[j] <= arb_gnt_mid[j];
    end

    // BUG-2 FIX: PIPELINED=0 → output is always from registered RAM.
    // No bypass path means mid_fifo_head is stable (registered) and cannot
    // alias to a new push's data on the same pop cycle.
    adn_common_fifo #(
        .DATA_WIDTH(MID_W),
        .FIFO_SIZE (FIFO_DEPTH_LOG2),
        .PIPELINED (0)                 // <-- deliberate: avoid bypass-path race
    ) u_mid_fifo (
        .arst_ni         (arst_ni),
        .clk_i           (clk_i),
        .data_in_i       (arb_gnt_mid[j]),
        .data_in_valid_i (arb_gnt_valid[j]),
        .data_in_ready_o (mid_fifo_ready[j]),
        .count_o         (),
        .data_out_o      (mid_fifo_head[j]),
        .data_out_valid_o(mid_fifo_valid[j]),
        .data_out_ready_i(slave_resp_popped[j])
    );

  end  // GEN_SLAVE_ARB

  //==========================================================================
  // 3. MASTER GRANT GENERATION  (PR-3, PR-6, Reset behavior)
  //
  //  mgnt → master only when:
  //   - Physical path: slave arbiter grants master i for slave j
  //   - Error   path: address not found, tracker has space
  //  During reset: output is forced to 0 in Section 7.
  //==========================================================================
  logic [NUM_MASTERS-1:0] master_mgnt;
  logic [NUM_MASTERS-1:0] req_accepted;

  always_comb begin
    master_mgnt = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (dec_error_req[i]) master_mgnt[i] = 1'b1;
      else if (dec_valid_req[i]) master_mgnt[i] = arb_gnt_oh[dec_sid[i]][i];
    end
  end

  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++)
    req_accepted[i] = (dec_valid_req[i] | dec_error_req[i]) & master_mgnt[i];
  end

  //==========================================================================
  // 4. REQUEST CROSSBAR  (N masters → M slaves)
  //==========================================================================
  logic [NUM_MASTERS-1:0][REQ_W-1:0] req_xbar_in;
  logic [ NUM_SLAVES-1:0][REQ_W-1:0] req_xbar_out;
  logic [ NUM_SLAVES-1:0][MID_W-1:0] req_xbar_sel;

  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      req_xbar_in[i] = {
        m_req_i[i].maddr,
        m_req_i[i].mwe,
        m_req_i[i].mwdata,
        m_req_i[i].mstrb,
        dec_valid_req[i]  // gated mreq (not the raw one)
      };
    end
    for (int j = 0; j < NUM_SLAVES; j++) req_xbar_sel[j] = arb_gnt_mid[j];
  end

  adn_common_xbar #(
      .DATA_WIDTH (REQ_W),
      .NUM_INPUTS (NUM_MASTERS),
      .NUM_OUTPUTS(NUM_SLAVES)
  ) u_req_xbar (
      .sel_i(req_xbar_sel),
      .in_i (req_xbar_in),
      .out_o(req_xbar_out)
  );

  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++) begin
      {
                s_req_o[j].maddr,
                s_req_o[j].mwe,
                s_req_o[j].mwdata,
                s_req_o[j].mstrb,
                s_req_o[j].mreq         // overridden below
      } = req_xbar_out[j];

      // mreq to slave: valid only on a real arbitration grant,
      // AND arst_ni guards the line (PR-1, reset rule)
      s_req_o[j].mreq = req_xbar_out[j][0] & arb_gnt_valid[j] & arst_ni;
    end
  end

  //==========================================================================
  // 5. PER-MASTER TRANSACTION ORDER TRACKER  (PR-10)
  //
  //  Tracks: which slave (or DEC_ERR_SID) each outstanding transaction
  //  belongs to, in strict issue order.  The head entry gates which
  //  per-(master,slave) resp FIFO we drain next.
  //==========================================================================
  logic [NUM_MASTERS-1:0][TRACK_W-1:0] track_fifo_in;
  logic [NUM_MASTERS-1:0][TRACK_W-1:0] track_fifo_head;
  logic [NUM_MASTERS-1:0]              track_fifo_valid;
  logic [NUM_MASTERS-1:0]              master_resp_consumed;
  logic [NUM_MASTERS-1:0]              dec_err_accepted;
  logic [NUM_MASTERS-1:0]              dec_err_retired;
  logic [NUM_MASTERS-1:0]              dec_err_has_pending;

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : GEN_TRACKER
    assign dec_err_accepted[i] = dec_error_req[i] & master_mgnt[i];
    assign track_fifo_in[i] = dec_error_req[i] ? DEC_ERR_SID : TRACK_W'(dec_sid[i]);

    adn_common_fifo #(
        .DATA_WIDTH(TRACK_W),
        .FIFO_SIZE (FIFO_DEPTH_LOG2),
        .PIPELINED (1)
    ) u_master_track_fifo (
        .arst_ni         (arst_ni),
        .clk_i           (clk_i),
        .data_in_i       (track_fifo_in[i]),
        .data_in_valid_i (req_accepted[i]),
        .data_in_ready_o (track_fifo_ready[i]),
        .count_o         (),
        .data_out_o      (track_fifo_head[i]),
        .data_out_valid_o(track_fifo_valid[i]),
        .data_out_ready_i(master_resp_consumed[i])
    );

    // Separate counter tracks outstanding decode-error responses
    adn_common_hs_counter #(
        .DEPTH    (1 << FIFO_DEPTH_LOG2),
        .PIPELINED(1)
    ) u_err_counter (
        .clk_i            (clk_i),
        .arst_ni          (arst_ni),
        .data_in_valid_i  (dec_err_accepted[i]),
        .data_in_ready_o  (err_counter_ready[i]),
        .count_o          (),
        .passing_through_o(),
        .data_out_valid_o (dec_err_has_pending[i]),
        .data_out_ready_i (dec_err_retired[i])
    );
  end  // GEN_TRACKER

  //==========================================================================
  // 6. PER-(MASTER, SLAVE) RESPONSE STAGING FIFOs  (PR-9, PR-10)
  //
  //  One FIFO per (master, slave) pair captures the response payload as
  //  soon as the slave asserts mack for that master's transaction.
  //  The head of the master's track_fifo tells Section 7 WHICH per-slave
  //  FIFO to drain next, ensuring strict in-order delivery (PR-10).
  //
  //  BUG-2 FIX: mid_fifo uses PIPELINED=0 so mid_fifo_head is always
  //  a registered value. slave_resp_popped only fires when mid_fifo_valid
  //  is asserted (FIFO non-empty), eliminating bypass-path ambiguity.
  //==========================================================================
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0][RSP_PAYLOAD_W-1:0] resp_fifo_out;
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0]                    resp_fifo_valid;
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0]                    resp_fifo_pop;

  // slave_has_dest: slave j has a valid mack AND we know which master owns it
  logic [ NUM_SLAVES-1:0]                                    slave_has_dest;

  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++) begin
      // mid_fifo_valid ensures we know the destination master (no guess)
      slave_has_dest[j]    = s_rsp_i[j].mack & mid_fifo_valid[j];
      // Pop the master-id FIFO only when we have a valid destination
      slave_resp_popped[j] = slave_has_dest[j];
    end
  end

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : GEN_M_RESP_QUEUES
    for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_S_RESP_QUEUE

      // Push exactly when slave j responds AND this master is at the
      // head of slave j's master-id FIFO (mid_fifo_head is registered
      // thanks to PIPELINED=0 on u_mid_fifo — BUG-2 FIX)
      logic push_resp;
      assign push_resp = slave_has_dest[j] & (mid_fifo_head[j] == MID_W'(i));

      adn_common_fifo #(
          .DATA_WIDTH(RSP_PAYLOAD_W),
          .FIFO_SIZE (FIFO_DEPTH_LOG2),
          .PIPELINED (1)
      ) u_resp_fifo (
          .arst_ni         (arst_ni),
          .clk_i           (clk_i),
          .data_in_i       ({s_rsp_i[j].mrdata, s_rsp_i[j].mresp}),
          .data_in_valid_i (push_resp),
          .data_in_ready_o (resp_fifo_ready[i][j]),
          .count_o         (),
          .data_out_o      (resp_fifo_out[i][j]),
          .data_out_valid_o(resp_fifo_valid[i][j]),
          .data_out_ready_i(resp_fifo_pop[i][j])
      );

    end
  end  // GEN_M_RESP_QUEUES

  //==========================================================================
  // 7. RESPONSE DISPATCH TO MASTERS  (PR-9, PR-10, PR-11, PR-12, Reset)
  //
  //  Drains the per-master transaction tracker (track_fifo) strictly
  //  head-first. Whichever slave (or error token) is at the head of the
  //  tracker is the ONLY source from which mack is issued this cycle.
  //  This enforces PMI PR-10 (in-order) regardless of which slave responds
  //  first.
  //
  //  PR-6/Reset: mgnt and mack are forced to 0 during arst_ni=0.
  //==========================================================================
  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      // Safe defaults (also cover reset path — arst_ni gate below)
      m_rsp_o[i].mgnt         = arst_ni ? master_mgnt[i] : 1'b0;
      m_rsp_o[i].mack         = 1'b0;
      m_rsp_o[i].mrdata       = '0;
      m_rsp_o[i].mresp        = 1'b0;
      master_resp_consumed[i] = 1'b0;
      dec_err_retired[i]      = 1'b0;

      for (int j = 0; j < NUM_SLAVES; j++) resp_fifo_pop[i][j] = 1'b0;

      // Only retire responses when out of reset and tracker is non-empty
      if (track_fifo_valid[i] & arst_ni) begin

        if (track_fifo_head[i] == DEC_ERR_SID) begin
          //----------------------------------------------------------
          // Head is a decode-error token: synthesise an ERROR response
          // immediately, no slave involved (PR-9: one mack per req)
          //----------------------------------------------------------
          if (dec_err_has_pending[i]) begin
            m_rsp_o[i].mack         = 1'b1;
            m_rsp_o[i].mresp        = 1'b1;  // PMI ERROR
            m_rsp_o[i].mrdata       = '0;
            master_resp_consumed[i] = 1'b1;  // pop track_fifo
            dec_err_retired[i]      = 1'b1;  // pop err_counter
          end

        end else begin
          //----------------------------------------------------------
          // Head is a physical slave SID: wait for that slave's
          // staging FIFO to have data (guarantees in-order delivery)
          //----------------------------------------------------------
          automatic int unsigned target_sid;
          target_sid = int'(track_fifo_head[i][SID_W-1:0]);

          if (resp_fifo_valid[i][target_sid]) begin
            m_rsp_o[i].mack                       = 1'b1;
            {m_rsp_o[i].mrdata, m_rsp_o[i].mresp} = resp_fifo_out[i][target_sid];
            resp_fifo_pop[i][target_sid]          = 1'b1;
            master_resp_consumed[i]               = 1'b1;
          end

        end
      end
    end
  end

endmodule
