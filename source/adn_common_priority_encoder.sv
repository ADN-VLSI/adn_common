/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use-case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR             | DESCRIPTION      |
|----------|------------|--------------------|------------------|
| 0.1      | 2026-07-30 | Shykul Islam Siam  | Initial version  |
| 1.0      | 2026-07-30 | Shykul Islam Siam  | Stable release   |
| 1.1      | 2026-08-01 | Foez Ahmed         | Simplified logic |

Author : Shykul Islam Siam (shykulislam32@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_priority_encoder #(
    parameter int NUM_WIRE            = 4,  // Number of input wires; must be at least two.
    parameter bit HIGH_INDEX_PRIORITY = 0   // When set, the highest asserted input has priority.
) (
    // Input bits to encode.
    input logic [NUM_WIRE-1:0] d_i,

    // Address of the selected input bit.
    output logic [$clog2(NUM_WIRE)-1:0] addr_o,
    // Indicates that at least one input is asserted.
    output logic                        addr_valid_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    logic found;
    found = '0;
    addr_o = '0;
    addr_valid_o = '0;
    if (HIGH_INDEX_PRIORITY) begin
      for (int i = NUM_WIRE - 1; i >= 0; i--) begin
        if (d_i[i] && !found) begin
          addr_o = i;
          found  = 1'b1;
        end
      end
    end else begin
      for (int i = 0; i < NUM_WIRE; i++) begin
        if (d_i[i] && !found) begin
          addr_o = i;
          found  = 1'b1;
        end
      end
    end
    addr_valid_o = found;
  end

endmodule
