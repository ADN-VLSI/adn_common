# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Width of data bus|
|ADDR_WIDTH|int||8|Address width (determines depth as 2^ADDR_WIDTH)|
|SYNC_STAGES|int||2|Number of synchronization stages for CDC|
|ALMOST_FULL_THRESH|int||(1 << ADDR_WIDTH) - 2|Threshold for almost full flag|
|ALMOST_EMPTY_THRESH|int||2|Threshold for almost empty flag|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wr_clk_i|input|logic||Write domain clock|
|wr_rst_n_i|input|logic||Active-low write domain reset|
|wr_en_i|input|logic||Write enable|
|wr_data_i|input|logic [DATA_WIDTH-1:0]||Write data input|
|full_o|output|logic||FIFO full flag|
|almost_full_o|output|logic||FIFO almost full flag|
|wr_count_o|output|logic [ ADDR_WIDTH:0]||Write domain occupancy count|
|rd_clk_i|input|logic||Read domain clock|
|rd_rst_n_i|input|logic||Active-low read domain reset|
|rd_en_i|input|logic||Read enable|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||Read data output|
|empty_o|output|logic||FIFO empty flag|
|almost_empty_o|output|logic||FIFO almost empty flag|
|rd_count_o|output|logic [ ADDR_WIDTH:0]||Read domain occupancy count|
## Description


This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for clock domain crossing (CDC) applications. It utilizes Gray-coded pointers to ensure safe data transfer between independent write and read clock domains, preventing metastability issues. The design includes configurable depth, data width, and programmable almost-full/almost-empty thresholds to optimize system throughput and latency.

### Usage

To use this module, instantiate it in your RTL and connect the write and read clock domains separately.

```systemverilog
adn_common_cdc_fifo #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8)
) u_fifo (
    .wr_clk_i(clk_a),
    .wr_rst_n_i(rst_n_a),
    .wr_en_i(wr_en),
    .wr_data_i(data_in),
    .full_o(full),
    .rd_clk_i(clk_b),
    .rd_rst_n_i(rst_n_b),
    .rd_en_i(rd_en),
    .rd_data_o(data_out),
    .empty_o(empty)
);
```

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | YYYY-MM-DD | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

