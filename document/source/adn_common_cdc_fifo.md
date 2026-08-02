# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_cdc_fifo_top.svg">

<img src="./adn_common_cdc_fifo_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||8|Width of the data bus|
|FIFO_SIZE|int||2|Log2 of the FIFO depth|
|SYNC_STAGES|int||2|Number of synchronization stages|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|data_in_arst_ni|input|logic||Asynchronous reset, active low (input domain)|
|data_in_clk_i|input|logic [DATA_WIDTH-1:0]||Clock signal for the input domain|
|data_in_i|input|logic [DATA_WIDTH-1:0]||Data input bus|
|data_in_valid_i|input|logic||Valid signal for input data|
|data_in_ready_o|output|logic||Ready signal for input data|
|data_in_count_o|output|logic [ FIFO_SIZE:0]||Current occupancy count (input domain)|
|data_out_arst_ni|input|logic||Asynchronous reset, active low (output domain)|
|data_out_clk_i|output|logic [DATA_WIDTH-1:0]||Clock signal for the output domain|
|data_out_o|output|logic [DATA_WIDTH-1:0]||Data output bus|
|data_out_valid_o|output|logic||Valid signal for output data|
|data_out_ready_i|input|logic||Ready signal for output data|
|data_out_count_o|output|logic [ FIFO_SIZE:0]||Current occupancy count (output domain)|
## Description


### Purpose
This module implements a Clock Domain Crossing (CDC) FIFO, designed to safely transfer data between two independent clock domains using Gray-coded pointers and multi-stage synchronizers to prevent metastability.

### Use Case
The `adn_common_cdc_fifo` is primarily used in digital systems where data must be passed between modules operating on different, asynchronous clock frequencies. By utilizing Gray-coded pointers, it ensures that only one bit changes at a time during pointer synchronization, effectively mitigating the risk of metastability that typically occurs when sampling signals across clock boundaries. It is ideal for streaming data interfaces, buffer management in high-speed communication protocols, and decoupling producer-consumer throughput variations.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-29 | Ahasan Ullah Khalid | Stable release                                     |
| 1.1      | 2026-08-02 | Foez Ahmed          | Ratified                                           |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

