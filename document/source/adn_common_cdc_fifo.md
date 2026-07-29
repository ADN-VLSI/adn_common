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
|wr_clk_i|input|logic|| Write Clock Domain|
|wr_rst_n_i|input|logic|||
|wr_en_i|input|logic|||
|wr_data_i|input|logic [DATA_WIDTH-1:0]|||
|full_o|output|logic|||
|almost_full_o|output|logic|||
|wr_count_o|output|logic [ ADDR_WIDTH:0]|||
|rd_clk_i|input|logic|| Read Clock Domain|
|rd_rst_n_i|input|logic|||
|rd_en_i|input|logic|||
|rd_data_o|output|logic [DATA_WIDTH-1:0]|||
|empty_o|output|logic|||
|almost_empty_o|output|logic|||
|rd_count_o|output|logic [ ADDR_WIDTH:0]|||
## Description

This module implements a Clock Domain Crossing (CDC) FIFO, designed to safely transfer data between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to ensure reliable data transfer and prevent metastability issues. The module provides status flags such as full, empty, almost full, and almost empty, along with word count outputs for both the write and read domains, making it suitable for high-performance asynchronous data buffering.

## Usage
To use this module, instantiate it in your RTL design by mapping the write and read clock domains to their respective ports. Ensure that the `wr_clk_i` and `rd_clk_i` are stable and that the reset signals `wr_rst_n_i` and `rd_rst_n_i` are asserted appropriately. Data is pushed into the FIFO by asserting `wr_en_i` when `full_o` is low, and data is retrieved by asserting `rd_en_i` when `empty_o` is low. The `almost_full_o` and `almost_empty_o` flags can be used to implement flow control or backpressure mechanisms to prevent overflow or underflow conditions.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | YYYY-MM-DD | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
