# adn_common_edge_detect (module)

### Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)

## TOP IO
<img src="./adn_common_edge_detect_top.svg">

<img src="./adn_common_edge_detect_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|EDGE_TYPE|int||0| Edge detection mode: 0 : Rising edge 1 : Falling edge 2 : Both edges|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk|input|logic|| System clock.|
|rst_n|input|logic|| Active-low synchronous reset.|
|signal_in|input|logic|| Input signal to monitor for edge transitions.|
|edge_pulse|output|logic|| One-clock-cycle pulse asserted when the configured edge is detected.|
## Description

The `adn_common_edge_detect` module is designed to detect specific signal transitions (rising, falling, or both) on an input signal and generate a single-cycle pulse upon detection. It provides a robust and configurable solution for synchronizing and capturing edge events within a synchronous digital system.

## Usage
To use this module, instantiate it in your RTL code and set the `EDGE_TYPE` parameter according to your requirements:
- Set `EDGE_TYPE = 0` to detect rising edges.
- Set `EDGE_TYPE = 1` to detect falling edges.
- Set `EDGE_TYPE = 2` to detect both rising and falling edges.

The `edge_pulse` output will remain high for exactly one clock cycle whenever the specified transition occurs on `signal_in`. Ensure that `clk` and `rst_n` are connected to your system's global clock and reset signals respectively.

| REVISION | DATE       | AUTHOR                 | DESCRIPTION                                            |
|----------|------------|------------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Md. Sakib Hasan Shawon | Initial version                                        |
| 1.0      | 2026-07-28 | Md. Sakib Hasan Shawon | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
