/*

### Purpose
This module generates a parity bit for a given input data vector. It supports configurable data widths and allows for dynamic selection between even and odd parity modes based on a specified number of valid bits.

### Use Case
This module is primarily used in communication interfaces and memory controllers where data integrity verification is required. By allowing dynamic selection of the number of valid bits and parity type (even/odd), it provides a flexible solution for error detection in systems handling variable-length data packets or protocols requiring specific parity schemes.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-08-02 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-08-09 | Ahasan Ullah Khalid | Stable release                                     |
| 1.1      | 2026-08-09 | Foez Ahmed          | Ratified                                           |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_parity_generator #(
    parameter int DATA_WIDTH = 8  // Width of the input data vector
) (
    input  logic [$clog2(DATA_WIDTH+1):0] num_bits_i,     // Number of bits to consider
    input  logic [        DATA_WIDTH-1:0] data_i,         // Input data to calculate parity for
    input  logic                          parity_type_i,  // 1 for even parity, 0 for odd
    output logic                          parity_o        // Calculated parity bit
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] mask;  // Bitmask to isolate valid data bits

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // @foez-bhai, add comments describing the logic behind the parity calculation and how the mask is applied to the input data. This will help future developers understand the purpose of each signal and the overall functionality of the module.
  always_comb begin
    mask[0] = data_i[0];
    for (int i = 1; i < num_bits_i; i++) begin
      mask[i] = data_i[i] ^ mask[i-1];
    end
  end

  // @foez-bhai, add comments describing the logic behind the parity calculation and how the mask is applied to the input data. This will help future developers understand the purpose of each signal and the overall functionality of the module.
  always_comb begin
    if (parity_type_i) begin
      parity_o = ~mask[num_bits_i-1];  // Even parity: invert the final mask bit
    end else begin
      parity_o = mask[num_bits_i-1];  // Odd parity: use the final mask bit directly
    end
  end

endmodule
