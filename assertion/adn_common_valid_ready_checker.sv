/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-09 | Foez Ahmed      | Initial version                                        |
| 1.0      | 2026-08-09 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_valid_ready_checker #(
    parameter DATA_WIDTH = 8
) (
    input logic arst_ni,
    input logic rst_ni,

    input logic clk_i,

    input logic [DATA_WIDTH-1:0] data_i,
    input logic                  valid_i,
    input logic                  ready_i
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  /* verilog_format: off*/

  assert property (@(posedge clk_i) if (arst_ni && rst_ni)
    (valid_i && !ready_i) |=> $stable(data_i))
  else
    $error("ASSERTION FAILED: BUS should remain stable when VALID is high and READY is low");

  assert property (@(posedge clk_i) if (arst_ni && rst_ni)
    ($past(valid_i) && !valid_i) |=> $past(ready_i, 2))
  else
    $error("ASSERTION FAILED: READY should be high when VALID goes low");

  assert property (@(posedge clk_i)
    !rst_ni |=> !valid_i)
  else
    $error("ASSERTION FAILED: VALID must be low when reset is asserted");

  assert property (@(posedge clk_i)
    !rst_ni |=> !ready_i)
  else
    $error("ASSERTION FAILED: READY must be low when reset is asserted");

  assert property (@(posedge clk_i) // PROBABLY JHAMELA
    !arst_ni |-> !valid_i)
  else
    $error("ASSERTION FAILED: VALID must be low when reset is asserted");

  assert property (@(posedge clk_i) // PROBABLY JHAMELA
    !arst_ni |-> !ready_i)
  else
    $error("ASSERTION FAILED: READY must be low when reset is asserted");

  /* verilog_format: on*/

  always @(negedge arst_ni) begin
    #1step;
    assert (!valid_i)
    else $error("ASSERTION FAILED: VALID must be low when reset is asserted");
    assert (!ready_i)
    else $error("ASSERTION FAILED: READY must be low when reset is asserted");
  end

endmodule

