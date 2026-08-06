/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-06 | Foez Ahmed | Initial version                                        |
| 1.0      | 2026-08-06 | Foez Ahmed | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_pipeline_join #(
    parameter int DATA_WIDTH = 32  // Data bus width
) (
    // Clock and Reset
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // Rising-edge clock

    // Input (Upstream) Interface
    input  logic [DATA_WIDTH-1:0] data_in_primary_i,        // Input data
    input  logic                  data_in_primary_valid_i,  // Input data valid
    output logic                  data_in_primary_ready_o,  // Input ready

    // Input (Upstream) Interface
    input  logic [DATA_WIDTH-1:0] data_in_secondary_i,        // Input data
    input  logic                  data_in_secondary_valid_i,  // Input data valid
    output logic                  data_in_secondary_ready_o,  // Input ready

    // Output (Downstream) Interface
    output logic [DATA_WIDTH-1:0] data_out_o,        // Output data
    output logic                  data_out_valid_o,  // Output data valid
    input  logic                  data_out_ready_i   // Output ready
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] pl_data;
  logic                  pl_valid;
  logic                  pl_ready;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb pl_data = data_in_primary_valid_i ? data_in_primary_i : data_in_secondary_i;

  always_comb pl_valid = data_in_primary_valid_i | data_in_secondary_valid_i;

  always_comb data_in_primary_ready_o = pl_ready;
  always_comb data_in_secondary_ready_o = pl_ready & ~data_in_primary_valid_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_pipeline #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_pl (
      .arst_ni         (arst_ni),
      .clk_i           (clk_i),
      .data_in_i       (pl_data),
      .data_in_valid_i (pl_valid),
      .data_in_ready_o (pl_ready),
      .data_out_o      (data_out_o),
      .data_out_valid_o(data_out_valid_o),
      .data_out_ready_i(data_out_ready_i)
  );

endmodule
