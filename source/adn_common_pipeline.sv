/*

This module implements a 1-deep pipeline register (skid buffer) with a
ready/valid handshake interface on both input and output sides. It provides
backpressure handling to prevent data loss when the downstream consumer is
not ready.

## Functionality

- **Data Storage**: Holds one data word of configurable width (`DATA_WIDTH`)
- **Handshake Protocol**: Ready/valid interface on both input and output
- **Backpressure**: Propagates `ready` signal upstream when pipeline is full
- **Reset**: Active-low asynchronous reset clears the pipeline state

## Behavior

1. When pipeline is empty (`is_full = 0`):
- `data_in_ready_o` is asserted (always ready to accept data)
- On valid input, data is captured into `data_reg` and `is_full` becomes 1

2. When pipeline is full (`is_full = 1`):
- `data_out_valid_o` is asserted with `data_out_o` = `data_reg`
- `data_in_ready_o` mirrors `data_out_ready_i` (backpressure)
- When downstream asserts `data_out_ready_i`, pipeline becomes empty

## Timing

- Data is registered on the rising edge of `clk_i`
- Ready/valid signals are combinational
- Reset is asynchronous active-low

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

  // ---------------------------------------------------------------------------
  // Internal Registers / State
  // ---------------------------------------------------------------------------
  logic [DATA_WIDTH-1:0] data_reg;  // Pipeline data register

  logic                  is_full;  // Pipeline full flag (valid data in data_reg)
  logic                  is_full_next;  // Next-state logic for is_full

  // ---------------------------------------------------------------------------
  // Combinational Logic: Ready/Valid Handshake
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
  // Sequential Logic: State Registers
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

endmodule
