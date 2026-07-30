/*

This module implements a synchronous one-hot ring counter. It rotates a single high bit through a register of a specified width on each clock cycle when enabled, providing a simple circular shift register functionality.

### Usage

To use this module, instantiate it in your design and specify the `DATA_WIDTH` parameter to define the number of states in the ring.

```systemverilog
adn_common_ring_counter #(
    .DATA_WIDTH(8)
) u_ring_counter (
    .clk    (clk),
    .rst_n  (rst_n),
    .enable (enable),
    .data   (ring_data)
);
```

- **`clk`**: Connect to the system clock.
- **`rst_n`**: Connect to an active-low reset signal. Upon reset, the counter initializes to `100...0`.
- **`enable`**: When high, the counter shifts the high bit to the next position on the rising edge of the clock.
- **`data`**: The one-hot encoded output vector.

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

  // Sequential block to handle reset and rotation logic
  always_ff @(posedge clk) begin

    // Asynchronous/Synchronous reset logic
    if (~rst_n) begin

      // Initialize one-hot state
      ring_counter <= RESET_VALUE;

    end

    // Rotation logic triggered by enable signal
    else if (enable) begin

      // Rotate bit position around the ring using concatenation
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

  // Simulation-only block to validate parameter constraints
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

  // Formal/Simulation assertion to ensure one-hot property is maintained
  assert property (
    @(posedge clk)
    $onehot(data)
  )
  else
    $error("Ring counter entered invalid state");

`endif

endmodule
