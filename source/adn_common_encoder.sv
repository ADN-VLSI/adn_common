/*

### Purpose

The `adn_common_encoder` converts an asserted bit in `d_i` into its binary address. When more than
one input bit is asserted, the lowest index wins. `enable_i` disables both the address-valid output
and address selection when low.

### Usage

Set `NUM_WIRE` to the number of input bits, assert `enable_i`, and drive `d_i`. `addr_o` identifies
the selected input when `addr_valid_o` is high.

| REVISION | DATE       | AUTHOR             | DESCRIPTION     |
|----------|------------|--------------------|-----------------|
| 0.1      | 2026-07-30 | Shykul Islam Siam  | Initial version |
| 1.0      | 2026-07-30 | Shykul Islam Siam  | Stable release  |

Author : Shykul Islam Siam (shykulislam32@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_encoder #(
    parameter int NUM_WIRE = 4  // Number of input wires; must be at least two.
) (
    input  logic                        enable_i,       // Enables address selection and valid output.
    input  logic [    NUM_WIRE-1:0]     d_i,            // Input bits to encode.
    output logic [$clog2(NUM_WIRE)-1:0] addr_o,         // Address of the selected input bit.
    output logic                        addr_valid_o    // Indicates a valid encoded address.
);

//////////////////////////////////////////////////////////////////////////////////////////////////
// ASSIGNMENTS
//////////////////////////////////////////////////////////////////////////////////////////////////
always_comb begin
  addr_o       = '0;
  addr_valid_o = 1'b0;

  if (enable_i) begin
    for (int i = NUM_WIRE - 1; i >= 0; i--) begin
      if (d_i[i]) begin
        addr_o       = i;
        addr_valid_o = 1'b1;
      end
    end
  end
end

//////////////////////////////////////////////////////////////////////////////////////////////////
// INITIAL CHECKS
//////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef SIMULATION
initial begin
if (NUM_WIRE < 2) begin
$error("%m NUM_WIRE must be at least 2; got %0d", NUM_WIRE);
end
end
`endif  // SIMULATION

endmodule