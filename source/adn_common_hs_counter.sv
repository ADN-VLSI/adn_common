/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim Jannat    | Initial version                                        |
| 1.0      | 2026-07-29 | Annim Jannat    | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

Author : Annim Jannat (jannatannim@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_hs_counter #(
    parameter int DEPTH = 8
) (
    input logic clk_i,
    input logic arst_ni,

    input  logic data_in_valid_i,
    output logic data_in_ready_o,


    output logic data_out_valid_o,
    input  logic data_out_ready_i,

    output logic [$clog2(DEPTH+1)-1:0] count_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic in_hs, out_hs;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // ready unless count is full
  always_comb data_in_ready_o = (count_o != DEPTH) & arst_ni;
  // valid if not empty
  always_comb data_out_valid_o = (count_o != '0) & arst_ni;

  // handshake occurs when both valid and ready are asserted
  always_comb in_hs = data_in_valid_i && data_in_ready_o;
  // handshake occurs when both valid and ready are asserted
  always_comb out_hs = data_out_valid_o && data_out_ready_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      count_o <= '0;
    end else begin
      case ({
        in_hs, out_hs
      })
        2'b10:   count_o <= (count_o == DEPTH) ? count_o : count_o + 1'b1;  // in only: increment
        2'b01:   count_o <= (count_o == '0) ? count_o : count_o - 1'b1;  // out only: decrement
        default: count_o <= count_o;  // no change or both in and out: no change
      endcase
    end
  end

endmodule

