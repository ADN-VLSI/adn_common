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
The `adn_common_hs_counter` module is designed to track the number of outstanding transactions in a handshake-based data path. It monitors input and output handshake signals to maintain a count of items currently in flight, providing flow control by asserting ready/valid signals based on the counter's state.

### Usage
To use this module, instantiate it in your design by specifying the `DEPTH` parameter, which defines the maximum number of items the counter can track. Connect the `clk_i` and `rst_ni` signals for synchronization. The module monitors the input handshake (`data_in_valid_i`, `data_in_ready_o`) and output handshake (`data_out_valid_o`, `data_out_ready_i`). The `count_o` port provides the current number of items in flight, while `overflow_o` indicates if the counter has exceeded its capacity.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim | Initial version                                        |
| 1.0      | 2026-07-29 | Annim | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

