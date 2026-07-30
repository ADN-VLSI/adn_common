# adn_common_fixed_priority_arbiter (module)

### Author : Shykul Islam Siam (shykulislam32@gmail.com)

## TOP IO
<img src="./adn_common_fixed_priority_arbiter_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|NUM_REQ|int||4|Number of request inputs; must be at least two.|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|allow_req_i|input|logic||Enables valid grant reporting.|
|req_i|input|logic [ NUM_REQ-1:0]||Enables valid grant reporting.|
|gnt_addr_o|output|logic [$clog2(NUM_REQ)-1:0]||Address of the selected requester.|
|gnt_addr_valid_o|output|logic||Indicates a valid selected requester.|
## Description


### Purpose

The `adn_common_fixed_priority_arbiter` arbitrates among `NUM_REQ` requesters using fixed low-index
priority. When `allow_req_i` is asserted, the lowest asserted bit in `req_i` is reported through `gnt_addr_o` and marked valid by
`gnt_addr_valid_o`.

### Usage

Set `NUM_REQ` to the number of requesters. Assert `allow_req_i` and drive `req_i`;
`gnt_addr_o` identifies the selected requester when `gnt_addr_valid_o` is high.

| REVISION | DATE       | AUTHOR             | DESCRIPTION     |
|----------|------------|--------------------|-----------------|
| 0.1      | 2026-07-30 | Shykul Islam Siam  | Initial version |
| 1.0      | 2026-07-30 | Shykul Islam Siam  | Stable release  |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

