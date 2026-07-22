/*
# Handshake Combiner Module

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-22 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module hs_combiner #(
    parameter int NUM_TX = 2,
    parameter int NUM_RX = 2
) (
    input  logic [NUM_TX-1:0] valid_i,
    output logic [NUM_TX-1:0] ready_o,

    output logic [NUM_RX-1:0] valid_o,
    input  logic [NUM_RX-1:0] ready_i
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    logic ok_v;
    logic ok_r;
    logic ok;
    ok_v = &valid_i;
    ok_r = &ready_i;
    ok = ok_v & ok_r;
    valid_o = ok ? '1 : '0;
    ready_o = ok ? '1 : '0;
  end

endmodule

