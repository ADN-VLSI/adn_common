/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim Jannat    | Initial version                                        |
| 1.0      | 2026-07-28 | Annim Jannat    | Stable release                                         |
 
Author : Annim Jannat (jannatannim@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_SIZE  = 2,
    parameter bit PIPELINED  = 1
) (
    input logic arst_ni,
    input logic clk_i,

    input  logic [DATA_WIDTH-1:0] data_in_i,
    input  logic                  data_in_valid_i,
    output logic                  data_in_ready_o,

    output logic [DATA_WIDTH-1:0] data_out_o,
    output logic                  data_out_valid_o,
    input  logic                  data_out_ready_i,

    output logic [(2**FIFO_SIZE):0] count_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int FIFO_DEPTH = 2 ** FIFO_SIZE;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [(2**FIFO_SIZE):0] wr_ptr;
  logic [(2**FIFO_SIZE):0] rd_ptr;

  logic in_hs;
  logic out_hs;

  logic full;
  logic empty;

  logic [DATA_WIDTH-1:0] mem_out;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb in_hs = data_in_valid_i & data_in_ready_o;
  always_comb out_hs = data_out_valid_o & data_out_ready_i;

  always_comb full = (count_o == FIFO_DEPTH);
  always_comb empty = (count_o == 0);

  always_comb data_in_ready_o = full ? data_out_ready_i : 1'b1;

  if (PIPELINED) begin
    always_comb data_out_o = mem_out;
    always_comb data_out_valid_o = ~empty;
  end else begin
    always_comb data_out_o = empty ? data_in_i : mem_out;
    always_comb data_out_valid_o = empty ? data_in_valid_i : '1;
  end

  always_comb count_o = wr_ptr - rd_ptr;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_dual_port_ram #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(FIFO_SIZE)
  ) u_mem (
      .clk_i(clk_i),
      .wr_en_i(in_hs),
      .wr_addr_i(wr_ptr[FIFO_SIZE-1:0]),
      .wr_data_i(data_in_i),
      .rd_addr_i(rd_ptr[FIFO_SIZE-1:0]),
      .rd_data_o(mem_out)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
    end else begin
      if (in_hs) wr_ptr <= wr_ptr + 1;
      if (out_hs) rd_ptr <= rd_ptr + 1;
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 128) begin
      $display("\033[1;33m%m Significant big data width: %0d\033[0m", DATA_WIDTH);
    end

    if (FIFO_SIZE > 10) begin
      $display("\033[1;33m%m Significant Deep FIFO size: %0d\033[0m", FIFO_SIZE);
      $display("Consider a memory buffer instead");
    end
  end
`endif  // SIMULATION

endmodule
