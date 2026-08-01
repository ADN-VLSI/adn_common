/*

# Purpose
The `adn_common_round_robin_arbiter` module implements a fair, round-robin arbitration scheme to select a single requester from multiple input requests. It ensures that every requester is granted access in a rotating order, preventing starvation and ensuring equitable bandwidth distribution among all input channels.

## Usage
To use this module, instantiate it by specifying the `NUM_REQ` parameter to match the number of input request channels. The module samples `req_i` and, when `allow_req_i` is high, grants access to one requester based on the round-robin pointer.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-28 | Motasim Faiyaz  | Initial version                                        |
| 1.0      | 2026-07-28 | Motasim Faiyaz  | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Simplified Logic                                       |
| 1.2      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

Author : Motasim Faiyaz (motasimfaiyaz@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_round_robin_arbiter #(
    // Number of request channels to arbitrate
    parameter int NUM_REQ = 8

) (
    // Clock input
    input logic clk_i,
    // Active-low asynchronous reset
    input logic arst_ni,

    // High when the arbiter is permitted to grant a new request
    input logic               allow_req_i,
    // Input request bus, one bit per channel
    input logic [NUM_REQ-1:0] req_i,

    // One-hot grant output, original bit order
    output logic [        NUM_REQ-1:0] gnt_o,            // TODO
    // Encoded grant address, original order
    output logic [$clog2(NUM_REQ)-1:0] gnt_addr_o,
    // High when gnt_addr_o contains a valid grant
    output logic                       gnt_addr_valid_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [$clog2(NUM_REQ)-1:0] last_gnt;
  logic [$clog2(NUM_REQ)-1:0] next_gnt;
  logic [NUM_REQ-1:0] fpa_in;
  logic [NUM_REQ-1:0] fpa_out;
  logic [$clog2(NUM_REQ)-1:0] fpa_gnt_addr;
  logic [NUM_REQ-1:0] fpa_gnt_addr_valid;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign gnt_addr_o = ((fpa_gnt_addr + next_gnt ) < NUM_REQ) ? (fpa_gnt_addr + next_gnt )
                      : ((fpa_gnt_addr + next_gnt) - NUM_REQ);

  assign next_gnt = ((last_gnt + 1) < NUM_REQ) ? (last_gnt + 1) : ((last_gnt + 1) - NUM_REQ);

  assign gnt_addr_valid_o = fpa_gnt_addr_valid & arst_ni & allow_req_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_rotating_xbar #(
      .DATA_WIDTH(1),
      .NUM_PORTS (NUM_REQ)
  ) in_xbar (
      .rotation_index_i(next_gnt),
      .in_i(req_i),
      .out_o(fpa_in)
  );

  adn_common_fixed_priority_arbiter #(
      .NUM_WIRE(NUM_REQ),
      .HIGH_INDEX_PRIORITY(0)
  ) fp_arb (
      .d_i(fpa_in),
      .addr_o(fpa_gnt_addr),
      .addr_valid_o(fpa_gnt_addr_valid)
  );

  adn_common_decoder #(
      .ADDR_WIDTH($clog2(NUM_REQ)),
      .DATA_WIDTH(NUM_REQ)
  ) decoder (
      .addr_i(gnt_addr_o),
      .addr_valid_i(gnt_addr_valid_o),
      .d_o(gnt_o)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      last_gnt <= NUM_REQ - 1;
    end else if (gnt_addr_valid_o) begin
      last_gnt <= gnt_addr_o;
    end
  end

endmodule
