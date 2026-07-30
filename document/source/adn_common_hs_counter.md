# adn_common_hs_counter (module)

### Author : Annim (jannatannim@gmail.com)

## TOP IO
<img src="./adn_common_hs_counter_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DEPTH|int||8|width of the counter|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic||clock input|
|rst_ni|input|logic||active-low async reset|
|data_in_valid_i|input|logic||sender says data is valid (input side)|
|data_in_ready_o|output|logic||receiver says it can accept (input side)|
|data_out_valid_o|output|logic||sender says data is valid (output side)|
|data_out_ready_i|input|logic||receiver says it can accept (output side)|
|count_o|output|logic [WIDTH-1:0]||number of outstanding handshakes|
|overflow_o|output|logic||pulses if counter wraps around|
## Description


@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Annim | Initial version                                        |
| 1.0      | YYYY-MM-DD | Annim | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

