/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-30 | Adnan Sami Anirban | Stable release                                         |

Author : Adnan Sami Anirban (adnananirban259@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_address_range_compare #(
    parameter int ADDR_WIDTH = 32
) (
    //input logic                  enable_i,
    input logic [ADDR_WIDTH-1:0] min_addr_i,
    input logic [ADDR_WIDTH-1:0] max_addr_i,
    input logic [ADDR_WIDTH-1:0] addr_i,

    output logic                 match_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
    
  //Address matches when:
  //MIN <= address < MAX
  always_comb begin 
      match_o = (min_addr_i < max_addr_i)&&(addr_i >= min_addr_i)&&(addr_i <  max_addr_i);
  end
endmodule
