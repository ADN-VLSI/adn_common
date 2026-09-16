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
    parameter int  NUM_MASTERS                         = 4,
    parameter int  NUM_SLAVES                          = 4,
    parameter int  ADDR_WIDTH                          = 32,
    parameter int  DATA_WIDTH                          = 32,
    parameter int  NUM_RULES                           = 4,
    parameter int  FIFO_DEPTH_LOG2                     = 4,
    parameter type pmi_req_t                           = logic,
    parameter type pmi_rsp_t                           = logic,
    parameter bit  FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH = 1'b0,

    // Derived parameters
    localparam int                 MID_W       = (NUM_MASTERS > 1) ? $clog2(NUM_MASTERS) : 1,
    localparam int                 SID_W       = (NUM_SLAVES > 1) ? $clog2(NUM_SLAVES) : 1,
    localparam int                 TRACK_W     = SID_W + 1,
    localparam logic [TRACK_W-1:0] DEC_ERR_SID = TRACK_W'(NUM_SLAVES),

    // Pure payload definitions
    localparam int REQ_PAYLOAD_W = ADDR_WIDTH + 1 + DATA_WIDTH + (DATA_WIDTH / 8),
    localparam int RSP_PAYLOAD_W = DATA_WIDTH + 1
) (
    input logic clk_i,
    input logic arst_ni,

    // Master-side interfaces (Crossbar functions as Slave to Masters)
    input  pmi_req_t [NUM_MASTERS-1:0] m_req_i,
    output pmi_rsp_t [NUM_MASTERS-1:0] m_rsp_o,

    // Slave-side interfaces (Crossbar functions as Master to Slaves)
    output pmi_req_t [NUM_SLAVES-1:0] s_req_o,
    input  pmi_rsp_t [NUM_SLAVES-1:0] s_rsp_i,

    // Address range mapping rules
    input logic [ADDR_WIDTH-1:0] min_addr_i [NUM_RULES],
    input logic [ADDR_WIDTH-1:0] max_addr_i [NUM_RULES],
    input logic [     SID_W-1:0] slave_map_i[NUM_RULES]
);

  //==========================================================================
  // 1. ADDRESS DECODING & REQUEST QUALIFICATION
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

    assign dec_valid_req[i] = m_req_i[i].mreq & dec_found[i] & track_fifo_ready[i] & arst_ni;
    assign dec_error_req[i] = m_req_i[i].mreq & ~dec_found[i] & track_fifo_ready[i] & err_counter_can_accept[i] & arst_ni;
  end

  // Build slave target matrix
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
  // 2. SLAVE ARBITRATION & FLOW-CONTROLLED ELIGIBILITY
  //==========================================================================
  logic [ NUM_SLAVES-1:0][NUM_MASTERS-1:0] arb_gnt_oh;
  logic [ NUM_SLAVES-1:0][      MID_W-1:0] arb_gnt_mid;
  logic [ NUM_SLAVES-1:0]                  arb_gnt_valid;

  logic [ NUM_SLAVES-1:0]                  mid_fifo_ready;
  logic [ NUM_SLAVES-1:0]                  mid_fifo_will_pop;
  logic [ NUM_SLAVES-1:0]                  mid_fifo_can_accept;

  logic [NUM_MASTERS-1:0][ NUM_SLAVES-1:0] resp_fifo_ready;
  logic [NUM_MASTERS-1:0][ NUM_SLAVES-1:0] resp_fifo_will_pop;
  logic [NUM_MASTERS-1:0][ NUM_SLAVES-1:0] resp_fifo_can_accept;
  logic [ NUM_SLAVES-1:0][NUM_MASTERS-1:0] req_eligible;

  // Pop-aware readiness calculations to avoid false backpressure deadlocks
  assign mid_fifo_can_accept    = mid_fifo_ready | (FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH ? mid_fifo_will_pop : '0);
  assign resp_fifo_can_accept   = resp_fifo_ready | (FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH ? resp_fifo_will_pop : '0);
  assign err_counter_can_accept = err_counter_ready | (FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH ? err_counter_will_retire : '0);

  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++) begin
      for (int i = 0; i < NUM_MASTERS; i++) begin
        req_eligible[j][i] = req_to_slave[j][i] & resp_fifo_can_accept[i][j];
      end
    end
  end

  // Master ID tracking per slave port
  logic [NUM_SLAVES-1:0][MID_W-1:0] mid_fifo_head;
  logic [NUM_SLAVES-1:0]            mid_fifo_valid;
  logic [NUM_SLAVES-1:0]            mid_fifo_push;
  logic [NUM_SLAVES-1:0]            mid_fifo_pop;

  for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_SLAVE_ARB
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

    assign mid_fifo_will_pop[j] = mid_fifo_valid[j] & s_rsp_i[j].mack;
  end

  //==========================================================================
  // 3. MASTER GRANT COMBINATORIAL GENERATION
  //==========================================================================
  logic [NUM_MASTERS-1:0] master_mgnt;
  logic [NUM_MASTERS-1:0] req_accepted;

  always_comb begin
    master_mgnt = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (dec_error_req[i]) begin
        master_mgnt[i] = 1'b1;
      end else if (dec_valid_req[i]) begin
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
  // 4. REQUEST PAYLOAD CROSSBAR
  //==========================================================================
  logic [NUM_MASTERS-1:0][REQ_PAYLOAD_W-1:0] req_xbar_in;
  logic [ NUM_SLAVES-1:0][REQ_PAYLOAD_W-1:0] req_xbar_out;
  logic [ NUM_SLAVES-1:0][        MID_W-1:0] req_xbar_sel;

  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      req_xbar_in[i] = {m_req_i[i].maddr, m_req_i[i].mwe, m_req_i[i].mwdata, m_req_i[i].mstrb};
    end
    for (int j = 0; j < NUM_SLAVES; j++) begin
      req_xbar_sel[j] = arb_gnt_valid[j] ? arb_gnt_mid[j] : '0;
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
      {s_req_o[j].maddr, s_req_o[j].mwe, s_req_o[j].mwdata, s_req_o[j].mstrb} = req_xbar_out[j];
      s_req_o[j].mreq = arb_gnt_valid[j] & arst_ni;
    end
  end

  //==========================================================================
  // 5. PER-MASTER TRANSACTION TRACKING & SYNTHETIC ERROR GENERATOR
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

    assign err_counter_will_retire[i] = track_fifo_valid[i]
            & (track_fifo_head[i] == DEC_ERR_SID)
            & dec_err_has_pending[i];
  end

  //==========================================================================
  // 6. SLAVE RESPONSE ROUTING & ZERO-LATENCY BYPASS
  //==========================================================================
  logic [NUM_SLAVES-1:0][        MID_W-1:0] resp_target_mid;
  logic [NUM_SLAVES-1:0]                    slave_resp_valid;
  logic [NUM_SLAVES-1:0][FIFO_DEPTH_LOG2:0] slave_outstanding_cnt;

  for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_SLAVE_TRACK_BYPASS
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
          default: ;  // Net zero change
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
          // Pop active head from MID FIFO
          resp_target_mid[j] = mid_fifo_head[j];
          mid_fifo_pop[j]    = 1'b1;
          mid_fifo_push[j]   = slave_req_sent;
        end else if (slave_req_sent) begin
          // Zero-latency direct bypass route
          resp_target_mid[j] = arb_gnt_mid[j];
          mid_fifo_push[j]   = 1'b0;
        end
      end else begin
        mid_fifo_push[j] = slave_req_sent;
      end
    end
  end

  //==========================================================================
  // 7. PER-(MASTER, SLAVE) RESPONSE QUEUES (N x M ARRAY)
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

      assign resp_fifo_will_pop[i][j] = track_fifo_valid[i]
                & (track_fifo_head[i] != DEC_ERR_SID)
                & (track_fifo_head[i][SID_W-1:0] == SID_W'(j))
                & resp_fifo_valid[i][j];
    end
  end

  //==========================================================================
  // 8. STRICT ORDERED RESPONSE DISPATCH (PR-1, PR-3, PR-5 COMPLIANT)
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
            m_rsp_o[i].mresp        = 1'b1;  // PMI Error Response
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
