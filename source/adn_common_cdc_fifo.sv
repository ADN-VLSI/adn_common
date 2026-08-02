/*

### Purpose
The `adn_common_cdc_fifo` module implements a high-performance, asynchronous First-In-First-Out (FIFO) buffer designed for reliable data transfer between two independent clock domains. It utilizes Gray-coded pointers and multi-stage synchronizers to mitigate metastability issues, ensuring robust data integrity during Clock Domain Crossing (CDC). The module provides full, empty, and programmable almost-full/almost-empty status flags, along with occupancy counters to facilitate flow control in complex digital systems.

### Use Case
This module is intended for scenarios where data must be passed between two modules operating on different clock frequencies or phases. Common use cases include:
- **Data Buffering:** Smoothing out bursts of data between a high-speed producer and a low-speed consumer.
- **Clock Domain Crossing (CDC):** Safely transferring control signals or data packets across asynchronous boundaries in SoC designs.
- **Flow Control:** Utilizing the `almost_full` and `almost_empty` flags to throttle upstream data producers or trigger downstream processing, preventing buffer overflow or underflow.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-29 | Ahasan Ullah Khalid | Stable release                                     |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_cdc_fifo #(
    // Width of the data bus
    parameter int DATA_WIDTH          = 32,
    // Address width
    parameter int ADDR_WIDTH          = 8,
    // Number of synchronization stages
    parameter int SYNC_STAGES         = 2,
    // Threshold for almost_full_o flag
    parameter int ALMOST_FULL_THRESH  = (1 << ADDR_WIDTH) - 2,
    // Threshold for almost_empty_o flag
    parameter int ALMOST_EMPTY_THRESH = 2

) (
    // PORTS

    //Write Clock Domain
    input  logic                  wr_clk_i,       // Write domain clock
    input  logic                  wr_rst_n_i,     // Active-low asynchronous reset for write domain
    input  logic                  wr_en_i,        // Write enable signal
    input  logic [DATA_WIDTH-1:0] wr_data_i,      // Data input bus
    output logic                  full_o,         // FIFO full flag
    output logic                  almost_full_o,  // FIFO almost full flag
    output logic [  ADDR_WIDTH:0] wr_count_o,     // Write domain occupancy count

    //Read Clock Domain
    input  logic                  rd_clk_i,        // Read domain clock
    input  logic                  rd_rst_n_i,      // Active-low asynchronous reset for read domain
    input  logic                  rd_en_i,         // Read enable signal
    output logic [DATA_WIDTH-1:0] rd_data_o,       // Data output bus
    output logic                  empty_o,         // FIFO empty flag
    output logic                  almost_empty_o,  // FIFO almost empty flag
    output logic [  ADDR_WIDTH:0] rd_count_o       // Read domain occupancy count
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Pointer width includes 1 extra bit (MSB) to distinguish full from empty conditions
  localparam int PtrWidth = ADDR_WIDTH + 1;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Internal synchronized active-low resets for domain isolation
  logic                wr_rst_n_int;
  logic                rd_rst_n_int;

  // Write Domain Pointers & Control Signals
  logic [PtrWidth-1:0] wr_ptr_bin;  // Binary write pointer
  logic [PtrWidth-1:0] wr_ptr_bin_next;  // Next binary write pointer
  logic [PtrWidth-1:0] wr_ptr_gray;  // Gray-coded write pointer
  logic [PtrWidth-1:0] wr_ptr_gray_next;  // Next Gray-coded write pointer
  logic [PtrWidth-1:0] wr_ptr_gray_rdclk;  // Write pointer synchronized to read domain
  logic [PtrWidth-1:0] wr_ptr_bin_rdclk;  // Write pointer converted to binary in read domain
  logic                wr_en_qualified;  // Write enable gated by full flag

  // Read Domain Pointers & Control Signals
  logic [PtrWidth-1:0] rd_ptr_bin;  // Binary read pointer
  logic [PtrWidth-1:0] rd_ptr_bin_next;  // Next binary read pointer
  logic [PtrWidth-1:0] rd_ptr_gray;  // Gray-coded read pointer
  logic [PtrWidth-1:0] rd_ptr_gray_next;  // Next Gray-coded read pointer
  logic [PtrWidth-1:0] rd_ptr_gray_wrclk;  // Read pointer synchronized to write domain
  logic [PtrWidth-1:0] rd_ptr_bin_wrclk;  // Read pointer converted to binary in write domain
  logic                rd_en_qualified;  // Read enable gated by empty flag

  // Combinational Next-State Flag Calculations
  logic                empty_next;  // Combinational empty status
  logic                full_next;  // Combinational full status

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Qualify write/read requests to ensure operations only occur when safe
  assign wr_en_qualified = wr_en_i && !full_o;
  assign rd_en_qualified = rd_en_i && !empty_o;

  // Calculate next binary pointers based on qualified enable signals
  assign wr_ptr_bin_next = wr_ptr_bin + (wr_en_qualified ? {{(PtrWidth - 1) {1'b0}}, 1'b1} : '0);
  assign rd_ptr_bin_next = rd_ptr_bin + (rd_en_qualified ? {{(PtrWidth - 1) {1'b0}}, 1'b1} : '0);

  // Look-Ahead Empty Condition: FIFO is empty when read pointer matches synchronized write pointer
  assign empty_next = (rd_ptr_gray_next == wr_ptr_gray_rdclk);

  // Look-Ahead Full Condition: FIFO is full when Gray pointers match MSB/MSB-1 inversion
  assign full_next  =
        (wr_ptr_gray_next[ADDR_WIDTH]     != rd_ptr_gray_wrclk[ADDR_WIDTH])   &&
        (wr_ptr_gray_next[ADDR_WIDTH-1]   != rd_ptr_gray_wrclk[ADDR_WIDTH-1]) &&
        (wr_ptr_gray_next[ADDR_WIDTH-2:0] == rd_ptr_gray_wrclk[ADDR_WIDTH-2:0]);

  // Occupancy Count Logic: Difference between pointers in respective domains
  assign wr_count_o = wr_ptr_bin - rd_ptr_bin_wrclk;
  assign rd_count_o = wr_ptr_bin_rdclk - rd_ptr_bin;

  // Threshold-based status indicators for flow control
  assign almost_full_o = (wr_count_o >= ALMOST_FULL_THRESH[ADDR_WIDTH:0]);
  assign almost_empty_o = (rd_count_o <= ALMOST_EMPTY_THRESH[ADDR_WIDTH:0]);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Reset Synchronizer: Write Clock Domain (Multi-stage FF chain)
  adn_common_synchronizer #(
      .WIDTH      (1),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_wr_rst_sync (
      .clk_i  (wr_clk_i),
      .arst_ni(wr_rst_n_i),
      .data_i ('1),
      .data_o (wr_rst_n_int)
  );

  // Reset Synchronizer: Read Clock Domain (Multi-stage FF chain)
  adn_common_synchronizer #(
      .WIDTH      (1),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_rd_rst_sync (
      .clk_i  (rd_clk_i),
      .arst_ni(rd_rst_n_i),
      .data_i ('1),
      .data_o (rd_rst_n_int)
  );

  // Binary-to-Gray Code Converter: Write Pointer (Prevents multi-bit transition glitches)
  adn_common_bin_to_gray #(
      .WIDTH(PtrWidth)
  ) u_wr_ptr_bin2gray (
      .bin_i (wr_ptr_bin_next),
      .gray_o(wr_ptr_gray_next)
  );

  // Binary-to-Gray Code Converter: Read Pointer
  adn_common_bin_to_gray #(
      .WIDTH(PtrWidth)
  ) u_rd_ptr_bin2gray (
      .bin_i (rd_ptr_bin_next),
      .gray_o(rd_ptr_gray_next)
  );

  // Dual-Port RAM: Memory Storage Block (Asynchronous read/write)
  adn_common_dual_port_ram #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) u_dual_port_ram (
      .clk_i    (wr_clk_i),
      .wr_en_i  (wr_en_qualified),
      .wr_addr_i(wr_ptr_bin[ADDR_WIDTH-1:0]),
      .wr_data_i(wr_data_i),

      .rd_addr_i(rd_ptr_bin[ADDR_WIDTH-1:0]),
      .rd_data_o(rd_data_o)
  );

  // CDC Synchronizer: Write Gray Pointer -> Read Domain (For Empty calculation)
  adn_common_synchronizer #(
      .WIDTH      (PtrWidth),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_wr_ptr_sync (
      .clk_i  (rd_clk_i),
      .arst_ni(rd_rst_n_int),
      .data_i (wr_ptr_gray),
      .data_o (wr_ptr_gray_rdclk)
  );

  // CDC Synchronizer: Read Gray Pointer -> Write Domain (For Full calculation)
  adn_common_synchronizer #(
      .WIDTH      (PtrWidth),
      .STAGES     (SYNC_STAGES),
      .RESET_VALUE('0)
  ) u_rd_ptr_sync (
      .clk_i  (wr_clk_i),
      .arst_ni(wr_rst_n_int),
      .data_i (rd_ptr_gray),
      .data_o (rd_ptr_gray_wrclk)
  );

  // Gray-to-Binary Converters (Used for occupancy/fill count metrics)
  adn_common_gray_to_bin #(
      .WIDTH(PtrWidth)
  ) u_rdptr_gray2bin_wrclk (
      .gray_i(rd_ptr_gray_wrclk),
      .bin_o (rd_ptr_bin_wrclk)
  );

  adn_common_gray_to_bin #(
      .WIDTH(PtrWidth)
  ) u_wrptr_gray2bin_rdclk (
      .gray_i(wr_ptr_gray_rdclk),
      .bin_o (wr_ptr_bin_rdclk)
  );


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Write Domain Sequential Register Updating (Pointers)
  always_ff @(posedge wr_clk_i or negedge wr_rst_n_int) begin
    if (!wr_rst_n_int) begin
      wr_ptr_bin  <= '0;
      wr_ptr_gray <= '0;
    end else begin
      wr_ptr_bin  <= wr_ptr_bin_next;
      wr_ptr_gray <= wr_ptr_gray_next;
    end
  end

  // Read Domain Sequential Register Updating (Pointers)
  always_ff @(posedge rd_clk_i or negedge rd_rst_n_int) begin
    if (!rd_rst_n_int) begin
      rd_ptr_bin  <= '0;
      rd_ptr_gray <= '0;
    end else begin
      rd_ptr_bin  <= rd_ptr_bin_next;
      rd_ptr_gray <= rd_ptr_gray_next;
    end
  end

  // Read Domain Output Flag Registering
  always_ff @(posedge rd_clk_i or negedge rd_rst_n_int) begin
    if (!rd_rst_n_int) empty_o <= 1'b1;
    else empty_o <= empty_next;
  end

  // Write Domain Output Flag Registering
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
