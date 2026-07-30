/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-30 | Md. Sakib Hasan Shawon | Initial version                                        |
| 1.0      | YYYY-MM-DD | Md. Sakib Hasan Shawon | Stable release                                         |

Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_ring_counter #(
    // Number of flip-flops and number of counter states
    parameter int DATA_WIDTH = 4
) (
    // Clock input
    input  logic clk,

    // Active-low synchronous reset
    input  logic rst_n,

    // Counter enable
    input  logic enable,

    // One-hot ring counter output
    output logic [DATA_WIDTH-1:0] data
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Initial one-hot state loaded during reset
  // The most significant bit is asserted while all other bits are cleared
  localparam logic [DATA_WIDTH-1:0] RESET_VALUE =
      {1'b1,{(DATA_WIDTH-1){1'b0}}};

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  // Internal register that stores the current one-hot counter state    
  logic [DATA_WIDTH-1:0] ring_counter;      

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Drive the module output with the current counter state
  assign data = ring_counter;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk) begin

    if (~rst_n) begin

      // Initialize one-hot state
      ring_counter <= RESET_VALUE;

    end

    else if (enable) begin

      // Rotate bit position around the ring
      ring_counter <= {
          ring_counter[DATA_WIDTH-2:0],
          ring_counter[DATA_WIDTH-1]
      };

    end

  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  `ifdef SIMULATION

  initial begin

    if (DATA_WIDTH < 2) begin
      $error("DATA_WIDTH must be greater than 1");
    end

  end

  `endif

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION

  // Check that exactly one bit is high
  assert property (
    @(posedge clk)
    $onehot(data)
  )
  else
    $error("Ring counter entered invalid state");

`endif

endmodule

