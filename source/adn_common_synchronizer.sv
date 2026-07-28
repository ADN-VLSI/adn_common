/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-07-28 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-07-28 | Ahasan Ullah Khalid | Stable release                                         |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_synchronizer #(
    // PARAMETERS
    parameter int               WIDTH       = 1,
    parameter int               STAGES      = 2,
    parameter logic [WIDTH-1:0] RESET_VALUE = '0
) (
    // PORTS
    input logic             clk_i,
    input logic             rst_n_i,
    input logic [WIDTH-1:0] data_i,
    input logic [WIDTH-1:0] data_o
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [WIDTH-1:0] sync_ff[STAGES];


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge rst_n_i) begin

    if (!rst_n_i) begin
      for (int i = 0; i < STAGES; i++) sync_ff[i] <= RESET_VALUE;
    end else begin
      sync_ff[0] <= data_i;
      for (int i = 0; i < STAGES; i++) sync_ff[i] <= sync_ff[i-1];
    end

  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign data_o = sync_ff[STAGES-1];

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

