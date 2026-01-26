// MEM STAGE
`timescale 1ns / 1ps


module MEM_Stage (
    input clk,
    input reset,
    input [31:0] EX_MEM_alu_result,
    input [4:0]  EX_MEM_rd,
    input [31:0] EX_MEM_rs2_data,
    input EX_MEM_RegWrite,
    input EX_MEM_MemRead,
    input EX_MEM_MemWrite,
    input EX_MEM_MemtoReg,
    output [31:0] MEM_WB_mem_data,
    output [31:0] MEM_WB_alu_result,
    output [4:0]  MEM_WB_rd,
    output MEM_WB_RegWrite,
    output MEM_WB_MemtoReg
);

    wire [31:0] mem_data;
    Data_Memory DMEM (
        .clk(clk),
        .MemWrite(EX_MEM_MemWrite),
        .MemRead(EX_MEM_MemRead),
        .read_address(EX_MEM_alu_result),
        .Write_data(EX_MEM_rs2_data),
        .MemData_out(mem_data)
    );

    // MEM/WB pipeline register
    MEM_WB MEM_WB_reg (
        .clk(clk),
        .reset(reset),
        .mem_data_in(mem_data),
        .alu_result_in(EX_MEM_alu_result),
        .rd_in(EX_MEM_rd),
        .RegWrite_in(EX_MEM_RegWrite),
        .MemtoReg_in(EX_MEM_MemtoReg),
        .mem_data_out(MEM_WB_mem_data),
        .alu_result_out(MEM_WB_alu_result),
        .rd_out(MEM_WB_rd),
        .RegWrite_out(MEM_WB_RegWrite),
        .MemtoReg_out(MEM_WB_MemtoReg)
    );

endmodule
