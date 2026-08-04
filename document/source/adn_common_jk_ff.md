# adn_common_jk_ff (module)

### Author : Shuparna Haque (sheikhshuparna3108@gmail.com)

## TOP IO
<img src="./adn_common_jk_ff_top.svg">

<img src="./adn_common_jk_ff_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic||Active-low asynchronous reset|
|clk_i|input|logic||Clock input|
|j_i|input|logic||J input (Set control)|
|k_i|input|logic||Clock input|
|q_o|output|logic||Output state|
|q_no|output|logic||Complementary output state|
## Description


### Purpose
This module implements a synchronous JK flip-flop with an active-low asynchronous reset. It provides the standard JK flip-flop functionality: holding the state, resetting to 0, setting to 1, or toggling the output based on the J and K inputs on the rising edge of the clock.

### Use Case
This module is primarily used in digital logic designs requiring state storage with flexible control logic. Common applications include:
- **Frequency Dividers:** Utilizing the toggle mode (J=1, K=1) to divide the clock frequency.
- **State Machines:** Serving as a fundamental building block for sequential controllers.
- **Counters:** Implementing binary or non-binary counters where specific set/reset/toggle behaviors are required.
- **Control Registers:** Managing status flags that need to be set, cleared, or toggled based on system events.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

<br>**This file is part of https://github.com/ADN-VLSI/adn_common**
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

