# adn_common_hs_counter (module)

### Author : Annim Jannat (jannatannim@gmail.com)

## TOP IO
<img src="./adn_common_hs_counter_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DEPTH|int||8|width of the counter|
|WIDTH|int||$clog2(DEPTH)||

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||clock input|
|rst_ni|input|logic||active-low async reset|
|data_in_valid_i|input|logic||sender says data is valid (input side)|
|data_in_ready_o|output|logic||receiver says it can accept (input side)|
|data_out_valid_o|output|logic||sender says data is valid (output side)|
|data_out_ready_i|input|logic||receiver says it can accept (output side)|
|count_o|output|logic [WIDTH-1:0]||number of outstanding handshakes|
|overflow_o|output|logic||pulses if counter wraps around|
## Description


### Purpose
The `adn_common_hs_counter` module is designed to track the number of outstanding transactions in a handshake-based data path. It monitors input and output handshake signals to maintain a count of items currently in flight, providing flow control and status monitoring for data streams.

### Usage
To use this module, instantiate it in your design by specifying the `DEPTH` parameter, which defines the maximum number of outstanding transactions the counter can track. Connect the `data_in_valid_i` and `data_in_ready_o` signals to the upstream producer, and the `data_out_valid_o` and `data_out_ready_i` signals to the downstream consumer. The module will automatically manage the `count_o` signal to reflect the current occupancy and assert `overflow_o` if an attempt is made to exceed the counter's capacity.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim | Initial version                                        |
| 1.0      | 2026-07-29 | Annim | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

