/*

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

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

// @foez---bhai, add comments to the parameters, ports
module adn_common_pmi_nxm_crossbar #(
    parameter int NUM_MASTERS     = 4,
    parameter int NUM_SLAVES      = 4,
    parameter int ADDR_WIDTH      = 32,
    parameter int DATA_WIDTH      = 32,
    parameter int NUM_RULES       = 4,
    parameter int FIFO_DEPTH_LOG2 = 4,

    // Derived parameters
    localparam int MID_W = $clog2(NUM_MASTERS),
    localparam int SID_W = $clog2(NUM_SLAVES),

    // req fields: maddr + mwe + mwdata + mstrb + mreq
    localparam int REQ_W = ADDR_WIDTH + 1 + DATA_WIDTH + (DATA_WIDTH / 8) + 1,
    // rsp fields: mrdata + mresp
    localparam int RSP_PAYLOAD_W = DATA_WIDTH + 1
) (
    input logic clk_i,
    input logic arst_ni,

    // Master ports
    input  pmi_req_t [NUM_MASTERS-1:0] m_req_i,
    output pmi_rsp_t [NUM_MASTERS-1:0] m_rsp_o,

    // Slave ports
    output pmi_req_t [NUM_SLAVES-1:0] s_req_o,
    input  pmi_rsp_t [NUM_SLAVES-1:0] s_rsp_i,

    // Static address map
    input logic [ADDR_WIDTH-1:0] min_addr_i [NUM_RULES],
    input logic [ADDR_WIDTH-1:0] max_addr_i [NUM_RULES],
    input logic [     SID_W-1:0] slave_map_i[NUM_RULES]
);

  //==========================================================================
  // ADDRESS DECODING & ERROR GENERATION
  //==========================================================================
  logic [NUM_MASTERS-1:0][SID_W-1:0] dec_sid;
  logic [NUM_MASTERS-1:0]            dec_found;
  logic [NUM_MASTERS-1:0]            dec_mreq;
  logic [NUM_MASTERS-1:0]            sid_fifo_in_ready;

  // Decode error internal handling (Default Slave per Master)
  logic [NUM_MASTERS-1:0]            dec_err_active;
  logic [NUM_MASTERS-1:0]            dec_err_gnt;
  logic [NUM_MASTERS-1:0]            dec_err_mack;

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

    // Default Slave State Machine: Immediate grant + next-cycle error response
    assign dec_err_gnt[i] = m_req_i[i].mreq && !dec_found[i] && !dec_err_active[i];

    always_ff @(posedge clk_i or negedge arst_ni) begin
      if (!arst_ni) begin
        dec_err_active[i] <= 1'b0;
        dec_err_mack[i]   <= 1'b0;
      end else begin
        dec_err_mack[i]   <= dec_err_gnt[i];
        dec_err_active[i] <= dec_err_gnt[i];
      end
    end

    // Real requests to crossbar: Must have valid address decode AND space in SID tracker
    assign dec_mreq[i] = m_req_i[i].mreq && dec_found[i] && sid_fifo_in_ready[i];
  end

  //==========================================================================
  // SLAVE REQUEST MATRIX GENERATION
  //==========================================================================
  logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] req_to_slave;

  always_comb begin
    req_to_slave = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (dec_mreq[i]) begin
        req_to_slave[dec_sid[i]][i] = 1'b1;
      end
    end
  end

  //==========================================================================
  // SLAVE-SIDE ARBITRATION & MASTER TRACKING FIFO
  //==========================================================================
  logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] arb_gnt_oh;
  logic [NUM_SLAVES-1:0][      MID_W-1:0] arb_gnt_mid;
  logic [NUM_SLAVES-1:0]                  arb_gnt_valid;
  logic [NUM_SLAVES-1:0]                  mid_fifo_in_ready;
  logic [NUM_SLAVES-1:0][      MID_W-1:0] mid_fifo_head;
  logic [NUM_SLAVES-1:0]                  mid_fifo_valid;
  logic [NUM_SLAVES-1:0]                  slave_resp_popped;

  for (genvar j = 0; j < NUM_SLAVES; j++) begin : GEN_SLAVE_ARB
    // Arbiter grants only when the slave is ready AND tracker FIFO can accept entry
    adn_common_round_robin_arbiter #(
        .NUM_REQ(NUM_MASTERS)
    ) u_rr_arb (
        .clk_i           (clk_i),
        .arst_ni         (arst_ni),
        .allow_req_i     (s_rsp_i[j].mgnt && mid_fifo_in_ready[j]),
        .req_i           (req_to_slave[j]),
        .gnt_addr_valid_o(arb_gnt_valid[j]),
        .gnt_addr_o      (arb_gnt_mid[j]),
        .gnt_o           (arb_gnt_oh[j])
    );

    // Tracks which master owns transactions currently running in Slave j
    adn_common_fifo #(
        .DATA_WIDTH(MID_W),
        .FIFO_SIZE (FIFO_DEPTH_LOG2),
        .PIPELINED (1)
    ) u_mid_fifo (
        .arst_ni         (arst_ni),
        .clk_i           (clk_i),
        .data_in_i       (arb_gnt_mid[j]),
        .data_in_valid_i (arb_gnt_valid[j]),
        .data_in_ready_o (mid_fifo_in_ready[j]),
        .count_o         (),
        .data_out_o      (mid_fifo_head[j]),
        .data_out_valid_o(mid_fifo_valid[j]),
        .data_out_ready_i(slave_resp_popped[j])
    );
  end

  //==========================================================================
  // MASTER GRANT (mgnt) GENERATION
  //==========================================================================
  logic [NUM_MASTERS-1:0] master_mgnt;
  logic [NUM_MASTERS-1:0] req_accepted;

  always_comb begin
    master_mgnt = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (dec_err_gnt[i]) begin
        master_mgnt[i] = 1'b1;
      end else if (dec_mreq[i]) begin
        master_mgnt[i] = arb_gnt_oh[dec_sid[i]][i];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      req_accepted[i] = dec_mreq[i] && master_mgnt[i];
    end
  end

  //==========================================================================
  // REQUEST CROSSBAR (Masters → Slaves)
  //==========================================================================
  logic [NUM_MASTERS-1:0][REQ_W-1:0] req_xbar_in;
  logic [ NUM_SLAVES-1:0][REQ_W-1:0] req_xbar_out;
  logic [ NUM_SLAVES-1:0][MID_W-1:0] req_xbar_sel;

  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      req_xbar_in[i] = {
        m_req_i[i].maddr, m_req_i[i].mwe, m_req_i[i].mwdata, m_req_i[i].mstrb, dec_mreq[i]
      };
    end

    for (int j = 0; j < NUM_SLAVES; j++) begin
      req_xbar_sel[j] = arb_gnt_mid[j];
    end
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

  // Unpack request fields to slaves
  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++) begin
      {
        s_req_o[j].maddr,
        s_req_o[j].mwe,
        s_req_o[j].mwdata,
        s_req_o[j].mstrb,
        s_req_o[j].mreq
      } = req_xbar_out[j];

      // Gated by grant validity to slave
      s_req_o[j].mreq = req_xbar_out[j][0] && arb_gnt_valid[j];
    end
  end

  //==========================================================================
  // MASTER-SIDE ORDER TRACKING (Slave-ID FIFO)
  //==========================================================================
  logic [NUM_MASTERS-1:0][SID_W-1:0] sid_fifo_head;
  logic [NUM_MASTERS-1:0]            sid_fifo_valid;
  logic [NUM_MASTERS-1:0]            master_resp_consumed;

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : GEN_SID_FIFO
    adn_common_fifo #(
        .DATA_WIDTH(SID_W),
        .FIFO_SIZE (FIFO_DEPTH_LOG2),
        .PIPELINED (1)
    ) u_sid_fifo (
        .arst_ni         (arst_ni),
        .clk_i           (clk_i),
        .data_in_i       (dec_sid[i]),
        .data_in_valid_i (req_accepted[i]),
        .data_in_ready_o (sid_fifo_in_ready[i]),
        .count_o         (),
        .data_out_o      (sid_fifo_head[i]),
        .data_out_valid_o(sid_fifo_valid[i]),
        .data_out_ready_i(master_resp_consumed[i])
    );
  end

  //==========================================================================
  // RESPONSE ROUTING & PER-MASTER STAGING BUFFERS
  //==========================================================================
  // Staging register per (Master, Slave) to capture early/out-of-order completions
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0][RSP_PAYLOAD_W-1:0] resp_buffer_data;
  logic [NUM_MASTERS-1:0][NUM_SLAVES-1:0]                    resp_buffer_valid;

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      resp_buffer_valid <= '0;
      resp_buffer_data  <= '0;
    end else begin
      // Step A: Capture returning responses from slaves into targeted buffer slot
      for (int j = 0; j < NUM_SLAVES; j++) begin
        if (s_rsp_i[j].mack && mid_fifo_valid[j]) begin
          resp_buffer_data[mid_fifo_head[j]][j]  <= {s_rsp_i[j].mrdata, s_rsp_i[j].mresp};
          resp_buffer_valid[mid_fifo_head[j]][j] <= 1'b1;
        end
      end

      // Step B: Clear buffer slot when the master consumes it in-order
      for (int i = 0; i < NUM_MASTERS; i++) begin
        if (master_resp_consumed[i] && !dec_err_mack[i]) begin
          resp_buffer_valid[i][sid_fifo_head[i]] <= 1'b0;
        end
      end
    end
  end

  // Slave FIFO pops immediately when the slave's response is safely captured
  always_comb begin
    for (int j = 0; j < NUM_SLAVES; j++) begin
      slave_resp_popped[j] = s_rsp_i[j].mack && mid_fifo_valid[j];
    end
  end

  //==========================================================================
  // DRIVE RESPONSES BACK TO MASTERS
  //==========================================================================
  always_comb begin
    for (int i = 0; i < NUM_MASTERS; i++) begin
      m_rsp_o[i].mgnt = master_mgnt[i];
      m_rsp_o[i].mack = 1'b0;
      m_rsp_o[i].mrdata = '0;
      m_rsp_o[i].mresp = 1'b0;
      master_resp_consumed[i] = 1'b0;

      if (dec_err_mack[i]) begin
        // Priority A: Internal unmapped decode error response
        m_rsp_o[i].mack   = 1'b1;
        m_rsp_o[i].mresp  = 1'b1;  // ERROR code
        m_rsp_o[i].mrdata = '0;
      end else if (sid_fifo_valid[i]) begin
        // Priority B: Check if the transaction at the head of SID FIFO has returned
        int cur_sid;
        cur_sid = sid_fifo_head[i];

        if (resp_buffer_valid[i][cur_sid]) begin
          m_rsp_o[i].mack                       = 1'b1;
          {m_rsp_o[i].mrdata, m_rsp_o[i].mresp} = resp_buffer_data[i][cur_sid];
          master_resp_consumed[i]               = 1'b1;
        end
      end
    end
  end

endmodule


