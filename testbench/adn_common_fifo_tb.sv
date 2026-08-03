/*

| TEST CASE   | DATE       | AUTHOR | DESCRIPTION                                                                       |
|-------------|------------|--------|-----------------------------------------------------------------------------------|
| TC_001      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Reset behavior (idle reset)                                   |
| TC_002      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Basic handshake-based write/read sequence                     |
| TC_003      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Full and backpressure behavior                                |
| TC_004      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Empty / underflow protection                                  |
| TC_005      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Overflow protection (write while full, not draining)          |
| TC_006      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Simultaneous read/write, incl. empty-bypass corner case       |
| TC_007      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Back-to-back full-throughput streaming                        |
| TC_008      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Data integrity patterns (0, all-1, walking-1, alternating)    |
| TC_009      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Randomized concurrent read/write stress                       |
| TC_010      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Reset during operation (mid-stream reset)                     |
| TC_011      | 2026-08-03 | Md Sakhawat Hossain Sabbir | Mode-specific latency check (pipeline vs fall-through)        |


| REVISION | DATE       | AUTHOR                     | DESCRIPTION                                            |
|----------|------------|----------------------------|--------------------------------------------------------|
| 0.1      | 2026-08-03 | MD Sakhawat Hossain Sabbir | Initial version                                        |
| 1.0      | 2026-08-03 | MD Sakhawat Hossain Sabbir | Stable release                                         |

Author : MD Sakhawat Hossain Sabbir (sabbirone939@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_fifo_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/adn_common_tb_headers.sv"


  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // PARAMETERS 
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  parameter int DATA_WIDTH = 32;
  parameter int FIFO_SIZE = 2;  // FIFO depth = 2^FIFO_SIZE
  parameter bit PIPELINED = 1;
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  localparam int FIFO_DEPTH = (1 << FIFO_SIZE);
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic                  clk_i;
  logic                  arst_ni;

  logic [DATA_WIDTH-1:0] data_in_i;
  logic                  data_in_valid_i;
  logic                  data_in_ready_o;

  logic [   FIFO_SIZE:0] count_o;

  logic [DATA_WIDTH-1:0] data_out_o;
  logic                  data_out_valid_o;
  logic                  data_out_ready_i;

  logic [DATA_WIDTH-1:0] sb_exp_data;
  logic [DATA_WIDTH-1:0] ref_fifo                                     [$];


  wire                   in_hs = data_in_valid_i & data_in_ready_o;
  wire                   out_hs = data_out_valid_o & data_out_ready_i;
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                    error_count;
  int                    error_before;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INTERFACES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DUT 
  //////////////////////////////////////////////////////////////////////////////////////////////////
  adn_common_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_SIZE (FIFO_SIZE),
      .PIPELINED (PIPELINED)
  ) dut (
      .arst_ni         (arst_ni),
      .clk_i           (clk_i),
      .data_in_i       (data_in_i),
      .data_in_valid_i (data_in_valid_i),
      .data_in_ready_o (data_in_ready_o),
      .count_o         (count_o),
      .data_out_o      (data_out_o),
      .data_out_valid_o(data_out_valid_o),
      .data_out_ready_i(data_out_ready_i)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  task automatic tb_error(input string msg);
    begin
      error_count++;
      $error("%s", msg);
    end
  endtask
  task automatic reset_fifo();
    begin
      arst_ni          = 1'b0;
      data_in_i        = '0;
      data_in_valid_i  = 1'b0;
      data_out_ready_i = 1'b0;

      repeat (3) @(posedge clk_i);

      arst_ni = 1'b1;
      @(posedge clk_i);

      assert (count_o == 0)
      else tb_error("FIFO COUNT NOT ZERO AFTER RESET");
      assert (!data_out_valid_o)
      else tb_error("OUTPUT VALID HIGH AFTER RESET");
      assert (data_in_ready_o)
      else tb_error("INPUT READY LOW AFTER RESET");
    end
  endtask


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SCOREBOARD
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      ref_fifo.delete();
    end else begin
      if (in_hs) ref_fifo.push_back(data_in_i);

      if (out_hs) begin
        if (ref_fifo.size() == 0) begin
          tb_error("SCOREBOARD UNDERFLOW: read handshake with empty reference model");
        end else begin
          sb_exp_data = ref_fifo.pop_front();
          if (data_out_o !== sb_exp_data) begin
            tb_error($sformatf("DATA MISMATCH: EXPECTED=%h GOT=%h", sb_exp_data, data_out_o));
          end
        end
      end
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DRIVER
  //////////////////////////////////////////////////////////////////////////////////////////////////
  task automatic write_item(input logic [DATA_WIDTH-1:0] data);
    begin
      @(negedge clk_i);
      data_in_i       = data;
      data_in_valid_i = 1'b1;

      do @(posedge clk_i); while (!data_in_ready_o);

      @(negedge clk_i);
      data_in_valid_i = 1'b0;
      data_in_i       = 'x;
    end
  endtask

  task automatic read_item(output logic [DATA_WIDTH-1:0] data);
    begin
      @(negedge clk_i);
      data_out_ready_i = 1'b1;

      do @(posedge clk_i); while (!data_out_valid_o);

      data = data_out_o;

      @(negedge clk_i);
      data_out_ready_i = 1'b0;
    end
  endtask

  task automatic read_and_check();
    logic [DATA_WIDTH-1:0] actual;
    begin
      read_item(actual);
    end
  endtask
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TC_001:Reset behavior (idle reset) 
  task automatic reset_test_basic();
    begin
      error_before = error_count;
      $display("TC_001: RESET BEHAVIOR ");
      reset_fifo();
      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask


  // TC_002:Basic handshake-based write/read sequence
  task automatic basic_test();
    begin
      error_before = error_count;
      $display("TC_002: BASIC WRITE/READ");
      reset_fifo();

      write_item(32'hAAAA_BBBB);
      write_item(32'hCCCC_DDDD);

      read_and_check();
      read_and_check();

      @(posedge clk_i);
      assert (count_o == 0)
      else tb_error("FIFO NOT EMPTY AFTER BASIC TEST");

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask


  // TC_003:Full and backpressure behavior
  task automatic full_test();
    integer i;
    begin
      error_before = error_count;
      $display("TC_003: FULL / BACKPRESSURE");
      reset_fifo();

      for (i = 0; i < FIFO_DEPTH; i++) write_item(i);

      @(posedge clk_i);
      assert (count_o == FIFO_DEPTH)
      else tb_error("FIFO DID NOT REACH FULL");
      assert (!data_in_ready_o)
      else tb_error("READY HIGH WHEN FIFO FULL");

      // backpressure release: a simultaneous read+write while full must
      // be admitted (ready follows data_out_ready_i when full) and the
      // count must stay pinned at capacity
      @(negedge clk_i);
      data_in_i        = 32'hF0F0_F0F0;
      data_in_valid_i  = 1'b1;
      data_out_ready_i = 1'b1;
      @(posedge clk_i);
      data_in_valid_i  = 1'b0;
      data_out_ready_i = 1'b0;
      data_in_i        = 'x;
      @(posedge clk_i);

      assert (count_o == FIFO_DEPTH)
      else tb_error("COUNT CHANGED AFTER SIMULTANEOUS FULL READ/WRITE");

      // drain everything scoreboard verifies data integrity end-to-end
      while (count_o != 0) read_and_check();

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask


  //TC_004:Empty / underflow protection
  task automatic empty_underflow_test();
    integer i;
    begin
      error_before = error_count;
      $display(" TC_004: EMPTY / UNDERFLOW ");
      reset_fifo();

      assert (!data_out_valid_o)
      else tb_error("VALID HIGH ON EMPTY FIFO");

      // attempt to read from an empty FIFO
      data_out_ready_i = 1'b1;
      repeat (3) begin
        @(posedge clk_i);
        assert (!data_out_valid_o)
        else tb_error("VALID ASSERTED DURING UNDERFLOW ATTEMPT");
      end
      data_out_ready_i = 1'b0;

      // fill then fully drain, re-check empty flags
      for (i = 0; i < FIFO_DEPTH; i++) write_item(i);
      for (i = 0; i < FIFO_DEPTH; i++) read_and_check();

      @(posedge clk_i);
      assert (count_o == 0)
      else tb_error("FIFO NOT EMPTY AFTER DRAIN");
      assert (!data_out_valid_o)
      else tb_error("VALID HIGH WHEN FIFO EMPTY");

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask


  //TC_005:Overflow protection (write while full, not draining) 
  task automatic overflow_test();
    integer i;
    logic [FIFO_SIZE:0] count_before;
    begin
      error_before = error_count;
      $display("TC_005: OVERFLOW PROTECTION");
      reset_fifo();

      for (i = 0; i < FIFO_DEPTH; i++) write_item(i);
      @(posedge clk_i);
      assert (!data_in_ready_o)
      else tb_error("FIFO ACCEPTING DATA WHEN FULL");

      count_before = count_o;

      // extra write attempt while full and NOT draining must be ignored
      @(negedge clk_i);
      data_in_i       = 32'hDEAD_BEEF;
      data_in_valid_i = 1'b1;
      @(posedge clk_i);
      data_in_valid_i = 1'b0;
      data_in_i       = 'x;
      @(posedge clk_i);

      assert (count_o == count_before)
      else tb_error("FIFO COUNT CHANGED AFTER OVERFLOW ATTEMPT");

      // old data must still be intact and in order
      for (i = 0; i < FIFO_DEPTH; i++) read_and_check();

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask


  //TC_006:Simultaneous read/write, incl. empty-bypass corner case  
  task automatic simultaneous_test();
    begin
      error_before = error_count;
      $display("TC_006: SIMULTANEOUS READ/WRITE");
      reset_fifo();

      //only valid for fall-through (non-pipelined)
      if (!PIPELINED) begin
        @(negedge clk_i);
        data_in_i        = 32'h1111_1111;
        data_in_valid_i  = 1'b1;
        data_out_ready_i = 1'b1;
        @(posedge clk_i);
        data_in_valid_i  = 1'b0;
        data_out_ready_i = 1'b0;
        data_in_i        = 'x;
        @(posedge clk_i);
        assert (count_o == 0)
        else tb_error("UNEXPECTED COUNT AFTER EMPTY-BYPASS SIMULTANEOUS XFER");
      end else begin
        $display("SKIP: empty-bypass check skipped in PIPELINED mode");
      end

      //behavior differs by mode
      write_item(32'h2222_2222);
      write_item(32'h3333_3333);

      @(negedge clk_i);
      data_in_i        = 32'h4444_4444;
      data_in_valid_i  = 1'b1;
      data_out_ready_i = 1'b1;
      @(posedge clk_i);
      data_in_valid_i  = 1'b0;
      data_out_ready_i = 1'b0;
      data_in_i        = 'x;
      @(posedge clk_i);

      if (!PIPELINED) begin
        assert (count_o == 2)
        else tb_error("COUNT CHANGED DURING NON-EMPTY SIMULTANEOUS XFER");
      end else begin
        $display(
            "NOTE: PIPELINED mode - skipping strict count assertion for simultaneous transfer");
      end

      // drain remaining items & scoreboard checks ordering
      while (count_o != 0) read_and_check();

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask

  //TC_007:Back-to-back full-throughput streaming
  task automatic streaming_test();
    integer i;
    integer num;
    begin
      error_before = error_count;
      num          = 4 * FIFO_DEPTH;
      $display("TC_007: BACK-TO-BACK STREAMING");
      reset_fifo();

      // consumer always ready; producer pushes as fast as backpressure allows
      data_out_ready_i = 1'b1;

      for (i = 0; i < num; i++) begin
        @(negedge clk_i);
        data_in_i       = i;
        data_in_valid_i = 1'b1;
        do @(posedge clk_i); while (!data_in_ready_o);
      end

      @(negedge clk_i);
      data_in_valid_i = 1'b0;

      while (count_o != 0) @(posedge clk_i);
      @(posedge clk_i);
      data_out_ready_i = 1'b0;

      assert (count_o == 0)
      else tb_error("FIFO NOT DRAINED AFTER STREAMING TEST");
      assert (ref_fifo.size() == 0)
      else tb_error("REFERENCE MODEL NOT EMPTY AFTER STREAMING TEST");

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask

  //TC_008:Data integrity patterns (0, all-1, walking-1, alternating) 
  task automatic data_pattern_test();
    logic [DATA_WIDTH-1:0] patterns    [$];
    logic [DATA_WIDTH-1:0] alt_pattern;
    int                    idx;
    int                    b;
    begin
      error_before = error_count;
      $display("TC_008: DATA INTEGRITY PATTERNS");
      reset_fifo();

      alt_pattern = '0;
      for (b = 0; b < DATA_WIDTH; b++) alt_pattern[b] = b[0];

      patterns.push_back('0);
      patterns.push_back('1);
      patterns.push_back(alt_pattern);
      for (b = 0; b < DATA_WIDTH; b++) patterns.push_back(1 << b);  // walking-1
      patterns.push_back($urandom);

      foreach (patterns[i]) begin
        write_item(patterns[i]);
        if (count_o == FIFO_DEPTH || i == patterns.size() - 1) begin
          while (count_o > 0) read_and_check();
        end
      end

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask

  //TC_009:Randomized concurrent read/write stress 
  task automatic random_test();
    int i;
    int num_cycles;
    begin
      error_before = error_count;
      num_cycles   = 500;
      $display("TC_009: RANDOM CONCURRENT STRESS");
      reset_fifo();

      for (i = 0; i < num_cycles; i++) begin
        @(negedge clk_i);

        if (!data_in_valid_i || data_in_ready_o) begin
          if ($urandom_range(0, 9) < 7) begin
            data_in_i       = $urandom;
            data_in_valid_i = 1'b1;
          end else begin
            data_in_valid_i = 1'b0;
          end
        end

        data_out_ready_i = ($urandom_range(0, 9) < 7);

        @(posedge clk_i);
      end
      data_in_valid_i  = 1'b0;

      // drain remaining items
      data_out_ready_i = 1'b1;
      while (count_o != 0) @(posedge clk_i);
      @(posedge clk_i);
      data_out_ready_i = 1'b0;

      assert (ref_fifo.size() == 0)
      else tb_error("REFERENCE MODEL NOT EMPTY AFTER RANDOM TEST DRAIN");

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask

  //TC_010:Reset during operation (mid-stream reset) 
  task automatic reset_during_operation_test();
    begin
      error_before = error_count;
      $display("TC_010: RESET DURING OPERATION");
      reset_fifo();

      write_item(32'hAAAA);
      write_item(32'hBBBB);

      assert (count_o != 0)
      else tb_error("FIFO EMPTY BEFORE MID-OPERATION RESET");

      arst_ni          = 1'b0;
      data_in_valid_i  = 1'b0;
      data_out_ready_i = 1'b0;

      repeat (3) @(posedge clk_i);
      arst_ni = 1'b1;
      @(posedge clk_i);

      assert (count_o == 0)
      else tb_error("FIFO NOT EMPTY AFTER MID-OPERATION RESET");
      assert (!data_out_valid_o)
      else tb_error("VALID HIGH AFTER MID-OPERATION RESET");
      assert (ref_fifo.size() == 0)
      else tb_error("REFERENCE MODEL NOT CLEARED ON RESET");

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask


  // TC_011:Mode-specific latency check (pipeline vs fall-through)
  task automatic mode_latency_test();
    logic [DATA_WIDTH-1:0] data;
    begin
      error_before = error_count;
      $display("TC_011: MODE-SPECIFIC LATENCY");
      reset_fifo();

      data = 32'h1234_5678;

      if (PIPELINED) begin
        @(negedge clk_i);
        data_in_i       = data;
        data_in_valid_i = 1'b1;
        @(posedge clk_i);
        data_in_valid_i = 1'b0;

        // pipelined FIFO: output only valid one cycle AFTER the write
        assert (!data_out_valid_o)
        else tb_error("PIPELINE MODE: DATA VISIBLE ON WRITE CYCLE");
        wait (data_out_valid_o);
        assert (data_out_o == data)
        else tb_error("PIPELINE MODE: DATA ERROR");

        data_out_ready_i = 1'b1;
        @(posedge clk_i);
        data_out_ready_i = 1'b0;
      end else begin
        $display("SKIP : PIPELINED MODE ASSUMED FALSE, TESTING FALL-THROUGH BYPASS");

        @(negedge clk_i);
        data_in_i       = data;
        data_in_valid_i = 1'b1;

        // fall-through FIFO: empty FIFO bypasses combinationally, same cycle
        #1;
        assert (data_out_valid_o)
        else tb_error("FALL-THROUGH MODE: VALID NOT ASSERTED SAME CYCLE");
        assert (data_out_o == data)
        else tb_error("FALL-THROUGH MODE: DATA ERROR");

        data_out_ready_i = 1'b1;
        @(posedge clk_i);
        data_in_valid_i  = 1'b0;
        data_out_ready_i = 1'b0;
      end

      if (error_count == error_before) note_case(1'b1);
      else note_case(1'b0);
    end
  endtask
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //ASSERTIONS
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  // count never exceeds depth
  property p_no_overflow;
    @(posedge clk_i) disable iff (!arst_ni) count_o <= FIFO_DEPTH;
  endproperty
  assert property (p_no_overflow)
  else tb_error("ASSERTION: COUNT EXCEEDS FIFO DEPTH");

  // reset clears the FIFO
  property p_reset_clears;
    @(posedge clk_i) !arst_ni |-> count_o == 0;
  endproperty
  assert property (p_reset_clears)
  else tb_error("ASSERTION: RESET DID NOT CLEAR COUNT");

  // count increments by exactly 1 on a write-only handshake
  property p_count_inc;
    @(posedge clk_i) disable iff (!arst_ni) (in_hs && !out_hs) |=> (count_o == $past(
        count_o
    ) + 1);
  endproperty
  assert property (p_count_inc)
  else tb_error("ASSERTION: COUNT DID NOT INCREMENT ON WRITE");

  // count decrements by exactly 1 on a read-only handshake
  property p_count_dec;
    @(posedge clk_i) disable iff (!arst_ni) (!in_hs && out_hs) |=> (count_o == $past(
        count_o
    ) - 1);
  endproperty
  assert property (p_count_dec)
  else tb_error("ASSERTION: COUNT DID NOT DECREMENT ON READ");

  // count stable on simultaneous handshake or fully idle cycle
  property p_count_stable;
    @(posedge clk_i) disable iff (!arst_ni) (in_hs == out_hs) |=> (count_o == $past(
        count_o
    ));
  endproperty
  assert property (p_count_stable)
  else tb_error("ASSERTION: COUNT CHANGED UNEXPECTEDLY");

  // ready only ever deasserted when full and the consumer is not draining
  property p_ready_low_reason;
    @(posedge clk_i) disable iff (!arst_ni) !data_in_ready_o |-> (count_o == FIFO_DEPTH && !data_out_ready_i);
  endproperty
  assert property (p_ready_low_reason)
  else tb_error("ASSERTION: READY LOW FOR UNEXPECTED REASON");

  //////////////////////////////////////////////////////////////////////////////////////////////
  // COVERAGE
  //////////////////////////////////////////////////////////////////////////////////////////////

  covergroup fifo_cov @(posedge clk_i);
    option.per_instance = 1;

    WRITE: coverpoint data_in_valid_i;
    READ: coverpoint data_out_ready_i;

    COUNT: coverpoint count_o {
      bins empty = {0}; bins middle = {[1 : FIFO_DEPTH - 1]}; bins full = {FIFO_DEPTH};
    }

    MODE: coverpoint PIPELINED;

    DATA_PATTERN: coverpoint data_in_i {bins zero = {'0}; bins ones = {'1}; bins others = default;}

    WR_RD: cross data_in_valid_i, data_out_ready_i;
    COUNT_MODE: cross COUNT, MODE;
  endgroup

  fifo_cov fifo_cov_inst = new();
  //////////////////////////////////////////////////////////////////////////////////////////////
  // CLOCK 
  //////////////////////////////////////////////////////////////////////////////////////////////

  initial begin
    clk_i = 1'b0;
    forever #5 clk_i = ~clk_i;
  end

  // main initial
  initial begin
    reset_fifo();

    case (test_name)
      "reset":        reset_during_operation_test();
      "reset_basic":  reset_test_basic();
      "basic":        basic_test();
      "full":         full_test();
      "empty":        empty_underflow_test();
      "underflow":    empty_underflow_test();
      "overflow":     overflow_test();
      "simultaneous": simultaneous_test();
      "streaming":    streaming_test();
      "pattern":      data_pattern_test();
      "random":       random_test();
      "fall":         mode_latency_test();  // no-ops the pipelined branch internally
      "pipeline":     mode_latency_test();  // no-ops the fall-through branch internally

      default: $error("UNKNOWN TEST : %s", test_name);
    endcase

    $display("/////////////////////////////////");
    $display("PIPELINED MODE = %0d", PIPELINED);
    $display("ERROR COUNT = %0d", error_count);
    $display("/////////////////////////////////");
    $finish;
  end

endmodule
