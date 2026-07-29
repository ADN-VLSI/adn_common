/*

### Purpose
The `adn_common_dual_port_ram` module implements a synchronous dual-port RAM with independent clock domains for read and write operations. It supports configurable data width, address depth, and an optional output pipeline register to balance between latency and timing performance.

### Usage
To instantiate this module, connect the write interface to your write clock domain and the read interface to your read clock domain.

```systemverilog
adn_common_dual_port_ram #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(10),
    .OUT_REG(1'b1)
) u_ram (
    .wr_clk_i(clk_a),
    .wr_rst_n_i(rst_n_a),
    .wr_en_i(we),
    .wr_addr_i(addr_a),
    .wr_data_i(data_in),
    .rd_clk_i(clk_b),
    .rd_rst_n_i(rst_n_b),
    .rd_en_i(re),
    .rd_addr_i(addr_b),
    .rd_data_o(data_out)
);
```

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
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
    parameter int DATA_WIDTH = 32, // Width of the data bus in bits
    parameter int ADDR_WIDTH = 8,  // Width of the address bus in bits
    bit OUT_REG = 1'b0             // 0 = Unregistered (1 cycle latency), 1 = Registered (2 cycle latency)
) (
    // PORTS

    // Write Port Interface (Write Clock Domain)
    input logic                  wr_clk_i,   // Write clock
    input logic                  wr_rst_n_i, // Active-low asynchronous reset for write domain
    input logic                  wr_en_i,    // Write enable signal
    input logic [ADDR_WIDTH-1:0] wr_addr_i,  // Write address
    input logic [DATA_WIDTH-1:0] wr_data_i,  // Data to be written

    // Read Port Interface (Read Clock Domain)
    input  logic                  rd_clk_i,   // Read clock
    input  logic                  rd_rst_n_i, // Active-low asynchronous reset for read domain
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

  // Read pipeline registers: Intermediate storage for read data
  logic [DATA_WIDTH-1:0] ram_data_out; // Combinational/Registered output from memory core
  logic [DATA_WIDTH-1:0] ram_data_reg; // Optional output register stage

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Synchronous Write Channel (wr_clk_i Domain): Handles data storage into the memory array
  always_ff @(posedge wr_clk_i) begin
    if (wr_en_i) begin
      mem_core[wr_addr_i] <= wr_data_i;
    end
  end

  // Synchronous Read Channel (rd_clk_i Domain): Fetches data from memory array
  always_ff @(posedge rd_clk_i) begin
    if (!rd_rst_n_i) begin
      ram_data_out <= '0;
    end else begin
      if (rd_en_i) begin
        ram_data_out <= mem_core[rd_addr_i];
      end
    end
  end

  // Output Pipeline Register Stage (OUT_REG): Optional stage to improve timing closure
  always_ff @(posedge rd_clk_i) begin
    if (!rd_rst_n_i) begin
      ram_data_reg <= '0;
    end else begin
      ram_data_reg <= ram_data_out;
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Continuous assignment output multiplexer: Selects between raw read data and registered output
  assign rd_data_o = (OUT_REG) ? ram_data_reg : ram_data_out;

  // Initialize Memory Array for Simulation (Prevents 'x on unwritten reads)
`ifdef SIMULATION
  initial begin
    for (int i = 0; i < DEPTH; i++) begin
      mem_core[i] = '0;
    end
  end
`endif

endmodule
