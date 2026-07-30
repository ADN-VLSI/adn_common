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
module adn_common_address_decoder #(

    parameter int ADDR_WIDTH     = 32,
    parameter int SLAVE_ID_WIDTH = 4,
    parameter int NUM_RULES      = 4

)(

    input logic [ADDR_WIDTH-1:0]      addr_i,
    input logic [ADDR_WIDTH-1:0]      min_addr_i [0:NUM_RULES-1],
    input logic [ADDR_WIDTH-1:0]      max_addr_i [0:NUM_RULES-1],
    input logic [SLAVE_ID_WIDTH-1:0]  slave_id_i [0:NUM_RULES-1],

    output logic [SLAVE_ID_WIDTH-1:0] slave_index_o,
    output logic                      addr_found_o

);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
    logic [NUM_RULES-1:0] match;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  generate
    for(genvar i = 0; i < NUM_RULES; i++)
    begin : GEN_ADDRESS_COMPARE
        adn_common_address_range_compare #(
            .ADDR_WIDTH    (ADDR_WIDTH)
        )
        u_address_range_compare
        (
            .min_addr_i    (min_addr_i[i]),
            .max_addr_i    (max_addr_i[i]),
            .addr_i        (addr_i),
            .match_o       (match[i])
        );
    end
  endgenerate

  adn_common_priority_selector #(
      .NUM_RULES         (NUM_RULES),
      .SLAVE_ID_WIDTH    (SLAVE_ID_WIDTH)
  )
  u_priority_selector
  (
      .match_i           (match),
      .slave_id_i        (slave_id_i),
      .slave_index_o     (slave_index_o),
      .addr_found_o      (addr_found_o)
  );
endmodule
