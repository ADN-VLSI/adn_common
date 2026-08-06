# adn_common_fifo (module)

### Author: Annim Jannat (jannatannim@gmail.com)

### Source: adn_common_fifo.sv

## Top IO

<img src="./adn_common_fifo_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||8|Width of the data bus in bits|
|FIFO_SIZE|int||2|Log2 of the FIFO depth|
|PIPELINED|bit||1|Enable pipelined mode for higher throughput|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic||Asynchronous reset, active low|
|clk_i|input|logic||System clock|
|data_in_i|input|logic [DATA_WIDTH-1:0]||Input data bus|
|data_in_valid_i|input|logic||Input data valid signal|
|data_in_ready_o|output|logic||Input ready signal (backpressure)|
|count_o|output|logic [FIFO_SIZE:0]||Current number of elements in FIFO|
|data_out_o|output|logic [DATA_WIDTH-1:0]||Output data bus|
|data_out_valid_o|output|logic||Output data valid signal|
|data_out_ready_i|input|logic||Output ready signal from consumer|


## Description

### Purpose
This module implements a configurable, synchronous First-In-First-Out (FIFO) buffer. It provides a flexible mechanism for data buffering between modules with different throughput requirements, supporting both pipelined and non-pipelined modes to optimize for either latency or throughput.

### Use Case
This FIFO is ideal for:
- **Backpressure Handling:** Acting as a shock absorber when a consumer module cannot keep up with a producer.
- **Pipelined Data Paths:** Decoupling stages in a high-performance processing pipeline to prevent stalls.
- **Burst Data Management:** Storing bursts of data to be processed at a steady rate by downstream logic.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim Jannat    | Initial version                                        |
| 1.0      | 2026-07-28 | Annim Jannat    | Stable release                                         |
| 1.1      | 2026-08-02 | Foez Ahmed      | Ratified                                               |

Author : Annim Jannat (jannatannim@gmail.com)
