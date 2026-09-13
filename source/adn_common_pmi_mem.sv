/*

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-09-14 | Foez Ahmed | Initial version                                        |
| 1.0      | 2026-09-14 | Foez Ahmed | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez---bhai, add comments to the parameters, ports
module adn_common_pmi_mem #(
    parameter type pmi_req_t = logic,
    parameter type pmi_rsp_t = logic,
    parameter int  LATENCY   = 5
) (
    input logic arst_ni,
    input logic clk_i,

    input  pmi_req_t req_i,
    output pmi_rsp_t rsp_o
);

  // @foez---bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int ADDR_WIDTH = $bits(type (req_i.maddr));
  localparam int DATA_WIDTH = $bits(type (req_i.mwdata));
  localparam int RSP_WIDTH = $bits(type (rsp_o));
  localparam int DROP_BITS = $clog2(DATA_WIDTH / 8);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] rdata;
  logic                  ack;
  logic [ADDR_WIDTH-1:0] addr;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign rsp_o.mgnt  = req_i.mreq;
  assign rsp_o.mresp = '0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_synchronizer #(
      .WIDTH      (DATA_WIDTH + 1),
      .STAGES     (LATENCY),
      .RESET_VALUE('0)
  ) u_lat_pile (
      .clk_i  (clk_i),
      .arst_ni(arst_ni),
      .en_i   (1'b1),
      .data_i ({ack, rdata}),
      .data_o ({rsp_o.mack, rsp_o.mrdata})
  );

  // TODO generic mem

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TODO WRITE
  // TODO READ

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

endmodule

