/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Motasim Faiyaz | Initial version                                        |
| 1.0      | YYYY-MM-DD | Motasim Faiyaz | Stable release                                         |

Author : Motasim Faiyaz (motasimfaiyaz@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez---bhai, add comments to the parameters, ports
module adn_common_b_rounder #(
    // PARAMETERS
    parameter int N = 8    
) (
    // PORTS
    input  logic [N-1:0] req_i,
    input logic [$clog2(N)-1:0] offset,
    output logic [N-1:0] grant_o
);

  // @foez---bhai, add comments to the functional blocks, signals, and submodules

    //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  always_comb begin
  
  
      int i= offset;
      int j= 0;
     
      grant_o = '0;
  
      for (i= offset; i < N; i++) begin
          
          grant_o[i] = req_i[j];
          j++;
      end
  
      i=0;
  
      for (i=0; i<offset; i++) begin
     
          grant_o[i] = req_i[j];
          j++;
      end
  
  end    
  

endmodule

