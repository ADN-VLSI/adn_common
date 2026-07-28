/*

This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for Clock Domain Crossing (CDC) applications. It enables reliable data transfer between two independent clock domains by utilizing Gray-coded pointers and multi-stage synchronizers to mitigate metastability issues.

### Usage

To use this module, instantiate it in your design by specifying the `DATA_WIDTH` and `ADDR_WIDTH` parameters. Ensure that `wr_clk` and `rd_clk` are connected to their respective clock domains.

```systemverilog
adn_common_cdc_fifo #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8)
) u_fifo (
    .wr_clk(clk_a),
    .wr_rst_n(rst_n_a),
    .wr_en(write_enable),
    .wr_data(data_in),
    .full(fifo_full),
    .rd_clk(clk_b),
    .rd_rst_n(rst_n_b),
    .rd_en(read_enable),
    .rd_data(data_out),
    .empty(fifo_empty)
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
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    parameter int SYNC_STAGES = 2,
    parameter int ALMOST_FULL_THRESH = (1 << ADDR_WIDTH) - 2,
    parameter int ALMOST_EMPTY_THRESH = 2

) (
    // PORTS

    //Write Clock Domain
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  full,
    output logic                  almost_full,
    output logic [  ADDR_WIDTH:0] wr_count,

    //Read Clock Domain
    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  empty,
    output logic                  almost_empty,
    output logic [  ADDR_WIDTH:0] rd_count
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int DEPTH = 1 << ADDR_WIDTH;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic [ADDR_WIDTH:0] wr_ptr, wr_ptr_gray;    // Write pointer and its Gray-coded version
  logic [ADDR_WIDTH:0] rd_ptr, rd_ptr_gray;    // Read pointer and its Gray-coded version
  logic [ADDR_WIDTH:0] wr_ptr_sync, rd_ptr_sync; // Synchronized pointers across domains
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];      // Dual-port RAM storage array

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  assign full  = (wr_ptr_gray == {~rd_ptr_sync[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_sync[ADDR_WIDTH-2:0]});
  assign empty = (wr_ptr_sync == rd_ptr);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Synchronizer modules for crossing Gray pointers between clock domains
  adn_common_cdc_sync #(.WIDTH(ADDR_WIDTH+1)) u_sync_wr (.clk(rd_clk), .rst_n(rd_rst_n), .in(wr_ptr_gray), .out(wr_ptr_sync));
  adn_common_cdc_sync #(.WIDTH(ADDR_WIDTH+1)) u_sync_rd (.clk(wr_clk), .rst_n(wr_rst_n), .in(rd_ptr_gray), .out(rd_ptr_sync));

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Write logic: Update write pointer and write data to memory
  always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) wr_ptr <= '0;
    else if (wr_en && !full) begin
      mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end

  // Read logic: Update read pointer and output data from memory
  always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) rd_ptr <= '0;
    else if (rd_en && !empty) begin
      rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

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
