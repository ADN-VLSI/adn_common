# adn_common_pipeline_split (module)

### Author: Foez Ahmed (foez.official@gmail.com)

### Source: adn_common_pipeline_split.sv

## Top IO

<img src="./adn_common_pipeline_split_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Data bus width|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic||Active-low asynchronous reset|
|clk_i|input|logic||Rising-edge clock|
|data_in_i|input|logic [DATA_WIDTH-1:0]||Input data|
|data_in_valid_i|input|logic||Input data valid|
|data_in_ready_o|output|logic||Input ready|
|data_out_primary_o|output|logic [DATA_WIDTH-1:0]||Output data|
|data_out_primary_valid_o|output|logic||Output data valid|
|data_out_primary_ready_i|input|logic||Output ready|
|data_out_secondary_o|output|logic [DATA_WIDTH-1:0]||Output data|
|data_out_secondary_valid_o|output|logic||Output data valid|
|data_out_secondary_ready_i|input|logic||Output ready|


## Description

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-06 | Foez Ahmed | Initial version                                        |
| 1.0      | 2026-08-06 | Foez Ahmed | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
