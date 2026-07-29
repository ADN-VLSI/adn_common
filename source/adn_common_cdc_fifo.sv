/*

This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to safely handle clock domain crossing (CDC) while providing status flags such as full, empty, almost full, and almost empty to manage data flow control.

### Usage

To use this module, instantiate it in your design by providing the desired `DATA_WIDTH` and `ADDR_WIDTH`. Connect the write-side signals (`wr_clk_i`, `wr_en_i`, `wr_data_i`) to the producer domain and the read-side signals (`rd_clk_i`, `rd_en_i`, `rd_data_o`) to the consumer domain. Ensure that reset signals are synchronized appropriately.

- **`DATA_WIDTH`**: Sets the bit-width of the data bus.
- **`ADDR_WIDTH`**: Sets the depth of the FIFO as $2^{ADDR\_WIDTH}$.
- **`SYNC_STAGES`**: Configures the number of flip-flop stages in the synchronizers to mitigate metastability.

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

    // PARAMETERS
    parameter int DATA_WIDTH = 32,                      // Width of data bus
    parameter int ADDR_WIDTH = 8,                       // Address width (depth = 2^ADDR_WIDTH)
    parameter int SYNC_STAGES = 2,                      // Number of synchronizer stages
    parameter int ALMOST_FULL_THRESH = (1 << ADDR_WIDTH) - 2, // Threshold for almost full flag
    parameter int ALMOST_EMPTY_THRESH = 2               // Threshold for almost empty flag

) (
    // PORTS

    // Write Clock Domain
    input  logic                  wr_clk_i,             // Write domain clock
    input  logic                  wr_rst_n_i,           // Write domain active-low reset
    input  logic                  wr_en_i,              // Write enable
    input  logic [DATA_WIDTH-1:0] wr_data_i,            // Write data input
    output logic                  full_o,               // FIFO full status
    output logic                  almost_full_o,        // FIFO almost full status
    output logic [  ADDR_WIDTH:0] wr_count_o,           // Write domain data count

    // Read Clock Domain
    input  logic                  rd_clk_i,             // Read domain clock
    input  logic                  rd_rst_n_i,           // Read domain active-low reset
    input  logic                  rd_en_i,              // Read enable
    output logic [DATA_WIDTH-1:0] rd_data_o,            // Read data output
    output logic                  empty_o,              // FIFO empty status
    output logic                  almost_empty_o,       // FIFO almost empty status
    output logic [  ADDR_WIDTH:0] rd_count_o            // Read domain data count
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int PtrWidth = ADDR_WIDTH + 1;             // Pointer width (includes wrap-around bit)

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Local Reset Synchronizers
  logic                wr_rst_n_int;                    // Synchronized write reset
  logic                rd_rst_n_int;                    // Synchronized read reset

  // Write Domain Pointers
  logic [PtrWidth-1:0] wr_ptr_bin;                      // Write pointer (binary)
  logic [PtrWidth-1:0] wr_ptr_bin_next;                 // Next write pointer (binary)
  logic [PtrWidth-1:0] wr_ptr_gray;                     // Write pointer (Gray code)
  logic [PtrWidth-1:0] wr_ptr_gray_next;                // Next write pointer (Gray code)
  logic [PtrWidth-1:0] wr_ptr_gray_rdclk;               // Write pointer synchronized to read domain
  logic [PtrWidth-1:0] wr_ptr_bin_rdclk;                // Write pointer converted to binary in read domain
  logic                wr_en_qualified;                 // Write enable gated by full flag

  // Read Domain Pointers
  logic [PtrWidth-1:0] rd_ptr_bin;                      // Read pointer (binary)
  logic [PtrWidth-1:0] rd_ptr_bin_next;                 // Next read pointer (binary)
  logic [PtrWidth-1:0] rd_ptr_gray;                     // Read pointer (Gray code)
  logic [PtrWidth-1:0] rd_ptr_gray_next;                // Next read pointer (Gray code)
  logic [PtrWidth-1:0] rd_ptr_gray_wrclk;               // Read pointer synchronized to write domain
  logic [PtrWidth-1:0] rd_ptr_bin_wrclk;                // Read pointer converted to binary in write domain
  logic                rd_en_qualified;                 // Read enable gated by empty flag

  // Empty/Full Signals
  logic                empty_next;                      // Combinational empty status
  logic                full_next;                       // Combinational full status

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Write Reset Synchronizer: Ensures write domain reset is stable
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

  // Read Reset Synchronizer: Ensures read domain reset is stable
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
