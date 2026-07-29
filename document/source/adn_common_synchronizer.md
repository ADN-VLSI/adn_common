# adn_common_synchronizer (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO
<img src="./adn_common_synchronizer_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|WIDTH|int||1|Width of the data bus to be synchronized|
|STAGES|int||2|Number of flip-flop stages for metastability mitigation|
|RESET_VALUE|logic [WIDTH-1:0]||'0|Value assigned to the synchronizer stages during reset|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||Destination clock domain clock|
|rst_n_i|input|logic||Active-low asynchronous reset|
|data_i|input|logic [WIDTH-1:0]||Input data from source clock domain|
|data_o|output|logic [WIDTH-1:0]||Synchronized output data in destination clock domain|
## Description


### Purpose
The `adn_common_synchronizer` module is a generic multi-stage flip-flop synchronizer designed to safely transfer multi-bit signals across asynchronous clock domains. It mitigates metastability issues by passing the input data through a configurable number of pipeline stages before presenting it at the output.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

