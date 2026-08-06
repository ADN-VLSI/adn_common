# adn_common_hs_combiner (module)

### Author: Foez Ahmed (foez.official@gmail.com)

### Source: adn_common_hs_combiner.sv

## Top IO

<img src="./adn_common_hs_combiner_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|NUM_TX|int||2|Number of input handshake channels|
|NUM_RX|int||2|Number of output handshake channels|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|valid_i|input|logic [NUM_TX-1:0]||Input valid signals from source|
|ready_o|output|logic [NUM_TX-1:0]||Output ready signals back to source|
|valid_o|output|logic [NUM_RX-1:0]||Output valid signals to destination|
|ready_i|input|logic [NUM_RX-1:0]||Input ready signals from destination|


## Description

# Handshake Combiner Module

This module serves as a synchronization and aggregation unit that combines multiple handshake interfaces. It ensures that data transmission only proceeds when all input valid signals and all output ready signals are simultaneously asserted, effectively acting as a multi-channel AND-gate for handshake protocols.

## Use Case
The `adn_common_hs_combiner` is primarily used in high-performance interconnects and data-path pipelines where multiple independent data streams must be synchronized before being processed by a downstream consumer. By aggregating multiple handshake channels, it simplifies control logic in complex SoC architectures, ensuring that data-flow integrity is maintained across multi-channel interfaces without requiring individual state machines for every signal pair.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-22 | Foez Ahmed      | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

Author : Foez Ahmed (foez.official@gmail.com)
