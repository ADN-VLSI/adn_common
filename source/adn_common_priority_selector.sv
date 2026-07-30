/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-30 | Adnan Sami Anirban | Stable release                                      |

Author : Adnan Sami Anirban (adnananirban259@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_priority_selector #(

    parameter int NUM_RULES = 4,
    parameter int SLAVE_ID_WIDTH = 4

)(

    input logic [NUM_RULES-1:0]       match_i,
    input logic [SLAVE_ID_WIDTH-1:0]  slave_id_i [0:NUM_RULES-1],

    output logic [SLAVE_ID_WIDTH-1:0] slave_index_o,
    output logic                      addr_found_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  integer i;
  always_comb begin
    slave_index_o = '0;
    addr_found_o  = 1'b0;
    for(i = 0; i < NUM_RULES; i = i + 1) begin
        if(!addr_found_o && match_i[i])
        begin
          slave_index_o = slave_id_i[i];
          addr_found_o  = 1'b1;

        end
    end
  end
endmodule


