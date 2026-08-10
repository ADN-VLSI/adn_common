/*

| TEST CASE             | DATE       | AUTHOR       | DESCRIPTION                                                              |
|-----------------------|------------|--------------|--------------------------------------------------------------------------|
| TC_RST_01             | 2026-08-10 | Annim Jannat | Asynchronous reset assertion with no active transfer                     |
| TC_RST_02             | 2026-08-10 | Annim Jannat | Asynchronous reset asserted mid-transfer (valid + both ready)            |
| TC_RST_03             | 2026-08-10 | Annim Jannat | Asynchronous reset asserted while stalled (valid high, neither ready)    |
| TC_BASIC_01           | 2026-08-10 | Annim Jannat | Single-beat transfer with both downstream interfaces ready               |
| TC_BASIC_02           | 2026-08-10 | Annim Jannat | Back-to-back multi-beat transfer, both downstreams always ready          |
| TC_PRI_ONLY_01        | 2026-08-10 | Annim Jannat | Primary ready / secondary not ready - secondary starvation check         |
| TC_SEC_ONLY_01        | 2026-08-10 | Annim Jannat | Secondary ready / primary not ready - primary starvation check           |
| TC_NONE_READY_01      | 2026-08-10 | Annim Jannat | Neither ready initially, then primary alone becomes ready                |
| TC_NONE_READY_02      | 2026-08-10 | Annim Jannat | Directed test of documented priority-drop: neither ready, then both ready|
| TC_STALL_VALID_01     | 2026-08-10 | Annim Jannat | Upstream valid de-asserted mid-stall before either downstream is ready   |
| TC_READY_TOGGLE_01    | 2026-08-10 | Annim Jannat | Valid held constant while both downstream readies toggle independently   |
| TC_WIDTH_ONES_01      | 2026-08-10 | Annim Jannat | Data integrity check with all-ones (max value) data pattern              |
| TC_WIDTH_ZEROS_01     | 2026-08-10 | Annim Jannat | Data integrity check with all-zeros data pattern                         |
| TC_BACK2BACK_STRESS   | 2026-08-10 | Annim Jannat | Continuous input stream with independently toggling downstream readies   |
| TC_RANDOM_01          | 2026-08-10 | Annim Jannat | Fully randomized valid/ready/data stress test over many cycles           |


| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-09 | Annim Jannat    | Initial version                                        |
| 1.0      | 2026-08-10 | Annim Jannat    | Stable release                                         |

Author : Annim Jannat (jannatannim@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/
// @foez-bhai add commments for this testbench module, each test case, variables, signals and tasks,functions.
module adn_common_pipeline_split_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/adn_common_tb_headers.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam time CLKPeriod  = 10ns;
  localparam int  DATA_WIDTH = 8;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                  clk;
  logic                  arst_n;

  // Upstream (input) interface
  logic [DATA_WIDTH-1:0] data_in;
  logic                  data_in_valid;
  logic                  data_in_ready;

  // Downstream - primary
  logic [DATA_WIDTH-1:0] data_out_primary;
  logic                  data_out_primary_valid;
  logic                  data_out_primary_ready;

  // Downstream - secondary
  logic [DATA_WIDTH-1:0] data_out_secondary;
  logic                  data_out_secondary_valid;
  logic                  data_out_secondary_ready;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  bit                     is_clk_edge_aligned;

  logic [DATA_WIDTH-1:0]  primary_exp_q[$];

  logic [DATA_WIDTH-1:0]  secondary_seen_q[$];

  logic                   secondary_valid_dly;
  logic                   secondary_ready_dly;
  logic                   primary_ready_dly;
  int unsigned            drop_event_count;
  int unsigned            primary_xfer_count;
  int unsigned            secondary_xfer_count;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_pipeline_split #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dut (
      .arst_ni                    (arst_n),
      .clk_i                      (clk),

      .data_in_i                  (data_in),
      .data_in_valid_i            (data_in_valid),
      .data_in_ready_o            (data_in_ready),

      .data_out_secondary_o       (data_out_secondary),
      .data_out_secondary_valid_o (data_out_secondary_valid),
      .data_out_secondary_ready_i (data_out_secondary_ready),

      .data_out_primary_o         (data_out_primary),
      .data_out_primary_valid_o   (data_out_primary_valid),
      .data_out_primary_ready_i   (data_out_primary_ready)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Task to Apply Reset
  task automatic apply_reset();
    #100ns;
    clk                      <= '0;
    arst_n                   <= '0;
    data_in                  <= '0;
    data_in_valid            <= '0;
    data_out_primary_ready   <= '0;
    data_out_secondary_ready <= '0;
    primary_exp_q.delete();
    secondary_seen_q.delete();
    secondary_valid_dly      <= '0;
    secondary_ready_dly      <= '0;
    primary_ready_dly        <= '0;
    drop_event_count         <= '0;
    primary_xfer_count       <= '0;
    secondary_xfer_count     <= '0;
    #100ns;
    arst_n <= '1;
    #100ns;
  endtask

  task automatic start_clock();
    fork
      forever #(CLKPeriod / 2) clk <= ~clk;
    join_none
    @(posedge clk);
  endtask

  // Drive the upstream data/valid on a clean clock-aligned window
  task automatic drive_input(input logic [DATA_WIDTH-1:0] data, input logic valid);
    wait (is_clk_edge_aligned);
    data_in       <= data;
    data_in_valid <= valid;
    @(posedge clk);
  endtask

  // Set downstream ready signals independently
  task automatic set_ready(input logic pri_rdy, input logic sec_rdy);
    wait (is_clk_edge_aligned);
    data_out_primary_ready   <= pri_rdy;
    data_out_secondary_ready <= sec_rdy;
    @(posedge clk);
  endtask

  task automatic start_checking();
    fork
      forever
      @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
          primary_exp_q.delete();
          secondary_seen_q.delete();
          secondary_valid_dly <= '0;
          secondary_ready_dly <= '0;
          primary_ready_dly   <= '0;
        end else begin
          #1ns;  // let combinational outputs settle after the edge

          // ---------------------------------------------------------------
          // Check 1: ready arbitration (documented: ready asserted whenever
          // EITHER downstream interface is ready)
          // ---------------------------------------------------------------
          if (data_in_ready !== (data_out_primary_ready | data_out_secondary_ready)) begin
            note_case(0);
            $display("[%s] FAIL [%0t] data_in_ready_o(%b) != pri_rdy(%b) | sec_rdy(%b)",
                      test_name, $realtime, data_in_ready, data_out_primary_ready,
                      data_out_secondary_ready);
          end else begin
            note_case(1);
          end

          // ---------------------------------------------------------------
          // Check 2: no unknowns on live outputs
          // ---------------------------------------------------------------
          if (data_out_primary_valid === 1'bx || data_out_secondary_valid === 1'bx ||
              data_in_ready === 1'bx) begin
            note_case(0);
            $display("[%s] FAIL [%0t] Unknown control signal detected: pri_vld=%b sec_vld=%b in_rdy=%b"
                      ,test_name, $realtime, data_out_primary_valid, data_out_secondary_valid,
                      data_in_ready);
          end else begin
            note_case(1);
          end

          // ---------------------------------------------------------------
          // Track accepted upstream transfers -> push into primary scoreboard
          // (primary has strict priority, so it must observe every accepted
          // beat, in order)
          // ---------------------------------------------------------------
          if (data_in_valid && data_in_ready) begin
            primary_exp_q.push_back(data_in);
            secondary_seen_q.push_back(data_in);
            if (debug) begin
              $display("[%s] UPSTREAM ACCEPTED: data=%0h [%0t]", test_name, data_in, $realtime);
            end
          end

          // ---------------------------------------------------------------
          // Check 3: primary data integrity, strict in-order
          // ---------------------------------------------------------------
          if (data_out_primary_valid && data_out_primary_ready) begin
            primary_xfer_count <= primary_xfer_count + 1;
            if (primary_exp_q.size() == 0) begin
              note_case(0);
              $display("[%s] FAIL [%0t] Unexpected PRIMARY transfer, data=%0h with empty scoreboard"
              ,test_name, $realtime, data_out_primary);
            end else begin
              automatic logic [DATA_WIDTH-1:0] exp = primary_exp_q.pop_front();
              if (data_out_primary !== exp) begin
                note_case(0);
                $display("[%s] FAIL [%0t] PRIMARY data mismatch: exp=%0h got=%0h",
                          test_name, $realtime, exp, data_out_primary);
              end else begin
                note_case(1);
                if (debug) begin
                  $display("[%s] PRIMARY XFER OK: data=%0h [%0t]", test_name, data_out_primary,
                            $realtime);
                end
              end
            end
          end

          // ---------------------------------------------------------------
          // Check 4: secondary data integrity, membership-based (order can
          // legitimately shift because of the documented priority-drop
          // behavior, so we only check the value was something genuinely
          // offered upstream, not strict FIFO order)
          // ---------------------------------------------------------------
          if (data_out_secondary_valid && data_out_secondary_ready) begin
            secondary_xfer_count <= secondary_xfer_count + 1;
            if (secondary_seen_q.size() == 0) begin
              note_case(0);
              $display("[%s] FAIL [%0t] Unexpected SECONDARY transfer, data=%0h with empty scoreboard"
              ,test_name, $realtime, data_out_secondary);
            end else begin
              automatic int idx = -1;
              for (int i = 0; i < secondary_seen_q.size(); i++) begin
                if (secondary_seen_q[i] === data_out_secondary) begin
                  idx = i;
                  break;
                end
              end
              if (idx == -1) begin
                note_case(0);
                $display("[%s] FAIL [%0t] SECONDARY data=%0h not found among offered upstream data",
                          test_name, $realtime, data_out_secondary);
              end else begin
                note_case(1);
                secondary_seen_q.delete(idx);
                if (debug) begin
                  $display("[%s] SECONDARY XFER OK: data=%0h [%0t]", test_name, data_out_secondary,
                            $realtime);
                end
              end
            end
          end

          // ---------------------------------------------------------------
          // Check 5: observe/report the documented priority-drop quirk.
          // Pattern: secondary was valid & stalled (ready low) last cycle,
          // and this cycle both readies are high, yet secondary_valid has
          // dropped instead of completing the transfer.
          // This is EXPECTED (by design, per module warning) - logged only,
          // not treated as a failure.
          // ---------------------------------------------------------------
          if (secondary_valid_dly && !secondary_ready_dly && !primary_ready_dly &&
              data_out_primary_ready && data_out_secondary_ready && !data_out_secondary_valid) begin
            drop_event_count <= drop_event_count + 1;
            $display("[%s] INFO [%0t] Observed documented SECONDARY priority-drop event (count=%0d)", test_name, $realtime, drop_event_count + 1);
          end

          secondary_valid_dly <= data_out_secondary_valid;
          secondary_ready_dly <= data_out_secondary_ready;
          primary_ready_dly   <= data_out_primary_ready;
        end
      end
    join_none
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TEST CASES
  //////////////////////////////////////////////////////////////////////////////////////////////////


  // Hold current data/valid/ready for N cycles (used to let stalls play out)
  task automatic hold_cycles(input int n);
    repeat (n) @(posedge clk);
  endtask

    task automatic run_tc_rst_01();
    apply_reset();
  endtask

  task automatic run_tc_rst_02();
    apply_reset();
    set_ready(1, 1);
    drive_input(8'hA5, 1);
    arst_n <= '0;
    #(CLKPeriod / 2);
    apply_reset();
  endtask

  task automatic run_tc_rst_03();
    // Reset asserted mid-stall (valid high, neither ready)
    apply_reset();
    set_ready(0, 0);
    drive_input(8'h3C, 1);
    hold_cycles(3);
    arst_n <= '0;
    #(CLKPeriod / 2);
    apply_reset();
  endtask

  task automatic run_tc_basic_01();
    // Single beat, both downstreams ready
    apply_reset();
    set_ready(1, 1);
    drive_input(8'h11, 1);
    drive_input(8'h00, 0);
    hold_cycles(3);
  endtask

  task automatic run_tc_basic_02();
    // Back-to-back beats, both downstreams always ready
    apply_reset();
    set_ready(1, 1);
    drive_input(8'h01, 1);
    drive_input(8'h02, 1);
    drive_input(8'h03, 1);
    drive_input(8'h04, 1);
    drive_input(8'h00, 0);
    hold_cycles(3);
  endtask

  task automatic run_tc_pri_only_01();
    // Only primary ready; secondary starved
    apply_reset();
    set_ready(1, 0);
    drive_input(8'h5A, 1);
    hold_cycles(4);
    drive_input(8'h00, 0);
    hold_cycles(2);
  endtask

  task automatic run_tc_sec_only_01();
    // Only secondary ready; primary starved
    apply_reset();
    set_ready(0, 1);
    drive_input(8'hA6, 1);
    hold_cycles(4);
    drive_input(8'h00, 0);
    hold_cycles(2);
  endtask

  task automatic run_tc_none_ready_01();
    // Neither ready initially, then primary alone becomes ready
    apply_reset();
    set_ready(0, 0);
    drive_input(8'h7E, 1);
    hold_cycles(3);
    set_ready(1, 0);
    hold_cycles(3);
    drive_input(8'h00, 0);
    hold_cycles(2);
  endtask

  task automatic run_tc_none_ready_02();
    // Directed test of the documented priority-drop corner case:
    // neither ready for a few cycles, then BOTH become ready together
    apply_reset();
    set_ready(0, 0);
    drive_input(8'hC3, 1);
    hold_cycles(3);
    set_ready(1, 1);
    hold_cycles(3);
    drive_input(8'h00, 0);
    hold_cycles(2);
  endtask

  task automatic run_tc_stall_valid_deassert_01();
    // Valid deasserted while waiting on a stalled downstream
    apply_reset();
    set_ready(0, 0);
    drive_input(8'h2D, 1);
    hold_cycles(2);
    drive_input(8'h00, 0);
    hold_cycles(2);
    set_ready(1, 1);
    hold_cycles(2);
  endtask

  task automatic run_tc_ready_toggle_01();
    // Valid held while both readies toggle independently
    apply_reset();
    drive_input(8'h6F, 1);
    set_ready(1, 0);
    set_ready(0, 1);
    set_ready(0, 0);
    set_ready(1, 1);
    drive_input(8'h00, 0);
    hold_cycles(3);
  endtask

  task automatic run_tc_width_allones_01();
    apply_reset();
    set_ready(1, 1);
    drive_input({DATA_WIDTH{1'b1}}, 1);
    drive_input(8'h00, 0);
    hold_cycles(2);
  endtask

  task automatic run_tc_width_allzeros_01();
    apply_reset();
    set_ready(1, 1);
    drive_input({DATA_WIDTH{1'b0}}, 1);
    drive_input(8'h00, 0);
    hold_cycles(2);
  endtask

  task automatic run_tc_back2back_stress_01();
    // Continuous stream with independently toggling downstream readies
    apply_reset();
    for (int i = 0; i < 20; i++) begin
      set_ready($urandom_range(0, 1), $urandom_range(0, 1));
      drive_input(i[DATA_WIDTH-1:0], 1);
    end
    drive_input(8'h00, 0);
    set_ready(1, 1);
    hold_cycles(5);
  endtask

  task automatic run_tc_random_01();
    // Fully randomized valid/ready/data over many cycles
    apply_reset();
    for (int i = 0; i < 50; i++) begin
      set_ready($urandom_range(0, 1), $urandom_range(0, 1));
      drive_input($urandom, $urandom_range(0, 1));
    end
    drive_input(8'h00, 0);
    set_ready(1, 1);
    hold_cycles(5);
  endtask


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always @(posedge clk) begin
    is_clk_edge_aligned <= arst_n;
    #1ns;
    is_clk_edge_aligned <= '0;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////


  initial begin

    apply_reset();

    start_clock();

    start_checking();

    case (test_name)
      "TC_RST_01":            run_tc_rst_01();
      "TC_RST_02":            run_tc_rst_02();
      "TC_RST_03":            run_tc_rst_03();
      "TC_BASIC_01":          run_tc_basic_01();
      "TC_BASIC_02":          run_tc_basic_02();
      "TC_PRI_ONLY_01":       run_tc_pri_only_01();
      "TC_SEC_ONLY_01":       run_tc_sec_only_01();
      "TC_NONE_READY_01":     run_tc_none_ready_01();
      "TC_NONE_READY_02":     run_tc_none_ready_02();
      "TC_STALL_VALID_01":    run_tc_stall_valid_deassert_01();
      "TC_READY_TOGGLE_01":   run_tc_ready_toggle_01();
      "TC_WIDTH_ONES_01":     run_tc_width_allones_01();
      "TC_WIDTH_ZEROS_01":    run_tc_width_allzeros_01();
      "TC_BACK2BACK_STRESS":  run_tc_back2back_stress_01();
      "TC_RANDOM_01":         run_tc_random_01();

      default: begin
        $fatal(1, "Unrecognized test_name '%s'", test_name);
      end
    endcase

    #100ns;
    $display("[%s] SUMMARY: primary_xfers=%0d secondary_xfers=%0d priority_drop_events=%0d",
              test_name, primary_xfer_count, secondary_xfer_count, drop_event_count);
    // Finish simulation
    $finish;

  end

endmodule

