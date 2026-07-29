# adn_common_edge_detect (module)

### Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)

## TOP IO

<img src="./adn_common_edge_detect_top.svg">

<img src="./adn_common_edge_detect_des.svg">

## Parameters

| Name      | Type | Dimension | Default Value | Description                                                          |
| --------- | ---- | --------- | ------------- | -------------------------------------------------------------------- |
| EDGE_TYPE | int  |           | 0             | Edge detection mode: 0 : Rising edge 1 : Falling edge 2 : Both edges |

## Ports

| Name       | Direction | Type  | Dimension | Description                                                          |
| ---------- | --------- | ----- | --------- | -------------------------------------------------------------------- |
| clk        | input     | logic |           | System clock.                                                        |
| rst_n      | input     | logic |           | Active-low synchronous reset.                                        |
| signal_in  | input     | logic |           | Input signal to monitor for edge transitions.                        |
| edge_pulse | output    | logic |           | One-clock-cycle pulse asserted when the configured edge is detected. |

## Description

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR                 | DESCRIPTION     |
| -------- | ---------- | ---------------------- | --------------- |
| 0.1      | 2026-07-27 | Md. Sakib Hasan Shawon | Initial version |
| 1.0      | 2026-07-28 | Md. Sakib Hasan Shawon | Stable release  |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
