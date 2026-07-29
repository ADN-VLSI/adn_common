/*

This module implements a high-performance asynchronous (CDC) FIFO buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to safely cross clock boundaries, preventing metastability issues while providing status flags such as full, empty, almost full, and almost empty.

### Usage
The `adn_common_cdc_fifo` module is used to buffer data between two asynchronous clock domains.
1. **Instantiation**: Configure the `DATA_WIDTH` and `ADDR_WIDTH` to match your data requirements and buffer depth.
2. **Write Interface**: Drive `wr_data_i` and `wr_en_i` using the `wr_clk_i` domain. Monitor `full_o` to prevent overflow.
3. **Read Interface**: Monitor `empty_o` in the `rd_clk_i` domain before asserting `rd_en_i` to read data from `rd_data_o`.
4. **Status Flags**: Use `almost_full_o` and `almost_empty_o` for flow control or to trigger backpressure mechanisms.

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
    parameter int DATA_WIDTH = 32,                          // Width of the data bus
    parameter int ADDR_WIDTH = 8,                           // Address width (determines FIFO depth as 2^ADDR_WIDTH)
    parameter int SYNC_STAGES = 2,                          // Number of synchronization stages for CDC
    parameter int ALMOST_FULL_THRESH = (1 << ADDR_WIDTH) - 2, // Threshold for almost_full_o flag
    parameter int ALMOST_EMPTY_THRESH = 2                   // Threshold for almost_empty_o flag

) (
    // PORTS

    // Write Clock Domain
    input  logic                  wr_clk_i,       // Write clock
    input  logic                  wr_rst_n_i,     // Active-low asynchronous reset for write domain
    input  logic                  wr_en_i,        // Write enable
    input  logic [DATA_WIDTH-1:0] wr_data_i,      // Data input
    output logic                  full_o,         // FIFO full flag
    output logic                  almost_full_o,  // FIFO almost full flag
    output logic [  ADDR_WIDTH:0] wr_count_o,     // Current write-side occupancy count

    // Read Clock Domain
    input  logic                  rd_clk_i,       // Read clock
    input  logic                  rd_rst_n_i,     // Active-low asynchronous reset for read domain
    input  logic                  rd_en_i,        // Read enable
    output logic [DATA_WIDTH-1:0] rd_data_o,      // Data output
    output logic                  empty_o,        // FIFO empty flag
    output logic                  almost_empty_o, // FIFO almost empty flag
    output logic [  ADDR_WIDTH:0] rd_count_o      // Current read-side occupancy count
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int PtrWidth = ADDR_WIDTH + 1; // Pointer width (includes wrap-around bit)

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Local Reset Synchronizers
  logic                wr_rst_n_int; // Synchronized write reset
  logic                rd_rst_n_int; // Synchronized read reset

  // Write Domain Pointers
  logic [PtrWidth-1:0] wr_ptr_bin;        // Binary write pointer
  logic [PtrWidth-1:0] wr_ptr_bin_next;   // Next binary write pointer
  logic [PtrWidth-1:0] wr_ptr_gray;       // Gray-coded write pointer
  logic [PtrWidth-1:0] wr_ptr_gray_next;  // Next Gray-coded write pointer
  logic [PtrWidth-1:0] wr_ptr_gray_rdclk; // Write pointer synchronized to read domain
  logic [PtrWidth-1:0] wr_ptr_bin_rdclk;  // Write pointer converted to binary in read domain
  logic                wr_en_qualified;   // Write enable gated by full status

  // Read Domain Pointers
  logic [PtrWidth-1:0] rd_ptr_bin;        // Binary read pointer
  logic [PtrWidth-1:0] rd_ptr_bin_next;   // Next binary read pointer
  logic [PtrWidth-1:0] rd_ptr_gray;       // Gray-coded read pointer
  logic [PtrWidth-1:0] rd_ptr_gray_next;  // Next Gray-coded read pointer
  logic [PtrWidth-1:0] rd_ptr_gray_wrclk; // Read pointer synchronized to write domain
  logic [PtrWidth-1:0] rd_ptr_bin_wrclk;  // Read pointer converted to binary in write domain
  logic                rd_en_qualified;   // Read enable gated by empty status

  // Empty-Full Signals
  logic                empty_next; // Combinational empty status
  logic                full_next;  // Combinational full status

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Logic to gate write/read operations based on FIFO status
  assign wr_en_qualified = wr_en_i && !full_o;
  assign wr_ptr_bin_next = wr_ptr_bin + (wr_en_qualified ? {{(PtrWidth - 1) {1'b0}}, 1'b1} : '0);

  assign rd_en_qualified = rd_en_i && !empty_o;
  assign rd_ptr_bin_next = rd_ptr_bin + (rd_en_qualified ? {{(PtrWidth - 1) {1'b0}}, 1'b1} : '0);

  // Empty/Full detection logic using Gray pointers
  assign empty_next = (rd_ptr_gray_next == wr_ptr_gray_rdclk);
  assign full_next  =
        (wr_ptr_gray_next[ADDR_WIDTH]     != rd_ptr_gray_wrclk[ADDR_WIDTH])   &&
        (wr_ptr_gray_next[ADDR_WIDTH-1]   != rd_ptr_gray_wrclk[ADDR_WIDTH-1]) &&
        (wr_ptr_gray_next[ADDR_WIDTH-2:0] == rd_ptr_gray_wrclk[ADDR_WIDTH-2:0]);

  // Occupancy calculations
  assign wr_count_o = wr_ptr_bin - rd_ptr_bin_wrclk;
  assign rd_count_o = wr_ptr_bin_rdclk - rd_ptr_bin;

  // Threshold flags
  assign almost_full_o = (wr_count_o >= ALMOST_FULL_THRESH[ADDR_WIDTH:0]);
  assign almost_empty_o = (rd_count_o <= ALMOST_EMPTY_THRESH[ADDR_WIDTH:0]);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Write Reset Synchronizer
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

  // Read Reset Synchronizer
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

  // Binary to Gray converters for pointers
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

  // Dual-port RAM for data storage
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

  // Pointer synchronizers (CDC)
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

  // Gray to Binary converters for pointer comparison
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

  // Update write pointers
  always_ff @(posedge wr_clk_i or negedge wr_rst_n_int) begin
    if (!wr_rst_n_int) begin
      wr_ptr_bin  <= '0;
      wr_ptr_gray <= '0;
    end else begin
      wr_ptr_bin  <= wr_ptr_bin_next;
      wr_ptr_gray <= wr_ptr_gray_next;
    end
  end

  // Update read pointers
  always_ff @(posedge rd_clk_i or negedge rd_rst_n_int) begin
    if (!rd_rst_n_int) begin
      rd_ptr_bin  <= '0;
      rd_ptr_gray <= '0;
    end else begin
      rd_ptr_bin  <= rd_ptr_bin_next;
      rd_ptr_gray <= rd_ptr_gray_next;
    end
  end

  // Update empty flag
  always_ff @(posedge rd_clk_i or negedge rd_rst_n_int) begin
    if (!rd_rst_n_int) empty_o <= 1'b1;
    else empty_o <= empty_next;
  end

  // Update full flag
  always_ff @(posedge wr_clk_i or negedge wr_rst_n_int) begin
    if (!wr_rst_n_int) full_o <= 1'b0;
    else full_o <= full_next;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION

  // Validate parameter constraints at elaboration time.
  initial begin
    if (SYNC_STAGES < 2) begin
      $error("%m: SYNC_STAGES must be >= 2 for reliable CDC metastability protection.");
    end
    if (ALMOST_FULL_THRESH >= (1 << ADDR_WIDTH)) begin
      $error("%m: ALMOST_FULL_THRESH (%0d) must be less than FIFO depth (%0d).",
             ALMOST_FULL_THRESH, (1 << ADDR_WIDTH));
    end
    if (ALMOST_EMPTY_THRESH < 0) begin
      $error("%m: ALMOST_EMPTY_THRESH must be non-negative.");
    end
    if (DATA_WIDTH <= 0) begin
      $error("%m: DATA_WIDTH must be > 0.");
    end
  end

`endif  // SIMULATION

endmodule
