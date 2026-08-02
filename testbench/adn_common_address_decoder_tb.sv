/*

| TEST CASE | DATE       | AUTHOR          | DESCRIPTION                                           |
|-----------|------------|-----------------|-------------------------------------------------------|  
| TC_001    | 2026-07-30 | Shuparna Haque | Each Rule Check : lower & upper-1 boundary of all rules |
| TC_002    | 2026-08-02 | Shuparna Haque | Out of Boundary : just above global max               |
| TC_003    | 2026-08-02 | Shuparna Haque | mid-range value inside each rule                       |
| TC_004    | YYYY-MM-DD | Shuparna Haque | Test case description goes here                       |
| TC_005    | YYYY-MM-DD | Shuparna Haque | Test case description goes here                       |

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Shuparna Haque | Initial version                                        |
| 1.0      | YYYY-MM-DD | Shuparna Haque | Stable release                                         |

Author : Shuparna Haque (sheikhshuparna3108@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_address_decoder_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/adn_common_tb_headers.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  localparam int ADDR_WIDTH = 32;  // Width of the address bus
  localparam int SLAVE_ID_WIDTH = 2;  // Width of the slave identifier
  localparam int NUM_RULES = 4;  // Number of address ranges to decode

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic [    ADDR_WIDTH-1:0] addr_i;
  logic [    ADDR_WIDTH-1:0] min_addr_i    [0:NUM_RULES-1];
  logic [    ADDR_WIDTH-1:0] max_addr_i    [0:NUM_RULES-1];
  logic [SLAVE_ID_WIDTH-1:0] slave_id_i    [0:NUM_RULES-1];
  logic [SLAVE_ID_WIDTH-1:0] slave_index_o;
  logic                      addr_found_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  adn_common_address_decoder #(

      .ADDR_WIDTH    (ADDR_WIDTH),
      .NUM_RULES     (NUM_RULES),
      .SLAVE_ID_WIDTH(SLAVE_ID_WIDTH)
  ) u_dut (
      .addr_i    (addr_i),
      .min_addr_i(min_addr_i),
      .max_addr_i(max_addr_i),
      .slave_id_i(slave_id_i),

      .slave_index_o(slave_index_o),
      .addr_found_o (addr_found_o)

  );
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic rule_table();
    begin
      min_addr_i[0] = 32'h0000_0000;
      max_addr_i[0] = 32'h0000_1000;
      slave_id_i[0] = 2'b00;
      min_addr_i[1] = 32'h0000_1000;
      max_addr_i[1] = 32'h0000_2000;
      slave_id_i[1] = 2'b01;
      min_addr_i[2] = 32'h0000_2000;
      max_addr_i[2] = 32'h0000_3000;
      slave_id_i[2] = 2'b10;
      min_addr_i[3] = 32'h0000_3000;
      max_addr_i[3] = 32'h0000_4000;
      slave_id_i[3] = 2'b11;
    end
  endtask

  task exp_gen(input logic [ADDR_WIDTH-1:0] addr_i, output logic [SLAVE_ID_WIDTH-1:0] expected_index,
               output logic expected_found);
    begin
      for (int i = 0; i < NUM_RULES; i++) begin
        if (addr_i >= min_addr_i[i] && addr_i < max_addr_i[i]) begin
          expected_found = 1'b1;
          expected_index = slave_id_i[i];
        end
      end
    end
  endtask
  task automatic check_address(input logic [ADDR_WIDTH-1:0] addr);
    begin
      logic [SLAVE_ID_WIDTH-1:0] expected_index;
      logic expected_found;

      addr_i = addr;
      #1;

      exp_gen(addr_i, expected_index, expected_found);
      if (u_dut.slave_index_o !== expected_index || u_dut.addr_found_o !== expected_found) begin
        $display(
            "Test failed for address: %h. Expected index: %h, found: %b. Got index: %h, found: %b",
            addr_i, expected_index, expected_found, u_dut.slave_index_o, u_dut.addr_found_o);
        note_case(1'b0);
      end else begin
        $display(
            "Test passed for address: %h. Expected index: %h, found: %b. Got index: %h, found: %b",
            addr_i, expected_index, expected_found, u_dut.slave_index_o, u_dut.addr_found_o);
        note_case(1'b1);
      end
    end
  endtask


  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial
    rule_table();
    // TC_001: lower & upper-1 boundary of every rule
    for (int i = 0; i < NUM_RULES; i++) begin
      check_address(min_addr_i[i]);
      check_address(max_addr_i[i] - 1);
    end
    $display("All test cases for lower and upper boundary completed.");

    // TC_002: Above the last rule's max address
    check_address(max_addr_i[NUM_RULES - 1]);  // Check just above the last rule's max address
    check_address(max_addr_i[NUM_RULES+3]);   //  Check well above the last rule's max address
    $display("Out of Boundary Tests Completed(Should be 2 failed cases).");

    //TC_003: mid-range value inside each rule
    for ( int i = 0; i < NUM_RULES; i++) begin 
      logic [ADDR_WIDTH-1:0] mid_addr = (min_addr_i[i] + max_addr_i[i]) >> 1; // Calculate mid-range address
      check_address(mid_addr);
    end
    $display("Mid-range Tests Completed.");

    // TC_004: Pressure test: Check all addresses in the range of each rule
    for (int i = 0; i < NUM_RULES; i++) begin
      for (int j = min_addr_i[i]; j < max_addr_i[i]; j++) begin
        check_address(j);
      end
    end
    $display("Pressure Tests Completed.");
    
    $display("All test cases completed.");
    $finish;

  end

endmodule
