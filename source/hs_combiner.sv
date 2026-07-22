/*
# Handshake Combiner Module

This module acts as a synchronization bridge that combines multiple handshake interfaces. It asserts output valid and ready signals only when all input valid and ready signals are high, ensuring atomic transaction completion across the combined interface.

## Usage

The `hs_combiner` is used to aggregate multiple independent handshake channels into a single synchronized interface. 

1. **Instantiation**: Set `NUM_TX` to match the number of source interfaces and `NUM_RX` to match the number of destination interfaces.
2. **Connectivity**: Connect the `valid_i` and `ready_o` ports to the source side, and `valid_o` and `ready_i` to the destination side.
3. **Behavior**: The module performs a logical AND reduction on all input signals. A transaction is only considered valid and ready to proceed when every bit in the input vectors is asserted high.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-22 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module hs_combiner #(
    parameter int NUM_TX = 2, // Number of source handshake interfaces
    parameter int NUM_RX = 2  // Number of destination handshake interfaces
) (
    input  logic [NUM_TX-1:0] valid_i, // Input valid signals from sources
    output logic [NUM_TX-1:0] ready_o, // Output ready signals to sources

    output logic [NUM_RX-1:0] valid_o, // Output valid signals to destinations
    input  logic [NUM_RX-1:0] ready_i  // Input ready signals from destinations
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Combinational logic block to synchronize handshake signals across interfaces
  always_comb begin
    logic ok_v; // Aggregated valid status
    logic ok_r; // Aggregated ready status
    logic ok;   // Global handshake synchronization flag
    
    // Perform AND reduction on all input valid and ready signals
    ok_v = &valid_i;
    ok_r = &ready_i;
    
    // Transaction proceeds only if both valid and ready conditions are met globally
    ok = ok_v & ok_r;
    
    // Drive output signals based on the synchronized global status
    valid_o = ok ? '1 : '0;
    ready_o = ok ? '1 : '0;
  end

endmodule
