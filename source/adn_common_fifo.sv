/*

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

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
    input  logic                  clk_i,
    input  logic                  rst_ni,

    input  logic                  wr_en_i,
    input  logic                  rd_en_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,

    output logic [DATA_WIDTH-1:0] rd_data_o,
    output logic                  full_o,
    output logic                  empty_o,
    output logic                  valid_o,

    output logic [ADDR_WIDTH:0]   count_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  logic [ADDR_WIDTH-1:0] wr_ptr;
  logic [ADDR_WIDTH-1:0] rd_ptr;

  logic wr_fire;
  logic rd_fire;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign full_o    = (count_o == DEPTH);
  assign empty_o   = (count_o == 0);

  assign wr_fire = wr_en_i && !full_o;
  assign rd_fire = rd_en_i && !empty_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES   - different memory module use kortesi na
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
      count_o  <= '0;
      rd_data_o <= '0;
      valid_o <= 1'b0;
    end
    else begin
      valid_o <= 1'b0;

      //--------------------------------------
      // Write
      //--------------------------------------
      if (wr_fire) begin
        mem[wr_ptr] <= wr_data_i;

        if (wr_ptr == DEPTH-1)
          wr_ptr <= '0;
        else
          wr_ptr <= wr_ptr + 1'b1;
      end

      //--------------------------------------
      // Read
      //--------------------------------------
      if (rd_fire) begin
        rd_data_o <= mem[rd_ptr];
        valid_o   <= 1'b1;

        if (rd_ptr == DEPTH-1)
          rd_ptr <= '0;
        else
          rd_ptr <= rd_ptr + 1'b1;
      end

      //--------------------------------------
      // count_o
      //--------------------------------------
      case ({wr_fire, rd_fire})
        2'b10: count_o <= count_o + 1'b1;
        2'b01: count_o <= count_o - 1'b1;
        default: count_o <= count_o;
      endcase
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef SYNTHESIS
  initial begin
    if (DEPTH <= 0)
      $fatal("DEPTH must be greater than 0.");

    if ((1 << ADDR_WIDTH) < DEPTH)
      $fatal("ADDR_WIDTH is insufficient for DEPTH.");
  end
`endif

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  function automatic logic is_full_o();
    return (count_o == DEPTH);
  endfunction

  function automatic logic is_empty_o();
    return (count_o == 0);
  endfunction

endmodule
