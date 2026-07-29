/*

### Purpose
This module provides a configurable edge detection mechanism for a single-bit input signal. It supports rising edge, falling edge, and dual-edge detection, generating a single-clock-cycle pulse whenever the specified transition occurs on the input signal relative to the system clock.

### Usage
To use this module, instantiate it in your design and set the `EDGE_TYPE` parameter to the desired detection mode:
- `0`: Rising edge detection.
- `1`: Falling edge detection.
- `2`: Dual-edge (both rising and falling) detection.

Connect the system clock (`clk`), active-low reset (`rst_n`), and the target signal (`signal_in`). The `edge_pulse` output will assert high for exactly one clock cycle when the specified transition is detected.

| REVISION | DATE       | AUTHOR                 | DESCRIPTION                                            |
|----------|------------|------------------------|--------------------------------------------------------|
| 0.1      | 2026-07-27 | Md. Sakib Hasan Shawon | Initial version                                        |
| 1.0      | 2026-07-28 | Md. Sakib Hasan Shawon | Stable release                                         |

Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_edge_detect #(
    // Edge detection mode: 0=Falling, 1=Rising, 2=Dual
    parameter int EDGE_TYPE = 0
) (
    // System clock input
    input  logic clk,
    // Active-low asynchronous reset
    input  logic rst_n,
    // Input signal to be monitored for edges
    input  logic signal_in,
    // Output pulse indicating edge detection
    output logic edge_pulse
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Previous sampled value of the input signal used for edge comparison.
  logic signal_prev;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Main sequential block: Synchronous logic to detect transitions and update state.
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      // Reset state: Clear history and output pulse.
      signal_prev <= 1'b0;
      edge_pulse  <= 1'b0;
    end else begin
      // Edge detection logic: Compare current input with previous state based on mode.
      case (EDGE_TYPE)
        // Falling edge detection:
        // Current signal is low and previous signal was high.
        0: edge_pulse <= signal_prev & ~signal_in;
        // Rising edge detection:
        // Current signal is high and previous signal was low.
        1: edge_pulse <= ~signal_prev & signal_in;
        // Both edge detection:
        // Current signal differs from previous sampled value.
        2: edge_pulse <= signal_prev ^ signal_in;
        // Invalid configuration handling.
        // Keep output deasserted for unsupported values.
        default: edge_pulse <= 1'b0;
      endcase

      // Update stored input history for the next clock cycle.
      signal_prev <= signal_in;
    end
  end


`ifdef SIMULATION
  // Simulation-only block: Validate parameter configuration.
  initial begin
    assert (EDGE_TYPE >= 0 && EDGE_TYPE <= 2)
    else $fatal(1, "%m: EDGE_TYPE must be 0 (falling), 1 (rising), or 2 (both).");
  end
`endif

endmodule
