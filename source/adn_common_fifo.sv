/*
 
@foez--bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.
 
@foez--bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.
 
| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Annim | Initial version                                        |
| 1.0      | YYYY-MM-DD | Annim | Stable release                                         |
 
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

  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];

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

