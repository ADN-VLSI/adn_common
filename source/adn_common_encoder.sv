/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-29 | Foez Ahmed      | Initial version                                        |
| 1.0      | 2026-08-29 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_encoder #(
    parameter int NUM_WIRE = 16
) (
    input logic [NUM_WIRE-1:0] wire_in,

    output logic [$clog2(NUM_WIRE)-1:0] index_o,
    output logic                        index_valid_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Array to hold intermediate reduction results for each level
  logic [NUM_WIRE/2-1:0] index_or_red[$clog2(NUM_WIRE)];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Generate block to calculate reduction for each level
  for (genvar j = 0; j < $clog2(NUM_WIRE); j++) begin : g_addr_or_red
    always_comb begin
      int k;
      index_or_red[j] = '0;  // Initialize reduction array to 0
      k = 0;
      for (int i = 0; i < NUM_WIRE; i++) begin
        // Condition to include the wire in the current reduction level
        if (!((i % (2 ** (j + 1))) < ((2 ** (j + 1)) / 2))) begin
          index_or_red[j][k] = wire_in[i];  // Assign wire to reduction array
          k++;
        end
      end
    end
  end

  // Generate block to assign output index based on the reduction results
  for (genvar i = 0; i < $clog2(NUM_WIRE); i++) begin : g_addr_o
    always_comb index_o[i] = |index_or_red[i];  // OR reduction results to form the output index
  end

  // Determine if any input wire is active
  always_comb index_valid_o = |wire_in;

endmodule
