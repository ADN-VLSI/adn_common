# adn_common_jk_ff (module)

### Author : Shuparna Haque (sheikhshuparna3108@gmail.com)

## TOP IO
<img src="./adn_common_jk_ff_top.svg">

<img src="./adn_common_jk_ff_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|j|input|logic|||
|k|input|logic|||
|clk_i|input|logic||Clock input|
|rst_ni|input|logic||Active-low asynchronous reset|
|q_o|output|logic||Output state|
## Description


### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the standard JK flip-flop functionality: holding the state, resetting to 0, setting to 1, or toggling the output based on the J and K inputs on the rising edge of the clock.

### Usage
To use this module, instantiate it in your design and connect the `j`, `k`, `clk_i`, and `rst_ni` signals. The `q_o` output will reflect the state of the flip-flop.
- `j=0, k=0`: Hold current state.
- `j=0, k=1`: Reset output to 0.
- `j=1, k=0`: Set output to 1.
- `j=1, k=1`: Toggle output state.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |

<br>**This file is part of https://github.com/ADN-VLSI/adn_common**
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

