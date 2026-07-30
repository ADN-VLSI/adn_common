/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | YYYY-MM-DD | Motasim Faiyaz | Initial version                                        |
| 1.0      | YYYY-MM-DD | Motasim Faiyaz | Stable release                                         |

Author : Motasim Faiyaz (motasimfaiyaz@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module adn_common_round_robin_arbiter #(
    // PARAMETERS
    parameter int NUM_REQ = 8
    
) (
    // PORTS
    input  logic                       clk_i,
    input  logic                       rst_ni,
 
    input  logic                       allow_req_i,
    input  logic [    NUM_REQ-1:0]     req_i,
 
    output logic [    NUM_REQ-1:0]     gnt_o,           // one-hot grant, original bit order
    output logic [$clog2(NUM_REQ)-1:0] gnt_addr_o,      // encoded grant address, original order
    output logic                       gnt_addr_valid_o    
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////
 
  if (NUM_REQ < 1) begin : gen_bad_param
    $fatal(1, "adn_rr_arbiter: NUM_REQ must be >= 1");
  end
 
  // ---------------------------------------------------------------------
  // NUM_REQ == 1: nothing to arbitrate, avoid a zero-width offset signal
  // ---------------------------------------------------------------------
  if (NUM_REQ == 1) begin : gen_single_req
 
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // ASSIGNMENTS
    //////////////////////////////////////////////////////////////////////////////////////////////////
 
    assign gnt_o            = req_i & {NUM_REQ{allow_req_i}};
    assign gnt_addr_o       = '0;
    assign gnt_addr_valid_o = allow_req_i & req_i[0];
 
  end else begin : gen_rr
 
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // LOCALPARAMS GENERATED
    //////////////////////////////////////////////////////////////////////////////////////////////////
 
    localparam int OFFSET_W = $clog2(NUM_REQ);
 
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // SIGNALS
    //////////////////////////////////////////////////////////////////////////////////////////////////
 
    logic [OFFSET_W-1:0] offset_q, offset_d;
 
    logic [NUM_REQ-1:0]  req_rot;
    logic [NUM_REQ-1:0]  gnt_rot;
 
    logic [OFFSET_W-1:0] gnt_addr_rot;
    logic                gnt_valid_rot;
 
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // ASSIGNMENTS
    //////////////////////////////////////////////////////////////////////////////////////////////////
 
    // one-hot encode the rotated winner, then rotate it back
    assign gnt_rot = gnt_valid_rot ? ({{(NUM_REQ - 1) {1'b0}}, 1'b1} << gnt_addr_rot) : '0;
 
    // translate the rotated-domain winner address back to the original domain
    assign gnt_addr_o       = (gnt_addr_rot + offset_q) % NUM_REQ;
    assign gnt_addr_valid_o = gnt_valid_rot;
 
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // SUBMODULES
    //////////////////////////////////////////////////////////////////////////////////////////////////
 
    // rotate requests so offset_q (next-in-line requester) lands on bit 0
    adn_common_f_rounder #(
        .N(NUM_REQ)
    ) u_f_rounder (
        .req_i  (req_i),
        .offset (offset_q),
        .req_o  (req_rot)
    );
 
    // fixed-priority arbiter picks the winner within the rotated domain
    adn_common_fixed_priority_arbiter #(
        .NUM_REQ(NUM_REQ)
    ) u_fixed_priority_arbiter (
        .allow_req_i      (allow_req_i),
        .req_i            (req_rot),
        .gnt_addr_o       (gnt_addr_rot),
        .gnt_addr_valid_o (gnt_valid_rot)
    );
 
    // rotate the one-hot winner back to the original domain
    adn_common_b_rounder #(
        .N(NUM_REQ)
    ) u_b_rounder (
        .req_i   (gnt_rot),
        .offset  (offset_q),
        .grant_o (gnt_o)
    );
 
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // SEQUENTIALS
    //////////////////////////////////////////////////////////////////////////////////////////////////
 
    // round-robin pointer: next arbitration starts just past this winner
    always_comb begin
      offset_d = offset_q;
      if (gnt_valid_rot) begin
        offset_d = (gnt_addr_o + 1) % NUM_REQ;
      end
    end
 
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) offset_q <= '0;
      else         offset_q <= offset_d;
    end
 

  end
endmodule

