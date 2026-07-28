  covergroup pipeline_cov @(posedge clk_i);

    // Reset
    cp_reset: coverpoint arst_ni {
      bins asserted = {0}; bins deasserted = {1};
    }

    // Internal state
    cp_is_full: coverpoint dut.is_full {
      bins empty = {0};
      bins full = {1};
      bins empty_to_full = (0 => 1);
      bins full_to_empty = (1 => 0);
    }

    cp_is_full_next: coverpoint dut.is_full_next {bins next_empty = {0}; bins next_full = {1};}

    cp_is_empty: coverpoint (!dut.is_full) {bins not_empty = {0}; bins empty = {1};}

    // Ready/Valid
    cp_in_valid: coverpoint data_in_valid_i;
    cp_in_ready: coverpoint data_in_ready_o;
    cp_out_valid: coverpoint data_out_valid_o;
    cp_out_ready: coverpoint data_out_ready_i;

    // Handshakes
    cp_accept: coverpoint (data_in_valid_i && data_in_ready_o);

    cp_transfer: coverpoint (data_out_valid_o && data_out_ready_i);

    cp_backpressure: coverpoint (data_out_valid_o && !data_out_ready_i);

    cp_simultaneous :
            coverpoint (data_in_valid_i &&
                        data_in_ready_o &&
                        data_out_valid_o &&
                        data_out_ready_i);

    // Data
    cp_data: coverpoint data_in_i {
      bins zero = {32'h00000000};
      bins all_ones = {32'hFFFFFFFF};
      bins alternating_A = {32'hAAAAAAAA};
      bins alternating_5 = {32'h55555555};
      bins others = default;
    }

    // Crosses
    cross cp_in_valid, cp_out_ready;
    cross cp_is_full, cp_in_valid;
    cross cp_is_full, cp_out_ready;
    cross cp_is_full, cp_in_ready;
    cross cp_is_full, cp_out_valid;

  endgroup
