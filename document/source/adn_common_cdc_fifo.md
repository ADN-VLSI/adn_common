# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

<img src="./adn_common_cdc_fifo_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Width of the data bus|
|ADDR_WIDTH|int||8|Address width (FIFO depth = 2^ADDR_WIDTH)|
|SYNC_STAGES|int||2|Number of synchronization stages for CDC|
|ALMOST_FULL_THRESH|int||(1 << ADDR_WIDTH) - 2|Threshold for almost_full_o flag|
|ALMOST_EMPTY_THRESH|int||2|Threshold for almost_empty_o flag|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wr_clk_i|input|logic||Write domain clock|
|wr_rst_n_i|input|logic||Active-low asynchronous reset|
|wr_en_i|input|logic||Write enable|
|wr_data_i|input|logic [DATA_WIDTH-1:0]||Data input bus|
|full_o|output|logic||FIFO full flag|
|almost_full_o|output|logic||FIFO almost full flag|
|wr_count_o|output|logic [ ADDR_WIDTH:0]||Write domain occupancy count|
|rd_clk_i|input|logic||Read domain clock|
|rd_rst_n_i|input|logic||Active-low asynchronous reset|
|rd_en_i|input|logic||Read enable|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||Data output bus|
|empty_o|output|logic||FIFO empty flag|
|almost_empty_o|output|logic||FIFO almost empty flag|
|rd_count_o|output|logic [ ADDR_WIDTH:0]||Read domain occupancy count|
## Description


### Purpose
The `adn_common_cdc_fifo` module provides a robust, asynchronous First-In-First-Out (FIFO) buffer designed for safe data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to prevent metastability issues, ensuring reliable data crossing while providing status flags (full, empty, almost full, almost empty) and occupancy counts for flow control.

### Usage
To use this module, instantiate it in your design by specifying the `DATA_WIDTH` and `ADDR_WIDTH` (which determines the FIFO depth as $2^{ADDR\_WIDTH}$). Connect the write-side signals to your producer clock domain and the read-side signals to your consumer clock domain. Ensure that the reset signals are asserted appropriately for each domain. The module automatically handles pointer synchronization and provides status flags to prevent overflow and underflow conditions.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-07-29 | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

