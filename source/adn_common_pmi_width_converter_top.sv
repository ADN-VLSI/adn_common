/*
@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.


| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-30 | Motasim Faiyaz | Initial version                                        |
| 1.0      | 2026-08-30 | Motasim Faiyaz | Stable release                                         |

Author : Motasim Faiyaz (motasimfaiyaz@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

//`include "pmi/typedef.svh"
// @foez-bhai, add comments to the parameters, ports
module adn_common_pmi_width_converter_top #(
  parameter int ADDR_WIDTH     = 32,
  parameter int IN_DATA_WIDTH  = 32,
  parameter int OUT_DATA_WIDTH = 64
) (
  input  logic                          clk,
  input  logic                          arst_n,

  input  logic [ADDR_WIDTH-1:0]         s_maddr,
  input  logic                          s_mwe,
  input  logic [IN_DATA_WIDTH-1:0]      s_mwdata,
  input  logic [(IN_DATA_WIDTH/8)-1:0]  s_mstrb,
  input  logic                          s_mreq,
  output logic                          s_mgnt,
  output logic                          s_mack,
  output logic [IN_DATA_WIDTH-1:0]      s_mrdata,
  output logic                          s_mresp,

  output logic [ADDR_WIDTH-1:0]         m_maddr,
  output logic                          m_mwe,
  output logic [OUT_DATA_WIDTH-1:0]     m_mwdata,
  output logic [(OUT_DATA_WIDTH/8)-1:0] m_mstrb,
  output logic                          m_mreq,
  input  logic                          m_mgnt,
  input  logic                          m_mack,
  input  logic [OUT_DATA_WIDTH-1:0]     m_mrdata,
  input  logic                          m_mresp
);
// @foez-bhai, add comments to the functional blocks, signals, and submodules
// `PMI_T(s_pmi, ADDR_WIDTH, IN_DATA_WIDTH)
// `PMI_T(m_pmi, ADDR_WIDTH, OUT_DATA_WIDTH)

  s_pmi_req_t s_pmi_req_i;
  s_pmi_rsp_t s_pmi_rsp_i;
  m_pmi_req_t m_pmi_req_i;
  m_pmi_rsp_t m_pmi_rsp_i;

  assign s_pmi_req_i.maddr  = s_maddr;
  assign s_pmi_req_i.mwe    = s_mwe;
  assign s_pmi_req_i.mwdata = s_mwdata;
  assign s_pmi_req_i.mstrb  = s_mstrb;
  assign s_pmi_req_i.mreq   = s_mreq;

  assign s_mgnt   = s_pmi_rsp_i.mgnt;
  assign s_mack   = s_pmi_rsp_i.mack;
  assign s_mrdata = s_pmi_rsp_i.mrdata;
  assign s_mresp  = s_pmi_rsp_i.mresp;

  assign m_pmi_req_i.maddr  = m_maddr;
  assign m_pmi_req_i.mwe    = m_mwe;
  assign m_pmi_req_i.mwdata = m_mwdata;
  assign m_pmi_req_i.mstrb  = m_mstrb;
  assign m_pmi_req_i.mreq   = m_mreq;

  assign m_pmi_rsp_i.mgnt   = m_mgnt;
  assign m_pmi_rsp_i.mack   = m_mack;
  assign m_pmi_rsp_i.mrdata = m_mrdata;
  assign m_pmi_rsp_i.mresp  = m_mresp;

  generate
    if (OUT_DATA_WIDTH > IN_DATA_WIDTH) begin : g_up
      adn_common_pmi_width_converter_up #(
        .ADDR_WIDTH   (ADDR_WIDTH),
        .S_DATA_WIDTH (IN_DATA_WIDTH),
        .M_DATA_WIDTH (OUT_DATA_WIDTH),
        .s_req_t      (s_pmi_req_t),
        .s_rsp_t      (s_pmi_rsp_t),
        .m_req_t      (m_pmi_req_t),
        .m_rsp_t      (m_pmi_rsp_t)
      ) u_width_converter_up (
        .clk_i       (clk),
        .arst_ni     (arst_n),
        .s_pmi_req_i (s_pmi_req_i),
        .s_pmi_rsp_o (s_pmi_rsp_i),
        .m_pmi_req_o (m_pmi_req_i),
        .m_pmi_rsp_i (m_pmi_rsp_i)
      );
    end : g_up
    else if (OUT_DATA_WIDTH < IN_DATA_WIDTH) begin : g_down
      adn_common_pmi_width_converter_down #(
        .s_req_t (s_pmi_req_t),
        .s_rsp_t (s_pmi_rsp_t),
        .m_req_t (m_pmi_req_t),
        .m_rsp_t (m_pmi_rsp_t)
      ) u_width_converter_down (
        .clk_i       (clk),
        .arst_ni     (arst_n),
        .s_pmi_req_i (s_pmi_req_i),
        .s_pmi_rsp_o (s_pmi_rsp_i),
        .m_pmi_req_o (m_pmi_req_i),
        .m_pmi_rsp_i (m_pmi_rsp_i)
      );
    end : g_down
    else begin : g_passthrough
      assign m_maddr  = s_maddr;
      assign m_mwe    = s_mwe;
      assign m_mwdata = s_mwdata;
      assign m_mstrb  = s_mstrb;
      assign m_mreq   = s_mreq;
      assign s_mgnt   = m_mgnt;
      assign s_mack   = m_mack;
      assign s_mrdata = m_mrdata;
      assign s_mresp  = m_mresp;
    end : g_passthrough
  endgenerate

endmodule : adn_common_pmi_width_converter_top

