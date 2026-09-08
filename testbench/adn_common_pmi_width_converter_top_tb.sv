/*

| TEST CASE | DATE       | AUTHOR          | DESCRIPTION                                           |
|-----------|------------|-----------------|-------------------------------------------------------|  
| TC_001    | 2026-09-07 | Shuparna Haque  | Test case description goes here                       |
| TC_002    | 2026-09-07 | Shuparna Haque | Test case description goes here                       |

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-09-07 | Shuparna Haque  | Initial release                                         |

Author : Shuparna Haque (sheikhshuparna3108@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module adn_common_pmi_width_converter_top_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/adn_common_tb_headers.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  localparam int ADDR_WIDTH = 32;
  localparam int WIDTH_32   = 32;
  localparam int WIDTH_64   = 64;
  localparam int RATIO_64_32 = WIDTH_64 / WIDTH_32;
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic clk;
  logic arst_n;
 
  // ---- dut_up : IN=32 (narrow, s side) -> OUT=64 (wide, m side) ----
  logic [ADDR_WIDTH-1:0]  up_s_maddr;
  logic                   up_s_mwe;
  logic [WIDTH_32-1:0]    up_s_mwdata;
  logic [(WIDTH_32/8)-1:0] up_s_mstrb;
  logic                   up_s_mreq;
  logic                   up_s_mgnt;
  logic                   up_s_mack;
  logic [WIDTH_32-1:0]    up_s_mrdata;
  logic                   up_s_mresp;
 
  logic [ADDR_WIDTH-1:0]  up_m_maddr;
  logic                   up_m_mwe;
  logic [WIDTH_64-1:0]    up_m_mwdata;
  logic [(WIDTH_64/8)-1:0] up_m_mstrb;
  logic                   up_m_mreq;
  logic                   up_m_mgnt;
  logic                   up_m_mack;
  logic [WIDTH_64-1:0]    up_m_mrdata;
  logic                   up_m_mresp;
 
  // ---- dut_down : IN=64 (wide, s side) -> OUT=32 (narrow, m side) ----
  logic [ADDR_WIDTH-1:0]  dn_s_maddr;
  logic                   dn_s_mwe;
  logic [WIDTH_64-1:0]    dn_s_mwdata;
  logic [(WIDTH_64/8)-1:0] dn_s_mstrb;
  logic                   dn_s_mreq;
  logic                   dn_s_mgnt;
  logic                   dn_s_mack;
  logic [WIDTH_64-1:0]    dn_s_mrdata;
  logic                   dn_s_mresp;
 
  logic [ADDR_WIDTH-1:0]  dn_m_maddr;
  logic                   dn_m_mwe;
  logic [WIDTH_32-1:0]    dn_m_mwdata;
  logic [(WIDTH_32/8)-1:0] dn_m_mstrb;
  logic                   dn_m_mreq;
  logic                   dn_m_mgnt;
  logic                   dn_m_mack;
  logic [WIDTH_32-1:0]    dn_m_mrdata;
  logic                   dn_m_mresp;
 
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
  assign up_m_mgnt   = up_m_mreq;
  assign up_m_mack   = up_m_mreq && up_m_mgnt;
  assign up_m_mresp  = 1'b0;
  assign up_m_mrdata = up_m_mwe ? '0 : {32'hCAFE_0000, up_m_maddr};
 
  // Narrow (32b) slave BFM for dut_down's downstream side
  assign dn_m_mgnt   = dn_m_mreq;
  assign dn_m_mack   = dn_m_mreq && dn_m_mgnt;
  assign dn_m_mresp  = 1'b0;
  assign dn_m_mrdata = dn_m_mwe ? '0 : dn_m_maddr;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  adn_common_pmi_width_converter_top #(
    .ADDR_WIDTH    (ADDR_WIDTH),
    .IN_DATA_WIDTH (WIDTH_32),
    .OUT_DATA_WIDTH(WIDTH_64)
  ) dut_up (
    .clk     (clk),
    .arst_n  (arst_n),
    .s_maddr (up_s_maddr),
    .s_mwe   (up_s_mwe),
    .s_mwdata(up_s_mwdata),
    .s_mstrb (up_s_mstrb),
    .s_mreq  (up_s_mreq),
    .s_mgnt  (up_s_mgnt),
    .s_mack  (up_s_mack),
    .s_mrdata(up_s_mrdata),
    .s_mresp (up_s_mresp),
    .m_maddr (up_m_maddr),
    .m_mwe   (up_m_mwe),
    .m_mwdata(up_m_mwdata),
    .m_mstrb (up_m_mstrb),
    .m_mreq  (up_m_mreq),
    .m_mgnt  (up_m_mgnt),
    .m_mack  (up_m_mack),
    .m_mrdata(up_m_mrdata),
    .m_mresp (up_m_mresp)
  );
 
  adn_common_pmi_width_converter_top #(
    .ADDR_WIDTH    (ADDR_WIDTH),
    .IN_DATA_WIDTH (WIDTH_64),
    .OUT_DATA_WIDTH(WIDTH_32)
  ) dut_down (
    .clk     (clk),
    .arst_n  (arst_n),
    .s_maddr (dn_s_maddr),
    .s_mwe   (dn_s_mwe),
    .s_mwdata(dn_s_mwdata),
    .s_mstrb (dn_s_mstrb),
    .s_mreq  (dn_s_mreq),
    .s_mgnt  (dn_s_mgnt),
    .s_mack  (dn_s_mack),
    .s_mrdata(dn_s_mrdata),
    .s_mresp (dn_s_mresp),
    .m_maddr (dn_m_maddr),
    .m_mwe   (dn_m_mwe),
    .m_mwdata(dn_m_mwdata),
    .m_mstrb (dn_m_mstrb),
    .m_mreq  (dn_m_mreq),
    .m_mgnt  (dn_m_mgnt),
    .m_mack  (dn_m_mack),
    .m_mrdata(dn_m_mrdata),
    .m_mresp (dn_m_mresp)
  );
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  task automatic apply_reset();
    arst_n = 0;
 
    up_s_maddr = '0; up_s_mwe = 0; up_s_mwdata = '0; up_s_mstrb = '0; up_s_mreq = 0;
    dn_s_maddr = '0; dn_s_mwe = 0; dn_s_mwdata = '0; dn_s_mstrb = '0; dn_s_mreq = 0;
 
    #20;
    arst_n = 1;
  endtask

    task automatic check_up_write(input logic [ADDR_WIDTH-1:0] addr,
                                 input logic [WIDTH_32-1:0]   data,
                                 input logic [(WIDTH_32/8)-1:0] strb);
    @(negedge clk);
    up_s_maddr = addr; up_s_mwe = 1'b1; up_s_mwdata = data; up_s_mstrb = strb; up_s_mreq = 1'b1;
    wait (up_s_mgnt === 1'b1);
 
    note_case(up_m_mwdata === {{(WIDTH_64-WIDTH_32){1'b0}}, data});
    note_case(up_m_mstrb  === {{((WIDTH_64/8)-(WIDTH_32/8)){1'b0}}, strb});
 
    @(negedge clk);
    up_s_mwe = 0; up_s_mreq = 0;
  endtask

  task automatic check_down_read(input logic [ADDR_WIDTH-1:0] addr);
    logic [WIDTH_64-1:0] expected;
    for (int beat = 0; beat < RATIO_64_32; beat++)
      expected[beat*WIDTH_32 +: WIDTH_32] = addr + beat*(WIDTH_32/8);
 
    @(negedge clk);
    dn_s_maddr = addr; dn_s_mwe = 1'b0; dn_s_mreq = 1'b1;
    wait (dn_s_mack === 1'b1);
 
    note_case(dn_s_mrdata === expected);
 
    @(negedge clk);
    dn_s_mreq = 0;
  endtask
  
  task automatic check_down_write(input logic [ADDR_WIDTH-1:0]    addr,
                                   input logic [WIDTH_64-1:0]      data,
                                   input logic [(WIDTH_64/8)-1:0]  strb);
    @(negedge clk);
    dn_s_maddr = addr; dn_s_mwe = 1'b1; dn_s_mwdata = data; dn_s_mstrb = strb; dn_s_mreq = 1'b1;
 
    for (int beat = 0; beat < RATIO_64_32; beat++) begin
      @(negedge clk);
      note_case(dn_m_maddr  === (addr + beat*(WIDTH_32/8)));
      note_case(dn_m_mwdata === data[beat*WIDTH_32 +: WIDTH_32]);
      note_case(dn_m_mstrb  === strb[beat*(WIDTH_32/8) +: (WIDTH_32/8)]);
    end
    note_case(dn_s_mgnt === 1'b1);
 
    @(negedge clk);
    dn_s_mwe = 0; dn_s_mreq = 0;
  endtask


  task automatic check_up_read(input logic [ADDR_WIDTH-1:0] addr);
    logic [WIDTH_32-1:0] expected;
    expected = addr;
 
    @(negedge clk);
    up_s_maddr = addr; up_s_mwe = 1'b0; up_s_mreq = 1'b1;
    wait (up_s_mgnt === 1'b1);
    wait (up_s_mack === 1'b1);
 
    note_case(up_s_mrdata === expected);
 
    @(negedge clk);
    up_s_mreq = 0;
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  initial clk = 0;
  always  #5 clk = ~ clk;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  initial begin  // main initial
    apply_reset();
 
    case (test_name)
      "TC_001": check_up_write(32'h0000_0010, 32'hDEAD_BEEF, 4'hF);
      "TC_002": check_down_read(32'h0000_0200);
      "TC_003": check_down_write(32'h0000_0100, 64'hDEAD_BEEF_CAFE_F00D, 8'hFF);
      "TC_004": check_up_read(32'h0000_0040);
      default: begin
        check_up_write(32'h0000_0010, 32'hDEAD_BEEF, 4'hF);
        check_down_read(32'h0000_0200);
        check_down_write(32'h0000_0100, 64'hDEAD_BEEF_CAFE_F00D, 8'hFF);
        check_up_read(32'h0000_0040);
      end
    endcase
    $finish;

  end

endmodule
