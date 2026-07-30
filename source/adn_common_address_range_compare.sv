/*

### Purpose
This module performs a range comparison to determine if a given address falls within a specified inclusive-minimum and exclusive-maximum range. It is designed to be used in memory-mapped systems or address decoding logic to validate address access.

### Usage
To use this module, instantiate it by specifying the `ADDR_WIDTH` parameter to match your system's address bus width. Connect the lower bound of the range to `min_addr_i`, the upper bound (exclusive) to `max_addr_i`, and the address to be checked to `addr_i`. The `match_o` output will assert high if `min_addr_i <= addr_i < max_addr_i`.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-30 | Adnan Sami Anirban | Stable release                                         |

Author : Adnan Sami Anirban (adnananirban259@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_address_range_compare #(
    // Parameter defining the bit-width of the address signals
    parameter int ADDR_WIDTH = 32 
) (
    // Inclusive lower bound of the address range
    input logic [ADDR_WIDTH-1:0] min_addr_i, 
    // Exclusive upper bound of the address range
    input logic [ADDR_WIDTH-1:0] max_addr_i, 
    // Address to be checked against the defined range
    input logic [ADDR_WIDTH-1:0] addr_i,     

    // Output signal: High if addr_i is within [min_addr_i, max_addr_i)
    output logic                 match_o     
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
    
  // Functional block to perform the range comparison logic.
  // The address matches if the range is valid (min < max) and the address 
  // falls within the inclusive-lower and exclusive-upper bounds.
  always_comb begin 
      match_o = (min_addr_i < max_addr_i)&&(addr_i >= min_addr_i)&&(addr_i <  max_addr_i);
  end
endmodule
