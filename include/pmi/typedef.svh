/*

# Purpose
This file provides a collection of SystemVerilog macros designed to standardize the generation of packed structures for the PMI (Processor Memory Interface). By using these macros, developers can consistently define request and response interfaces with configurable address and data widths, ensuring architectural uniformity across the ADN-VLSI/adn_common project.

# Use Case
This file serves as a centralized library for generating standardized SystemVerilog packed structures. It is primarily used to:
- Ensure architectural consistency across the PMI (Processor Memory Interface) by enforcing a uniform signal layout.
- Reduce boilerplate code when defining request and response interfaces.
- Provide flexibility through configurable parameters for address (`__AW__`) and data (`__DW__`) widths.
- Facilitate rapid integration of master-slave communication channels in the `ADN-VLSI/adn_common` project.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 0.1      | 2026-08-04 | Foez Ahmed      | Initial version                                        |
| 1.0      | 2026-08-04 | Foez Ahmed      | Stable release                                         |

Author : Foez Ahmed (foez.official@gmail.com)
This file is part of ADN-VLSI/adn_common
Copyright (c) 2026 ADN-VLSI
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

`ifndef __GUARD_PMI_TYPEDEF_SVH__
`define __GUARD_PMI_TYPEDEF_SVH__ 0

// Macro: PMI_REQ_T
// Purpose: Generates a packed struct for an PMI request interface.
// Usecase: Use this to define the master-to-slave request signals with configurable address and data widths.
`define PMI_REQ_T(__NM__, __AW__, __DW__)        \
  typedef struct packed {                        \
    logic [``__AW__``-1:0]   maddr;              \
    logic                    mwe;                \
    logic [``__DW__``-1:0]   mwdata;             \
    logic [``__DW__``/8-1:0] mstrb;              \
    logic                    mreq;               \
    logic                    mgnt;               \
  } ``__NM__``_req_t;                            \


// Macro: PMI_RESP_T
// Purpose: Generates a packed struct for an PMI response interface.
// Usecase: Use this to define the slave-to-master response signals with configurable data width.
`define PMI_RESP_T(__NM__, __DW__)               \
  typedef struct packed {                        \
    logic                    mack;               \
    logic [``__DW__``-1:0]   mrdata;             \
    logic                    mresp;              \
  } ``__NM__``_resp_t;                           \


// Macro: PMI_T
// Purpose: Generates both request and response packed structs for an PMI interface.
// Usecase: Use this to instantiate a complete PMI interface pair (req/resp) with a single macro call, ensuring consistency across the design.
`define PMI_T(__NM__, __AW__, __DW__)            \
  `PMI_REQ_T(``__NM__``, ``__AW__``, ``__DW__``) \
  `PMI_RESP_T(``__NM__``, ``__DW__``)            \


`endif
