# adn_common_pmi_nxm_crossbar (module)

### Author: Ahasan Ullah Khalid (aukhalid02@gmail.com), Md Sakib Hasan SHawon, Md Sakhawat Hossain Sabbir, Annim Jannat

### Source: adn_common_pmi_nxm_crossbar.sv

## Top IO

<img src="./adn_common_pmi_nxm_crossbar_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|NUM_MASTERS|int||4|Number of master ports|
|NUM_SLAVES|int||4|Number of slave ports|
|ADDR_WIDTH|int||32|Width of address bus|
|DATA_WIDTH|int||32|Width of data bus|
|NUM_RULES|int||4|Number of address map rules|
|FIFO_DEPTH_LOG2|int||4|Log2 of FIFO depth for tracking|
|pmi_req_t|type||logic|PMI request struct type|
|pmi_rsp_t|type||logic|PMI response struct type|
|FIFO_SUPPORTS_SIMULTANEOUS_POP_PUSH|bit||1'b0|See "POP-AWARE READY" caveat below. Defaults to 0 (safe) until the underlying FIFO/counter components are confirmed to support simultaneous full+pop+push.|
|MID_W|int||(NUM_MASTERS > 1) ? $clog2(NUM_MASTERS) : 1|Derived parameters|
|SID_W|int||(NUM_SLAVES > 1) ? $clog2(NUM_SLAVES) : 1||
|TRACK_W|int||SID_W + 1|TRACK_W: SID bits + 1 decode-error flag bit|
|DEC_ERR_SID|logic [TRACK_W-1:0]||TRACK_W'(NUM_SLAVES)||
|REQ_PAYLOAD_W|int||ADDR_WIDTH + 1 + DATA_WIDTH + (DATA_WIDTH / 8)|Pure payload bus: maddr + mwe + mwdata + mstrb (clean separation from mreq)|
|RSP_PAYLOAD_W|int||DATA_WIDTH + 1|Response payload: mrdata + mresp|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||System clock|
|arst_ni|input|logic||Asynchronous active-low reset|
|m_req_i|input|pmi_req_t [NUM_MASTERS-1:0]||Master request inputs|
|m_rsp_o|output|pmi_rsp_t [NUM_MASTERS-1:0]||Master response outputs|
|s_req_o|output|pmi_req_t [NUM_SLAVES-1:0]||Slave request outputs|
|s_rsp_i|input|pmi_rsp_t [NUM_SLAVES-1:0]||Slave response inputs|
|min_addr_i|input|logic [ADDR_WIDTH-1:0]|[NUM_RULES]|Minimum address for each rule|
|max_addr_i|input|logic [ADDR_WIDTH-1:0]|[NUM_RULES]|Maximum address for each rule|
|slave_map_i|input|logic [ SID_W-1:0]|[NUM_RULES]|Slave ID for each rule|


## Description

### Purpose
This module implements an N-master to M-slave crossbar switch for the PMI (Protocol Memory Interface) protocol. It provides address decoding, arbitration, request routing, and response tracking to ensure strict transaction ordering and protocol compliance.

### Use Case
The `adn_common_pmi_nxm_crossbar` is designed for high-performance SoC interconnects where multiple masters (e.g., CPUs, DMA engines) need to access multiple memory-mapped slave peripherals or memory controllers simultaneously. It acts as a central switching fabric that:
- Decodes master requests based on a static address map.
- Arbitrates access to slaves using a round-robin scheme to ensure fairness.
- Maintains strict transaction ordering by tracking request-response pairs per master.
- Handles protocol-level flow control and error reporting (e.g., address decoding errors) while preventing combinational loops in the request/grant handshake.

| REVISION | DATE       | AUTHOR                                                                               | DESCRIPTION                                            |
|----------|------------|--------------------------------------------------------------------------------------|--------------------------------------------------------|
| 0.1      | 2026-09-15 | Ahasan Ullah Khalid                                                                  | Initial version                                        |
| 1.0      | 2026-09-15 | Ahasan Ullah Khalid, Md Sakib Hasan SHawon, Md Sakhawat Hossain Sabbir, Annim Jannat | Stable release                                         |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com), Md Sakib Hasan SHawon, Md Sakhawat Hossain Sabbir, Annim Jannat
