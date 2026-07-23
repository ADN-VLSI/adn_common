module coverage_pipeline_tb;

    //============================================================
    // Clock and Reset
    //============================================================

    logic clk_i;
    logic arst_ni;

    //============================================================
    // Input Interface
    //============================================================

    logic [31:0] data_in_i;
    logic        data_in_valid_i;
    logic        data_in_ready_o;

    //============================================================
    // Output Interface
    //============================================================

    logic [31:0] data_out_o;
    logic        data_out_valid_o;
    logic        data_out_ready_i;

    //============================================================
    // DUT
    //============================================================

    adn_common_pipeline dut (
        .arst_ni          (arst_ni),
        .clk_i            (clk_i),
        .data_in_i        (data_in_i),
        .data_in_valid_i  (data_in_valid_i),
        .data_in_ready_o  (data_in_ready_o),
        .data_out_o       (data_out_o),
        .data_out_valid_o (data_out_valid_o),
        .data_out_ready_i (data_out_ready_i)
    );

    //============================================================
    // Clock Generation
    //============================================================

    always #5 clk_i = ~clk_i;

    //============================================================
    // Debug Print
    //============================================================

    always @(posedge clk_i) begin
        $display("t=%0t valid_in=%0b ready_in=%0b valid_out=%0b ready_out=%0b full=%0b full_next=%0b",
                 $time,
                 data_in_valid_i,
                 data_in_ready_o,
                 data_out_valid_o,
                 data_out_ready_i,
                 dut.is_full,
                 dut.is_full_next);
    end

    //============================================================
    // Functional Coverage
    //============================================================

    covergroup pipeline_cov @(posedge clk_i);

        // Reset
        cp_reset : coverpoint arst_ni {
            bins asserted   = {0};
            bins deasserted = {1};
        }

        // Internal state
        cp_is_full : coverpoint dut.is_full {
            bins empty = {0};
            bins full  = {1};
            bins empty_to_full = (0 => 1);
            bins full_to_empty = (1 => 0);
        }

        cp_is_full_next : coverpoint dut.is_full_next {
            bins next_empty = {0};
            bins next_full  = {1};
        }

        cp_is_empty : coverpoint (!dut.is_full) {
            bins not_empty = {0};
            bins empty     = {1};
        }

        // Ready/Valid
        cp_in_valid  : coverpoint data_in_valid_i;
        cp_in_ready  : coverpoint data_in_ready_o;
        cp_out_valid : coverpoint data_out_valid_o;
        cp_out_ready : coverpoint data_out_ready_i;

        // Handshakes
        cp_accept :
            coverpoint (data_in_valid_i && data_in_ready_o);

        cp_transfer :
            coverpoint (data_out_valid_o && data_out_ready_i);

        cp_backpressure :
            coverpoint (data_out_valid_o && !data_out_ready_i);

        cp_simultaneous :
            coverpoint (data_in_valid_i &&
                        data_in_ready_o &&
                        data_out_valid_o &&
                        data_out_ready_i);

        // Data
        cp_data : coverpoint data_in_i {
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

    pipeline_cov cov;

    initial begin

        cov = new();

        clk_i = 0;
        arst_ni = 0;
        data_in_i = 0;
        data_in_valid_i = 0;
        data_out_ready_i = 0;

        #10;
        arst_ni = 1;


    //==========================================================
    // Directed test vectors for cp_data coverage
    //==========================================================

    @(negedge clk_i);
    data_in_valid_i  = 1;
    data_out_ready_i = 1;
    data_in_i        = 32'h00000000;

    @(negedge clk_i);
    data_in_i        = 32'hFFFFFFFF;

    @(negedge clk_i);
    data_in_i        = 32'hAAAAAAAA;

    @(negedge clk_i);
    data_in_i        = 32'h55555555;

    //==========================================================
    // Random testing
    //==========================================================

    
    //==========================================================
    // Directed stimulus for cp_data coverage
    //==========================================================
    
    @(negedge clk_i);
    data_in_valid_i  = 1;
    data_out_ready_i = 1;
    data_in_i        = 32'h00000000;
    
    @(negedge clk_i);
    data_in_valid_i  = 1;
    data_out_ready_i = 1;
    data_in_i        = 32'hFFFFFFFF;
    
    @(negedge clk_i);
    data_in_valid_i  = 1;
    data_out_ready_i = 1;
    data_in_i        = 32'hAAAAAAAA;
    
    @(negedge clk_i);
    data_in_valid_i  = 1;
    data_out_ready_i = 1;
    data_in_i        = 32'h55555555;
    
    //==========================================================
    // Random stimulus
    //==========================================================
    
    repeat (20) begin
    @(negedge clk_i);
    
    data_in_valid_i  = $urandom_range(0,1);
    data_out_ready_i = $urandom_range(0,1);
    data_in_i        = $urandom;
end

endmodule

