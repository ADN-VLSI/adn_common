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
|arst_ni|input|logic||Active-low asynchronous reset|
|clk_i|input|logic||Clock input|
|j_i|input|logic||J input (Set control)|
|k_i|input|logic||Clock input|
|q_o|output|logic||Output state|
## Description


### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the standard JK flip-flop functionality: hold, reset, set, and toggle states based on the J and K inputs, synchronized to the rising edge of the clock.

### Usage
To use this module, instantiate it in your design and connect the `clk_i` to your system clock, `arst_ni` to your active-low reset signal, and the `j_i` and `k_i` inputs to your control logic. The `q_o` output will reflect the state of the flip-flop.

| J | K | Operation |
|---|---|-----------|
| 0 | 0 | Hold      |
| 0 | 1 | Reset     |
| 1 | 0 | Set       |
| 1 | 1 | Toggle    |

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |

<br>**This file is part of https://github.com/ADN-VLSI/adn_common**
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

