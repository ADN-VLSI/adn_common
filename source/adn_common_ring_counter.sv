/*

The `adn_common_ring_counter` module implements a synchronous one-hot ring counter. It rotates a single high bit through a register of a configurable width, providing a circular shift operation that is useful for state machine sequencing, token passing, or simple pulse generation.

### Usage

To use this module, instantiate it in your design and specify the `DATA_WIDTH` parameter to define the number of states in the ring.

```systemverilog
adn_common_ring_counter #(
    .DATA_WIDTH(8)
) u_ring_counter (
    .clk    (clk),
    .rst_n  (rst_n),
    .enable (enable),
    .data   (counter_out)
);
```

- **`clk`**: Connect to the system clock.
- **`rst_n`**: Connect to an active-low asynchronous or synchronous reset. Upon reset, the counter initializes to `100...0`.
- **`enable`**: When high, the counter shifts the high bit to the next position on the rising edge of the clock.
- **`data`**: The one-hot encoded output vector.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-07-30 | Md. Sakib Hasan Shawon | Initial version                                 |
| 1.0      | YYYY-MM-DD | Md. Sakib Hasan Shawon | Stable release                                  |

Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_ring_counter #(
    // Parameter: DATA_WIDTH defines the number of bits in the ring counter
    parameter int DATA_WIDTH = 4
) (
    // Input: System clock signal
    input  logic clk,

    // Input: Active-low synchronous reset signal
    input  logic rst_n,

    // Input: Enable signal to trigger the rotation of the bit
    input  logic enable,

    // Output: One-hot encoded vector representing the current state
    output logic [DATA_WIDTH-1:0] data
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Localparam: RESET_VALUE defines the initial state (100...0) loaded during reset
  localparam logic [DATA_WIDTH-1:0] RESET_VALUE =
      {1'b1,{(DATA_WIDTH-1){1'b0}}};

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  // Signal: ring_counter holds the internal state of the one-hot register
  logic [DATA_WIDTH-1:0] ring_counter;      

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Assignment: Connect the internal register to the module output port
  assign data = ring_counter;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Block: Sequential logic to update the ring counter state on clock edges
  always_ff @(posedge clk) begin

    if (~rst_n) begin

      // Reset logic: Initialize the counter to the defined RESET_VALUE
      ring_counter <= RESET_VALUE;

    end

    else if (enable) begin

      // Rotation logic: Perform a circular left shift of the one-hot bit
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

  // Block: Simulation-only check to ensure valid parameter configuration
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

  // Assertion: Verify that the output remains one-hot at every clock cycle
  assert property (
    @(posedge clk)
    $onehot(data)
  )
  else
    $error("Ring counter entered invalid state");

`endif

endmodule
