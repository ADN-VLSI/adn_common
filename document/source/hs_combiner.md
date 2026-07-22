# hs_combiner (module)

### Author : Foez Ahmed (foez.official@gmail.com)

## TOP IO
<img src="./hs_combiner_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|NUM_TX|int||2|Number of source handshake interfaces|
|NUM_RX|int||2|Number of destination handshake interfaces|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|valid_i|input|logic [NUM_TX-1:0]||Input valid signals from sources|
|ready_o|output|logic [NUM_TX-1:0]||Output ready signals to sources|
|valid_o|output|logic [NUM_RX-1:0]||Output valid signals to destinations|
|ready_i|input|logic [NUM_RX-1:0]||Input ready signals from destinations|
## Description

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

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

