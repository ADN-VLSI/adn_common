/*

### Purpose
The `adn_common_pipeline` module implements a single-stage pipeline register with a standard ready/valid handshake protocol. It acts as a buffer to decouple timing paths between upstream and downstream modules, allowing for improved clock frequency by inserting a register stage in the data path while maintaining flow control.

### Use Case
This module is primarily used in high-speed digital designs to break long combinational paths. By inserting this pipeline stage between two modules, you can effectively "cut" the critical path, allowing the design to meet tighter timing constraints. It is ideal for:
- **Inter-module communication:** Buffering data between modules operating on different logic levels or physical distances.
- **Backpressure handling:** Managing data flow when the downstream module is temporarily unable to accept new data (e.g., due to a full FIFO or busy state).
- **Timing closure:** Improving the maximum operating frequency ($F_{max}$) of the design by adding a single cycle of latency in exchange for a shorter combinational path.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-20 | Foez Ahmed      | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of https://github.com/ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/


module adn_common_pipeline #(
    parameter int DATA_WIDTH = 32  // Data bus width
) (
    // Clock and Reset
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // Rising-edge clock

    // Input (Upstream) Interface
    input  logic [DATA_WIDTH-1:0] data_in_i,        // Input data
    input  logic                  data_in_valid_i,  // Input data valid
    output logic                  data_in_ready_o,  // Input ready (backpressure to upstream)

    // Output (Downstream) Interface
    output logic [DATA_WIDTH-1:0] data_out_o,        // Output data
    output logic                  data_out_valid_o,  // Output data valid
    input  logic                  data_out_ready_i   // Output ready (backpressure from downstream)
);

  // ===========================================================================
  // DESIGN BLOCK: Internal Registers / State
  // ===========================================================================

  logic [DATA_WIDTH-1:0] data_reg;  // Pipeline data register

  logic                  is_full;  // Pipeline full flag (valid data in data_reg)
  logic                  is_full_next;  // Next-state logic for is_full

  // ---------------------------------------------------------------------------
  // DESIGN BLOCK: Combinational Logic: Ready/Valid Handshake
  // ---------------------------------------------------------------------------

  // Input ready when pipeline not full, or when full and downstream is ready
  always_comb data_in_ready_o = is_full ? data_out_ready_i : '1;

  // Output data comes from pipeline register
  always_comb data_out_o = data_reg;

  // Output valid when pipeline is full
  always_comb data_out_valid_o = is_full;

  // Next-state logic for pipeline full flag
  // Set when valid input accepted, clear when downstream ready and pipeline full
  always_comb is_full_next = data_in_valid_i ? '1 : (data_out_ready_i ? '0 : is_full);

  // ---------------------------------------------------------------------------
  // DESIGN BLOCK: Sequential Logic: State Registers
  // ---------------------------------------------------------------------------

  // Pipeline full flag with async active-low reset
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      is_full <= '0;
    end else begin
      is_full <= is_full_next;
    end
  end

  // Data register: capture input when valid and ready (pipeline not full)
  always_ff @(posedge clk_i) begin
    if (arst_ni & data_in_valid_i & data_in_ready_o) begin
      data_reg <= data_in_i;
    end
  end

  // ===========================================================================
  // ASSERTION BLOCK: SystemVerilog Assertions (SVA)
  // ===========================================================================

`ifndef SYNTHESIS

  // Default clocking and reset context for properties
  default clocking cb_clk @(posedge clk_i);
  endclocking
  default disable iff (!arst_ni);

  // Internal Helper Handshake Signals
  wire in_transfer = data_in_valid_i && data_in_ready_o;
  wire out_transfer = data_out_valid_o && data_out_ready_i;

  // -------------------------------------------------------------------------
  // 1. Reset Checks
  // -------------------------------------------------------------------------

  // Check that state is clear right after reset is deasserted
  property p_reset_cleanup;
    $rose(
        arst_ni
    ) |-> (!is_full && !data_out_valid_o);
  endproperty

  check_reset_state :
  assert property (p_reset_cleanup)
  else $error("[SVA ERROR] Pipeline state not cleared during reset!");

  // -------------------------------------------------------------------------
  // 2. Ready/Valid Protocol Rules
  // -------------------------------------------------------------------------

  // Output data must remain stable during backpressure
  property p_output_data_stable;
    data_out_valid_o && !data_out_ready_i |=> $stable(
        data_out_o
    );
  endproperty

  check_output_data_stable :
  assert property (p_output_data_stable)
  else $error("[SVA ERROR] Output data changed while valid was active!");

  // Output valid must remain asserted until handshake completes
  property p_output_valid_stable;
    data_out_valid_o && !data_out_ready_i |=> data_out_valid_o;
  endproperty

  check_output_valid_stable :
  assert property (p_output_valid_stable)
  else $error("[SVA ERROR] Output valid dropped without handshake!");

  // -------------------------------------------------------------------------
  // 3. Data Integrity Checks
  // -------------------------------------------------------------------------

  // Transferred input data must land in the output on the next clock cycle
  property p_data_propagation;
    in_transfer |=> (data_out_o == $past(
        data_in_i
    ));
  endproperty

  check_data_propagation :
  assert property (p_data_propagation)
  else $error("[SVA ERROR] Transferred data corrupted in register!");

  // -------------------------------------------------------------------------
  // 4. Upstream Protocol Assumptions
  // -------------------------------------------------------------------------

  // Upstream must maintain valid data until ready is sampled
  property p_input_data_stable;
    data_in_valid_i && !data_in_ready_o |=> $stable(
        data_in_i
    ) && data_in_valid_i;
  endproperty

  assume_input_data_stable :
  assume property (p_input_data_stable)
  else $warning("[SVA WARNING] Upstream changed data/valid prior to ready!");

  // -------------------------------------------------------------------------
  // 5. Functional Coverage
  // -------------------------------------------------------------------------

  cover_single_transfer :
  cover property (in_transfer ##1 out_transfer);
  cover_backpressure :
  cover property (is_full && !data_out_ready_i);
  cover_simultaneous_in_out :
  cover property (in_transfer && out_transfer);

`endif

endmodule
