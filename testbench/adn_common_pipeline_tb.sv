module adn_common_pipeline_tb;

  `include "vip/adn_common_tb_headers.sv"
  parameter int DATA_WIDTH = 32;

  // Clock and reset
  logic                  clk_i;
  logic                  arst_ni;

  // Input interface
  logic [DATA_WIDTH-1:0] data_in_i;
  logic                  data_in_valid_i;
  logic                  data_in_ready_o;

  // Output interface
  logic [DATA_WIDTH-1:0] data_out_o;
  logic                  data_out_valid_o;
  logic                  data_out_ready_i;

  logic [DATA_WIDTH-1:0] expected_q[$];

  logic [DATA_WIDTH-1:0] rand_data;
  logic                  rand_valid;
  logic                  rand_ready;


  // Clock generation
  initial clk_i = '0;
  always #5 clk_i <= ~clk_i;

  // Reset generation
  initial begin
    arst_ni <= '0;
    repeat (5) @(posedge clk_i);
    arst_ni <= '1;
  end

  // DUT instantiation
  adn_common_pipeline #(
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .arst_ni         (arst_ni),
      .clk_i           (clk_i),
      .data_in_i       (data_in_i),
      .data_in_valid_i (data_in_valid_i),
      .data_in_ready_o (data_in_ready_o),
      .data_out_o      (data_out_o),
      .data_out_valid_o(data_out_valid_o),
      .data_out_ready_i(data_out_ready_i)
  );

  // Test stimulus
  initial begin
    // Initialize inputs
    data_in_i        <= '0;
    data_in_valid_i  <= 1'b0;
    data_out_ready_i <= 1'b1;

    // Wait for reset
    @(posedge arst_ni);
    @(posedge clk_i);


    //----------------------------------------------------------------------
    // Test 1: Simple data transfer
    //----------------------------------------------------------------------
    $display("Test 1: Simple data transfer");

    data_out_ready_i <= 1'b1;

    data_in_i       <= 32'hDEADBEEF;
    data_in_valid_i <= 1'b1;

    // Wait until input transfer occurs
    do
        @(posedge clk_i);
    while (!(data_in_valid_i && data_in_ready_o));

    // Remove valid after handshake
    data_in_valid_i <= 1'b0;

    // Wait until output transfer occurs
    do
        @(posedge clk_i);
    while (!(data_out_valid_o && data_out_ready_i));

    // Check received data
    assert (data_out_o == 32'hDEADBEEF)
    else
        $error("Test 1 failed: Expected 0xDEADBEEF, Got 0x%08h", data_out_o);

    $display("Test 1 passed");




    //----------------------------------------------------------------------
    // Test 2: True Back-to-Back Transfers
    //----------------------------------------------------------------------
    $display("Test 2: Back-to-back transfers");

    data_out_ready_i <= 1'b1;

    fork

        // Producer
        begin
            data_in_valid_i <= 1'b1;

            for (int i = 0; i < 5; i++) begin

                // Present next word
                data_in_i <= i;

                // Wait until this word is accepted
                do
                    @(posedge clk_i);
                while (!(data_in_valid_i && data_in_ready_o));

            end

            // Deassert valid after the final transfer
            data_in_valid_i <= 1'b0;
        end

        // Consumer
        begin
            for (int i = 0; i < 5; i++) begin

                // Wait until output transfer occurs
                do
                    @(posedge clk_i);
                while (!(data_out_valid_o && data_out_ready_i));

                assert (data_out_o == i)
                else
                    $error("Test 2 failed: Expected %0d, Got %0d",
                           i, data_out_o);

            end
        end

    join

    $display("Test 2 passed");




    //---------------------------------------------------------------------
    // Test 3: Backpressure on output
    //---------------------------------------------------------------------
    $display("Test 3: Backpressure on output");

    // Stall downstream
    data_out_ready_i <= 1'b0;

    // Send one word
    data_in_i       <= 32'hCAFEBABE;
    data_in_valid_i <= 1'b1;

    // Wait until DUT accepts the input
    do
        @(posedge clk_i);
    while (!(data_in_valid_i && data_in_ready_o));

    // Remove valid after handshake
    data_in_valid_i <= 1'b0;

    // Hold backpressure
    repeat (3)
        @(posedge clk_i);

    // Data must remain available while stalled
    assert (data_out_valid_o)
    else
        $error("Test 3 failed: data_out_valid_o deasserted during backpressure");

    assert (data_out_o == 32'hCAFEBABE)
    else
        $error("Test 3 failed: Expected 0xCAFEBABE, Got 0x%08h", data_out_o);

    // Release downstream
    data_out_ready_i <= 1'b1;

    // Wait until output transfer occurs
    do
        @(posedge clk_i);
    while (!(data_out_valid_o && data_out_ready_i));

    // One more clock for the DUT to update its state
    @(posedge clk_i);

    // Pipeline should now be empty
    assert (!data_out_valid_o)
    else
        $error("Test 3 failed: Pipeline not emptied");

    $display("Test 3 passed");




    //---------------------------------------------------------------------
    // Test 4: Random data with random backpressure
    //---------------------------------------------------------------------
    $display("Test 4: Random data with random backpressure");

    expected_q.delete();

    // Initialize interface
    data_in_i        <= '0;
    data_in_valid_i  <= 1'b0;
    data_out_ready_i <= 1'b1;

    repeat (2) @(posedge clk_i);

    // Generate random traffic
    for (int i = 0; i <20; i++) begin

        // Generate random stimulus
        rand_data  = $urandom;
        rand_valid = $urandom_range(0,1);
        rand_ready = $urandom_range(0,1);

        // Drive DUT
        data_in_i        <= rand_data;
        data_in_valid_i  <= rand_valid;
        data_out_ready_i <= rand_ready;

        @(posedge clk_i);

        // Input handshake
        if (rand_valid && data_in_ready_o) begin
        expected_q.push_back(rand_data);
        $display("[%0t] Input Handshake: Accepted Data = 0x%08h, Queue Size = %0d",
                 $time, rand_data, expected_q.size());
    end

        // Output handshake
        if (data_out_valid_o && rand_ready) begin

            logic [DATA_WIDTH-1:0] exp_data;

            assert(expected_q.size() > 0)
                else $fatal(0, "Unexpected output from DUT");

            exp_data = expected_q.pop_front();

            assert(data_out_o == exp_data)
                else
                    $error("Random test mismatch: Expected = 0x%08h, Got = 0x%08h",
                           exp_data, data_out_o);
        end
    end

    // Stop sending data
    data_in_valid_i  <= 1'b0;
    data_out_ready_i <= 1'b1;

    // Drain remaining pipeline contents
    while (expected_q.size() > 0) begin

        @(posedge clk_i);

        if (data_out_valid_o) begin

            logic [DATA_WIDTH-1:0] exp_data;

            exp_data = expected_q.pop_front();

            assert(data_out_o == exp_data)
                else
                    $error("Drain mismatch: Expected = 0x%08h, Got = 0x%08h",
                           exp_data, data_out_o);
        end
    end

    // Pipeline should now be empty
    @(posedge clk_i);

    assert(!data_out_valid_o)
        else $error("Pipeline not empty after drain");

    $display("Test 4 passed");
    $finish;
  end

  // Timeout watchdog
  initial begin
    #10000000;
    $error("Testbench timeout");
    $finish;
  end

  // Waveform dumping
  initial begin
    $dumpfile("adn_common_pipeline_tb.vcd");
    $dumpvars(0, adn_common_pipeline_tb);
  end

endmodule

