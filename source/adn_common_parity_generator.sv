/*

### Purpose
This module generates a parity bit for a given input data vector. It supports configurable data widths and allows for dynamic selection between even and odd parity modes based on a specified number of valid bits.

### Use Case
This module is primarily used in communication interfaces and memory controllers where data integrity verification is required. By allowing dynamic selection of the number of valid bits and parity type (even/odd), it provides a flexible solution for error detection in systems handling variable-length data packets or protocols requiring specific parity schemes.

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

module adn_common_parity_generator #(
    parameter int DATA_WIDTH = 8 // Width of the input data vector
) (
    input  logic [        DATA_WIDTH-1:0] data_i,              // Input data to calculate parity for
    input  logic [$clog2(DATA_WIDTH)-1:0] parity_valid_bits_i, // Number of bits to consider for parity
    input  logic                          parity_type_i,       // 1 for even parity, 0 for odd parity
    output logic                          parity_o             // Calculated parity bit
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] mask;        // Bitmask to isolate valid data bits
  logic [DATA_WIDTH-1:0] masked_data; // Data after applying the bitmask
  logic                  even_parity; // Intermediate even parity result

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Generate a dynamic mask based on the number of valid bits specified
  always_comb begin
    mask = '0;
    for (int i = 0; i < parity_valid_bits_i; i++) begin
      mask[i] = '1;
    end
  end

  // Apply mask to input data
  assign masked_data = data_i & mask;

  // Calculate even parity using XOR reduction
  assign even_parity = ^masked_data;
  assign parity_o    = parity_type_i ? ~even_parity : even_parity;

endmodule
