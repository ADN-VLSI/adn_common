/*
 
### Purpose
This module implements a synchronous First-In-First-Out (FIFO) buffer designed for data flow control between clock domains or modules. It provides a configurable data width and depth, utilizing a circular buffer architecture to manage data storage and retrieval with full/empty status flags.

### Use Case
The `adn_common_fifo` is primarily used to decouple producers and consumers that operate at different rates or require buffering to prevent data loss during bursts. Typical applications include:
- **Data Streaming:** Buffering packets between a high-speed interface (e.g., AXI, SPI) and a processing core.
- **Clock Domain Crossing (CDC):** Acting as a staging area for data moving between synchronous domains (when managed with appropriate synchronization logic).
- **Flow Control:** Providing backpressure mechanisms in pipelines to ensure that data is not overwritten before it is consumed.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim Jannat    | Initial version                                        |
| 1.0      | 2026-07-28 | Annim Jannat    | Stable release                                         |
 
Author : Annim (jannatannim@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information
 
*/

module adn_common_fifo #(

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // PARAMETERS
    //////////////////////////////////////////////////////////////////////////////////////////////////
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // LOCALPARAMS
    //////////////////////////////////////////////////////////////////////////////////////////////////
    localparam int ADDR_WIDTH = $clog2(DEPTH)
) (
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // PORTS
    //////////////////////////////////////////////////////////////////////////////////////////////////
    input logic clk_i,
    input logic rst_ni,

    input logic                  wr_en_i,
    input logic                  rd_en_i,
    input logic [DATA_WIDTH-1:0] data_i,

    output logic [DATA_WIDTH-1:0] data_o,
    output logic                  full_o,
    output logic                  empty_o,
    output logic                  valid_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] mem[DEPTH];

  logic [ADDR_WIDTH:0] wr_ptr;
  logic [ADDR_WIDTH:0] rd_ptr;  // extra bit for msb that checks if the fifo is full or empty

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign full_o = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
  assign empty_o = (wr_ptr == rd_ptr);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES   - different memory module use kortesi na
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wr_ptr  <= '0;
      rd_ptr  <= '0;
      data_o  <= '0;
      valid_o <= 1'b0;
    end else begin
      valid_o <= 1'b0;

      // Write
      if (wr_en_i && !full_o) begin
        mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_i;
        wr_ptr <= wr_ptr + 1'b1;
      end

      // Read
      if (rd_en_i && !empty_o) begin
        data_o  <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        valid_o <= 1'b1;
        rd_ptr  <= rd_ptr + 1'b1;
      end
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef SYNTHESIS
  initial begin
    if (DEPTH <= 0) $fatal("DEPTH must be greater than 0.");

    if ((1 << ADDR_WIDTH) < DEPTH) $fatal("ADDR_WIDTH is insufficient for DEPTH.");
  end
`endif
endmodule
