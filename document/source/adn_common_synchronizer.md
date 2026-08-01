# adn_common_synchronizer (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_synchronizer_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|WIDTH|int||1|Bit width of the data bus|
|STAGES|int||2|Number of synchronization stages (min 2 recommended)|
|RESET_VALUE|logic [WIDTH-1:0]||'0|Value to load during reset|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||Destination clock domain|
|arst_ni|input|logic||Active-low asynchronous reset|
|data_i|input|logic [WIDTH-1:0]||Asynchronous input data|
|data_o|output|logic [WIDTH-1:0]||Synchronized output data|
## Description


### Purpose
The `adn_common_synchronizer` module is a generic multi-stage flip-flop synchronizer designed to safely transfer asynchronous signals between different clock domains. It mitigates metastability issues by passing the input data through a configurable number of sequential stages before outputting the synchronized signal.

### Use Case
This module is primarily used when a signal originates in one clock domain and must be sampled by logic in a different clock domain. By utilizing a chain of flip-flops, it provides the necessary settling time for the signal to stabilize, effectively preventing metastability from propagating into the destination domain's logic. It is ideal for control signals, status flags, and single-bit handshaking protocols where data integrity across clock boundaries is critical.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                     |
| 1.1      | 2026-08-01 | Foez Ahmed          | Ratified                                           |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

