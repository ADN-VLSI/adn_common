/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-08-02 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-08-02 | Ahasan Ullah Khalid | Stable release                                     |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_parity_generator #(
    parameter int DATA_WIDTH = 8
) (
    input  logic [       DATA_WIDTH-1:0] data_i,
    input  logic [clog2(DATA_WIDTH)-1:0] parity_valid_bits_i,
    input  logic                         parity_type_i,
    output logic                         parity_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] mask;
  logic [DATA_WIDTH-1:0] masked_data;
  logic                  even_parity;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    mask = '0;
    for (int i = 0; i < parity_valid_bits_i; i++) begin
      mask[i] = '1;
    end
  end
  assign masked_data = data_i & mask;
  assign even_parity = ^masked_data;
  assign parity_o = parity_type_i ? even_parity : ~even_parity;

endmodule


