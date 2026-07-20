/*

### Purpose
The `adn_common_pipeline` module implements a single-stage pipeline register with a standard ready/valid handshake protocol. It acts as a buffer to decouple timing paths between upstream and downstream modules, allowing for improved clock frequency by inserting a register stage in the data path while maintaining flow control.

### Usage
To use this module, instantiate it between two modules communicating via a ready/valid interface. Connect the upstream module's `data`, `valid`, and `ready` signals to the `data_in_*` ports, and the downstream module's signals to the `data_out_*` ports. The module will automatically buffer one word of data, asserting `data_in_ready_o` when it is ready to accept new data and driving `data_out_valid_o` when it has data ready for the downstream consumer.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-20 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of https://github.com/ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/


module adn_common_pipeline #(
    parameter int DATA_WIDTH = 32  // Data bus width
) (
    // Clock and Reset
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // Rising-edge clock

    // Input (Upstream) Interface
    input  logic [DATA_WIDTH-1:0] data_in_i,        // Input data
    input  logic                  data_in_valid_i,  // Input data valid
    output logic                  data_in_ready_o,  // Input ready (backpressure to upstream)

    // Output (Downstream) Interface
    output logic [DATA_WIDTH-1:0] data_out_o,        // Output data
    output logic                  data_out_valid_o,  // Output data valid
    input  logic                  data_out_ready_i   // Output ready (backpressure from downstream)
);

  // ---------------------------------------------------------------------------
  // Internal Registers / State
  // ---------------------------------------------------------------------------
  logic [DATA_WIDTH-1:0] data_reg;  // Pipeline data register

  logic                  is_full;  // Pipeline full flag (valid data in data_reg)
  logic                  is_full_next;  // Next-state logic for is_full

  // ---------------------------------------------------------------------------
  // Combinational Logic: Ready/Valid Handshake
  // ---------------------------------------------------------------------------
  // Input ready when pipeline not full, or when full and downstream is ready
  always_comb data_in_ready_o = is_full ? data_out_ready_i : '1;

  // Output data comes from pipeline register
  always_comb data_out_o = data_reg;

  // Output valid when pipeline is full
  always_comb data_out_valid_o = is_full;

  // Next-state logic for pipeline full flag
  // Set when valid input accepted, clear when downstream ready and pipeline full
  always_comb is_full_next = data_in_valid_i ? '1 : (data_out_ready_i ? '0 : is_full);

  // ---------------------------------------------------------------------------
  // Sequential Logic: State Registers
  // ---------------------------------------------------------------------------
  // Pipeline full flag with async active-low reset
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      is_full <= '0;
    end else begin
      is_full <= is_full_next;
    end
  end

  // Data register: capture input when valid and ready (pipeline not full)
  always_ff @(posedge clk_i) begin
    if (arst_ni & data_in_valid_i & data_in_ready_o) begin
      data_reg <= data_in_i;
    end
  end

endmodule
