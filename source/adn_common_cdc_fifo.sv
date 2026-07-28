/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

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

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int PtrWidth = ADDR_WIDTH + 1;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //Local Reset Syncronizers
  logic                wr_rst_n_int;
  logic                rd_rst_n_int;

  //Write Domain Pointers
  logic [PtrWidth-1:0] wr_ptr_bin;
  logic [PtrWidth-1:0] wr_ptr_bin_next;
  logic [PtrWidth-1:0] wr_ptr_gray;
  logic [PtrWidth-1:0] wr_ptr_gray_next;
  logic [PtrWidth-1:0] wr_ptr_gray_rdclk;
  logic [PtrWidth-1:0] wr_ptr_bin_rdclk;
  logic                wr_en_qualified;

  //Read Domain Pointers
  logic [PtrWidth-1:0] rd_ptr_bin;
  logic [PtrWidth-1:0] rd_ptr_bin_next;
  logic [PtrWidth-1:0] rd_ptr_gray;
  logic [PtrWidth-1:0] rd_ptr_gray_next;
  logic [PtrWidth-1:0] rd_ptr_gray_wrclk;
  logic [PtrWidth-1:0] rd_ptr_bin_wrclk;
  logic                rd_en_qualified;

  //Enpty/Full Signals
  logic                empty_next;
  logic                full_next;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //Write Reset Syncronizers
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

  //Read Reset Syncronizers
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

