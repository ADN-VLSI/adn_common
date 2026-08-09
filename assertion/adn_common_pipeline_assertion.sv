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
module adn_common_pipeline_assertion #(
    parameter int DATA_WIDTH = 32  // Data bus width
) (
    // Clock and Reset
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // Rising-edge clock

    // Input (Upstream) Interface
    input logic [DATA_WIDTH-1:0] data_in_i,        // Input data
    input logic                  data_in_valid_i,  // Input data valid
    input logic                  data_in_ready_o,  // Input ready (backpressure to upstream)

    // Output (Downstream) Interface
    input logic [DATA_WIDTH-1:0] data_out_o,        // Output data
    input logic                  data_out_valid_o,  // Output data valid
    input logic                  data_out_ready_i   // Output ready (backpressure from downstream)
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_valid_ready_checker #(
      .DATA_WIDTH(DATA_WIDTH)
  ) a_in (
      .arst_ni(arst_ni),
      .rst_ni ('1),
      .clk_i  (clk_i),
      .data_i (data_in_i),
      .valid_i(data_in_valid_i),
      .ready_i(data_in_ready_o)
  );

  adn_common_valid_ready_checker #(
      .DATA_WIDTH(DATA_WIDTH)
  ) a_out (
      .arst_ni(arst_ni),
      .rst_ni ('1),
      .clk_i  (clk_i),
      .data_i (data_out_o),
      .valid_i(data_out_valid_o),
      .ready_i(data_out_ready_i)
  );

endmodule

