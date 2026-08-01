/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-01 | Foez Ahmed      | Initial version                                        |
| 1.0      | 2026-08-01 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_xbar #(
    parameter DATA_WIDTH  = 2,
    parameter NUM_INPUTS  = 2,
    parameter NUM_OUTPUTS = 2
) (
    input logic [DATA_WIDTH-1:0] in_i[NUM_INPUTS],

    input logic [$clog2(NUM_INPUTS)-1:0] sel_i[NUM_OUTPUTS],

    output logic [DATA_WIDTH-1:0] out_o[NUM_OUTPUTS]
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin : gen_xbar
    for (int i = 0; i < NUM_OUTPUTS; i++) begin
      out_o[i] = in_i[sel_i[i]];
    end
  end

endmodule

