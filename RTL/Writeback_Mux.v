// Writeback MUX
`timescale 1ns / 1ps


module Writeback_Mux (
    input [31:0] ALU_Result,
    input [31:0] Mem_Data,
    input MemtoReg,
    output [31:0] Write_Data
);
    assign Write_Data = (MemtoReg) ? Mem_Data : ALU_Result;
endmodule