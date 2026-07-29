/*

### Purpose
The `adn_common_synchronizer` module is a parameterized multi-stage flip-flop synchronizer designed to safely transfer asynchronous signals between different clock domains. It mitigates metastability issues by passing the input data through a configurable number of sequential register stages before outputting the synchronized signal.

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
    parameter int               WIDTH       = 1,   // Width of the data bus
    parameter int               STAGES      = 2,   // Number of synchronization stages
    parameter logic [WIDTH-1:0] RESET_VALUE = '0   // Value of registers during reset
) (
    // PORTS
    input logic             clk_i,    // Clock input
    input logic             rst_n_i,  // Active-low asynchronous reset
    input logic [WIDTH-1:0] data_i,   // Asynchronous input data
    output logic [WIDTH-1:0] data_o   // Synchronized output data
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Array of registers representing the synchronization chain stages
  logic [WIDTH-1:0] sync_ff[STAGES];


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Synchronizer chain logic: shifts data through the register array to resolve metastability
  always_ff @(posedge clk_i or negedge rst_n_i) begin

    if (!rst_n_i) begin
      // Asynchronous reset: initialize all stages to the defined reset value
      for (int i = 0; i < STAGES; i++) sync_ff[i] <= RESET_VALUE;
    end else begin
      // Shift operation: input data enters the first stage, subsequent stages capture previous stage
      sync_ff[0] <= data_i;
      for (int i = 1; i < STAGES; i++) sync_ff[i] <= sync_ff[i-1];
    end

  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Output the final stage of the synchronization chain
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
