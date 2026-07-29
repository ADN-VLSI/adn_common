# adn_common_synchronizer (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_synchronizer_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|WIDTH|int||1|Bit width of the data bus|
|STAGES|int||2|Number of synchronization stages (min 2 recommended)|
|RESET_VALUE|logic [WIDTH-1:0]||'0|Value of the synchronizer registers during reset|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||Clock signal for the destination domain|
|rst_n_i|input|logic||Active-low asynchronous reset|
|data_i|input|logic [WIDTH-1:0]||Asynchronous input data|
|data_o|output|logic [WIDTH-1:0]||Synchronized output data|
## Description


### Purpose
The `adn_common_synchronizer` module is a parameterized multi-stage flip-flop chain designed to synchronize asynchronous input signals to a target clock domain. It effectively mitigates metastability issues by passing the input data through a configurable number of pipeline stages before presenting it at the output.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

