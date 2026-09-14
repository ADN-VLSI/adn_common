# adn_common_pmi_mem (module)

### Author: Foez Ahmed (foez.official@gmail.com)

### Source: adn_common_pmi_mem.sv

## Top IO

<img src="./adn_common_pmi_mem_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|pmi_req_t|type||logic|PMI request structure type|
|pmi_rsp_t|type||logic|PMI response structure type|
|LATENCY|int||5|Pipeline latency for memory access|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic||Asynchronous active-low reset|
|clk_i|input|logic||System clock|
|req_i|input|pmi_req_t||PMI request input|
|rsp_o|output|pmi_rsp_t||PMI response output|


## Description

### Purpose
This module provides a generic, latency-configurable memory interface wrapper based on the PMI (Processor Memory Interface) protocol. It facilitates read and write operations to a dual-port RAM while managing byte-level write strobes and synchronization latency.

### Use Case
This module is designed to act as a bridge between a high-level processor memory interface (PMI) and low-level physical memory primitives. It is primarily used in SoC designs where memory access latency needs to be tuned for timing closure or synchronization across clock domains. By abstracting the byte-strobe logic and providing a configurable pipeline depth, it allows designers to drop in a standard memory block without manually handling the complexities of read-modify-write cycles or synchronization stages.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-09-14 | Foez Ahmed | Initial version                                        |
| 1.0      | 2026-09-14 | Foez Ahmed | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
