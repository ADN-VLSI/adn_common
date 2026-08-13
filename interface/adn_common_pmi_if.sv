/*

@foez-bhai, write the purpose of this interface in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this interface in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-13 | Foez Ahmed      | Initial version                                        |
| 1.0      | 2026-08-13 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
interface adn_common_pmi_if #(
    parameter type req_t = logic,
    parameter type rsp_t = logic
) (
    input logic arst_ni,
    input logic clk_i
);

  // @foez-bhai, add comments to the functional blocks, signals, and modports

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  req_t req;
  rsp_t rsp;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  bit   is_aligned;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // MODPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  modport master(input arst_ni, input clk_i, output req, input rsp);

  modport slave(input arst_ni, input clk_i, input req, output rsp);

  modport monitor(input arst_ni, input clk_i, input req, input rsp);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always @(posedge clk_i) begin
    is_aligned = '1;
    #1step;
    is_aligned = '0;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////


  task automatic m_reset();
    req <= '0;
  endtask

  task automatic s_reset();
    rsp <= '0;
  endtask

  longint id_q_msend [$];
  longint n_id_msend;
  task automatic msend(input logic [31:0] addr, input logic we, input logic [31:0] wdata,
                       input logic [3:0] strb);
    longint t_id;
    t_id = n_id_msend;
    n_id_msend++;
    id_q_msend.push_back(t_id);
    forever @(id_q_msend.size()) if (id_q_msend[0] == t_id) break;

    if (arst_ni) begin
      wait (is_aligned);
      req.maddr  <= addr ;
      req.mwe    <= we   ;
      req.mwdata <= wdata;
      req.mstrb  <= strb ;
      req.mreq   <= '1   ;
      do @(posedge clk_i); while (arst_ni && rsp.mgnt !== 1);
      req.mreq <= '0;
    end

    id_q_msend.delete(0);
  endtask



  longint id_q_mrecv [$];
  longint n_id_mrecv;
  task automatic mrecv(output logic [31:0] rdata, output logic resp);
    longint t_id;
    t_id = n_id_mrecv;
    n_id_mrecv++;
    id_q_mrecv.push_back(t_id);
    forever @(id_q_mrecv.size()) if (id_q_mrecv[0] == t_id) break;

    if (arst_ni) begin
      do @(posedge clk_i); while (arst_ni && rsp.mack !== 1);
      rdata = rsp.mrdata;
      resp  = rsp.mresp;
    end

    id_q_mrecv.delete(0);
  endtask



  longint id_q_ssend [$];
  longint n_id_ssend;
  task automatic ssend(input logic [31:0] rdata, input logic resp);
    longint t_id;
    t_id = n_id_ssend;
    n_id_ssend++;
    id_q_ssend.push_back(t_id);
    forever @(id_q_ssend.size()) if (id_q_ssend[0] == t_id) break;

    if (arst_ni) begin
      wait (is_aligned);
      rsp.mrdata <= rdata;
      rsp.mresp  <= resp;
      rsp.mack   <= '1;
      @(posedge clk_i);
      rsp.mack <= '0;
    end

    id_q_ssend.delete(0);
  endtask



  longint id_q_srecv [$];
  longint n_id_srecv;
  task automatic srecv(output logic [31:0] addr, output logic we, output logic [31:0] wdata,
                       output logic [3:0] strb);
    longint t_id;
    t_id = n_id_srecv;
    n_id_srecv++;
    id_q_srecv.push_back(t_id);
    forever @(id_q_srecv.size()) if (id_q_srecv[0] == t_id) break;

    if (arst_ni) begin
      wait (is_aligned);
      rsp.mgnt <= '1;
      do @(posedge clk_i); while (arst_ni && rsp.mack !== 1);
      addr  = req.maddr;
      we    = req.mwe;
      wdata = req.mwdata;
      strb  = req.mstrb;
      rsp.mgnt <= '0;
    end

    id_q_srecv.delete(0);
  endtask


  task automatic mwrite(input logic [31:0] addr, input logic [31:0] data, input logic [3:0] strb,
                        output logic resp);
    int dummy;
    fork
      msend(addr, '1, data, strb);
      mrecv(dummy, resp);
    join
  endtask


  task automatic mread(input logic [31:0] addr, output logic [31:0] data, output logic resp);
    fork
      msend(addr, '0, '0, '0);
      mrecv(data, resp);
    join
  endtask

endinterface

