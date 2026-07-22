# hs_combiner (module)

### Author : Foez Ahmed (foez.official@gmail.com)

## TOP IO
<img src="./hs_combiner_top.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|NUM_TX|int||2||
|NUM_RX|int||2||

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|valid_i|input|logic [NUM_TX-1:0]|||
|ready_o|output|logic [NUM_TX-1:0]|||
|valid_o|output|logic [NUM_RX-1:0]|||
|ready_i|input|logic [NUM_RX-1:0]|||
## Description

# Handshake Combiner Module

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-22 | Foez Ahmed      | Stable release                                         |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**

