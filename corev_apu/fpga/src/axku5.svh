// AXKU5 board configuration for ariane_xilinx
// This file is included by corev_apu/fpga/scripts/run.tcl when BOARD=axku5.

`ifndef AXKU5_SVH
`define AXKU5_SVH

// Identify this build as targeting the AXKU5 FPGA board
`define AXKU5

// 64-bit SoC data path, same as other 64-bit boards
`define ARIANE_DATA_WIDTH 64

// Use write-through dcache by default on FPGA (matches Nexys Video style)
//`define WB_DCACHE
`define WT_DCACHE

// Additional AXKU5-specific defines can be added here later if needed.

`endif // AXKU5_SVH