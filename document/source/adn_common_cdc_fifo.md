# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32| PARAMETERS|
|ADDR_WIDTH|int||8||
|SYNC_STAGES|int||2||
|ALMOST_FULL_THRESH|int||(1 << ADDR_WIDTH) - 2||
|ALMOST_EMPTY_THRESH|int||2||

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wr_clk|input|logic|| Write Clock Domain|
|wr_rst_n|input|logic|||
|wr_en|input|logic|||
|wr_data|input|logic [DATA_WIDTH-1:0]|||
|full|output|logic|||
|almost_full|output|logic|||
|wr_count|output|logic [ ADDR_WIDTH:0]|||
|rd_clk|input|logic|| Read Clock Domain|
|rd_rst_n|input|logic|||
|rd_en|input|logic|||
|rd_data|output|logic [DATA_WIDTH-1:0]|||
|empty|output|logic|||
|almost_empty|output|logic|||
|rd_count|output|logic [ ADDR_WIDTH:0]|||
## Description


This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for Clock Domain Crossing (CDC) applications. It enables reliable data transfer between two independent clock domains by utilizing Gray-coded pointers and multi-stage synchronizers to mitigate metastability issues.

### Usage

To use this module, instantiate it in your design by specifying the `DATA_WIDTH` and `ADDR_WIDTH` parameters. Ensure that `wr_clk` and `rd_clk` are connected to their respective clock domains.

```systemverilog
adn_common_cdc_fifo #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8)
) u_fifo (
    .wr_clk(clk_a),
    .wr_rst_n(rst_n_a),
    .wr_en(write_enable),
    .wr_data(data_in),
    .full(fifo_full),
    .rd_clk(clk_b),
    .rd_rst_n(rst_n_b),
    .rd_en(read_enable),
    .rd_data(data_out),
    .empty(fifo_empty)
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

