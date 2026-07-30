# adn_common_priority_encoder (module)

### Author : Shykul Islam Siam (shykulislam32@gmail.com)

## TOP IO
<img src="./adn_common_priority_encoder_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|NUM_WIRE|int||4|Number of input wires; must be at least two.|
|HIGH_INDEX_PRIORITY|bit||0|When set, the highest asserted input has priority.|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|d_i|input|logic [ NUM_WIRE-1:0]||Input bits to encode.|
|addr_o|output|logic [$clog2(NUM_WIRE)-1:0]||Address of the selected input bit.|
|addr_valid_o|output|logic||Indicates that at least one input is asserted.|
## Description


### Purpose

The `adn_common_priority_encoder` selects one asserted bit from `d_i` using fixed priority and
converts that one-hot selection to an address. `HIGH_INDEX_PRIORITY` chooses whether the highest
or lowest asserted input bit wins. The priority mask is built from explicit AND/De Morgan logic
before being encoded.

### Usage

Set `NUM_WIRE` to the number of input bits and `HIGH_INDEX_PRIORITY` to select which end of `d_i`
wins ties. Drive `d_i`; `addr_o` reports the winning bit's index when `addr_valid_o` is high.

| REVISION | DATE       | AUTHOR             | DESCRIPTION     |
|----------|------------|--------------------|-----------------|
| 0.1      | 2026-07-30 | Shykul Islam Siam  | Initial version |
| 1.0      | 2026-07-30 | Shykul Islam Siam  | Stable release  |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

