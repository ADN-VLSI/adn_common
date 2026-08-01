/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR             | DESCRIPTION     |
|----------|------------|--------------------|-----------------|
| 0.1      | 2026-07-30 | Shykul Islam Siam  | Initial version |
| 1.0      | 2026-07-30 | Shykul Islam Siam  | Stable release  |
| 1.1      | 2026-08-01 | Foez Ahmed         | Port Fix        |

Author : Shykul Islam Siam (shykulislam32@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_fixed_priority_arbiter #(
    parameter int NUM_REQ = 4
) (
    input logic [NUM_REQ-1:0] req_i,
    input logic               allow_req_i,

    output logic [NUM_REQ-1:0] gnt_i
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [NUM_REQ-1:1] already_granted;  // Tracks if a higher priority request has been granted

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb already_granted[NUM_REQ-1] = req_i[NUM_REQ-1];
  for (genvar i = NUM_REQ - 2; i >= 1; i--) begin
    always_comb already_granted[i] = req_i[i] | already_granted[i+1];
  end

  always_comb gnt_i[NUM_REQ-1] = req_i[NUM_REQ-1] & allow_req_i;
  for (genvar i = NUM_REQ - 2; i >= 0; i--) begin
    always_comb gnt_i[i] = req_i[i] & allow_req_i & ~already_granted[i+1];
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (NUM_REQ < 1) begin
      $display("\033[1;33m%m Is arbiter necessary?\033[0m");
    end
  end
`endif  // SIMULATION

endmodule
