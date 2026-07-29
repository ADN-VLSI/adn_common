/*

This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for clock domain crossing (CDC) applications. It utilizes Gray-coded pointers to ensure safe data transfer between independent write and read clock domains, preventing metastability issues. The design includes configurable depth, data width, and programmable almost-full/almost-empty thresholds to optimize system throughput and latency.

### Usage

To use this module, instantiate it in your RTL and connect the write and read clock domains separately.

```systemverilog
adn_common_cdc_fifo #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8)
) u_fifo (
    .wr_clk_i(clk_a),
    .wr_rst_n_i(rst_n_a),
    .wr_en_i(wr_en),
    .wr_data_i(data_in),
    .full_o(full),
    .rd_clk_i(clk_b),
    .rd_rst_n_i(rst_n_b),
    .rd_en_i(rd_en),
    .rd_data_o(data_out),
    .empty_o(empty)
);
```

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | YYYY-MM-DD | Ahasan Ullah Khalid | Stable release                                         |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez---bhai, add comments to the parameters, ports
module adn_common_cdc_fifo #(

    //PARAMETERS
    parameter int DATA_WIDTH = 32,                     // Width of data bus
    parameter int ADDR_WIDTH = 8,                      // Address width (determines depth as 2^ADDR_WIDTH)
    parameter int SYNC_STAGES = 2,                     // Number of synchronization stages for CDC
    parameter int ALMOST_FULL_THRESH = (1 << ADDR_WIDTH) - 2, // Threshold for almost full flag
    parameter int ALMOST_EMPTY_THRESH = 2              // Threshold for almost empty flag

) (
    // PORTS

    //Write Clock Domain
    input  logic                  wr_clk_i,            // Write domain clock
    input  logic                  wr_rst_n_i,          // Active-low write domain reset
    input  logic                  wr_en_i,             // Write enable
    input  logic [DATA_WIDTH-1:0] wr_data_i,           // Write data input
    output logic                  full_o,              // FIFO full flag
    output logic                  almost_full_o,       // FIFO almost full flag
    output logic [  ADDR_WIDTH:0] wr_count_o,          // Write domain occupancy count

    //Read Clock Domain
    input  logic                  rd_clk_i,            // Read domain clock
    input  logic                  rd_rst_n_i,          // Active-low read domain reset
    input  logic                  rd_en_i,             // Read enable
    output logic [DATA_WIDTH-1:0] rd_data_o,           // Read data output
    output logic                  empty_o,             // FIFO empty flag
    output logic                  almost_empty_o,      // FIFO almost empty flag
    output logic [  ADDR_WIDTH:0] rd_count_o           // Read domain occupancy count
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int PtrWidth = ADDR_WIDTH + 1;            // Pointer width (includes wrap-around bit)

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //Local Reset Syncronizers
  logic                wr_rst_n_int;                   // Synchronized write reset
  logic                rd_rst_n_int;                   // Synchronized read reset

  //Write Domain Pointers
  logic [PtrWidth-1:0] wr_ptr_bin;                     // Write pointer (binary)
  logic [PtrWidth-1:0] wr_ptr_bin_next;                // Next write pointer (binary)
  logic [PtrWidth-1:0] wr_ptr_gray;                    // Write pointer (Gray code)
  logic [PtrWidth-1:0] wr_ptr_gray_next;               // Next write pointer (Gray code)
  logic [PtrWidth-1:0] wr_ptr_gray_rdclk;              // Write pointer synced to read domain
  logic [PtrWidth-1:0] wr_ptr_bin_rdclk;               // Write pointer (binary) synced to read domain
  logic                wr_en_qualified;                // Write enable gated by full status

  //Read Domain Pointers
  logic [PtrWidth-1:0] rd_ptr_bin;                     // Read pointer (binary)
  logic [PtrWidth-1:0] rd_ptr_bin_next;                // Next read pointer (binary)
  logic [PtrWidth-1:0] rd_ptr_gray;                    // Read pointer (Gray code)
  logic [PtrWidth-1:0] rd_ptr_gray_next;               // Next read pointer (Gray code)
  logic [PtrWidth-1:0] rd_ptr_gray_wrclk;              // Read pointer synced to write domain
  logic [PtrWidth-1:0] rd_ptr_bin_wrclk;               // Read pointer (binary) synced to write domain
  logic                rd_en_qualified;                // Read enable gated by empty status

  //Enpty/Full Signals
  logic                empty_next;                     // Combinational empty status
  logic                full_next;                      // Combinational full status

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //Write Reset Syncronizers: Synchronizes the external reset into the write clock domain
  adn_common_synchronizer #(
      .WIDTH      (1),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_wr_rst_sync (
      .clk_i  (wr_clk_i),
      .rst_n_i(wr_rst_n_i),
      .data_i ('1),
      .data_o (wr_rst_n_int)
  );

  //Read Reset Syncronizers: Synchronizes the external reset into the read clock domain
  adn_common_synchronizer #(
      .WIDTH      (1),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_rd_rst_sync (
      .clk_i  (rd_clk_i),
      .rst_n_i(rd_rst_n_i),
      .data_i ('1),
      .data_o (rd_rst_n_int)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION

  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule
