/*

| TEST CASE  | DATE       | AUTHOR              | DESCRIPTION                                             |
|------------|------------|---------------------|---------------------------------------------------------|
| TC_RST_01  | 2026-07-30 | Ahasan Ullah Khalid | Asynchronous Reset Assertion                            |
| TC_RST_02  | 2026-07-30 | Ahasan Ullah Khalid | Asynchronous Reset Assertion when Signal is High        |
| TC_RST_03  | 2026-07-30 | Ahasan Ullah Khalid | Reset De-assertion Recovery                             |
| TC_RISE_01 | 2026-07-30 | Ahasan Ullah Khalid | Rising edge detection trigger test (EDGE_TYPE = 0)      |
| TC_RISE_02 | 2026-07-30 | Ahasan Ullah Khalid | Sustained High input test (single-cycle pulse check)    |
| TC_FALL_01 | 2026-07-30 | Ahasan Ullah Khalid | Falling edge detection trigger test (EDGE_TYPE = 1)     |
| TC_FALL_02 | 2026-07-30 | Ahasan Ullah Khalid | Sustained Low input test (single-cycle pulse check)     |
| TC_DUAL_01 | 2026-07-30 | Ahasan Ullah Khalid | Dual edge mode trigger for Rising Edge (EDGE_TYPE = 2)  |
| TC_DUAL_02 | 2026-07-30 | Ahasan Ullah Khalid | Dual edge mode trigger for Falling Edge (EDGE_TYPE = 2) |
| TC_STR_01  | 2026-07-30 | Ahasan Ullah Khalid | Back-to-back toggle stress test at maximum frequency    |
| TC_STR_02  | 2026-07-30 | Ahasan Ullah Khalid | Sub-cycle glitch/pulse edge handling                    |
| TC_ROB_01  | 2026-07-30 | Ahasan Ullah Khalid | Unknown handling for X input and recovery to 0          |
| TC_ROB_02  | 2026-07-30 | Ahasan Ullah Khalid | Unknown handling for X input and recovery to 1          |
| TC_ROB_03  | 2026-07-30 | Ahasan Ullah Khalid | Glitch handling for Z input and recovery to 0           |
| TC_ROB_04  | 2026-07-30 | Ahasan Ullah Khalid | Glitch handling for Z input and recovery to 1           |

| REVISION   | DATE       | AUTHOR              | DESCRIPTION                                             |
|------------|------------|---------------------|---------------------------------------------------------|
| 0.1        | 2026-07-30 | Ahasan Ullah Khalid | Initial version                                         |
| 1.0        | 2026-07-30 | Ahasan Ullah Khalid | Stable release                                          |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_edge_detect_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/adn_common_tb_headers.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam time CLKPeriod = 10ns;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic clk;
  logic rst_n;
  logic signal_in;
  logic edge_pulse_rise;
  logic edge_pulse_fall;
  logic edge_pulse_dual;
  logic signal_in_q;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Instance 1: Rising Edge Detection Mode (EDGE_TYPE = 1)
  adn_common_edge_detect #(
      .EDGE_TYPE(1)
  ) u_rise (
      .clk_i       (clk),
      .rst_n_i     (rst_n),
      .signal_in_i (signal_in),
      .edge_pulse_o(edge_pulse_rise)
  );

  // Instance 2: Falling Edge Detection Mode (EDGE_TYPE = 0)
  adn_common_edge_detect #(
      .EDGE_TYPE(0)
  ) u_fall (
      .clk_i       (clk),
      .rst_n_i     (rst_n),
      .signal_in_i (signal_in),
      .edge_pulse_o(edge_pulse_fall)
  );

  // Instance 1: Dual Edge Detection Mode (EDGE_TYPE = 2)
  adn_common_edge_detect #(
      .EDGE_TYPE(2)
  ) u_dual (
      .clk_i       (clk),
      .rst_n_i     (rst_n),
      .signal_in_i (signal_in),
      .edge_pulse_o(edge_pulse_dual)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //Task to Apply Reset
  task automatic apply_reset();
    rst_n     <= '0;
    signal_in <= '0;
    repeat (2) @(negedge clk);
    rst_n <= '0;
    @(negedge clk);
  endtask

  //Task to drive signal_in on negative clock edge
  task automatic drive_signal_in(input logic value);
    signal_in <= value;
    @(negedge clk);
  endtask

  //Task to check outputs againts expected values
  task automatic check_pulse(input string tc_id, input logic expected_rise,
                             input logic expected_fall, input logic expected_dual);

    bit pass;
    pass = (edge_pulse_rise === expected_rise) &&
           (edge_pulse_fall === expected_fall) &&
           (edge_pulse_dual === expected_dual);

    note_case(pass);

    if (debug || !pass) begin
      if (pass) begin
        $display("\n===========================================================================\n");
        $display("[%s] PASSED\n", tc_id);
        $display("Output Pulse: Rise = %b, Fall = %b, Dual = %b \n", edge_pulse_rise,
                 edge_pulse_fall, edge_pulse_dual);
        $display("Expected Pulse: Rise = %b, Fall = %b, Dual = %b \n", expected_rise,
                 expected_fall, expected_dual);
        $display("\n===========================================================================\n");
      end else begin
        $display("\n===========================================================================\n");
        $display("[%s] FAILED\n", tc_id);
        $display("Output Pulse: Rise = %b, Fall = %b, Dual = %b \n", edge_pulse_rise,
                 edge_pulse_fall, edge_pulse_dual);
        $display("Expected Pulse: Rise = %b, Fall = %b, Dual = %b \n", expected_rise,
                 expected_fall, expected_dual);
        $display("\n===========================================================================\n");
      end
    end
  endtask

  task automatic check_unknown_recovery(input string tc_id, input logic unknown_value,
                                        input logic recover_value);
    signal_in <= unknown_value;
    @(negedge clk);

    if ($isunknown(signal_in)) begin
      if (debug) begin
        $display("\n===========================================================================\n");
        $display("[%s] INFO\n", tc_id);
        $display("Successfully Injected Unknown Input Signal %b \n", unknown_value);
        $display("\n===========================================================================\n");
      end
      if (edge_pulse_rise === '1 || edge_pulse_fall === '1 || edge_pulse_dual === '1) begin
        $display("\n===========================================================================\n");
        $display("[%s] FAILED", tc_id);
        $display("Spurious Pulse Detected During X/Z Input State! Rise:%b Fall:%b Dual:%b",
                 edge_pulse_rise, edge_pulse_fall, edge_pulse_dual);
        $display("\n===========================================================================\n");
      end else begin
        note_case('1);
        $display("\n===========================================================================\n");
        $display("[%s] PASSED", tc_id);
        $display("No spurious high pulse generated while input is %b", unknown_value);
        $display("\n===========================================================================\n");
      end
    end
    signal_in <= recover_value;
    @(negedge clk);
  endtask

  // Individual Test Tasks
  task automatic run_tc_rst_01();
    apply_reset();
    check_pulse("TC_RST_01", '0, '0, '0);
  endtask

  task automatic run_tc_rst_02();
    apply_reset();
    drive_signal_in('1);
    rst_n <= '0;
    #(CLKPeriod / 2);
    check_pulse("TC_RST_02", '0, '0, '0);
    apply_reset();
  endtask

  task automatic run_tc_rst_03();
    apply_reset();
    repeat (2) @(negedge clk);
    drive_signal_in('1);
    check_pulse("TC_RST_03", '1, '0, '1);
  endtask

  task automatic run_tc_rise_01();
    apply_reset();
    drive_signal_in('1);
    check_pulse("TC_RISE_01", '1, '0, '1);
    @(negedge clk);
  endtask

  task automatic run_tc_rise_02();
    apply_reset();
    drive_signal_in('1);
    repeat (4) begin
      @(negedge clk);
      check_pulse("TC_RISE_02", '0, '0, '0);
    end
  endtask

  task automatic run_tc_fall_01();
    apply_reset();
    drive_signal_in('1);
    @(negedge clk);
    drive_signal_in('0);
    check_pulse("TC_FALL_01", '0, '1, '1);
  endtask

  task automatic run_tc_fall_02();
    apply_reset();
    drive_signal_in('1);
    @(negedge clk);
    drive_signal_in('0);
    repeat (4) begin
      @(negedge clk);
      check_pulse("TC_FALL_02", '0, '0, '0);
    end
  endtask

  task automatic run_tc_dual_01();
    apply_reset();
    drive_signal_in('1);
    check_pulse("TC_DUAL_01", '1, '0, '1);
  endtask

  task automatic run_tc_dual_02();
    apply_reset();
    drive_signal_in('1);
    @(negedge clk);
    drive_signal_in('0);
    check_pulse("TC_DUAL_02", '0, '1, '1);
  endtask

  task automatic run_tc_str_01();
    apply_reset();

    // Cycle 1: 0 -> 1
    drive_signal_in('1);
    check_pulse("TC_STR_01a", '1, '0, '1);

    // Cycle 2: 1 -> 0
    drive_signal_in('0);
    check_pulse("TC_STR_01b", '0, '1, '1);

    // Cycle 3: 0 -> 1
    drive_signal_in('1);
    check_pulse("TC_STR_01c", '1, '0, '1);

    // Cycle 4: 1 -> 0
    drive_signal_in('0);
    check_pulse("TC_STR_01d", '0, '1, '1);

    // Return to low steady state
    drive_signal_in('0);
    check_pulse("TC_STR_01e", '0, '0, '0);
  endtask

  task automatic run_tc_str_02();
    apply_reset();

    // Wait until the middle of the clock period
    #(CLKPeriod / 4);
    drive_signal_in('1);
    #(CLKPeriod / 2);
    drive_signal_in('0);
    check_pulse("TC_STR_02", '0, '1, '1);
  endtask

  task automatic run_tc_rob_01();
    apply_reset();
    check_unknown_recovery("TC_ROB_01", 1'bx, '0);
    check_pulse("TC_ROB_01_REC", '0, '0, '0);
  endtask

  task automatic run_tc_rob_02();
    apply_reset();
    check_unknown_recovery("TC_ROB_02", 1'bx, '1);
    check_pulse("TC_ROB_02_REC", '0, '0, '0);
  endtask

  task automatic run_tc_rob_03();
    apply_reset();
    check_unknown_recovery("TC_ROB_03", 1'bz, '0);
    check_pulse("TC_ROB_03_REC", '0, '0, '0);
  endtask

  task automatic run_tc_rob_04();
    apply_reset();
    check_unknown_recovery("TC_ROB_04", 1'bz, '1);
    check_pulse("TC_ROB_04_REC", '0, '0, '0);
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //Clock Generation
  initial begin
    clk = '0;
    forever #(CLKPeriod / 2) clk = ~clk;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    apply_reset();

    case (test_name)
      "TC_RST_01":  run_tc_rst_01();
      "TC_RST_02":  run_tc_rst_02();
      "TC_RST_03":  run_tc_rst_03();
      "TC_RISE_01": run_tc_rise_01();
      "TC_RISE_02": run_tc_rise_02();
      "TC_FALL_01": run_tc_fall_01();
      "TC_FALL_02": run_tc_fall_02();
      "TC_DUAL_01": run_tc_dual_01();
      "TC_DUAL_02": run_tc_dual_02();
      "TC_STR_01":  run_tc_str_01();
      "TC_STR_02":  run_tc_str_02();
      "TC_ROB_01":  run_tc_rob_01();
      "TC_ROB_02":  run_tc_rob_02();
      "TC_ROB_03":  run_tc_rob_03();
      "TC_ROB_04":  run_tc_rob_04();

      "all": begin
        $display("[INFO] Running full test regression suite...");
        run_tc_rst_01();
        run_tc_rst_02();
        run_tc_rst_03();
        run_tc_rise_01();
        run_tc_rise_02();
        run_tc_fall_01();
        run_tc_fall_02();
        run_tc_dual_01();
        run_tc_dual_02();
        run_tc_str_01();
        run_tc_str_02();
        run_tc_rob_01();
        run_tc_rob_02();
        run_tc_rob_03();
        run_tc_rob_04();
      end

      default: begin
        $display("[WARNING] Unrecognized test_name '%s'. Executing full regression...", test_name);
        run_tc_rst_01();
        run_tc_rst_02();
        run_tc_rst_03();
        run_tc_rise_01();
        run_tc_rise_02();
        run_tc_fall_01();
        run_tc_fall_02();
        run_tc_dual_01();
        run_tc_dual_02();
        run_tc_str_01();
        run_tc_str_02();
        run_tc_rob_01();
        run_tc_rob_02();
        run_tc_rob_03();
        run_tc_rob_04();
      end
    endcase

    // Finish simulation
    $finish;
  end
endmodule
