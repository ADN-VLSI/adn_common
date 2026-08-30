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

// =============================================================================
// File        : adn_common_pmi_width_converter_up.sv
// Module      : adn_common_pmi_width_converter_up
// Description : PMI data-width up-converter.
//
//               Bridges a narrow (S_DATA_WIDTH) upstream PMI master to a wide
//               (M_DATA_WIDTH) downstream PMI slave. Write data / byte strobes
//               are zero-extended into the upper (unused) lanes of the wide
//               bus; read data is truncated back down on the return path.
//
//               This is a lane-0 ("low aligned") converter: it does NOT
//               perform address-based byte-lane placement. The narrow
//               transaction is always mapped onto bits [S_DATA_WIDTH-1:0] of
//               the wide bus, and mstrb[S_STRB_WIDTH-1:0] of the wide bus.
//               It is intended for the common case where the downstream wide
//               slave decodes an entire word per access (e.g. a register
//               file / memory that is itself only ever driven through this
//               converter). If the wide slave must be shared with other,
//               natively-wide masters that expect proper byte-lane
//               alignment based on maddr, extend RTLS below accordingly.
//
//               Handshake and channel semantics (mreq/mgnt, mack, in-order
//               single response per request) are preserved 1:1 between the
//               two interfaces -- this module never splits or merges
//               transactions, so it is purely combinational.
// =============================================================================
*/

//////////////////////////////////////////////////////////////////////////////////////////////////
// TYPEDEFS
//////////////////////////////////////////////////////////////////////////////////////////////////
//`include "pmi/typedef.svh"

//`PMI_T(s_pmi, 32, 32)
//`PMI_T(m_pmi, 32, 64)

// @foez-bhai, add comments to the parameters, ports
module adn_common_pmi_width_converter_up #(
  parameter int ADDR_WIDTH   = 32,
  parameter int S_DATA_WIDTH = 32,
  parameter int M_DATA_WIDTH = 64,
  parameter type s_req_t = s_pmi_req_t,
  parameter type s_rsp_t = s_pmi_rsp_t,
  parameter type m_req_t = m_pmi_req_t,
  parameter type m_rsp_t = m_pmi_rsp_t
) (
  input logic clk_i,
  input logic arst_ni,

  input  s_req_t s_pmi_req_i,
  output s_rsp_t s_pmi_rsp_o,

  output m_req_t m_pmi_req_o,
  input  m_rsp_t m_pmi_rsp_i
);
// @foez-bhai, add comments to the functional blocks, signals, and submodules

  localparam int S_STRB_WIDTH = S_DATA_WIDTH / 8;
  localparam int M_STRB_WIDTH = M_DATA_WIDTH / 8;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Request channel: pass address / write-enable / request straight through
  assign m_pmi_req_o.maddr = s_pmi_req_i.maddr;
  assign m_pmi_req_o.mwe   = s_pmi_req_i.mwe;
  assign m_pmi_req_o.mreq  = s_pmi_req_i.mreq;
  assign s_pmi_rsp_o.mgnt  = m_pmi_rsp_i.mgnt;

  // Write data path: zero-pad into the upper, unused lanes
  assign m_pmi_req_o.mwdata = {{(M_DATA_WIDTH - S_DATA_WIDTH){1'b0}}, s_pmi_req_i.mwdata};
  assign m_pmi_req_o.mstrb  = {{(M_STRB_WIDTH - S_STRB_WIDTH){1'b0}}, s_pmi_req_i.mstrb};

  // Response channel: pass through, truncate read data on return path
  assign s_pmi_rsp_o.mack   = m_pmi_rsp_i.mack;
  assign s_pmi_rsp_o.mresp  = m_pmi_rsp_i.mresp;
  assign s_pmi_rsp_o.mrdata = m_pmi_rsp_i.mrdata[S_DATA_WIDTH-1:0];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  initial begin
    if (M_DATA_WIDTH <= S_DATA_WIDTH) begin
      $error("adn_common_pmi_width_converter_up: M_DATA_WIDTH (%0d) must be greater than S_DATA_WIDTH (%0d)",
             M_DATA_WIDTH, S_DATA_WIDTH);
    end
    if ((M_DATA_WIDTH % 8) != 0 || (S_DATA_WIDTH % 8) != 0) begin
      $error("adn_common_pmi_width_converter_up: data widths must be byte-multiples (got S=%0d, M=%0d)",
             S_DATA_WIDTH, M_DATA_WIDTH);
    end
  end

endmodule : adn_common_pmi_width_converter_up