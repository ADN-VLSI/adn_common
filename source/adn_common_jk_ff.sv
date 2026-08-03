/*
 
### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the standard JK flip-flop functionality: holding the state, resetting to 0, setting to 1, or toggling the output based on the J and K inputs on the rising edge of the clock.

### Use Case
This module is primarily used in digital logic designs requiring state storage with flexible control logic. Common applications include:
- **Frequency Dividers:** Utilizing the toggle mode (J=1, K=1) to divide the clock frequency.
- **State Machines:** Serving as a fundamental building block for sequential controllers.
- **Counters:** Implementing binary or non-binary counters where specific set/reset/toggle behaviors are required.
- **Control Registers:** Managing status flags that need to be set, cleared, or toggled based on system events.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Ratified                                               |
 
Author : Shuparna Haque (sheikhshuparna3108@gmail.com)
This file is part of https://github.com/ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information
 
*/

module adn_common_jk_ff (
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // Clock input

    input logic j_i,  // J input (Set control)
    input logic k_i,  // K input (Reset control)

    output logic q_o,  // Output state
    output logic q_no  // Complementary output state
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Sequential logic block triggered on the rising edge of the clock
  always_ff @(posedge clk_i or negedge arst_ni) begin
    // Asynchronous reset logic: active-low
    if (~arst_ni) begin
      q_o <= '0; // Reset output to 0 on asynchronous reset
    end else begin
      // JK Flip-Flop truth table implementation
      case ({
        j_i, k_i
      })
        'b01: q_o <= '0;      // Reset state
        'b10: q_o <= '1;      // Set state
        'b11: q_o <= q_no;    // Toggle state
        default: q_o <= q_o;  // Hold state
      endcase
    end
  end

  assign q_no = ~q_o;  // Ensure complementary output is always the inverse of q_o

endmodule
