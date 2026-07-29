/*

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Adnan Sami Anirban | Initial version                                        |
| 1.0      | YYYY-MM-DD | Adnan Sami Anirban | Stable release                                         |

Author : Adnan Sami Anirban (adnananirban259@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/
`include "adn_common_address_decoder_pkg.sv"

module adn_common_address_decoder #(
    // PARAMETERS
    parameter int ADDR_WIDTH = adn_common_address_decoder_pkg::ADDR_DECODER_ADDR_WIDTH,
    parameter int SLV_INDEX_WIDTH = adn_common_address_decoder_pkg::ADDR_DECODER_SLV_INDEX_WIDTH,
    parameter int NUM_RULES = adn_common_address_decoder_pkg::ADDR_DECODER_NUM_RULES,
    parameter type addr_map_t = adn_common_address_decoder_pkg::addr_decoder_addr_map_t,
    parameter addr_map_t ADDR_MAP[NUM_RULES] = adn_common_address_decoder_pkg::ADDR_MAP,
    parameter bit HIGH_INDEX_PRIORITY = 0
) (
    // PORTS
    input logic [ADDR_WIDTH-1:0]        addr_i,

    output logic [SLV_INDEX_WIDTH-1:0]  slave_index_o,
    output logic                        addr_found_o
);


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  always_comb begin
    slave_index_o = '0;
    addr_found_o  = 1'b0;
    for (int i = 0; i < NUM_RULES; i++) begin
      automatic int idx = HIGH_INDEX_PRIORITY ? (NUM_RULES - 1 - i) : i;
      if (!addr_found_o && (addr_i >= ADDR_MAP[idx].lower_bound) && (addr_i < ADDR_MAP[idx].upper_bound)) begin
        slave_index_o = ADDR_MAP[idx].slave_index;
        addr_found_o  = 1'b1;
      end
    end
  end

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule
