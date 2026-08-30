# adn_common_encoder (module)

### Author: Foez Ahmed (foez.official@gmail.com)

### Source: adn_common_encoder.sv

## Top IO

<img src="./adn_common_encoder_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|NUM_WIRE|int||16|Total number of input wires to be encoded|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wire_in|input|logic [NUM_WIRE-1:0]||Input vector to be priority encoded|
|index_o|output|logic [$clog2(NUM_WIRE)-1:0]||Encoded binary index output|
|index_valid_o|output|logic||High when at least one input wire is active|


## Description

### Purpose
This module implements a priority encoder that converts a multi-bit input vector into its corresponding binary index. It identifies the position of the active bit and provides a validity signal to indicate if any input wire is asserted.

### Use Case
This module is primarily used in arbitration logic, interrupt controllers, and resource allocation systems where multiple request lines exist, and the system needs to determine the highest-priority active request to grant access to a shared resource. It is highly efficient for mapping sparse one-hot or multi-bit signals into a compact binary representation for downstream address decoding or state machine transitions.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-29 | Foez Ahmed      | Initial version                                        |
| 1.0      | 2026-08-29 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
