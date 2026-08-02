/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                        |
|----------|------------|---------------------|----------------------------------------------------|
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version                                    |
| 1.0      | 2026-07-29 | Ahasan Ullah Khalid | Stable release                                     |
| 1.1      | 2026-08-02 | Foez Ahmed          | Ratified                                           |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_cdc_fifo #(
    parameter int DATA_WIDTH  = 8,
    parameter int FIFO_SIZE   = 2,
    parameter int SYNC_STAGES = 2
) (
    input  logic                  data_in_arst_ni,
    input  logic [DATA_WIDTH-1:0] data_in_clk_i,
    input  logic [DATA_WIDTH-1:0] data_in_i,
    input  logic                  data_in_valid_i,
    output logic                  data_in_ready_o,
    output logic [   FIFO_SIZE:0] data_in_count_o,

    input  logic                  data_out_arst_ni,
    output logic [DATA_WIDTH-1:0] data_out_clk_i,
    output logic [DATA_WIDTH-1:0] data_out_o,
    output logic                  data_out_valid_o,
    input  logic                  data_out_ready_i,
    output logic [   FIFO_SIZE:0] data_out_count_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic common_arst_n;

  logic [FIFO_SIZE:0] wr_addr;
  logic [FIFO_SIZE:0] rd_addr;

  logic [FIFO_SIZE:0] wr_addr_;
  logic [FIFO_SIZE:0] rd_addr_;

  logic [FIFO_SIZE:0] wpgi;
  logic [FIFO_SIZE:0] wpgo;
  logic [FIFO_SIZE:0] rpgi;
  logic [FIFO_SIZE:0] rpgo;

  logic [FIFO_SIZE:0] wr_ptr_pass;
  logic [FIFO_SIZE:0] rd_ptr_pass;

  logic [FIFO_SIZE:0] wr_ptr_ic;
  logic [FIFO_SIZE:0] rd_ptr_oc;

  logic in_hs;
  logic out_hs;

  logic full_ic;
  logic empty_oc;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb common_arst_n = data_in_arst_ni & data_out_arst_ni;

  always_comb
    full_ic = (wr_addr[FIFO_SIZE-1:0] == rd_addr_[FIFO_SIZE-1:0])
                    & (wr_addr[FIFO_SIZE] != rd_addr_[FIFO_SIZE]);

  always_comb empty_oc = (wr_addr_[FIFO_SIZE-1:0] == rd_addr[FIFO_SIZE-1:0]);

  always_comb data_in_ready_o = ~full_ic;
  always_comb data_out_valid_o = ~empty_oc;

  always_comb in_hs = data_in_valid_i & data_in_ready_o;
  always_comb out_hs = data_out_valid_o & data_out_ready_i;

  always_comb data_in_count_o = wr_addr - rd_addr_;
  always_comb data_out_count_o = wr_addr_ - rd_addr;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_dual_port_ram #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(FIFO_SIZE)
  ) u_mem (
      .clk_i(data_in_clk_i),
      .wr_en_i(in_hs),
      .wr_addr_i(wr_addr[FIFO_SIZE-1:0]),
      .wr_data_i(data_in_i),
      .rd_addr_i(rd_addr[FIFO_SIZE-1:0]),
      .rd_data_o(data_out_o)
  );

  adn_common_bin_to_gray #(
      .WIDTH(FIFO_SIZE + 1)
  ) b2g_w (
      .bin_i (wr_addr + 1),
      .gray_o(wpgi)
  );

  adn_common_bin_to_gray #(
      .WIDTH(FIFO_SIZE + 1)
  ) b2g_r (
      .bin_i (rd_addr + 1),
      .gray_o(rpgi)
  );

  adn_common_gray_to_bin #(
      .WIDTH(FIFO_SIZE + 1)
  ) g2b_wi (
      .gray_i(wr_ptr_pass),
      .bin_o (wr_addr)
  );

  adn_common_gray_to_bin #(
      .WIDTH(FIFO_SIZE + 1)
  ) g2b_wo (
      .gray_i(wpgo),
      .bin_o (wr_addr_)
  );

  adn_common_gray_to_bin #(
      .WIDTH(FIFO_SIZE + 1)
  ) g2b_ri (
      .gray_i(rpgo),
      .bin_o (rd_addr_)
  );

  adn_common_gray_to_bin #(
      .WIDTH(FIFO_SIZE + 1)
  ) g2b_ro (
      .gray_i(rd_ptr_pass),
      .bin_o (rd_addr)
  );

  adn_common_synchronizer #(
      .WIDTH(FIFO_SIZE + 1),
      .STAGES(1),
      .RESET_VALUE('0)
  ) wr_ptr_ic (
      .clk_i(data_in_clk_i),
      .arst_ni(common_arst_n),
      .en_i(in_hs),
      .data_i(wpgi),
      .data_o(wr_ptr_pass)
  );

  adn_common_synchronizer #(
      .WIDTH(FIFO_SIZE + 1),
      .STAGES(SYNC_STAGES),
      .RESET_VALUE('0)
  ) wr_ptr_oc (
      .clk_i(data_out_clk_i),
      .arst_ni(common_arst_n),
      .en_i('1),
      .data_i(wr_ptr_pass),
      .data_o(wpgo)
  );

  adn_common_synchronizer #(
      .WIDTH(FIFO_SIZE + 1),
      .STAGES(1),
      .RESET_VALUE('0)
  ) rd_ptr_oc (
      .clk_i(data_out_clk_i),
      .arst_ni(common_arst_n),
      .en_i(out_hs),
      .data_i(rpgi),
      .data_o(rd_ptr_pass)
  );

  adn_common_synchronizer #(
      .WIDTH(FIFO_SIZE + 1),
      .STAGES(SYNC_STAGES),
      .RESET_VALUE('0)
  ) rd_ptr_ic (
      .clk_i(data_in_clk_i),
      .arst_ni(common_arst_n),
      .en_i('1),
      .data_i(rd_ptr_pass),
      .data_o(rpgo)
  );

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

