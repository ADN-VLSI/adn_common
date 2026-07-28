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

  `include "coverage/pipeline_cov.sv"

pipeline_cov cov;

  // Test stimulus
  initial begin

    cov = new();

    // Initialize inputs
    data_in_i        <= '0;
    data_in_valid_i  <= 1'b0;
    data_out_ready_i <= 1'b1;

    // Wait for reset
    @(posedge arst_ni);
    @(posedge clk_i);

    // Test 1: Simple data transfer
    $display("Test 1: Simple data transfer");
    data_in_i       <= 32'hDEADBEEF;
    data_in_valid_i <= 1'b1;
    @(posedge clk_i);
    while (!data_in_ready_o) @(posedge clk_i);
    data_in_valid_i <= 1'b0;
    @(posedge clk_i);
    assert (data_out_o == 32'hDEADBEEF)
    else $error("Test 1 failed: data mismatch");
    assert (data_out_valid_o)
    else $error("Test 1 failed: valid not asserted");
    $display("Test 1 passed");

    // Test 2: Back-to-back transfers
    $display("Test 2: Back-to-back transfers");
    for (int i = 0; i < 5; i++) begin
      data_in_i       <= i[DATA_WIDTH-1:0];
      data_in_valid_i <= 1'b1;
      @(posedge clk_i);
      while (!data_in_ready_o) @(posedge clk_i);
    end
    data_in_valid_i <= 1'b0;
    for (int i = 0; i < 5; i++) begin
      @(posedge clk_i);
      while (!data_out_valid_o) @(posedge clk_i);
      assert (data_out_o == i[DATA_WIDTH-1:0])
      else $error("Test 2 failed at iteration %0d", i);
    end
    $display("Test 2 passed");

    // Test 3: Backpressure on output
    $display("Test 3: Backpressure on output");
    data_out_ready_i = 1'b0;
    data_in_i       <= 32'hCAFEBABE;
    data_in_valid_i <= 1'b1;
    @(posedge clk_i);
    while (!data_in_ready_o) @(posedge clk_i);
    data_in_valid_i <= 1'b0;
    // Wait a few cycles with backpressure
    repeat (3) @(posedge clk_i);
    // Release backpressure
    data_out_ready_i = 1'b1;
    @(posedge clk_i);
    while (!data_out_valid_o) @(posedge clk_i);
    assert (data_out_o == 32'hCAFEBABE)
    else $error("Test 3 failed: data mismatch");
    $display("Test 3 passed");

    // Test 4: Random data with random backpressure
    $display("Test 4: Random data with random backpressure");
    for (int i = 0; i < 20; i++) begin
      data_in_i        = $urandom;
      data_in_valid_i  = $urandom_range(0, 1);
      data_out_ready_i = $urandom_range(0, 1);
      @(posedge clk_i);
    end
    data_in_valid_i  = 1'b0;
    data_out_ready_i = 1'b1;
    // Drain the pipeline
    repeat (10) @(posedge clk_i);
    $display("Test 4 passed");

    $display("All tests passed!");
    $finish;
  end

  // Timeout watchdog
  initial begin
    #100000;
    $error("Testbench timeout");
    $finish;
  end

  // Waveform dumping
  initial begin
    $dumpfile("adn_common_pipeline_tb.vcd");
    $dumpvars(0, adn_common_pipeline_tb);
  end

endmodule

