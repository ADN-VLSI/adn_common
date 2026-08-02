# adn_common_edge_detect (module)

### Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)

## TOP IO
<img src="./adn_common_edge_detect_top.svg">

<img src="./adn_common_edge_detect_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|EDGE_TYPE|int||0| Edge detection mode: 0=Falling, 1=Rising, 2=Dual|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||Active-low asynchronous reset|
|rst_n_i|input|logic||Input signal to be monitored for edges|
|signal_in_i|input|logic||Output pulse indicating edge detection|
|edge_pulse_o|output|logic|| System clock input Active-low asynchronous reset Input signal to be monitored for edges Output pulse indicating edge detection|
## Description


### Purpose
This module provides a configurable edge detection mechanism for a single-bit input signal. It supports rising edge, falling edge, and dual-edge detection, generating a single-clock-cycle pulse whenever the specified transition occurs on the input signal relative to the system clock.

### Use Case
This module is primarily used in digital systems to synchronize asynchronous signals or to trigger state machine transitions based on specific signal changes. Common applications include:
- Generating a single-cycle trigger from a level-sensitive input (e.g., a button press or a status flag).
- Detecting the start of a data packet in serial communication protocols.
- Creating pulse-based control signals for counters or registers within a synchronous design.

Connect the system clock (`clk_i`), active-low reset (`rst_n_i`), and the target signal (`signal_in_i`). The `edge_pulse_o` output will assert high for exactly one clock cycle when the specified transition is detected.

| REVISION | DATE       | AUTHOR                 | DESCRIPTION                                            |
|----------|------------|------------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Md. Sakib Hasan Shawon | Initial version                                        |
| 1.0      | 2026-07-28 | Md. Sakib Hasan Shawon | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed             | Ratified                                               |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

