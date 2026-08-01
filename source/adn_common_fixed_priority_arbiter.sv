/*

### Purpose
This module implements a fixed-priority arbiter that grants access to a resource based on the highest index request. It evaluates multiple input requests and ensures that only the request with the highest priority (highest index) is granted, provided the global allow signal is asserted.

### Usage
To use this module, instantiate it with the desired number of requests (`NUM_REQ`). Connect your request vector to `req_i` and the global enable signal to `allow_req_i`. The module will output a one-hot encoded grant vector `gnt_i` where the highest index bit set in `req_i` is granted, provided `allow_req_i` is high.

Example:
```systemverilog
adn_common_fixed_priority_arbiter #(
    .NUM_REQ(8)
) u_arbiter (
    .req_i(request_bus),
    .allow_req_i(global_enable),
    .gnt_i(grant_bus)
);
```

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

module adn_common_fixed_priority_arbiter #(
    parameter int NUM_REQ = 4 // Number of request inputs to arbitrate
) (
    input logic [NUM_REQ-1:0] req_i,       // Request vector, higher index has higher priority
    input logic               allow_req_i, // Global enable signal to permit granting

    output logic [NUM_REQ-1:0] gnt_i       // One-hot encoded grant output
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Internal tracking signal to identify if any higher-priority request has already claimed the resource
  logic [NUM_REQ-1:1] already_granted;  

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Logic to propagate the grant status from the highest index downwards
  always_comb already_granted[NUM_REQ-1] = req_i[NUM_REQ-1];
  for (genvar i = NUM_REQ - 2; i >= 1; i--) begin
    // Accumulate requests: if current or any higher index is active, mark as granted
    always_comb already_granted[i] = req_i[i] | already_granted[i+1];
  end

  // Generate grant signals: only grant if the request is active, global allow is high, 
  // and no higher priority request has claimed the resource
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
