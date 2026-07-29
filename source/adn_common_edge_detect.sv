/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

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

// @foez-bhai, add comments to the parameters, ports
module adn_common_edge_detect #(
    // Edge detection mode:
    // 0 : Rising edge
    // 1 : Falling edge
    // 2 : Both edges
    parameter int EDGE_TYPE = 0
) (
    // System clock.
    input  logic clk,
    // Active-low synchronous reset.
    input  logic rst_n,
    // Input signal to monitor for edge transitions.
    input  logic signal_in,
    // One-clock-cycle pulse asserted when the configured edge is detected.
    output logic edge_pulse
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Previous sampled value of the input signal.
  logic signal_prev;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      // Initialize previous signal state.
      signal_prev <= 1'b0;
      // Disable edge pulse during reset.
      edge_pulse  <= 1'b0;
    end else begin
      // Generate a single-cycle pulse based on the selected edge detection mode.
      case (EDGE_TYPE)
        // Rising edge detection:
        // Current signal is high and previous signal was low.
        0: edge_pulse <= ~signal_prev & signal_in;
        // Falling edge detection:
        // Current signal is low and previous signal was high.
        1: edge_pulse <= signal_prev & ~signal_in;
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
  initial begin
    assert (EDGE_TYPE >= 0 && EDGE_TYPE <= 2)
    else $error("%m: EDGE_TYPE must be 0 (rising), 1 (falling), or 2 (both).");
  end
`endif

endmodule

