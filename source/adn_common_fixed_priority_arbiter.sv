/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use-case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR             | DESCRIPTION                      |
|----------|------------|--------------------|----------------------------------|
| 0.1      | 2026-07-30 | Shykul Islam Siam  | Initial version                  |
| 1.0      | 2026-07-30 | Shykul Islam Siam  | Stable release                   |
| 1.1      | 2026-08-01 | Foez Ahmed         | Ports Fixed and simplified logic |

Author : Shykul Islam Siam (shykulislam32@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_fixed_priority_arbiter #(
    parameter int NUM_REQ             = 4,  // Number of request lines; must be at least one.
    parameter bit HIGH_INDEX_PRIORITY = 0   // When set, the highest index request has priority.
) (
    input logic [NUM_REQ-1:0] req_i,       // Request vector, higher index has higher priority
    input logic               allow_req_i, // Global enable signal to permit granting

    output logic [NUM_REQ-1:0] gnt_o  // One-hot encoded grant output
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [$clog2(NUM_REQ)-1:0] addr;
  logic                       addr_valid;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_priority_encoder #(
      .NUM_WIRE           (NUM_REQ),
      .HIGH_INDEX_PRIORITY(HIGH_INDEX_PRIORITY)
  ) u_encoder (
      .d_i   (req_i),
      .addr_o   (addr),
      .addr_valid_o(addr_valid)
  );

  adn_common_decoder #(
      .ADDR_WIDTH($clog2(NUM_REQ)),
      .DATA_WIDTH(NUM_REQ)
  ) u_decoder (
      .addr_i   (addr),
      .addr_valid_i(addr_valid),
      .d_o(gnt_o)
  );

endmodule
