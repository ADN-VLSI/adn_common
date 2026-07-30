/*

### Purpose
The `adn_common_f_rounder` module implements a circular shifter (or barrel shifter) that rotates the input bit vector `req_i` by a specified `offset` to produce the output `req_o`. This is typically used in round-robin arbitration schemes or circular buffer indexing where elements need to be reordered based on a dynamic priority or starting position.

### Usage
To use this module, instantiate it by specifying the width `N` of the input vector. Provide the data to be rotated on the `req_i` port and the rotation amount on the `offset` port. The module will perform a left-circular shift, where the bit at index `offset` of the input becomes the bit at index 0 of the output.

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

module adn_common_f_rounder #(
    // PARAMETERS
    parameter int N = 8 // Width of the input and output vectors
) (
    // PORTS
    input  logic [N-1:0] req_i,             // Input vector to be rotated
    input logic [$clog2(N)-1:0] offset,     // Rotation amount (left shift)
    output logic [N-1:0] req_o              // Rotated output vector
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  always_comb begin
  
      // Internal loop indices
      int i = offset;
      int j = 0;
      
      // Initialize output to zero
      req_o = '0;
  
      // First loop: Map bits from offset to N-1 to the start of the output vector
      for (i = offset; i < N; i++) begin
          req_o[j] = req_i[i];
          j++;
      end
  
      // Second loop: Map bits from 0 to offset-1 to the remainder of the output vector
      i = 0;
      for (i = 0; i < offset; i++) begin
          req_o[j] = req_i[i];
          j++;
      end
  
  end    

endmodule
