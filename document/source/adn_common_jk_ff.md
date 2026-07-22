# adn_common_jk_ff (module)

### Author : Shuparna Haque (sheikhshuparna3108@gmail.com)

## TOP IO
<img src="./adn_common_jk_ff_top.svg">

<img src="./adn_common_jk_ff_des.svg">

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|RESET_VAL|logic|1|1'b0|Initial state of the flip-flop after reset|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|j|input|logic||J input control signal|
|k|input|logic||K input control signal|
|clk_i|input|logic||Clock input signal|
|rst_ni|input|logic||Active-low asynchronous reset|
|q_o|output|logic||Output state of the flip-flop|

## Internal Signals
|Name|Type|Dimension|Description|
|-|-|-|-|
|q_next|logic||Next state logic for the flip-flop|

## Description

The `adn_common_jk_ff` module implements a standard JK flip-flop, a fundamental sequential logic building block. It captures the state based on the J and K inputs at the rising edge of the clock signal, providing a toggle functionality when both inputs are high, a hold state when both are low, and set/reset operations based on the individual input levels.

## Usage
To use this module, instantiate it in your Verilog/SystemVerilog design by connecting the `j` and `k` control inputs, the `clk_i` clock signal, and the `rst_ni` active-low asynchronous reset. The output `q_o` will reflect the internal state of the flip-flop.

Example instantiation:
```systemverilog
adn_common_jk_ff u_jk_ff (
    .j      (j_signal),
    .k      (k_signal),
    .clk_i  (clk),
    .rst_ni (rst_n),
    .q_o    (q_out)
);
```

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-05-04 | Shuparna Haque  | Stable release                                         |

<br>**This file is part of https://github.com/ADN-VLSI/adn_common**
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
