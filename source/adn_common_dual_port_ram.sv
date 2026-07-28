/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

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

// @foez-bhai, add comments to the parameters, ports
module adn_common_dual_port_ram #(
    // PARAMETERS
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    bit OUT_REG = 1'b0  // 0 = Unregistered (1 cycle latency), 1 = Registered (2 cycle latency)
) (
    // PORTS

    // Write Port Interface (Write Clock Domain)
    input logic                  wr_clk_i,
    input logic                  wr_rst_n_i,
    input logic                  wr_en_i,
    input logic [ADDR_WIDTH-1:0] wr_addr_i,
    input logic [DATA_WIDTH-1:0] wr_data_i,

    // Read Port Interface (Read Clock Domain)
    input  logic                  rd_clk_i,
    input  logic                  rd_rst_n_i,
    input  logic                  rd_en_i,
    input  logic [ADDR_WIDTH-1:0] rd_addr_i,
    output logic [DATA_WIDTH-1:0] rd_data_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////
  localparam int DEPTH = 1 << ADDR_WIDTH;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Dual-Port memory matrix array
  logic [DATA_WIDTH-1:0] mem_core[DEPTH];

  // Read pipeline registers
  logic [DATA_WIDTH-1:0] ram_data_out;
  logic [DATA_WIDTH-1:0] ram_data_reg;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Synchronous Write Channel (wr_clk_i Domain)
  always_ff @(posedge wr_clk_i) begin
    if (wr_en_i) begin
      mem_core[wr_addr_i] <= wr_data_i;
    end
  end

  // Synchronous Read Channel (rd_clk_i Domain)
  always_ff @(posedge rd_clk_i) begin
    if (!rd_rst_n_i) begin
      ram_data_out <= '0;
    end else begin
      if (rd_en_i) begin
        ram_data_out <= mem_core[rd_addr_i];
      end
    end
  end

  // Output Pipeline Register Stage (OUT_REG)
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

  // Continuous assignment output multiplexer
  assign rd_data_o = (OUT_REG) ? ram_data_reg : ram_data_out;

  // Initialize Memory Array for Simulation (Prevents 'x on unwritten reads)
`ifdef SIMULATION
  initial begin
    for (int i = 0; i < DEPTH; i++) begin
      mem_core[i] = '0;
    end
  end
`endif

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule

