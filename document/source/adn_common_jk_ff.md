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
|clk_i|input|logic||System clock input|
|rst_ni|input|logic||Active-low asynchronous reset|
|q_o|output|logic||Output state of the flip-flop|
## Description


### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the fundamental logic for state transitions based on the J and K inputs, supporting set, reset, hold, and toggle operations on the rising edge of the clock.

### Usage
To use this module, instantiate it in your design and connect the `j` and `k` inputs to control the state transitions, `clk_i` to your system clock, and `rst_ni` to an active-low reset signal. The output `q_o` will reflect the current state of the flip-flop.
- **Hold:** J=0, K=0
- **Reset:** J=0, K=1
- **Set:** J=1, K=0
- **Toggle:** J=1, K=1

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |

<br>**This file is part of https://github.com/ADN-VLSI/adn_common**
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

