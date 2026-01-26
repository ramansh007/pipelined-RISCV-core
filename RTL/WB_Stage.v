// WB STAGE
`timescale 1ns / 1ps


module WB_Stage (
    input [31:0] MEM_WB_mem_data,
    input [31:0] MEM_WB_alu_result,
    input [4:0]  MEM_WB_rd,
    input MEM_WB_RegWrite,
    input MEM_WB_MemtoReg,
    output [4:0]  WB_rd,
    output [31:0] WB_WriteData,
    output        WB_RegWrite
);

    Writeback_Mux WB_MUX (
        .ALU_Result(MEM_WB_alu_result),
        .Mem_Data(MEM_WB_mem_data),
        .MemtoReg(MEM_WB_MemtoReg),
        .Write_Data(WB_WriteData)
    );

    assign WB_rd       = MEM_WB_rd;
    assign WB_RegWrite = MEM_WB_RegWrite;

endmodule
