/*

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-08-25 | Shuparna Haque  | Initial version                                        |
| 1.0      | 2026-08-25 | Shuparna Haque  | Stable release                                         |

Author : Shuparna Haque (sheikhshuparna3108@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez---bhai, add comments to the parameters, ports
module adn_common_pmi_width_converter_down #(
    // PARAMETERS
    parameter type s_req_t = logic,
    parameter type s_rsp_t = logic,  
    parameter type m_req_t = logic,  
    parameter type m_rsp_t = logic 
) (
    // PORTS
    input logic clk_i,
    input logic arst_ni,

    input  s_req_t s_pmi_req_i,
    output s_rsp_t s_pmi_rsp_o,

    output m_req_t m_pmi_req_o,
    input  m_rsp_t m_pmi_rsp_i
);
  // @foez---bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////
    localparam int WIDE_DW   = $bits(s_pmi_req_i.mwdata);
    localparam int NARROW_DW = $bits(m_pmi_req_o.mwdata);
    localparam int RATIO     = WIDE_DW / NARROW_DW;
    localparam int BEAT_W    = (RATIO <= 1) ? 1 : $clog2(RATIO);
    localparam int NARROW_ADDR_LSB = $clog2(NARROW_DW / 8);
    

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
    logic [BEAT_W:0]    issue_cnt;
    logic [BEAT_W:0]    ack_cnt;
    logic [WIDE_DW-1:0] rdata_acc;
    logic                mrsp_acc;
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
    assign m_pmi_req_o.mreq = s_pmi_req_i.mreq && (issue_cnt < RATIO);
  
    assign s_pmi_rsp_o.mgnt = m_pmi_req_o.mreq && m_pmi_rsp_i.mgnt && (issue_cnt == RATIO - 1);
  
    assign m_pmi_req_o.maddr = s_pmi_req_i.maddr | ({{($bits(s_pmi_req_i.maddr) - BEAT_W) {1'b0}}, issue_cnt[BEAT_W-1:0]} << NARROW_ADDR_LSB);
  
    assign m_pmi_req_o.mwe = s_pmi_req_i.mwe;
  
    assign m_pmi_req_o.mwdata = s_pmi_req_i.mwe ? s_pmi_req_i.mwdata[issue_cnt*NARROW_DW+:NARROW_DW] : '0;
  
    assign m_pmi_req_o.mstrb = s_pmi_req_i.mwe ? s_pmi_req_i.mstrb[issue_cnt*(NARROW_DW/8)+:(NARROW_DW/8)] : '0;
  
    assign s_pmi_rsp_o.mack   = m_pmi_rsp_i.mack && (ack_cnt == (RATIO - 1));
    assign s_pmi_rsp_o.mrdata = rdata_acc | ({{(WIDE_DW - NARROW_DW) {1'b0}}, m_pmi_rsp_i.mrdata} << (ack_cnt * NARROW_DW));
    assign s_pmi_rsp_o.mrsp   = mrsp_acc | m_pmi_rsp_i.mrsp;
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      issue_cnt <= '0;
    end else begin
      if (issue_cnt < RATIO) begin
        if (m_pmi_req_o.mreq && m_pmi_rsp_i.mgnt) begin
          issue_cnt <= issue_cnt + 1'b1;
        end
      end else begin
        if (ack_cnt == '0) begin
          issue_cnt <= '0;
        end
      end
    end
  end
 
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      ack_cnt   <= '0;
      rdata_acc <= '0;
      mrsp_acc  <= 1'b0;
    end else if (m_pmi_rsp_i.mack) begin
      if (ack_cnt == (RATIO - 1)) begin
        ack_cnt   <= '0;
        rdata_acc <= '0;
        mrsp_acc  <= 1'b0;
      end else begin
        ack_cnt <= ack_cnt + 1'b1;
        rdata_acc[ack_cnt*NARROW_DW+:NARROW_DW] <= m_pmi_rsp_i.mrdata;
        mrsp_acc <= mrsp_acc | m_pmi_rsp_i.mrsp;
      end
    end
  end
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  initial begin
    if ((WIDE_DW % NARROW_DW) != 0) begin
      $error("adn_common_pmi_width_converter_down: WIDE_DW must be an integer multiple of NARROW_DW");
    end
  end
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (RATIO > 8) begin
      $display("\033[1;33m%m RATIO\033[0m");
    end
  end
`endif  // SIMULATION

endmodule

