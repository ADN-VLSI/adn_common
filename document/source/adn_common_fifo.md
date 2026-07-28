# adn_common_fifo (module)

### Author : Annim (jannatannim@gmail.com)

## TOP IO
<img src="./adn_common_fifo_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32| //////////////////////////////////////////////////////////////////////////////////////////////// PARAMETERS ////////////////////////////////////////////////////////////////////////////////////////////////|
|DEPTH|int||16||
|ADDR_WIDTH|int||$clog2(DEPTH)| //////////////////////////////////////////////////////////////////////////////////////////////// LOCALPARAMS ////////////////////////////////////////////////////////////////////////////////////////////////|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic|| //////////////////////////////////////////////////////////////////////////////////////////////// PORTS ////////////////////////////////////////////////////////////////////////////////////////////////|
|rst_ni|input|logic|||
|wr_en_i|input|logic|||
|rd_en_i|input|logic|||
|data_i|input|logic [DATA_WIDTH-1:0]|||
|data_o|output|logic [DATA_WIDTH-1:0]|||
|full_o|output|logic|||
|empty_o|output|logic|||
|valid_o|output|logic|||
## Description


@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Annim | Initial version                                        |
| 1.0      | YYYY-MM-DD | Annim | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

