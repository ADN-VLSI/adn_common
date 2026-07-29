# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Width of data bus|
|ADDR_WIDTH|int||8|Address width (depth = 2^ADDR_WIDTH)|
|SYNC_STAGES|int||2|Number of synchronizer stages|
|ALMOST_FULL_THRESH|int||(1 << ADDR_WIDTH) - 2|Threshold for almost full flag|
|ALMOST_EMPTY_THRESH|int||2|Threshold for almost empty flag|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wr_clk_i|input|logic||Write domain clock|
|wr_rst_n_i|input|logic||Write domain active-low reset|
|wr_en_i|input|logic||Write enable|
|wr_data_i|input|logic [DATA_WIDTH-1:0]||Write data input|
|full_o|output|logic||FIFO full status|
|almost_full_o|output|logic||FIFO almost full status|
|wr_count_o|output|logic [ ADDR_WIDTH:0]||Write domain data count|
|rd_clk_i|input|logic||Read domain clock|
|rd_rst_n_i|input|logic||Read domain active-low reset|
|rd_en_i|input|logic||Read enable|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||Read data output|
|empty_o|output|logic||FIFO empty status|
|almost_empty_o|output|logic||FIFO almost empty status|
|rd_count_o|output|logic [ ADDR_WIDTH:0]||Read domain data count|
## Description


This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to safely handle clock domain crossing (CDC) while providing status flags such as full, empty, almost full, and almost empty to manage data flow control.

### Usage

To use this module, instantiate it in your design by providing the desired `DATA_WIDTH` and `ADDR_WIDTH`. Connect the write-side signals (`wr_clk_i`, `wr_en_i`, `wr_data_i`) to the producer domain and the read-side signals (`rd_clk_i`, `rd_en_i`, `rd_data_o`) to the consumer domain. Ensure that reset signals are synchronized appropriately.

- **`DATA_WIDTH`**: Sets the bit-width of the data bus.
- **`ADDR_WIDTH`**: Sets the depth of the FIFO as $2^{ADDR\_WIDTH}$.
- **`SYNC_STAGES`**: Configures the number of flip-flop stages in the synchronizers to mitigate metastability.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | YYYY-MM-DD | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

