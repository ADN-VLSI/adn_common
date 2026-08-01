# adn_common_dual_port_ram (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_dual_port_ram_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Width of the data bus in bits|
|ADDR_WIDTH|int||8|Width of the address bus (determines depth)|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||Write clock|
|arst_ni|input|logic||Active-low asynchronous reset for write domain|
|wr_en_i|input|logic||Write enable signal|
|wr_addr_i|input|logic [ADDR_WIDTH-1:0]||Write address|
|wr_data_i|input|logic [DATA_WIDTH-1:0]||Data to be written|
|rd_addr_i|input|logic [ADDR_WIDTH-1:0]||Read address|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||Data read from memory|
## Description


### Purpose
This module implements a synchronous dual-port RAM with independent read and write clock domains. It supports configurable data width, address depth, and an optional output pipeline register to balance between latency and timing performance.

### Usage
To instantiate this module, define the `DATA_WIDTH` and `ADDR_WIDTH` parameters to match your memory requirements. Set `OUT_REG` to `1` if you require an additional pipeline stage to improve timing at the cost of one extra clock cycle of latency.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                     |
| 1.1      | 2026-08-01 | Foez Ahmed          | Ratified                                           |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

