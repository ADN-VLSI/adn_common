/*

### Purpose

The `adn_common_priority_encoder` selects one asserted bit from `d_i` using fixed priority and
converts that one-hot selection to an address. `HIGH_INDEX_PRIORITY` chooses whether the highest
or lowest asserted input bit wins. The priority mask is built from explicit AND/De Morgan logic
before being encoded.

### Usage

Set `NUM_WIRE` to the number of input bits and `HIGH_INDEX_PRIORITY` to select which end of `d_i`
wins ties. Drive `d_i`; `addr_o` reports the winning bit's index when `addr_valid_o` is high.

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

module adn_common_priority_encoder #(
    parameter int NUM_WIRE            = 4,  // Number of input wires; must be at least two.
    parameter bit HIGH_INDEX_PRIORITY = 0   // When set, the highest asserted input has priority.
) (
    input  logic [    NUM_WIRE-1:0]     d_i,           // Input bits to encode.
    output logic [$clog2(NUM_WIRE)-1:0] addr_o,        // Address of the selected input bit.
    output logic                        addr_valid_o   // Indicates that at least one input is asserted.
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic [NUM_WIRE-1:0] select_already_found;  // Indicates a higher-priority request has been seen.
  logic [NUM_WIRE-1:0] allowed_selects;       // One-hot request remaining after priority masking.

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  genvar i;
  generate
    // Allow a request only when no higher-priority request is present.
    for (i = 0; i < NUM_WIRE; i = i + 1) begin : g_allowed_selects
      assign allowed_selects[i] = d_i[i] & ~select_already_found[i];
    end

    if (HIGH_INDEX_PRIORITY) begin : g_msb_p
      // Propagate the presence of higher-index requests toward lower indices.
      for (i = 0; i < (NUM_WIRE - 1); i = i + 1) begin : g_select_found
        assign select_already_found[i] = ~(~select_already_found[i+1] & ~d_i[i+1]);
      end
      assign select_already_found[NUM_WIRE-1] = 1'b0;
    end else begin : g_lsb_p
      // Propagate the presence of lower-index requests toward higher indices.
      assign select_already_found[0] = 1'b0;
      for (i = 1; i < NUM_WIRE; i = i + 1) begin : g_select_found
        assign select_already_found[i] = ~(~select_already_found[i-1] & ~d_i[i-1]);
      end
    end
  endgenerate

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Converts the one-hot allowed selection into a binary address.
  adn_common_encoder #(
    .NUM_WIRE(NUM_WIRE)
) u_encoder (
    .enable_i(1'b1),
    .d_i(allowed_selects),
    .addr_o(addr_o),
    .addr_valid_o(addr_valid_o)
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef SIMULATION
  initial begin
    if (NUM_WIRE > 32) begin
      $display("\033[7;31m %m NUM_WIRE=%0d \033[0m", NUM_WIRE);
    end
  end
`endif  // SIMULATION

endmodule