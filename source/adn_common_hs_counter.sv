/*
 
@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.
 
@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.
 
| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Annim | Initial version                                        |
| 1.0      | 2026-07-29 | Annim | Stable release                                         |
 
Author : Annim Jannat (jannatannim@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information
 
*/

module adn_common_hs_counter #(

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // PARAMETERS
    //////////////////////////////////////////////////////////////////////////////////////////////////

    parameter int DEPTH = 8  // width of the counter

) (

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // PORTS
    //////////////////////////////////////////////////////////////////////////////////////////////////

    input logic clk_i,  // clock input
    input logic rst_ni, // active-low async reset

    // input handshake interface
    input  logic data_in_valid_i,  // sender says data is valid (input side)
    output logic data_in_ready_o,  // receiver says it can accept (input side)

    // output handshake interface
    output logic data_out_valid_o,  // sender says data is valid (output side)
    input  logic data_out_ready_i,  // receiver says it can accept (output side)

    output logic [WIDTH-1:0] count_o,    // number of outstanding handshakes
    output logic             overflow_o  // pulses if counter wraps around
);


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int WIDTH = $clog2(DEPTH);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic in_hs, out_hs;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign in_hs            = data_in_valid_i && data_in_ready_o;
  assign out_hs           = data_out_valid_o && data_out_ready_i;
  assign data_in_ready_o  = (count_o != {WIDTH{'1}});  // ready unless count is full
  assign data_out_valid_o = (count_o != '0);  // valid if not empty

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      count_o    <= '0;
      overflow_o <= 1'b0;
    end else begin
      overflow_o <= 1'b0;

      if (data_in_valid_i && count_o == '1) begin
        data_in_ready_o <= 1'b0;
      end

      if (data_out_ready_i && count_o == '0) begin
        data_out_valid_o <= 1'b0;
      end 

      else begin
        overflow_o <= 1'b0;
        case ({
          in_hs, out_hs
        })
          2'b10:   {overflow_o, count_o} <= count_o + 1'b1;  // in only: increment
          2'b01:   count_o <= (count_o == '0) ? count_o : count_o - 1'b1;  // out only: decrement
          default: count_o <= count_o;
        endcase
      end
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin
    assert (DEPTH > 0)
    else $fatal(1, "adn_common_hs_counter: DEPTH must be greater than 0");
  end

endmodule
