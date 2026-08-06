/*

FILE: valid_ready.svh

### Purpose
Checks for valid-ready handshake protocol compliance. This file is intended to be included in
SystemVerilog modules or testbenches to provide assertions that verify the correct behavior of
valid-ready handshake signals. The assertions ensure that the valid and ready signals adhere to the
expected protocol, preventing data corruption and ensuring proper communication between modules.

### Use Case
This file is included in SystemVerilog modules or testbenches that implement valid-ready handshake
protocols. By including this file, designers can automatically check for compliance with the
valid-ready handshake protocol, ensuring that the valid and ready signals behave as expected. The
assertions provided in this file help catch potential issues early in the design and verification
process, improving the reliability and robustness of the system.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-08-06 | Foez Ahmed      | Stable release                                         |
| 1.1      | 2026-08-06 | Foez Ahmed      | Ratified                                               |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of https://github.com/ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add description of the arguments of the following macro
`define VALID_READY_ASSERTION_CHECKS(__ARST_N__, __CLK__, __BUS__, __VALID__, __READY__)                                 \
                                                                                                                         \
  assert property                                                                                                        \
    (@(posedge ``__CLK__``) disable iff (!``__ARST_N__)                                                                  \
    (``__VALID__`` && !``__READY__``) |=> $stable(``__BUS__``))                                                          \
  else                                                                                                                   \
    $error(`"ASSERTION FAILED: ``__BUS__`` should remain stable when ``__VALID__`` is high and ``__READY__`` is low`");  \
                                                                                                                         \
  assert property                                                                                                        \
    (@(posedge ``__CLK__``) disable iff (!``__ARST_N__)                                                                  \
    ($past(``__VALID__``) && !``__VALID__``) |=> $past(``__READY__``,2))                                                 \
  else                                                                                                                   \
    $error(`"ASSERTION FAILED: ``__READY__`` should be high when ``__VALID__`` goes low`");                              \
                                                                                                                         \
  assert property                                                                                                        \
    (@(negedge ``__ARST_N__``) !``__VALID__``)                                                                           \
  else                                                                                                                   \
    $error(`"ASSERTION FAILED: ``__VALID__`` must be low when reset is asserted`");                                      \
                                                                                                                         \
  assert property                                                                                                        \
    (@(negedge ``__ARST_N__``) !``__READY__``)                                                                           \
  else                                                                                                                   \
    $error(`"ASSERTION FAILED: ``__READY__`` must be low when reset is asserted`");                                      \

