/*

### Purpose
The `adn_common_cdc_fifo` is a high-performance, asynchronous First-In-First-Out (FIFO) buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to safely cross clock boundaries, preventing metastability issues while providing status flags such as full, empty, almost full, and almost empty to manage flow control.

### Usage
To use this module, instantiate it in your RTL by connecting the write-side signals to your producer clock domain and the read-side signals to your consumer clock domain. Ensure that `wr_rst_n_i` and `rd_rst_n_i` are properly synchronized to their respective clocks.

```systemverilog
adn_common_cdc_fifo #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(4)
) u_fifo (
    .wr_clk_i(clk_a),
    .wr_rst_n_i(rst_n_a),
    .wr_en_i(valid_a),
    .wr_data_i(data_a),
    .full_o(full_a),
    .rd_clk_i(clk_b),
    .rd_rst_n_i(rst_n_b),
    .rd_en_i(ready_b),
    .rd_data_o(data_b),
    .empty_o(empty_b)
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
    input  logic                  wr_clk_i,
    input  logic                  wr_rst_n_i,
    input  logic                  wr_en_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,
    output logic                  full_o,
    output logic                  almost_full_o,
    output logic [  ADDR_WIDTH:0] wr_count_o,

    //Read Clock Domain
    input  logic                  rd_clk_i,
    input  logic                  rd_rst_n_i,
    input  logic                  rd_en_i,
    output logic [DATA_WIDTH-1:0] rd_data_o,
    output logic                  empty_o,
    output logic                  almost_empty_o,
    output logic [  ADDR_WIDTH:0] rd_count_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Pointer width includes an extra bit for full/empty detection
  localparam int PtrWidth = ADDR_WIDTH + 1;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Local Reset Synchronizers: Synchronized reset signals for internal logic
  logic                wr_rst_n_int;
  logic                rd_rst_n_int;

  // Write Domain Pointers: Binary and Gray pointers for write tracking
  logic [PtrWidth-1:0] wr_ptr_bin;
  logic [PtrWidth-1:0] wr_ptr_bin_next;
  logic [PtrWidth-1:0] wr_ptr_gray;
  logic [PtrWidth-1:0] wr_ptr_gray_next;
  logic [PtrWidth-1:0] wr_ptr_gray_rdclk; // Gray pointer synchronized to read clock
  logic [PtrWidth-1:0] wr_ptr_bin_rdclk;  // Binary converted pointer in read clock
  logic                wr_en_qualified;   // Write enable gated by full status

  // Read Domain Pointers: Binary and Gray pointers for read tracking
  logic [PtrWidth-1:0] rd_ptr_bin;
  logic [PtrWidth-1:0] rd_ptr_bin_next;
  logic [PtrWidth-1:0] rd_ptr_gray;
  logic [PtrWidth-1:0] rd_ptr_gray_next;
  logic [PtrWidth-1:0] rd_ptr_gray_wrclk; // Gray pointer synchronized to write clock
  logic [PtrWidth-1:0] rd_ptr_bin_wrclk;  // Binary converted pointer in write clock
  logic                rd_en_qualified;   // Read enable gated by empty status

  // Empty/Full Signals: Next state logic for FIFO status
  logic                empty_next;
  logic                full_next;

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
