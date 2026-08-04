# adn_common_address_decoder (module)

### Author: Adnan Sami Anirban (adnananirban259@gmail.com)

### Source: adn_common_address_decoder.sv

## Top IO

<img src="./adn_common_address_decoder_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|ADDR_WIDTH|int||32||
|SLAVE_ID_WIDTH|int||4||
|NUM_RULES|int||4||


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|addr_i|input|logic [ADDR_WIDTH-1:0]|||
|min_addr_i|input|logic [ADDR_WIDTH-1:0]|[0:NUM_RULES-1]||
|max_addr_i|input|logic [ADDR_WIDTH-1:0]|[0:NUM_RULES-1]||
|slave_id_i|input|logic [SLAVE_ID_WIDTH-1:0]|[0:NUM_RULES-1]||
|slave_index_o|output|logic [SLAVE_ID_WIDTH-1:0]|||
|addr_found_o|output|logic|||


## Description

### Purpose
The `adn_common_address_decoder` module is designed to perform address decoding by comparing an input address against a set of programmable address ranges. It identifies the corresponding slave device associated with the matched range and provides a priority-based selection mechanism to resolve overlapping address regions.

### Usage
To use this module, instantiate it by specifying the `ADDR_WIDTH`, `SLAVE_ID_WIDTH`, and `NUM_RULES`. Provide the input address via `addr_i` and define the address space mapping using the `min_addr_i`, `max_addr_i`, and `slave_id_i` arrays. The module will output the identified `slave_index_o` and a valid flag `addr_found_o` indicating if the address falls within any of the defined ranges.

| REVISION | DATE       | AUTHOR             | DESCRIPTION                                         |
|----------|------------|--------------------|-----------------------------------------------------|
| 1.0      | 2026-07-30 | Adnan Sami Anirban | Stable release                                      |

Author : Adnan Sami Anirban (adnananirban259@gmail.com)
