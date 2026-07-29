# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

<img src="./adn_common_cdc_fifo_des.svg">

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

The `adn_common_cdc_fifo` module provides a robust Clock Domain Crossing (CDC) First-In-First-Out (FIFO) buffer. It is designed to safely transfer data between two asynchronous clock domains using Gray-coded pointers and multi-stage synchronizers to prevent metastability issues. The module supports configurable data widths, FIFO depths, and synchronization stages, while providing status flags such as full, empty, almost full, and almost empty, along with word count indicators for both clock domains.

## Usage
To use the `adn_common_cdc_fifo` in your design, instantiate the module by mapping the write and read clock domains to their respective ports. Ensure that the `wr_clk_i` and `rd_clk_i` are stable before de-asserting the active-low resets (`wr_rst_n_i` and `rd_rst_n_i`). Data is written on the rising edge of `wr_clk_i` when `wr_en_i` is high, provided `full_o` is low. Data is read on the rising edge of `rd_clk_i` when `rd_en_i` is high, provided `empty_o` is low. The `almost_full_o` and `almost_empty_o` flags can be used to implement flow control or backpressure mechanisms.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-07-29 | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
