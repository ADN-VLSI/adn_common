/*

| TEST CASE | DATE       | AUTHOR            | DESCRIPTION                                            |
|-----------|------------|-------------------|--------------------------------------------------------|  
| TC_001    | 2026-08-02 | Shykul Islam Siam | Idle state verification with no requests active        |
| TC_002    | 2026-08-02 | Shykul Islam Siam | Single isolated requests arbitration                   |
| TC_003    | 2026-08-02 | Shykul Islam Siam | Continuous round-robin rotation with all requests high |
| TC_004    | 2026-08-02 | Shykul Islam Siam | Sparse requests arbitration (skipping inactive ports)  |
| TC_005    | 2026-08-02 | Shykul Islam Siam | Disable arbitration via allow_req_i signal              |
| TC_006    | 2026-08-02 | Shykul Islam Siam | Asynchronous active-low reset verification              |

| REVISION | DATE       | AUTHOR            | DESCRIPTION                                            |
|----------|------------|-------------------|--------------------------------------------------------|
| 0.1      | 2026-08-02 | Shykul Islam Siam | Initial version                                        |
| 1.0      | 2026-08-02 | Shykul Islam Siam | Stable release                                         |

Author : Shykul Islam Siam (shykulislam32@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_round_robin_arbiter_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/adn_common_tb_headers.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int NUM_REQ = 4;
  localparam time CLK_PERIOD = 10ns;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                       clk_i;
  logic                       arst_ni;
  logic                       allow_req_i;
  logic [NUM_REQ-1:0]         req_i;

  logic                       gnt_addr_valid_o;
  logic [$clog2(NUM_REQ)-1:0] gnt_addr_o;
  logic [NUM_REQ-1:0]         gnt_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INTERFACES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // CLASSES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_round_robin_arbiter #(
      .NUM_REQ(NUM_REQ)
  ) u_dut (
      .clk_i           (clk_i),
      .arst_ni         (arst_ni),
      .allow_req_i     (allow_req_i),
      .req_i           (req_i),
      .gnt_addr_valid_o(gnt_addr_valid_o),
      .gnt_addr_o      (gnt_addr_o),
      .gnt_o           (gnt_o)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic reset_dut();
    arst_ni     = 1'b0;
    allow_req_i = 1'b0;
    req_i       = '0;
    repeat (2) @(posedge clk_i);
    arst_ni     = 1'b1;
    allow_req_i = 1'b1;
    @(posedge clk_i);
  endtask

  task automatic check_grant(input logic exp_valid, input logic [$clog2(NUM_REQ)-1:0] exp_addr);
    logic pass;
    #1ps;
    if (exp_valid) begin
      pass = (gnt_addr_valid_o == 1'b1) && (gnt_addr_o == exp_addr) && (gnt_o == (1 << exp_addr)) && $onehot(gnt_o);
      note_case(pass);
      if (pass) begin
        $display("[PASS] Expected addr=%0d, Got valid=%0b addr=%0d gnt_o=%0b", exp_addr, gnt_addr_valid_o, gnt_addr_o, gnt_o);
      end else begin
        $display("[FAIL] Expected addr=%0d, Got valid=%0b addr=%0d gnt_o=%0b", exp_addr, gnt_addr_valid_o, gnt_addr_o, gnt_o);
      end
    end else begin
      pass = (gnt_addr_valid_o == 1'b0) && (gnt_o == '0);
      note_case(pass);
      if (pass) begin
        $display("[PASS] Expected invalid grant, Got valid=%0b gnt_o=%0b", gnt_addr_valid_o, gnt_o);
      end else begin
        $display("[FAIL] Expected invalid grant, Got valid=%0b gnt_o=%0b", gnt_addr_valid_o, gnt_o);
      end
    end
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    clk_i = 1'b0;
    reset_dut();

    // TC_001: Idle State Verification (No Requests)
    req_i = 4'b0000;
    check_grant(1'b0, 0);

    // TC_002: Single Isolated Request Test
    req_i = 4'b0001;
    check_grant(1'b1, 0);
    @(posedge clk_i);

    req_i = 4'b0100;
    check_grant(1'b1, 2);
    @(posedge clk_i);

    // TC_003: Continuous Round Robin Rotation (All Requests High)
    req_i = 4'b1111;
    check_grant(1'b1, 3); @(posedge clk_i);
    check_grant(1'b1, 0); @(posedge clk_i);
    check_grant(1'b1, 1); @(posedge clk_i);
    check_grant(1'b1, 2); @(posedge clk_i);

    // TC_004: Sparse Requests Rotation (Ports 1 and 3)
    req_i = 4'b1010;
    check_grant(1'b1, 3); @(posedge clk_i);
    check_grant(1'b1, 1); @(posedge clk_i);
    check_grant(1'b1, 3); @(posedge clk_i);

    // TC_005: Global Enable Control (allow_req_i)
    req_i = 4'b1111;
    allow_req_i = 1'b0;
    check_grant(1'b0, 0);

    allow_req_i = 1'b1;
    check_grant(1'b1, 0);
    @(posedge clk_i);

    // TC_006: Asynchronous Reset Verification
    arst_ni = 1'b0;
    #1ps;
    check_grant(1'b0, 0);

    reset_dut();
    req_i = 4'b1111;
    check_grant(1'b1, 0);

    $finish;

  end

endmodule