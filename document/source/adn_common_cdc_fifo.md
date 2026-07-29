# adn_common_cdc_fifo (module)

### Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)

## TOP IO

<img src="./adn_common_cdc_fifo_top.svg">

## Parameters

| Name                | Type | Dimension | Default Value         | Description |
| ------------------- | ---- | --------- | --------------------- | ----------- |
| DATA_WIDTH          | int  |           | 32                    | PARAMETERS  |
| ADDR_WIDTH          | int  |           | 8                     |             |
| SYNC_STAGES         | int  |           | 2                     |             |
| ALMOST_FULL_THRESH  | int  |           | (1 << ADDR_WIDTH) - 2 |             |
| ALMOST_EMPTY_THRESH | int  |           | 2                     |             |

## Ports

| Name           | Direction | Type                   | Dimension | Description        |
| -------------- | --------- | ---------------------- | --------- | ------------------ |
| wr_clk_i       | input     | logic                  |           | Write Clock Domain |
| wr_rst_n_i     | input     | logic                  |           |                    |
| wr_en_i        | input     | logic                  |           |                    |
| wr_data_i      | input     | logic [DATA_WIDTH-1:0] |           |                    |
| full_o         | output    | logic                  |           |                    |
| almost_full_o  | output    | logic                  |           |                    |
| wr_count_o     | output    | logic [ ADDR_WIDTH:0]  |           |                    |
| rd_clk_i       | input     | logic                  |           | Read Clock Domain  |
| rd_rst_n_i     | input     | logic                  |           |                    |
| rd_en_i        | input     | logic                  |           |                    |
| rd_data_o      | output    | logic [DATA_WIDTH-1:0] |           |                    |
| empty_o        | output    | logic                  |           |                    |
| almost_empty_o | output    | logic                  |           |                    |
| rd_count_o     | output    | logic [ ADDR_WIDTH:0]  |           |                    |

## Description

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the usage of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION     |
| -------- | ---------- | ------------------- | --------------- |
| 0.1      | 2026-07-27 | Ahasan Ullah Khalid | Initial version |
| 1.0      | YYYY-MM-DD | Ahasan Ullah Khalid | Stable release  |

This file is part of ADN-VLSI/adn_common
<br>**Copyright (c) 2026 ADN Semiconductors**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the project root for full license information**
