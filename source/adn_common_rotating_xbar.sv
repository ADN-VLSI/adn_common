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
module adn_common_rotating_xbar #(
    parameter DATA_WIDTH = 2,
    parameter NUM_PORTS  = 2
) (
    input logic [DATA_WIDTH-1:0] in_i[NUM_PORTS],

    input logic [$clog2(NUM_PORTS)-1:0] rotation_index_i,

    output logic [DATA_WIDTH-1:0] out_o[NUM_PORTS]
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin : gen_xbar
    for (int i = 0; i < NUM_PORTS; i++) begin
      out_o[i] = in_i[(i+rotation_index_i)%NUM_PORTS];
    end
  end

endmodule

