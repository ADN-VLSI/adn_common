# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Width of the data bus|
|ADDR_WIDTH|int||8|Address width (FIFO depth = 2^ADDR_WIDTH)|
|SYNC_STAGES|int||2|Number of synchronization stages for CDC|
|ALMOST_FULL_THRESH|int||(1 << ADDR_WIDTH) - 2|Threshold for almost_full_o signal|
|ALMOST_EMPTY_THRESH|int||2|Threshold for almost_empty_o signal|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wr_clk_i|input|logic||Write domain clock|
|wr_rst_n_i|input|logic||Active-low asynchronous reset (write domain)|
|wr_en_i|input|logic||Write enable|
|wr_data_i|input|logic [DATA_WIDTH-1:0]||Data input|
|full_o|output|logic||FIFO full flag|
|almost_full_o|output|logic||FIFO almost full flag|
|wr_count_o|output|logic [ ADDR_WIDTH:0]||Write domain data count|
|rd_clk_i|input|logic||Read domain clock|
|rd_rst_n_i|input|logic||Active-low asynchronous reset (read domain)|
|rd_en_i|input|logic||Read enable|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||Data output|
|empty_o|output|logic||FIFO empty flag|
|almost_empty_o|output|logic||FIFO almost empty flag|
|rd_count_o|output|logic [ ADDR_WIDTH:0]||Read domain data count|
## Description


This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to safely cross clock boundaries, preventing metastability issues while maintaining high throughput.

### Usage

The `adn_common_cdc_fifo` module is used to buffer data between two clock domains.

1. **Instantiation**: Connect `wr_clk_i`/`wr_rst_n_i` to the producer domain and `rd_clk_i`/`rd_rst_n_i` to the consumer domain.
2. **Writing**: Assert `wr_en_i` when `full_o` is low to push data into the FIFO.
3. **Reading**: Assert `rd_en_i` when `empty_o` is low to pop data from the FIFO.
4. **Status**: Monitor `almost_full_o` and `almost_empty_o` for flow control, and use `wr_count_o`/`rd_count_o` for depth tracking.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | YYYY-MM-DD | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

