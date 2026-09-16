/*

### Purpose
This module implements an N-master to M-slave crossbar switch for the PMI (Protocol Memory Interface) protocol. It provides address decoding, arbitration, request routing, and response tracking to ensure strict transaction ordering and protocol compliance.

### Use Case
The `adn_common_pmi_nxm_crossbar` is designed for high-performance SoC interconnects where multiple masters (e.g., CPUs, DMA engines) need to access multiple memory-mapped slave peripherals or memory controllers simultaneously. It acts as a central switching fabric that:
- Decodes master requests based on a static address map.
- Arbitrates access to slaves using a round-robin scheme to ensure fairness.
- Maintains strict transaction ordering by tracking request-response pairs per master.
- Handles protocol-level flow control and error reporting (e.g., address decoding errors) while preventing combinational loops in the request/grant handshake.

| REVISION | DATE       | AUTHOR                                                                               | DESCRIPTION                                            |
|----------|------------|--------------------------------------------------------------------------------------|--------------------------------------------------------|
| 0.1      | 2026-09-15 | Ahasan Ullah Khalid                                                                  | Initial version                                        |
| 1.0      | 2026-09-15 | Ahasan Ullah Khalid, Md Sakib Hasan SHawon, Md Sakhawat Hossain Sabbir, Annim Jannat | Stable release                                         |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com), Md Sakib Hasan SHawon, Md Sakhawat Hossain Sabbir, Annim Jannat
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_pmi_nxm_crossbar #(
    parameter int  NUM_MASTERS     = 4,                 // Number of master ports
    parameter int  NUM_SLAVES      = 4,                 // Number of slave ports
    parameter int  ADDR_WIDTH      = 32,                // Width of address bus
    parameter int  DATA_WIDTH      = 32,                // Width of data bus
    parameter int  NUM_RULES       = 4,                 // Number of address map rules
    parameter int  FIFO_DEPTH_LOG2 = 4,                 // Log2 of FIFO depth for tracking
    parameter type pmi_req_t       = logic,             // PMI request struct type
    parameter type pmi_rsp_t       = logic,             // PMI response struct type

    // See "POP-AWARE READY" caveat below. Defaults to 0 (safe) until the
    // underlying FIFO/counter components are confirmed to support
    // simultaneous full+pop+push.
    parameter bit FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH = 1'b0,

    // Derived parameters
    localparam int MID_W = (NUM_MASTERS > 1) ? $clog2(NUM_MASTERS) : 1,
    localparam int SID_W = (NUM_SLAVES > 1) ? $clog2(NUM_SLAVES) : 1,
    // TRACK_W: SID bits + 1 decode-error flag bit
    localparam int TRACK_W = SID_W + 1,
    localparam logic [TRACK_W-1:0] DEC_ERR_SID = TRACK_W'(NUM_SLAVES),

    // Pure payload bus: maddr + mwe + mwdata + mstrb (clean separation from mreq)
    localparam int REQ_PAYLOAD_W = ADDR_WIDTH + 1 + DATA_WIDTH + (DATA_WIDTH / 8),
    // Response payload: mrdata + mresp
    localparam int RSP_PAYLOAD_W = DATA_WIDTH + 1
) (
    input logic clk_i,                                  // System clock
    input logic arst_ni,                                // Asynchronous active-low reset

    // Master ports (crossbar acts as slave toward these)
    input  pmi_req_t [NUM_MASTERS-1:0] m_req_i,         // Master request inputs
    output pmi_rsp_t [NUM_MASTERS-1:0] m_rsp_o,         // Master response outputs

    // Slave ports (crossbar acts as master toward these)
    output pmi_req_t [NUM_SLAVES-1:0] s_req_o,          // Slave request outputs
    input  pmi_rsp_t [NUM_SLAVES-1:0] s_rsp_i,          // Slave response inputs

    // Static address map
    input logic [ADDR_WIDTH-1:0] min_addr_i [NUM_RULES], // Minimum address for each rule
    input logic [ADDR_WIDTH-1:0] max_addr_i [NUM_RULES], // Maximum address for each rule
    input logic [     SID_W-1:0] slave_map_i[NUM_RULES]  // Slave ID for each rule
);

  //==========================================================================
  // ADDRESS DECODING
  //==========================================================================
  logic [NUM_MASTERS-1:0][SID_W-1:0] dec_sid;
  logic [NUM_MASTERS-1:0]            dec_found;
  logic [NUM_MASTERS-1:0]            dec_valid_req;
  logic [NUM_MASTERS-1:0]            dec_error_req;
  logic [NUM_MASTERS-1:0]            track_fifo_ready;
  logic [NUM_MASTERS-1:0]            err_counter_ready;
  logic [NUM_MASTERS-1:0]            err_counter_will_retire;
  logic [NUM_MASTERS-1:0]            err_counter_can_accept;

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

    // Request qualification. track_fifo_ready is intentionally NOT
    // pop-aware (see header item 2) -- only err_counter_can_accept is.
    assign dec_valid_req[i] = m_req_i[i].mreq & dec_found[i] & track_fifo_ready[i];
    assign dec_error_req[i] = m_req_i[i].mreq & ~dec_found[i] & track_fifo_ready[i] & err_counter_can_accept[i];
  end

  // Build per-slave target matrix
  logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] req_to_slave;
  always_comb begin
    req_to_slave = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (dec_valid_req[i]) begin
        req_to_slave[dec_sid[i]][i] = 1'b1;
      end
    end
  end

  //==========================================================================
  // SLAVE-SIDE ARBITRATION & ELIGIBLE REQUEST FILTERING
  //==========================================================================
  logic [ NUM_SLAVES-1:0][NUM_MASTERS-1:0] arb_gnt_oh;
  logic [ NUM_SLAVES-1:0][      MID_W-1:0] arb_gnt_mid;
  logic [ NUM_SLAVES-1:0]                  arb_gnt_valid;   // ACCEPTED grant (mgnt-gated)
  logic [ NUM_SLAVES-1:0]                  arb_cand_valid;  // NEW: CANDIDATE exists (mgnt-independent)
  logic [ NUM_SLAVES-1:0]                  mid_fifo_ready;
  logic [ NUM_SLAVES-1:0]                  mid_fifo_will_pop;
  logic [ NUM_SLAVES-1:0]                  mid_fifo_can_accept;

  logic [NUM_MASTERS-1:0][ NUM_SLAVES-1:0] resp_fifo_ready;
  logic [NUM_MASTERS-1:0][ NUM_SLAVES-1:0] resp_fifo_will_pop;
  logic [NUM_MASTERS-1:0][ NUM_SLAVES-1:0] resp_fifo_can_accept;
  logic [ NUM_SLAVES-1:0][NUM_MASTERS-1:0] req_eligible;

  // POP-AWARE READY: each "will_pop"/"can_accept" signal below is built
  // only from registered/state signals and primary slave inputs (mack),
  // never from this-cycle grant/allow signals, so there is no
  // combinational loop through the arbiter.
  assign mid_fifo_can_accept = mid_fifo_ready
      | (FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH ? mid_fifo_will_pop : '0);

  assign resp_fifo_can_accept = resp_fifo_ready
      | (FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH ? resp_fifo_will_pop : '0);

  assign err_counter_can_accept = err_counter_ready
      | (FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH ? err_counter_will_retire : '0);

  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++) begin
      for (int i = 0; i < NUM_MASTERS; i++) begin
        // Request is eligible only when the specific master's response staging FIFO has space
        // (or is draining this cycle -- see POP-AWARE READY above).
        req_eligible[j][i] = req_to_slave[j][i] & resp_fifo_can_accept[i][j];
      end

      // FIX (PR-2/PR-3 compliance): a candidate winner exists whenever any
      // master is eligible for slave j, REGARDLESS of s_rsp_i[j].mgnt.
      // This is exactly equal to the arbiter's internal fpa_gnt_addr_valid
      // (OR-reduction is invariant under the arbiter's internal request
      // rotation), so it reproduces the arbiter's "candidate exists" flag
      // without adding a port to adn_common_round_robin_arbiter or touching
      // allow_req_i. Used below to drive the slave-facing mreq/address so
      // that the payload the slave sees never depends on that slave's own
      // mgnt output (avoids a combinational loop through mgnt).
      arb_cand_valid[j] = (|req_eligible[j]) & arst_ni;
    end
  end

  // Master ID tracking per slave
  logic [NUM_SLAVES-1:0][MID_W-1:0] mid_fifo_head;
  logic [NUM_SLAVES-1:0]            mid_fifo_valid;
  logic [NUM_SLAVES-1:0]            mid_fifo_push;
  logic [NUM_SLAVES-1:0]            mid_fifo_pop;

  for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_SLAVE_ARB
    // Arbiter instantiation UNCHANGED -- no new ports, no modified logic.
    adn_common_round_robin_arbiter #(
        .NUM_REQ(NUM_MASTERS)
    ) u_rr_arb (
        .clk_i           (clk_i),
        .arst_ni         (arst_ni),
        .allow_req_i     (s_rsp_i[j].mgnt & mid_fifo_can_accept[j]),
        .req_i           (req_eligible[j]),
        .gnt_addr_valid_o(arb_gnt_valid[j]),
        .gnt_addr_o      (arb_gnt_mid[j]),
        .gnt_o           (arb_gnt_oh[j])
    );

    adn_common_fifo #(
        .DATA_WIDTH(MID_W),
        .FIFO_SIZE (FIFO_DEPTH_LOG2),
        .PIPELINED (0)
    ) u_mid_fifo (
        .clk_i           (clk_i),
        .arst_ni         (arst_ni),
        .data_in_i       (arb_gnt_mid[j]),
        .data_in_valid_i (mid_fifo_push[j]),
        .data_in_ready_o (mid_fifo_ready[j]),
        .count_o         (),
        .data_out_o      (mid_fifo_head[j]),
        .data_out_valid_o(mid_fifo_valid[j]),
        .data_out_ready_i(mid_fifo_pop[j])
    );

    // Independent, loop-safe formulation of "will this FIFO be popped this
    // cycle", used only for the pop-aware ready calculation above. Must
    // stay logically consistent with the real mid_fifo_pop[j] in Sec. 6.
    assign mid_fifo_will_pop[j] = mid_fifo_valid[j] & s_rsp_i[j].mack;
  end

  //==========================================================================
  // MASTER GRANT GENERATION
  //==========================================================================
  logic [NUM_MASTERS-1:0] master_mgnt;
  logic [NUM_MASTERS-1:0] req_accepted;

  always_comb begin
    master_mgnt = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (dec_error_req[i]) begin
        master_mgnt[i] = 1'b1;
      end else if (dec_valid_req[i]) begin
        // Unchanged: a master's own mgnt legitimately depends on the
        // slave's ACCEPTED grant -- that's downstream causality, not a loop.
        master_mgnt[i] = arb_gnt_oh[dec_sid[i]][i];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      req_accepted[i] = (dec_valid_req[i] | dec_error_req[i]) & master_mgnt[i] & arst_ni;
    end
  end

  //==========================================================================
  // REQUEST PAYLOAD CROSSBAR
  //==========================================================================
  logic [NUM_MASTERS-1:0][REQ_PAYLOAD_W-1:0] req_xbar_in;
  logic [ NUM_SLAVES-1:0][REQ_PAYLOAD_W-1:0] req_xbar_out;
  logic [ NUM_SLAVES-1:0][        MID_W-1:0] req_xbar_sel;

  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      req_xbar_in[i] = {m_req_i[i].maddr, m_req_i[i].mwe, m_req_i[i].mwdata, m_req_i[i].mstrb};
    end
    for (int j = 0; j < NUM_SLAVES; j++) begin
      // FIX: select is driven by arb_cand_valid (mgnt-independent), not
      // arb_gnt_valid. Per PMI PR-2/PR-3, the slave must be shown a valid
      // address before/independent of whatever it decides about mgnt --
      // using the accepted-grant flag here would make the payload the
      // slave sees depend on the slave's own mgnt output.
      req_xbar_sel[j] = arb_cand_valid[j] ? arb_gnt_mid[j] : '0;
    end
  end

  adn_common_xbar #(
      .DATA_WIDTH (REQ_PAYLOAD_W),
      .NUM_INPUTS (NUM_MASTERS),
      .NUM_OUTPUTS(NUM_SLAVES)
  ) u_req_xbar (
      .sel_i(req_xbar_sel),
      .in_i (req_xbar_in),
      .out_o(req_xbar_out)
  );

  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++) begin
      // Because req_xbar_sel[j] holds steady on the same candidate master
      // as long as that master's own request stays asserted (arbiter's
      // last_gnt/rotation only advances on an ACCEPTED grant, never on a
      // mere candidate), this bus naturally stays stable across cycles
      // where mgnt=0 -- satisfying PR-4 for the crossbar's own s_req_o
      // interface toward each slave.
      {s_req_o[j].maddr, s_req_o[j].mwe, s_req_o[j].mwdata, s_req_o[j].mstrb} = req_xbar_out[j];

      // FIX: mreq must be an independent input to the slave's
      // accept-decision, not a function of its output (PR-3: "accepted
      // only on cycles where mreq=1 AND mgnt=1" requires mreq itself to
      // not depend on mgnt).
      s_req_o[j].mreq = arb_cand_valid[j];
    end
  end

  //==========================================================================
  // PER-MASTER TRANSACTION ORDER TRACKING & DECODE ERROR COUNTER
  //==========================================================================
  logic [NUM_MASTERS-1:0][TRACK_W-1:0] track_fifo_in;
  logic [NUM_MASTERS-1:0][TRACK_W-1:0] track_fifo_head;
  logic [NUM_MASTERS-1:0]              track_fifo_valid;
  logic [NUM_MASTERS-1:0]              master_resp_consumed;
  logic [NUM_MASTERS-1:0]              dec_err_accepted;
  logic [NUM_MASTERS-1:0]              dec_err_retired;
  logic [NUM_MASTERS-1:0]              dec_err_has_pending;

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : GEN_TRACKER
    assign dec_err_accepted[i] = dec_error_req[i] & master_mgnt[i] & arst_ni;
    assign track_fifo_in[i]    = dec_error_req[i] ? DEC_ERR_SID : TRACK_W'(dec_sid[i]);

    adn_common_fifo #(
        .DATA_WIDTH(TRACK_W),
        .FIFO_SIZE (FIFO_DEPTH_LOG2),
        .PIPELINED (1)
    ) u_master_track_fifo (
        .clk_i           (clk_i),
        .arst_ni         (arst_ni),
        .data_in_i       (track_fifo_in[i]),
        .data_in_valid_i (req_accepted[i]),
        .data_in_ready_o (track_fifo_ready[i]),
        .count_o         (),
        .data_out_o      (track_fifo_head[i]),
        .data_out_valid_o(track_fifo_valid[i]),
        .data_out_ready_i(master_resp_consumed[i])
    );

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

    // Independent, loop-safe formulation mirroring the dispatch logic
    // used only for the pop-aware ready calculation in Sec. 1/2.
    assign err_counter_will_retire[i] = track_fifo_valid[i]
        & (track_fifo_head[i] == DEC_ERR_SID)
        & dec_err_has_pending[i];
  end

  //==========================================================================
  // SLAVE RESPONSE ROUTING & ZERO-LATENCY BYPASS
  //==========================================================================
  logic [NUM_SLAVES-1:0][        MID_W-1:0] resp_target_mid;
  logic [NUM_SLAVES-1:0]                    slave_resp_valid;

  // Per-slave outstanding count -- see header item D for what this models.
  logic [NUM_SLAVES-1:0][FIFO_DEPTH_LOG2:0] slave_outstanding_cnt;

  for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_SLAVE_TRACK_BYPASS
    // Unchanged: acceptance-derived (arb_gnt_valid), correctly gates
    // counting/tracking of transactions the slave actually took.
    wire slave_req_sent = arb_gnt_valid[j] & arst_ni;
    wire slave_resp_valid_raw = s_rsp_i[j].mack & ((slave_outstanding_cnt[j] > 0) | slave_req_sent);

    always_ff @(posedge clk_i or negedge arst_ni) begin
      if (!arst_ni) begin
        slave_outstanding_cnt[j] <= '0;
      end else begin
        case ({
          slave_req_sent, slave_resp_valid_raw
        })
          2'b10:   slave_outstanding_cnt[j] <= slave_outstanding_cnt[j] + 1'b1;
          2'b01:   slave_outstanding_cnt[j] <= slave_outstanding_cnt[j] - 1'b1;
          default: ;  // 2'b11 and 2'b00 net change is 0
        endcase
      end
    end

    always_comb begin
      mid_fifo_push[j]    = 1'b0;
      mid_fifo_pop[j]     = 1'b0;
      slave_resp_valid[j] = slave_resp_valid_raw;
      resp_target_mid[j]  = '0;

      if (slave_resp_valid_raw) begin
        if (mid_fifo_valid[j]) begin
          // Case 1: Active entries in FIFO, pop head and route response
          resp_target_mid[j] = mid_fifo_head[j];
          mid_fifo_pop[j]    = 1'b1;
          mid_fifo_push[j]   = slave_req_sent;
        end else if (slave_req_sent) begin
          // Case 2: Zero-latency same-cycle response when FIFO is empty
          // Direct bypass to response queue without queuing into MID FIFO
          resp_target_mid[j] = arb_gnt_mid[j];
          mid_fifo_push[j]   = 1'b0;
        end
      end else begin
        mid_fifo_push[j] = slave_req_sent;
      end
    end
  end

  //==========================================================================
  // PER-(MASTER, SLAVE) RESPONSE STAGING FIFOs
  //==========================================================================
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0][RSP_PAYLOAD_W-1:0] resp_fifo_out;
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0]                    resp_fifo_valid;
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0]                    resp_fifo_pop;

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : GEN_M_RESP_QUEUES
    for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_S_RESP_QUEUE
      logic push_resp;
      assign push_resp = slave_resp_valid[j] & (resp_target_mid[j] == MID_W'(i));

      adn_common_fifo #(
          .DATA_WIDTH(RSP_PAYLOAD_W),
          .FIFO_SIZE (FIFO_DEPTH_LOG2),
          .PIPELINED (1)
      ) u_resp_fifo (
          .clk_i           (clk_i),
          .arst_ni         (arst_ni),
          .data_in_i       ({s_rsp_i[j].mrdata, s_rsp_i[j].mresp}),
          .data_in_valid_i (push_resp),
          .data_in_ready_o (resp_fifo_ready[i][j]),
          .count_o         (),
          .data_out_o      (resp_fifo_out[i][j]),
          .data_out_valid_o(resp_fifo_valid[i][j]),
          .data_out_ready_i(resp_fifo_pop[i][j])
      );

      // Independent, loop-safe formulation mirroring the dispatch logic in
      // Sec. 8, used only for the pop-aware ready calculation in Sec. 2.
      assign resp_fifo_will_pop[i][j] = track_fifo_valid[i]
          & (track_fifo_head[i] != DEC_ERR_SID)
          & (track_fifo_head[i][SID_W-1:0] == SID_W'(j))
          & resp_fifo_valid[i][j];
    end
  end

  //==========================================================================
  // STRICT ORDERED RESPONSE DISPATCH TO MASTERS
  //==========================================================================
  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      m_rsp_o[i].mgnt         = arst_ni ? master_mgnt[i] : 1'b0;
      m_rsp_o[i].mack         = 1'b0;
      m_rsp_o[i].mrdata       = '0;
      m_rsp_o[i].mresp        = 1'b0;
      master_resp_consumed[i] = 1'b0;
      dec_err_retired[i]      = 1'b0;

      for (int j = 0; j < NUM_SLAVES; j++) begin
        resp_fifo_pop[i][j] = 1'b0;
      end

      if (arst_ni && track_fifo_valid[i]) begin
        if (track_fifo_head[i] == DEC_ERR_SID) begin
          if (dec_err_has_pending[i]) begin
            m_rsp_o[i].mack         = 1'b1;
            m_rsp_o[i].mresp        = 1'b1;  // PMI Error
            m_rsp_o[i].mrdata       = '0;
            master_resp_consumed[i] = 1'b1;
            dec_err_retired[i]      = 1'b1;
          end
        end else begin
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
