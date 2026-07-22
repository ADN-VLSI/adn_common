/*
 
@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.
 
@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.
 
@foez-bhai, add commments for the port, parameter and internal signal
 
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
    input   logic j,
    input   logic k,
    input   logic clk_i,
    input   logic rst_ni,
    output  logic q_o
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
