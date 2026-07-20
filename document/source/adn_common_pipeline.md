# adn_common_pipeline (module)

### Author : 

## TOP IO
<img src="./adn_common_pipeline_top.svg">

## Description


This module implements a 1-deep pipeline register (skid buffer) with a
ready/valid handshake interface on both input and output sides. It provides
backpressure handling to prevent data loss when the downstream consumer is
not ready.

## Functionality

- **Data Storage**: Holds one data word of configurable width (`DATA_WIDTH`)
- **Handshake Protocol**: Ready/valid interface on both input and output
- **Backpressure**: Propagates `ready` signal upstream when pipeline is full
- **Reset**: Active-low asynchronous reset clears the pipeline state

## Behavior

1. When pipeline is empty (`is_full = 0`):
- `data_in_ready_o` is asserted (always ready to accept data)
- On valid input, data is captured into `data_reg` and `is_full` becomes 1

2. When pipeline is full (`is_full = 1`):
- `data_out_valid_o` is asserted with `data_out_o` = `data_reg`
- `data_in_ready_o` mirrors `data_out_ready_i` (backpressure)
- When downstream asserts `data_out_ready_i`, pipeline becomes empty

## Timing

- Data is registered on the rising edge of `clk_i`
- Ready/valid signals are combinational
- Reset is asynchronous active-low

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||32|Data bus width|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic||Active-low asynchronous reset|
|clk_i|input|logic||Rising-edge clock|
|data_in_i|input|logic [DATA_WIDTH-1:0]||Input data|
|data_in_valid_i|input|logic||Input data valid|
|data_in_ready_o|output|logic||Input ready (backpressure to upstream)|
|data_out_o|output|logic [DATA_WIDTH-1:0]||Output data|
|data_out_valid_o|output|logic||Output data valid|
|data_out_ready_i|input|logic||Output ready (backpressure from downstream)|
