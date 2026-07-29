/*

### Purpose
The `adn_common_synchronizer` module is a parameterized multi-stage flip-flop chain designed to synchronize asynchronous input signals to a target clock domain. It helps mitigate metastability issues when transferring data between different clock domains or from asynchronous sources.

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

module adn_common_synchronizer #(
    // PARAMETERS
    parameter int               WIDTH       = 1,   // Width of the data bus to be synchronized
    parameter int               STAGES      = 2,   // Number of flip-flop stages for metastability reduction
    parameter logic [WIDTH-1:0] RESET_VALUE = '0   // Value of the synchronizer registers during reset
) (
    // PORTS
    input logic             clk_i,    // Clock signal for the destination domain
    input logic             rst_n_i,  // Active-low asynchronous reset
    input logic [WIDTH-1:0] data_i,   // Asynchronous input data
    input logic [WIDTH-1:0] data_o    // Synchronized output data
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Array of registers representing the multi-stage synchronizer chain
  logic [WIDTH-1:0] sync_ff[STAGES];


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Synchronizer chain logic: shifts input data through flip-flop stages to resolve metastability
  always_ff @(posedge clk_i or negedge rst_n_i) begin

    if (!rst_n_i) begin
      // Reset all stages to the defined RESET_VALUE
      for (int i = 0; i < STAGES; i++) sync_ff[i] <= RESET_VALUE;
    end else begin
      // Shift data through the chain: first stage captures input, subsequent stages shift previous values
      sync_ff[0] <= data_i;
      for (int i = 1; i < STAGES; i++) sync_ff[i] <= sync_ff[i-1];
    end

  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Output the value from the final stage of the synchronizer chain
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
