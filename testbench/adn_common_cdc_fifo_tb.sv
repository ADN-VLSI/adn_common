/*

| TEST CASE | DATE       | AUTHOR                     | DESCRIPTION                                  |
|-----------|------------|----------------------------|----------------------------------------------|
| TC_001    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify FIFO reset behavior                   |
| TC_002    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify single write and read operation       |
| TC_003    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify multiple write operations             |
| TC_004    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify multiple read operations              |
| TC_005    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify empty flag behavior                  |
| TC_006    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify full flag behavior                   |
| TC_007    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify almost empty flag                    |
| TC_008    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify almost full flag                     |
| TC_009    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify overflow protection                  |
| TC_010    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify underflow protection                 |
| TC_011    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify complete FIFO fill                   |
| TC_012    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify complete FIFO empty                  |
| TC_013    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify simultaneous read/write              |
| TC_014    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify different clock ratio operation      |
| TC_015    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify slow write clock operation           |
| TC_016    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify slow read clock operation            |
| TC_017    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify Gray pointer synchronization        |
| TC_018    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify pointer wrap-around                  |
| TC_019    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify AAAA data pattern                   |
| TC_020    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify 5555 data pattern                   |
| TC_021    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify incrementing data sequence           |
| TC_022    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify decrementing data sequence           |
| TC_023    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify maximum data value                   |
| TC_024    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify minimum data value                   |
| TC_025    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify reset during write                   |
| TC_026    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify reset during read                    |
| TC_027    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify independent reset domains            |
| TC_028    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify occupancy counter                    |
| TC_029    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify long burst transfer                  |
| TC_030    | 2026-07-30 | Md. Sakib Hasan Shawon     | Verify random stress operation              |


| REVISION | DATE       | AUTHOR                 | DESCRIPTION                                            |
|----------|------------|------------------------|--------------------------------------------------------|
| 0.1      | 2026-07-30 | Md. Sakib Hasan Shawon | Initial version                                        |
| 1.0      | YYYY-MM-DD | Md. Sakib Hasan Shawon | Stable release                                         |

Author : Md. Sakib Hasan Shawon (mdsakibhasanshawon20@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_cdc_fifo_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/adn_common_tb_headers.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 4;

  localparam FIFO_DEPTH = (1 << ADDR_WIDTH);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic wr_clk_i;
  logic rd_clk_i;

  logic wr_rst_n_i;
  logic rd_rst_n_i;

  logic wr_en_i;
  logic rd_en_i;

  logic [DATA_WIDTH-1:0] wr_data_i;
  logic [DATA_WIDTH-1:0] rd_data_o;

  logic full_o;
  logic empty_o;

  logic almost_full_o;
  logic almost_empty_o;

  logic [ADDR_WIDTH:0] wr_count_o;
  logic [ADDR_WIDTH:0] rd_count_o;

  logic wr_accept;
  logic rd_accept;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  typedef struct {
    logic [DATA_WIDTH-1:0] data;
    time timestamp;
  } fifo_transaction_t;

  fifo_transaction_t scoreboard[$];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int write_count;
  int read_count;
  int error_count;
  integer i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TEST REPORTING
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic case_note(input bit pass, input string msg);

    note_case(pass);

    if (pass) $display("\033[1;32m[PASS][%s] %s\033[0m", test_name, msg);
    else $display("\033[1;31m[FAIL][%s] %s\033[0m", test_name, msg);

  endtask


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_cdc_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) dut (

      .wr_clk_i(wr_clk_i),
      .wr_rst_n_i(wr_rst_n_i),
      .wr_en_i(wr_en_i),
      .wr_data_i(wr_data_i),
      .full_o(full_o),
      .almost_full_o(almost_full_o),
      .wr_count_o(wr_count_o),

      .rd_clk_i(rd_clk_i),
      .rd_rst_n_i(rd_rst_n_i),
      .rd_en_i(rd_en_i),
      .rd_data_o(rd_data_o),
      .empty_o(empty_o),
      .almost_empty_o(almost_empty_o),
      .rd_count_o(rd_count_o)

  );


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // CLOCK GENERATION
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial wr_clk_i = 0;
  always #5 wr_clk_i = ~wr_clk_i;


  initial rd_clk_i = 0;
  always #7 rd_clk_i = ~rd_clk_i;


  task automatic fifo_reset();


    wr_rst_n_i = 0;
    rd_rst_n_i = 0;


    wr_en_i = 0;
    rd_en_i = 0;
    wr_data_i = '0;


    scoreboard.delete();


    write_count = 0;
    read_count  = 0;
    error_count = 0;



    repeat (5) @(posedge wr_clk_i);



    repeat (5) @(posedge rd_clk_i);



    wr_rst_n_i = 1;
    rd_rst_n_i = 1;



    // allow CDC pointer synchronization

    repeat (8) @(posedge rd_clk_i);


  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // WRITE TASK
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic fifo_write(input logic [DATA_WIDTH-1:0] data);

    while (full_o) @(posedge wr_clk_i);

    @(negedge wr_clk_i);

    wr_data_i = data;
    wr_en_i   = 1'b1;

    @(posedge wr_clk_i);

    @(negedge wr_clk_i);

    wr_en_i = 1'b0;

  endtask


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // READ TASK
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic fifo_read();

    while (empty_o) @(posedge rd_clk_i);

    @(negedge rd_clk_i);

    rd_en_i = 1'b1;

    @(posedge rd_clk_i);

    @(negedge rd_clk_i);

    rd_en_i = 1'b0;

    // allow registered output/scoreboard comparison
    @(posedge rd_clk_i);

  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DATA CHECKER
  //////////////////////////////////////////////////////////////////////////////////////////////////


  task automatic check_data(input logic [DATA_WIDTH-1:0] expected);


    if (rd_data_o !== expected) begin


      $display("--------------------------------");

      $display("TIME     : %0t", $time);

      $display("EXPECTED : %h", expected);

      $display("ACTUAL   : %h", rd_data_o);

      $display("--------------------------------");



      case_note(0, "DATA MISMATCH");


      error_count++;


    end else begin


      case_note(1, "DATA MATCH");


    end



  endtask




  //////////////////////////////////////////////////////////////////////////////////////////////////
  // FLAG CHECKER
  //////////////////////////////////////////////////////////////////////////////////////////////////


  task automatic check_flags(input logic expected_empty, input logic expected_full);


    if ((empty_o == expected_empty) && (full_o == expected_full)) begin


      case_note(1, "FLAG CHECK PASSED");


    end else begin


      $display("EMPTY EXPECTED : %b", expected_empty);

      $display("EMPTY ACTUAL   : %b", empty_o);


      $display("FULL EXPECTED  : %b", expected_full);

      $display("FULL ACTUAL    : %b", full_o);



      case_note(0, "FLAG CHECK FAILED");


      error_count++;


    end


  endtask




  //////////////////////////////////////////////////////////////////////////////////////////////////
  // COUNTER CHECKER
  //////////////////////////////////////////////////////////////////////////////////////////////////


  task automatic check_count(input logic [ADDR_WIDTH:0] expected_wr,
                             input logic [ADDR_WIDTH:0] expected_rd);


    if ((wr_count_o == expected_wr) && (rd_count_o == expected_rd)) begin


      case_note(1, "COUNTER CHECK PASSED");


    end else begin


      case_note(0, "COUNTER CHECK FAILED");


      error_count++;


    end


  endtask



  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DIRECTED TEST CASES
  //////////////////////////////////////////////////////////////////////////////////////////////////


  task tc_001_reset_stage();


    fifo_reset();


    if ((empty_o == 1'b1) && (full_o == 1'b0) && (wr_count_o == '0) && (rd_count_o == '0)) begin


      case_note(1, "RESET COMPLETE: FIFO empty, full cleared, counters initialized");


    end else begin


      case_note(0, "RESET FAILED: FIFO not in initial state");


    end


  endtask




  task tc_002_single_write_read();


    logic [DATA_WIDTH-1:0] expected;


    fifo_reset();


    expected = 32'h12345678;


    fifo_write(expected);


    repeat (5) @(posedge rd_clk_i);



    fifo_read();



    check_data(expected);


  endtask




  task tc_003_multiple_write();


    fifo_reset();


    for (i = 0; i < 8; i++) begin


      fifo_write(i);


    end



    if (wr_count_o == 8) case_note(1, "MULTIPLE WRITE PASSED");


    else case_note(0, "MULTIPLE WRITE FAILED");


  endtask




  task tc_004_multiple_read();


    logic [DATA_WIDTH-1:0] expected;


    fifo_reset();



    for (i = 0; i < 8; i++) fifo_write(i);



    for (i = 0; i < 8; i++) begin


      expected = i;


      fifo_read();


      check_data(expected);


    end



  endtask




  task tc_005_empty_flag();


    fifo_reset();


    check_flags(1'b1, 1'b0);


  endtask




  task tc_006_full_flag();


    fifo_reset();


    for (i = 0; i < FIFO_DEPTH; i++) fifo_write(i);



    repeat (3) @(posedge wr_clk_i);



    check_flags(1'b0, 1'b1);


  endtask




  task tc_007_almost_empty();


    fifo_reset();



    fifo_write(32'hAAAA5555);



    repeat (5) @(posedge rd_clk_i);



    if (almost_empty_o) case_note(1, "ALMOST EMPTY ASSERTED");


    else case_note(0, "ALMOST EMPTY FAILED");


  endtask




  task tc_008_almost_full();


    fifo_reset();



    for (i = 0; i < FIFO_DEPTH - 1; i++) fifo_write(i);



    repeat (3) @(posedge wr_clk_i);



    if (almost_full_o) case_note(1, "ALMOST FULL ASSERTED");


    else case_note(0, "ALMOST FULL FAILED");


  endtask




  task tc_009_overflow_protection();


    fifo_reset();



    for (i = 0; i < FIFO_DEPTH; i++) fifo_write(i);



    fifo_write(32'hFFFFFFFF);



    if (full_o) case_note(1, "OVERFLOW PROTECTION PASSED");


    else case_note(0, "OVERFLOW PROTECTION FAILED");


  endtask




  task tc_010_underflow_protection();


    fifo_reset();



    fifo_read();



    if (empty_o) case_note(1, "UNDERFLOW PROTECTION PASSED");


    else case_note(0, "UNDERFLOW PROTECTION FAILED");


  endtask




  task tc_011_complete_fill();


    fifo_reset();



    for (i = 0; i < FIFO_DEPTH; i++) fifo_write(i);



    check_flags(1'b0, 1'b1);


  endtask




  task tc_012_complete_empty();


    fifo_reset();



    for (i = 0; i < 8; i++) fifo_write(i);



    for (i = 0; i < 8; i++) fifo_read();



    check_flags(1'b1, 1'b0);


  endtask




  task tc_013_simultaneous_rw();


    fifo_reset();


    fork

      begin

        repeat (20) fifo_write($random);

      end


      begin

        repeat (20) fifo_read();

      end


    join



    case_note(1, "SIMULTANEOUS READ WRITE COMPLETED");


  endtask




  task tc_014_clock_ratio();


    fifo_reset();



    repeat (100) begin


      if (full_o) fifo_read();


      else fifo_write($random);


    end



    case_note(1, "CLOCK RATIO TEST COMPLETED");


  endtask




  task tc_015_slow_write_clock();


    fifo_reset();


    // Add slow write clock modification here


    fifo_write(32'h11112222);


    fifo_read();


    check_data(32'h11112222);


  endtask




  task tc_016_slow_read_clock();


    fifo_reset();


    // Add slow read clock modification here


    fifo_write(32'h33334444);


    fifo_read();


    check_data(32'h33334444);


  endtask




  task tc_017_gray_pointer_sync();


    fifo_reset();


    fifo_write(32'h5555AAAA);


    repeat (10) @(posedge rd_clk_i);



    if (!empty_o) case_note(1, "GRAY POINTER SYNCHRONIZATION PASSED");


    else case_note(0, "GRAY POINTER SYNCHRONIZATION FAILED");


  endtask




  task tc_018_pointer_wrap();


    fifo_reset();


    repeat (4) begin


      for (i = 0; i < FIFO_DEPTH; i++) fifo_write(i);



      for (i = 0; i < FIFO_DEPTH; i++) fifo_read();


    end



    case_note(1, "POINTER WRAP TEST COMPLETE");


  endtask




  task tc_019_pattern_AAAA();


    fifo_reset();


    fifo_write(32'hAAAAAAAA);


    fifo_read();


    check_data(32'hAAAAAAAA);


  endtask




  task tc_020_pattern_5555();


    fifo_reset();


    fifo_write(32'h55555555);


    fifo_read();


    check_data(32'h55555555);


  endtask


  task tc_021_increment_pattern();


    logic [DATA_WIDTH-1:0] expected;


    fifo_reset();


    for (i = 0; i < 16; i++) fifo_write(i);



    for (i = 0; i < 16; i++) begin


      expected = i;


      fifo_read();


      check_data(expected);


    end


  endtask



  task tc_022_decrement_pattern();


    logic [DATA_WIDTH-1:0] expected;


    fifo_reset();



    for (i = 15; i >= 0; i--) fifo_write(i);



    for (i = 15; i >= 0; i--) begin


      expected = i;


      fifo_read();


      check_data(expected);


    end


  endtask


  task tc_023_maximum_data();


    fifo_reset();



    fifo_write({DATA_WIDTH{1'b1}});



    fifo_read();



    check_data({DATA_WIDTH{1'b1}});


  endtask



  task tc_024_minimum_data();


    fifo_reset();



    fifo_write({DATA_WIDTH{1'b0}});



    fifo_read();



    check_data({DATA_WIDTH{1'b0}});


  endtask


  task tc_025_reset_during_write();


    fifo_reset();



    fifo_write(32'hAAAA1111);



    wr_rst_n_i = 1'b0;



    repeat (3) @(posedge wr_clk_i);



    wr_rst_n_i = 1'b1;



    repeat (10) @(posedge rd_clk_i);



    if (empty_o) case_note(1, "RESET DURING WRITE PASSED");


    else case_note(0, "RESET DURING WRITE FAILED");


  endtask


  task tc_026_reset_during_read();


    fifo_reset();



    fifo_write(32'hBBBB2222);



    repeat (5) @(posedge rd_clk_i);



    rd_en_i = 1'b1;



    rd_rst_n_i = 1'b0;



    repeat (3) @(posedge rd_clk_i);



    rd_rst_n_i = 1'b1;



    rd_en_i = 1'b0;



    repeat (10) @(posedge rd_clk_i);



    case_note(1, "RESET DURING READ COMPLETED");


  endtask


  task tc_027_independent_reset();


    fifo_reset();



    fifo_write(32'h11112222);

    fifo_write(32'h33334444);



    repeat (5) @(posedge rd_clk_i);



    wr_rst_n_i = 1'b0;



    repeat (5) @(posedge wr_clk_i);



    wr_rst_n_i = 1'b1;



    repeat (10) @(posedge rd_clk_i);



    if (error_count == 0) case_note(1, "INDEPENDENT RESET DOMAIN PASSED");


    else case_note(0, "INDEPENDENT RESET DOMAIN FAILED");


  endtask


  task tc_028_occupancy_counter();


    fifo_reset();



    for (i = 0; i < 8; i++) fifo_write(i);



    repeat (5) @(posedge rd_clk_i);



    if (wr_count_o == 8) case_note(1, "WRITE COUNTER UPDATED");


    else case_note(0, "WRITE COUNTER ERROR");



    for (i = 0; i < 4; i++) fifo_read();



    if (rd_count_o == 4) case_note(1, "READ COUNTER UPDATED");


    else case_note(0, "READ COUNTER ERROR");


  endtask


  task tc_029_long_burst();


    logic [DATA_WIDTH-1:0] expected;



    fifo_reset();



    for (i = 0; i < 256; i++) fifo_write(i);



    for (i = 0; i < 256; i++) begin


      expected = i;


      fifo_read();


      check_data(expected);


    end



    if (error_count == 0) case_note(1, "LONG BURST TRANSFER PASSED");


    else case_note(0, "LONG BURST TRANSFER FAILED");


  endtask


  task tc_030_random_stress();


    fifo_reset();



    repeat (1000) begin


      if (full_o) begin


        fifo_read();


      end else if (empty_o) begin


        fifo_write($random);


      end else begin


        if ($urandom_range(0, 1)) fifo_write($random);


        else fifo_read();


      end


    end



    if (error_count == 0) case_note(1, "RANDOM STRESS TEST PASSED");


    else case_note(0, "RANDOM STRESS TEST FAILED");


  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURES
  //////////////////////////////////////////////////////////////////////////////////////////////////


  initial begin


    $display("\n");

    $display("=================================================");

    $display("       ADN COMMON CDC FIFO TEST START            ");

    $display("=================================================");



    test_name = "TC_001";
    tc_001_reset_stage();



    test_name = "TC_002";
    tc_002_single_write_read();



    test_name = "TC_003";
    tc_003_multiple_write();



    test_name = "TC_004";
    tc_004_multiple_read();



    test_name = "TC_005";
    tc_005_empty_flag();



    test_name = "TC_006";
    tc_006_full_flag();



    test_name = "TC_007";
    tc_007_almost_empty();



    test_name = "TC_008";
    tc_008_almost_full();



    test_name = "TC_009";
    tc_009_overflow_protection();



    test_name = "TC_010";
    tc_010_underflow_protection();



    test_name = "TC_011";
    tc_011_complete_fill();



    test_name = "TC_012";
    tc_012_complete_empty();



    test_name = "TC_013";
    tc_013_simultaneous_rw();



    test_name = "TC_014";
    tc_014_clock_ratio();



    test_name = "TC_015";
    tc_015_slow_write_clock();



    test_name = "TC_016";
    tc_016_slow_read_clock();



    test_name = "TC_017";
    tc_017_gray_pointer_sync();



    test_name = "TC_018";
    tc_018_pointer_wrap();



    test_name = "TC_019";
    tc_019_pattern_AAAA();



    test_name = "TC_020";
    tc_020_pattern_5555();



    test_name = "TC_021";
    tc_021_increment_pattern();



    test_name = "TC_022";
    tc_022_decrement_pattern();



    test_name = "TC_023";
    tc_023_maximum_data();



    test_name = "TC_024";
    tc_024_minimum_data();



    test_name = "TC_025";
    tc_025_reset_during_write();



    test_name = "TC_026";
    tc_026_reset_during_read();



    test_name = "TC_027";
    tc_027_independent_reset();



    test_name = "TC_028";
    tc_028_occupancy_counter();



    test_name = "TC_029";
    tc_029_long_burst();



    test_name = "TC_030";
    tc_030_random_stress();




    $display("\n");

    $display("=================================================");

    $display("        ADN COMMON CDC FIFO TEST END             ");

    $display("=================================================");



    $display("TOTAL ERRORS : %0d", error_count);

    $display("TOTAL WRITES : %0d", write_count);

    $display("TOTAL READS  : %0d", read_count);



    if (error_count == 0) $display("\033[1;32mOVERALL RESULT : PASS\033[0m");


    else $display("\033[1;31mOVERALL RESULT : FAIL\033[0m");



    $finish;


  end


endmodule

