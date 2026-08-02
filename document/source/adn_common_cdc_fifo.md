# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

<img src="./adn_common_cdc_fifo_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32| Width of the data bus|
|ADDR_WIDTH|int||8| Address width|
|SYNC_STAGES|int||2| Number of synchronization stages|
|ALMOST_FULL_THRESH|int||(1 << ADDR_WIDTH) - 2| Threshold for almost_full_o flag|
|ALMOST_EMPTY_THRESH|int||2| Threshold for almost_empty_o flag|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|wr_clk_i|input|logic||Write domain clock|
|wr_rst_n_i|input|logic||Active-low asynchronous reset for write domain|
|wr_en_i|input|logic||Write enable signal|
|wr_data_i|input|logic [DATA_WIDTH-1:0]||Data input bus|
|full_o|output|logic||FIFO full flag|
|almost_full_o|output|logic||FIFO almost full flag|
|wr_count_o|output|logic [ ADDR_WIDTH:0]||Write domain occupancy count|
|rd_clk_i|input|logic||Read domain clock|
|rd_rst_n_i|input|logic||Active-low asynchronous reset for read domain|
|rd_en_i|input|logic||Read enable signal|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||Data output bus|
|empty_o|output|logic||FIFO empty flag|
|almost_empty_o|output|logic||FIFO almost empty flag|
|rd_count_o|output|logic [ ADDR_WIDTH:0]||Read domain occupancy count|
## Description


### Purpose
The `adn_common_cdc_fifo` module implements a high-performance, asynchronous First-In-First-Out (FIFO) buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to mitigate metastability issues, ensuring robust data integrity during Clock Domain Crossing (CDC). The module provides full, empty, and programmable almost-full/almost-empty status flags, along with occupancy counters to facilitate flow control in complex digital systems.

### Use Case
This module is intended for scenarios where data must be passed between two modules operating on different clock frequencies or phases. Common use cases include:
- **Data Buffering:** Smoothing out bursts of data between a high-speed producer and a low-speed consumer.
- **Clock Domain Crossing (CDC):** Safely transferring control signals or data packets across asynchronous boundaries in SoC designs.
- **Flow Control:** Utilizing the `almost_full` and `almost_empty` flags to throttle upstream data producers or trigger downstream processing, preventing buffer overflow or underflow.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-29 | Ahasan Ullah Khalid | Stable release                                     |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

