# adn_common_round_robin_arbiter (module)

### Author : Motasim Faiyaz (motasimfaiyaz@gmail.com)

## TOP IO
<img src="./adn_common_round_robin_arbiter_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|NUM_REQ|int||8| Number of request channels to arbitrate|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic|| Clock input|
|rst_ni|input|logic|| Active-low asynchronous reset|
|allow_req_i|input|logic|| High when the arbiter is permitted to grant a new request|
|req_i|input|logic [ NUM_REQ-1:0]|| High when the arbiter is permitted to grant a new request|
|gnt_o|output|logic [ NUM_REQ-1:0]|| One-hot grant output, original bit order|
|gnt_addr_o|output|logic [$clog2(NUM_REQ)-1:0]|| Encoded grant address, original order|
|gnt_addr_valid_o|output|logic|| High when gnt_addr_o contains a valid grant|
## Description


# Purpose
The `adn_common_round_robin_arbiter` module implements a fair, round-robin arbitration scheme to select a single requester from multiple input requests. It ensures that every requester is granted access in a rotating order, preventing starvation and ensuring equitable bandwidth distribution among all input channels.

## Usage
To use this module, instantiate it by specifying the `NUM_REQ` parameter to match the number of input request channels. The module samples `req_i` and, when `allow_req_i` is high, grants access to one requester based on the round-robin pointer.

### Example Instantiation
```systemverilog
adn_common_round_robin_arbiter #(
    .NUM_REQ(4)
) u_arbiter (
    .clk_i            (clk),
    .rst_ni           (rst_n),
    .allow_req_i      (ready_to_accept),
    .req_i            (request_bus),
    .gnt_o            (grant_one_hot),
    .gnt_addr_o       (grant_index),
    .gnt_addr_valid_o (grant_valid)
);
```

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Motasim Faiyaz | Initial version                                        |
| 1.0      | YYYY-MM-DD | Motasim Faiyaz | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

