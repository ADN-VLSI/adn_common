# adn_common_fifo (module)

### Author : Annim Jannat (jannatannim@gmail.com)

## TOP IO
<img src="./adn_common_fifo_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||8||
|FIFO_SIZE|int||2||
|PIPELINED|bit||1||

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic|||
|clk_i|input|logic|||
|data_in_i|input|logic [DATA_WIDTH-1:0]|||
|data_in_valid_i|input|logic|||
|data_in_ready_o|output|logic|||
|data_out_o|output|logic [DATA_WIDTH-1:0]|||
|data_out_valid_o|output|logic|||
|data_out_ready_i|input|logic|||
|count_o|output|logic [(2**FIFO_SIZE):0]|||
## Description


@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim Jannat    | Initial version                                        |
| 1.0      | 2026-07-28 | Annim Jannat    | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

