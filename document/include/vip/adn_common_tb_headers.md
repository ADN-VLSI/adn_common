# vip/adn_common_tb_headers.sv  (unknown)

### Author: Foez Ahmed (foez.official@gmail.com)

### Source: adn_common_tb_headers.sv

## Parameters

_None_


## Description

FILE: adn_common_tb_headers.sv

### Purpose
This file contains common testbench headers and utility functions for ADN Common modules. This file
is intended to be included in testbenches to provide standardized logging, test case tracking, and
simulation control. This module provides global variables and functions to track the number of
passed and failed test cases, as well as to manage simulation parameters such as test name, test
count, VCD generation, and debug mode.

### Use Case
This file is included in testbenches for ADN Common modules to provide a consistent framework for
running tests, logging results, and generating VCD files for waveform analysis. It allows
testbenches to easily track the number of passed and failed test cases, manage simulation
parameters, and provide clear output at the start and end of simulations.

| Variable                | Description                                                                                 |
| ----------------------- | ------------------------------------------------------------------------------------------- |
| `longint passed_cases;` | Counter for the number of passed test cases                                                 |
| `longint failed_cases;` | Counter for the number of failed test cases                                                 |
| `string top_name;`      | Name of the top module being simulated                                                      |
| `string test_name;`     | Name of the test being executed, can be set via command line argument "TN"                  |
| `int test_count;`       | Number of test iterations to run, can be set via command line argument "TC"                 |
| `int vcd;`              | Flag to indicate whether to generate VCD file, can be set via command line argument "VCD"   |
| `int debug;`            | Flag to indicate whether to enable debug mode, can be set via command line argument "DEBUG" |

Use `note_case(1);` to note a passed test case and `note_case(0);` to note a failed test case. The
final result of the test will be displayed at the end of the simulation, indicating whether all
test cases passed or if there were any failures.

| REVISION | DATE       | AUTHOR          | DESCRIPTION                                            |
|----------|------------|-----------------|--------------------------------------------------------|
| 1.0      | 2026-07-20 | Foez Ahmed      | Stable release                                         |
| 1.1      | 2026-08-01 | Foez Ahmed      | Ratified                                               |

Author : Foez Ahmed (foez.official@gmail.com)
