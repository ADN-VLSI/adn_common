# adn_common_ring_counter (module)

### Author: Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)

### Source: adn_common_ring_counter.sv

## Top IO

<img src="./adn_common_ring_counter_top.svg">

<img src="./adn_common_ring_counter_des.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|DATA_WIDTH|int||4|DATA_WIDTH defines the number of bits in the ring counter|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|clk_i|input|logic|||
|arst_ni|input|logic|||
|enable_i|input|logic|||
|data_o|output|logic [DATA_WIDTH-1:0]|||


## Description

The `adn_common_ring_counter` module implements a synchronous one-hot ring counter. It rotates a single high bit through a register of a configurable width, providing a circular shift operation that is useful for state machine sequencing, token passing, or simple pulse generation.

### Use Cases
- **Round-Robin Arbitration**: Distributing access to a shared resource among multiple requesters.
- **Time-Division Multiplexing (TDM)**: Generating control signals to enable different data paths in a sequential manner.
- **Pulse Train Generation**: Creating periodic pulses for triggering events at specific clock cycles.
- **State Machine Sequencing**: Implementing simple, low-overhead state machines where each state is represented by a single bit.

- **`clk_i`**: Connect to the system clock.
- **`arst_ni`**: Connect to an active-low asynchronous or synchronous reset. Upon reset, the counter initializes to `100...0`.
- **`enable_i`**: When high, the counter shifts the high bit to the next position on the rising edge of the clock.
- **`data_o`**: The one-hot encoded output vector.

| REVISION | DATE       | AUTHOR                 | DESCRIPTION                                     |
|----------|------------|------------------------|-------------------------------------------------|
| 0.1      | 2026-07-30 | Md. Sakib Hasan Shawon | Initial version                                 |
| 1.0      | 2026-07-30 | Md. Sakib Hasan Shawon | Stable release                                  |
| 1.1      | 2026-08-01 | Foez Ahmed             | Ratified                                        |

Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)
