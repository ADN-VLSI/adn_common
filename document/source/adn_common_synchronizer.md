# adn_common_synchronizer (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_synchronizer_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|WIDTH|int||1| PARAMETERS|
|STAGES|int||2||
|RESET_VALUE|logic [WIDTH-1:0]||'0||

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic|| PORTS|
|rst_n_i|input|logic|||
|data_i|input|logic [WIDTH-1:0]|||
|data_o|input|logic [WIDTH-1:0]|||
## Description

The `adn_common_synchronizer` module is designed to safely transfer multi-bit or single-bit signals across different clock domains. It utilizes a configurable number of flip-flop stages to minimize the probability of metastability, ensuring reliable data sampling in the destination clock domain.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
