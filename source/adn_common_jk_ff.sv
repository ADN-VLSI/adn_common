/*
 
### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the standard JK flip-flop functionality: holding the state, resetting to 0, setting to 1, or toggling the output based on the J and K inputs on the rising edge of the clock.

### Usage
To use this module, instantiate it in your design and connect the `clk_i` to your system clock, `arst_ni` to your active-low reset signal, and the `j_i` and `k_i` inputs to your control logic. The `q_o` output will reflect the current state of the flip-flop.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |
 
Author : Shuparna Haque (sheikhshuparna3108@gmail.com)
This file is part of https://github.com/ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information
 
*/

module adn_common_jk_ff (
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // Clock input

    input logic j_i,      // J input (Set control)
    input logic k_i,      // K input (Reset control)

    output logic q_o      // Output state
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Sequential logic block triggered on the rising edge of the clock
  always_ff @(posedge clk_i or negedge arst_ni) begin
    // Asynchronous reset logic: active-low
    if (!arst_ni) begin
      q_o <= 1'b0;
    // Set condition: J=1, K=0
    end else if (j_i == 1'b1 && k_i == 1'b0) begin
      q_o <= 1'b1;
    // Reset condition: J=0, K=1
    end else if (j_i == 1'b0 && k_i == 1'b1) begin
      q_o <= 1'b0;
    // Toggle condition: J=1, K=1
    end else if (j_i == 1'b1 && k_i == 1'b1) begin
      q_o <= ~q_o;
    // Hold condition: J=0, K=0
    end else begin
      q_o <= q_o;
    end
  end

endmodule
