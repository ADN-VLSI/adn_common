# adn_common_fixed_priority_arbiter (module)

### Author : Shykul Islam Siam (shykulislam32@gmail.com)

## TOP IO
<img src="./adn_common_fixed_priority_arbiter_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|NUM_REQ|int||4|Number of request inputs to arbitrate|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|req_i|input|logic [NUM_REQ-1:0]||Request vector, higher index has higher priority|
|allow_req_i|input|logic||Global enable signal to permit granting|
|gnt_i|output|logic [NUM_REQ-1:0]||One-hot encoded grant output|
## Description


### Purpose
This module implements a fixed-priority arbiter that grants access to a resource based on the highest index request. It evaluates multiple input requests and ensures that only the request with the highest priority (highest index) is granted, provided the global allow signal is asserted.

### Usage
To use this module, instantiate it with the desired number of requests (`NUM_REQ`). Connect your request vector to `req_i` and the global enable signal to `allow_req_i`. The module will output a one-hot encoded grant vector `gnt_i` where the highest index bit set in `req_i` is granted, provided `allow_req_i` is high.

Example:
```systemverilog
adn_common_fixed_priority_arbiter #(
    .NUM_REQ(8)
) u_arbiter (
    .req_i(request_bus),
    .allow_req_i(global_enable),
    .gnt_i(grant_bus)
);
```

| REVISION | DATE       | AUTHOR             | DESCRIPTION     |
|----------|------------|--------------------|-----------------|
| 0.1      | 2026-07-30 | Shykul Islam Siam  | Initial version |
| 1.0      | 2026-07-30 | Shykul Islam Siam  | Stable release  |
| 1.1      | 2026-08-01 | Foez Ahmed         | Port Fix        |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

