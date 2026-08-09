/*
# Purpose
This file defines the `adn_PMI` interface, a synchronous, pipelined
request/response bus used for master-slave communication in the
ADN-VLSI/adn_common project. It encapsulates the request channel
(address, write-enable, write-data, strobe, valid) and the
grant/response channel (grant, ack, read-data, response status)
between a single master and a single slave.

# Use Case
This file serves as the standard interconnect definition for PMI-based
memory and peripheral access. It is primarily used to:
- Provide a uniform signal bundle for request and response channels,
  parameterized by configurable address (`ADDR_WIDTH`) and data
  (`DATA_WIDTH`) widths.
- Decouple request and response timing, allowing a request and a
  response to transfer independently in the same cycle.
- Expose dedicated `master`, `slave`, and `monitor` modports to
  restrict signal directionality based on the connecting agent's role.
- Enable consistent, reusable master-slave connections across RTL and
  verification environments in the `ADN-VLSI/adn_common` project.

| REVISION | DATE       | AUTHOR                 | DESCRIPTION                                            |
|----------|------------|------------------------|--------------------------------------------------------|
| 0.1      | 2026-08-04 | Shykul Islam Siam      | Initial version                                        |
| 1.0      | 2026-08-09 | Shykul Islam Siam      | Stable release                                         |

Author : Shykul Islam Siam (shykulislam32@gmail.com)

This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN-VLSI
Licensed under the MIT License
See LICENSE file in the project root for full license information
*/

`include "pmi/typedef.svh"

interface adn_PMI #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    input logic clk,
    input logic arst_n
);

  // PMI supports byte-addressable data widths only.
  localparam int STRB_WIDTH = DATA_WIDTH / 8;

  // Response status encodings defined by the PMI specification.
  localparam logic RESP_OKAY  = 1'b0;
  localparam logic RESP_ERROR = 1'b1;

  // Master-to-slave request channel.
  logic [ADDR_WIDTH-1:0] maddr;
  logic                  mwe;
  logic [DATA_WIDTH-1:0] mwdata;
  logic [STRB_WIDTH-1:0] mstrb;
  logic                  mreq;

  // Slave-to-master grant and response channels.
  logic                  mgnt;
  logic                  mack;
  logic [DATA_WIDTH-1:0] mrdata;
  logic                  mresp;

  // Convenience types for storing complete PMI requests and responses.
  `PMI_T(adn_PMI, ADDR_WIDTH, DATA_WIDTH)

  // A request transfer creates an outstanding transaction.  A response has
  // no ready signal and therefore completes whenever mack is asserted.
  wire request_accepted = arst_n && mreq && mgnt;
  wire response_complete = arst_n && mack;

  // Connect a requester to this modport.  The master owns only the request
  // payload and valid signal; the slave owns grant and response signals.
  modport master (
      input  clk, arst_n, mgnt, mack, mrdata, mresp,
      output maddr, mwe, mwdata, mstrb, mreq
  );

  // Connect a memory/peripheral implementation to this modport.
  modport slave (
      input  clk, arst_n, maddr, mwe, mwdata, mstrb, mreq,
      output mgnt, mack, mrdata, mresp
  );

  // Passive protocol observers, scoreboards, and assertions can use this
  // modport without gaining drive access to the bus.
  modport monitor (
      input clk, arst_n, maddr, mwe, mwdata, mstrb, mreq,
            mgnt, mack, mrdata, mresp, request_accepted, response_complete
  );

endinterface
