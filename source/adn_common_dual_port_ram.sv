/*

### Purpose
This module implements a synchronous dual-port RAM with independent read and write clock domains. It supports configurable data width, address depth, and an optional output pipeline register to balance between latency and timing performance.

### Use Case
This module is designed for scenarios requiring asynchronous data buffering between two different clock domains (CDC). It is ideal for:
- **FIFO Buffers:** Acting as the storage core for asynchronous FIFOs where the producer and consumer operate at different frequencies.
- **Data Decoupling:** Buffering data streams in high-speed interfaces to prevent data loss during clock domain transitions.
- **Shared Memory:** Providing a bridge for data exchange between disparate processing units in a System-on-Chip (SoC) architecture.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                     |
| 1.1      | 2026-08-01 | Foez Ahmed          | Ratified                                           |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_dual_port_ram #(
    // PARAMETERS
    parameter int DATA_WIDTH = 32,  // Width of the data bus in bits
    parameter int ADDR_WIDTH = 8    // Width of the address bus (determines depth)
) (
    // PORTS

    //Clock/Reset
    input logic clk_i,   // Write clock
    input logic arst_ni, // Active-low asynchronous reset for write domain

    // Write Port Interface
    input logic                  wr_en_i,    // Write enable signal
    input logic [ADDR_WIDTH-1:0] wr_addr_i,  // Write address
    input logic [DATA_WIDTH-1:0] wr_data_i,  // Data to be written

    // Read Port Interface
    input  logic [ADDR_WIDTH-1:0] rd_addr_i,  // Read address
    output logic [DATA_WIDTH-1:0] rd_data_o   // Data read from memory
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Calculate total memory depth based on address width
  localparam int DEPTH = 1 << ADDR_WIDTH;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Dual-Port memory matrix array: The physical storage element
  logic [DATA_WIDTH-1:0] mem_core[DEPTH];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Synchronous Write Channel (wr_clk_i Domain): Handles data storage into the memory array
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      mem_core[wr_addr_i] <= '0;
    end else if (wr_en_i) begin
      mem_core[wr_addr_i] <= wr_data_i;
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Asynchronous Read Channel: Instantly reflects changes on rd_addr_i when rd_en_i is high
  always_comb rd_data_o = mem_core[rd_addr_i];

endmodule
