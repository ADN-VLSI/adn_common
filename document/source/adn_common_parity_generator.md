# adn_common_parity_generator (module)

### Author: Ahasan Ullah Khalid (aukhalid02@gmail.com)

### Source: adn_common_parity_generator.sv

## Top IO

<img src="./adn_common_parity_generator_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||8|Width of the input data vector|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|num_bits_i|input|logic [$clog2(DATA_WIDTH+1):0]||Number of bits to consider|
|data_i|input|logic [ DATA_WIDTH-1:0]||Input data to calculate parity for|
|parity_type_i|input|logic||0 for even parity, 1 for odd|
|parity_o|output|logic||Calculated parity bit|


## Description

### Purpose
This module computes a parity bit for a variable-length subset of an input data vector. It supports configurable data widths and provides dynamic selection between even and odd parity modes, allowing for flexible error detection across different data packet lengths.

### Use Case
This module is intended for use in communication interfaces, bus protocols, and memory controllers that require robust data integrity verification. It is particularly useful in systems where the number of active data bits changes dynamically, enabling a single hardware instance to handle various protocol-specific parity requirements.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-08-02 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-08-09 | Ahasan Ullah Khalid | Stable release                                     |
| 1.1      | 2026-08-09 | Foez Ahmed          | Ratified                                           |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
