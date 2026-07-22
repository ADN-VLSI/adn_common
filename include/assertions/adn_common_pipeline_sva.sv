module adn_common_pipeline_sva #(
    parameter int DATA_WIDTH = 32
) (
    input logic                  clk_i,
    input logic                  arst_ni,
    input logic [DATA_WIDTH-1:0] data_in_i,
    input logic                  data_in_valid_i,
    input logic                  data_in_ready_o,
    input logic [DATA_WIDTH-1:0] data_out_o,
    input logic                  data_out_valid_o,
    input logic                  data_out_ready_i,
    input logic                  is_full
);

  default clocking cb_clk @(posedge clk_i);
  endclocking
  default disable iff (!arst_ni);

  // Helper flags
  wire in_transfer = data_in_valid_i && data_in_ready_o;
  wire out_transfer = data_out_valid_o && data_out_ready_i;

  // ---------------------------------------------------------------------------
  // 1. Reset Checks
  // ---------------------------------------------------------------------------

  property p_reset_state;
    @(posedge clk_i) !arst_ni |-> (!is_full && !data_out_valid_o);
  endproperty

  check_reset_state :
  assert property (p_reset_state)
  else $error("[SVA ERROR] Pipeline state not cleared during reset!");

  // ---------------------------------------------------------------------------
  // 2. Ready/Valid Protocol Rules
  // ---------------------------------------------------------------------------

  property p_output_data_stable;
    data_out_valid_o && !data_out_ready_i |=> $stable(
        data_out_o
    );
  endproperty

  check_output_data_stable :
  assert property (p_output_data_stable)
  else $error("[SVA ERROR] Output data changed while valid was active!");

  property p_output_valid_stable;
    data_out_valid_o && !data_out_ready_i |=> data_out_valid_o;
  endproperty

  check_output_valid_stable :
  assert property (p_output_valid_stable)
  else $error("[SVA ERROR] Output valid dropped without handshake!");

  // ---------------------------------------------------------------------------
  // 3. Data Integrity Checks
  // ---------------------------------------------------------------------------

  property p_data_propagation;
    in_transfer |=> (data_out_o == $past(
        data_in_i
    ));
  endproperty

  check_data_propagation :
  assert property (p_data_propagation)
  else $error("[SVA ERROR] Transferred data corrupted in register!");

  // ---------------------------------------------------------------------------
  // 4. Upstream Protocol Assumption
  // ---------------------------------------------------------------------------

  property p_input_data_stable;
    data_in_valid_i && !data_in_ready_o |=> $stable(
        data_in_i
    ) && data_in_valid_i;
  endproperty

  assume_input_data_stable :
  assume property (p_input_data_stable)
  else
    $warning(
        "[SVA WARNING] Upstream changed data/valid prior to ready! This may be a protocol violation."
    );

  // ---------------------------------------------------------------------------
  // 5. Functional Coverage
  // ---------------------------------------------------------------------------
  cover_single_transfer :
  cover property (in_transfer ##1 out_transfer);
  cover_backpressure :
  cover property (is_full && !data_out_ready_i);
  cover_simultaneous_in_out :
  cover property (in_transfer && out_transfer);

endmodule


// =============================================================================
// This binds the assertion module directly inside the target RTL module!
// =============================================================================
bind adn_common_pipeline adn_common_pipeline_sva #(
    .DATA_WIDTH(DATA_WIDTH)
) u_adn_common_pipeline_sva (
    .clk_i           (clk_i),
    .arst_ni         (arst_ni),
    .data_in_i       (data_in_i),
    .data_in_valid_i (data_in_valid_i),
    .data_in_ready_o (data_in_ready_o),
    .data_out_o      (data_out_o),
    .data_out_valid_o(data_out_valid_o),
    .data_out_ready_i(data_out_ready_i),
    .is_full         (is_full)
);
