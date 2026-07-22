/*
 
### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the standard JK flip-flop functionality: holding the state, resetting to 0, setting to 1, or toggling the output based on the J and K inputs on the rising edge of the clock.
 
### Usage
To use this module, instantiate it in your design and connect the `j`, `k`, `clk_i`, and `rst_ni` signals. The `q_o` output will reflect the state of the flip-flop.
- `j=0, k=0`: Hold current state.
- `j=0, k=1`: Reset output to 0.
- `j=1, k=0`: Set output to 1.
- `j=1, k=1`: Toggle output state.
 
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
    input   logic j,      // J input
    input   logic k,      // K input
    input   logic clk_i,  // Clock input
    input   logic rst_ni, // Active-low asynchronous reset
    output  logic q_o     // Output state
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff@ (posedge clk_i )
  begin
    if (!rst_ni)
    begin
      q_o <= 1'b0;
    end
    else if (j==1'b1 && k==1'b0)
    begin
      q_o <= 1'b1;
    end
    else if (j==1'b0 && k==1'b1)
    begin
      q_o <= 1'b0;
    end
    else if (j==1'b1 && k==1'b1)
    begin
      q_o <= ~q_o;
    end
    else
    begin
      q_o <= q_o;
    end
  end

endmodule
