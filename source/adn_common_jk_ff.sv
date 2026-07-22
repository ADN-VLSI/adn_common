/*
 
@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |
 
Author : Shuparna Haque (sheikhshuparna3108@gmail.com)
This file is part of https://github.com/ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information
 
*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_jk_ff (
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // Clock input

    input logic j_i,  // J input
    input logic k_i,  // K input

    output logic q_o  // Output state
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // @foez-bhai, add comments to the functional blocks, signals, and submodules
  always_ff @(posedge clk_i) begin
    if (!arst_ni) begin
      q_o <= 1'b0;
    end else if (j_i == 1'b1 && k_i == 1'b0) begin
      q_o <= 1'b1;
    end else if (j_i == 1'b0 && k_i == 1'b1) begin
      q_o <= 1'b0;
    end else if (j_i == 1'b1 && k_i == 1'b1) begin
      q_o <= ~q_o;
    end else begin
      q_o <= q_o;
    end
  end

endmodule
