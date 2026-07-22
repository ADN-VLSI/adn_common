/*
 
### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the fundamental logic for state transitions based on the J and K inputs, supporting set, reset, hold, and toggle operations on the rising edge of the clock.
 
### Usage
To use this module, instantiate it in your design and connect the `j` and `k` inputs to control the state transitions, `clk_i` to your system clock, and `rst_ni` to an active-low reset signal. The output `q_o` will reflect the current state of the flip-flop.
- **Hold:** J=0, K=0
- **Reset:** J=0, K=1
- **Set:** J=1, K=0
- **Toggle:** J=1, K=1
 
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
    input   logic j,      // J input for JK flip-flop logic
    input   logic k,      // K input for JK flip-flop logic
    input   logic clk_i,  // System clock input
    input   logic rst_ni, // Active-low asynchronous reset
    output  logic q_o     // Output state of the flip-flop
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
