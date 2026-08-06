# adn_common_address_range_compare (module)

### Author: Adnan Sami Anirban (adnananirban259@gmail.com)

### Source: adn_common_address_range_compare.sv

## Top IO

<img src="./adn_common_address_range_compare_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|ADDR_WIDTH|int||32||


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|min_addr_i|input|logic [ADDR_WIDTH-1:0]|||
|max_addr_i|input|logic [ADDR_WIDTH-1:0]|||
|addr_i|input|logic [ADDR_WIDTH-1:0]|||
|match_o|output|logic|||


## Description

### Purpose
This module performs a range comparison to determine if a given address falls within a specified inclusive-minimum and exclusive-maximum range. It is designed to be used in memory-mapped systems or address decoding logic to validate address access.

### Usage
To use this module, instantiate it by specifying the `ADDR_WIDTH` parameter to match your system's address bus width. Connect the lower bound of the range to `min_addr_i`, the upper bound (exclusive) to `max_addr_i`, and the address to be checked to `addr_i`. The `match_o` output will assert high if `min_addr_i <= addr_i < max_addr_i`.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-30 | Adnan Sami Anirban | Stable release                                         |

Author : Adnan Sami Anirban (adnananirban259@gmail.com)
