# adn_common_dual_port_ram (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_dual_port_ram_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32| PARAMETERS|
|ADDR_WIDTH|int||8||

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wr_clk_i|input|logic|| Write Port Interface (Write Clock Domain)|
|wr_rst_n_i|input|logic|||
|wr_en_i|input|logic|||
|wr_addr_i|input|logic [ADDR_WIDTH-1:0]|||
|wr_data_i|input|logic [DATA_WIDTH-1:0]|||
|rd_clk_i|input|logic|| Read Port Interface (Read Clock Domain)|
|rd_rst_n_i|input|logic|||
|rd_en_i|input|logic|||
|rd_addr_i|input|logic [ADDR_WIDTH-1:0]|||
|rd_data_o|output|logic [DATA_WIDTH-1:0]|||
## Description


@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                     |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

