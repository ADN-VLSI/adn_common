/*

### Purpose
This module implements a synchronous dual-port RAM with independent read and write clock domains. It supports configurable data width, address depth, and an optional output pipeline register to balance between latency and timing performance.

### Usage
To instantiate this module, define the `DATA_WIDTH` and `ADDR_WIDTH` parameters to match your memory requirements. Set `OUT_REG` to `1` if you require an additional pipeline stage to improve timing at the cost of one extra clock cycle of latency.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                     |

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
    input logic rst_n_i, // Active-low asynchronous reset for write domain

    // Write Port Interface
    input logic                  wr_en_i,    // Write enable signal
    input logic [ADDR_WIDTH-1:0] wr_addr_i,  // Write address
    input logic [DATA_WIDTH-1:0] wr_data_i,  // Data to be written

    // Read Port Interface
    input  logic                  rd_en_i,    // Read enable signal
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
  always_ff @(posedge clk_i) begin
    if (rst_n_i && wr_en_i) begin
      mem_core[wr_addr_i] <= wr_data_i;
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Asynchronous Read Channel: Instantly reflects changes on rd_addr_i when rd_en_i is high
  always_comb begin
    if (rd_en_i) begin
      rd_data_o = mem_core[rd_addr_i];
    end else begin
      rd_data_o = '0;
    end
  end

  // Initialize Memory Array for Simulation (Prevents 'x on unwritten reads)
`ifdef SIMULATION
  initial begin
    for (int i = 0; i < DEPTH; i++) begin
      mem_core[i] = '0;
    end
  end
`endif

endmodule
