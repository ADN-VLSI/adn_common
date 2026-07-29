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

The `adn_common_cdc_fifo` module is a high-performance, asynchronous First-In-First-Out (FIFO) buffer designed to safely transfer data between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to prevent metastability issues, ensuring reliable data integrity in multi-clock system-on-chip (SoC) designs.

## Usage
To use this module, instantiate it in your RTL by mapping the write-side signals to your producer clock domain and the read-side signals to your consumer clock domain. Ensure that `wr_rst_n_i` and `rd_rst_n_i` are asserted appropriately for their respective domains. Monitor `full_o` and `empty_o` to prevent overflow and underflow conditions, and utilize `almost_full_o` or `almost_empty_o` for flow control logic if required.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | YYYY-MM-DD | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
