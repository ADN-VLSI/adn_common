# adn_common_pipeline (module)

### Author: Foez Ahmed (foez.official@gmail.com)

### Source: adn_common_pipeline.sv

## Top IO

<img src="./adn_common_pipeline_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Data bus width|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic||Active-low asynchronous reset|
|clk_i|input|logic||Rising-edge clock|
|data_in_i|input|logic [DATA_WIDTH-1:0]||Input data|
|data_in_valid_i|input|logic||Input data valid|
|data_in_ready_o|output|logic||Input ready (backpressure to upstream)|
|data_out_o|output|logic [DATA_WIDTH-1:0]||Output data|
|data_out_valid_o|output|logic||Output data valid|
|data_out_ready_i|input|logic||Output ready (backpressure from downstream)|


## Description

### Purpose
The `adn_common_pipeline` module implements a single-stage pipeline register with a standard ready/valid handshake protocol. It acts as a buffer to decouple timing paths between upstream and downstream modules, allowing for improved clock frequency by inserting a register stage in the data path while maintaining flow control.

### Use Case
This module is primarily used in high-speed digital designs to break long combinational paths. By inserting this pipeline stage between two modules, you can effectively "cut" the critical path, allowing the design to meet tighter timing constraints. It is ideal for:
- **Inter-module communication:** Buffering data between modules operating on different logic levels or physical distances.
- **Backpressure handling:** Managing data flow when the downstream module is temporarily unable to accept new data (e.g., due to a full FIFO or busy state).
- **Timing closure:** Improving the maximum operating frequency ($F_{max}$) of the design by adding a single cycle of latency in exchange for a shorter combinational path.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-20 | Foez Ahmed      | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

Author : Foez Ahmed (foez.official@gmail.com)
