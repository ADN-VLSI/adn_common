/*

This module implements a high-performance asynchronous FIFO (First-In-First-Out) buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to safely cross clock boundaries, preventing metastability issues while maintaining high throughput.

### Usage

The `adn_common_cdc_fifo` module is used to buffer data between two clock domains. 

1. **Instantiation**: Connect `wr_clk_i`/`wr_rst_n_i` to the producer domain and `rd_clk_i`/`rd_rst_n_i` to the consumer domain.
2. **Writing**: Assert `wr_en_i` when `full_o` is low to push data into the FIFO.
3. **Reading**: Assert `rd_en_i` when `empty_o` is low to pop data from the FIFO.
4. **Status**: Monitor `almost_full_o` and `almost_empty_o` for flow control, and use `wr_count_o`/`rd_count_o` for depth tracking.

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
    parameter int DATA_WIDTH = 32,                      // Width of the data bus
    parameter int ADDR_WIDTH = 8,                       // Address width (FIFO depth = 2^ADDR_WIDTH)
    parameter int SYNC_STAGES = 2,                      // Number of synchronization stages for CDC
    parameter int ALMOST_FULL_THRESH = (1 << ADDR_WIDTH) - 2, // Threshold for almost_full_o signal
    parameter int ALMOST_EMPTY_THRESH = 2               // Threshold for almost_empty_o signal

) (
    // PORTS

    // Write Clock Domain
    input  logic                  wr_clk_i,             // Write domain clock
    input  logic                  wr_rst_n_i,           // Active-low asynchronous reset (write domain)
    input  logic                  wr_en_i,              // Write enable
    input  logic [DATA_WIDTH-1:0] wr_data_i,            // Data input
    output logic                  full_o,               // FIFO full flag
    output logic                  almost_full_o,        // FIFO almost full flag
    output logic [  ADDR_WIDTH:0] wr_count_o,           // Write domain data count

    // Read Clock Domain
    input  logic                  rd_clk_i,             // Read domain clock
    input  logic                  rd_rst_n_i,           // Active-low asynchronous reset (read domain)
    input  logic                  rd_en_i,              // Read enable
    output logic [DATA_WIDTH-1:0] rd_data_o,            // Data output
    output logic                  empty_o,              // FIFO empty flag
    output logic                  almost_empty_o,       // FIFO almost empty flag
    output logic [  ADDR_WIDTH:0] rd_count_o            // Read domain data count
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int PtrWidth = ADDR_WIDTH + 1;             // Pointer width (extra bit for full/empty logic)

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Local Reset Synchronizers
  logic                wr_rst_n_int;                    // Synchronized write reset
  logic                rd_rst_n_int;                    // Synchronized read reset

  // Write Domain Pointers
  logic [PtrWidth-1:0] wr_ptr_bin;                      // Current write pointer (binary)
  logic [PtrWidth-1:0] wr_ptr_bin_next;                 // Next write pointer (binary)
  logic [PtrWidth-1:0] wr_ptr_gray;                     // Current write pointer (Gray)
  logic [PtrWidth-1:0] wr_ptr_gray_next;                // Next write pointer (Gray)
  logic [PtrWidth-1:0] wr_ptr_gray_rdclk;               // Write pointer synchronized to read domain
  logic [PtrWidth-1:0] wr_ptr_bin_rdclk;                // Write pointer (binary) in read domain
  logic                wr_en_qualified;                 // Write enable gated by full flag

  // Read Domain Pointers
  logic [PtrWidth-1:0] rd_ptr_bin;                      // Current read pointer (binary)
  logic [PtrWidth-1:0] rd_ptr_bin_next;                 // Next read pointer (binary)
  logic [PtrWidth-1:0] rd_ptr_gray;                     // Current read pointer (Gray)
  logic [PtrWidth-1:0] rd_ptr_gray_next;                // Next read pointer (Gray)
  logic [PtrWidth-1:0] rd_ptr_gray_wrclk;               // Read pointer synchronized to write domain
  logic [PtrWidth-1:0] rd_ptr_bin_wrclk;                // Read pointer (binary) in write domain
  logic                rd_en_qualified;                 // Read enable gated by empty flag

  // Empty-Full Signals
  logic                empty_next;                      // Combinational empty calculation
  logic                full_next;                       // Combinational full calculation

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Logic to qualify enables based on FIFO status
  assign wr_en_qualified = wr_en_i && !full_o;
  assign wr_ptr_bin_next = wr_ptr_bin + (wr_en_qualified ? {{(PtrWidth - 1) {1'b0}}, 1'b1} : '0);

  assign rd_en_qualified = rd_en_i && !empty_o;
  assign rd_ptr_bin_next = rd_ptr_bin + (rd_en_qualified ? {{(PtrWidth - 1) {1'b0}}, 1'b1} : '0);

  // Empty/Full status logic using Gray code comparison
  assign empty_next = (rd_ptr_gray_next == wr_ptr_gray_rdclk);
  assign full_next  =
        (wr_ptr_gray_next[ADDR_WIDTH]     != rd_ptr_gray_wrclk[ADDR_WIDTH])   &&
        (wr_ptr_gray_next[ADDR_WIDTH-1]   != rd_ptr_gray_wrclk[ADDR_WIDTH-1]) &&
        (wr_ptr_gray_next[ADDR_WIDTH-2:0] == rd_ptr_gray_wrclk[ADDR_WIDTH-2:0]);

  // FIFO depth tracking
  assign wr_count_o = wr_ptr_bin - rd_ptr_bin_wrclk;
  assign rd_count_o = wr_ptr_bin_rdclk - rd_ptr_bin;

  // Threshold logic
  assign almost_full_o = (wr_count_o >= ALMOST_FULL_THRESH[ADDR_WIDTH:0]);
  assign almost_empty_o = (rd_count_o <= ALMOST_EMPTY_THRESH[ADDR_WIDTH:0]);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Write Reset Synchronizer: Ensures reset release is stable in write domain
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

  // Read Reset Synchronizer: Ensures reset release is stable in read domain
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

  // Binary to Gray converters for pointer logic
  adn_endec_bin_to_gray #(
      .WIDTH(PtrWidth)
  ) u_wr_ptr_bin2gray (
      .bin_i (wr_ptr_bin_next),
      .gray_o(wr_ptr_gray_next)
  );

  adn_endec_bin_to_gray #(
      .WIDTH(PtrWidth)
  ) u_rd_ptr_bin2gray (
      .bin_i (rd_ptr_bin_next),
      .gray_o(rd_ptr_gray_next)
  );

  // Dual-port RAM: The actual storage element
  adn_common_dual_port_ram #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .OUT_REG   (1'b0)
  ) u_dual_port_ram (
      .wr_clk_i  (wr_clk_i),
      .wr_rst_n_i(wr_rst_n_int),
      .wr_en_i   (wr_en_qualified),
      .wr_addr_i (wr_ptr_bin[ADDR_WIDTH-1:0]),
      .wr_data_i (wr_data_i),

      .rd_clk_i  (rd_clk_i),
      .rd_rst_n_i(rd_rst_n_int),
      .rd_en_i   (rd_en_qualified),
      .rd_addr_i (rd_ptr_bin[ADDR_WIDTH-1:0]),
      .rd_data_o (rd_data_o)
  );

  // Pointer Synchronizers: Cross Gray-coded pointers between domains
  adn_common_synchronizer #(
      .WIDTH      (PtrWidth),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_wr_ptr_sync (
      .clk_i  (rd_clk_i),
      .rst_n_i(rd_rst_n_int),
      .data_i (wr_ptr_gray),
      .data_o (wr_ptr_gray_rdclk)
  );

  adn_common_synchronizer #(
      .WIDTH      (PtrWidth),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_rd_ptr_sync (
      .clk_i  (wr_clk_i),
      .rst_n_i(wr_rst_n_int),
      .data_i (rd_ptr_gray),
      .data_o (rd_ptr_gray_wrclk)
  );

  // Gray to Binary converters for count calculation
  adn_endec_gray_to_bin #(
      .WIDTH(PtrWidth)
  ) u_rdptr_gray2bin_wrclk (
      .gray_i(rd_ptr_gray_wrclk),
      .bin_o (rd_ptr_bin_wrclk)
  );

  adn_endec_gray_to_bin #(
      .WIDTH(PtrWidth)
  ) u_wrptr_gray2bin_rdclk (
      .gray_i(wr_ptr_gray_rdclk),
      .bin_o (wr_ptr_bin_rdclk)
  );


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Write pointer registers
  always_ff @(posedge wr_clk_i or negedge wr_rst_n_int) begin
    if (!wr_rst_n_int) begin
      wr_ptr_bin  <= '0;
      wr_ptr_gray <= '0;
    end else begin
      wr_ptr_bin  <= wr_ptr_bin_next;
      wr_ptr_gray <= wr_ptr_gray_next;
    end
  end

  // Read pointer registers
  always_ff @(posedge rd_clk_i or negedge rd_rst_n_int) begin
    if (!rd_rst_n_int) begin
      rd_ptr_bin  <= '0;
      rd_ptr_gray <= '0;
    end else begin
      rd_ptr_bin  <= rd_ptr_bin_next;
      rd_ptr_gray <= rd_ptr_gray_next;
    end
  end

  // Status flag registers
  always_ff @(posedge rd_clk_i or negedge rd_rst_n_int) begin
    if (!rd_rst_n_int) empty_o <= 1'b1;
    else empty_o <= empty_next;
  end

  always_ff @(posedge wr_clk_i or negedge wr_rst_n_int) begin
    if (!wr_rst_n_int) full_o <= 1'b0;
    else full_o <= full_next;
  end

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
