/*

### Purpose
The `adn_common_priority_selector` module implements a priority-based selection logic that identifies the first active match from a set of input rules. It maps the highest-priority matching rule to a corresponding slave identifier and provides a status signal indicating whether a valid match was found.

### Usage
To use this module, instantiate it by specifying the `NUM_RULES` (number of input match signals) and `SLAVE_ID_WIDTH` (bit-width of the slave identifiers). Connect the `match_i` vector where each bit represents a rule status, and provide the `slave_id_i` array containing the IDs associated with each rule. The module will output the `slave_index_o` corresponding to the highest-priority (lowest index) active bit in `match_i`, and assert `addr_found_o` if any match is detected.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-30 | Adnan Sami Anirban | Stable release                                      |

Author : Adnan Sami Anirban (adnananirban259@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_priority_selector #(

    parameter int NUM_RULES      = 4, // Number of input rules to evaluate
    parameter int SLAVE_ID_WIDTH = 4  // Bit-width of the slave ID output

)(

    input logic [NUM_RULES-1:0]       match_i,                   // Vector of match signals per rule
    input logic [SLAVE_ID_WIDTH-1:0]  slave_id_i [0:NUM_RULES-1], // Array of slave IDs mapped to each rule

    output logic [SLAVE_ID_WIDTH-1:0] slave_index_o,             // Selected slave ID based on priority
    output logic                      addr_found_o               // High if at least one match is found
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Loop index for priority evaluation
  integer i;

  // Priority encoder logic: scans match_i from index 0 upwards
  always_comb begin
    // Default values to prevent latches
    slave_index_o = '0;
    addr_found_o  = 1'b0;

    // Iterate through rules to find the first active match
    for(i = 0; i < NUM_RULES; i = i + 1) begin
        // If no match found yet and current rule is active
        if(!addr_found_o && match_i[i])
        begin
          // Assign corresponding slave ID and set found flag
          slave_index_o = slave_id_i[i];
          addr_found_o  = 1'b1;

        end
    end
  end
endmodule
