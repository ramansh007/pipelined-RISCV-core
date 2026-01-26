// ID STAGE
`timescale 1ns / 1ps


module ID_Stage (
    input clk,
    input reset,
    input ID_EX_Flush,
    input [31:0] IF_ID_instr,
    input WB_RegWrite,
    input [4:0] MEM_WB_rd,
    input [31:0] WB_WriteData,
    output [31:0] ID_EX_rs1_data,
    output [31:0] ID_EX_rs2_data,
    output [31:0] ID_EX_imm,
    output [4:0]  ID_EX_rd,
    output ID_EX_RegWrite,
    output ID_EX_MemRead,
    output ID_EX_MemWrite,
    output ID_EX_MemtoReg,
    output ID_EX_ALUSrc,
    output [1:0] ID_EX_ALUOp,
    output  [2:0] ID_EX_funct3,
    output        ID_EX_funct7,
    output [4:0] ID_EX_rs1,              // Forwarding
    output [4:0] ID_EX_rs2
    
);
    wire [6:0] opcode = IF_ID_instr[6:0];
    wire [4:0] rd     = IF_ID_instr[11:7];
    wire [4:0] rs1    = IF_ID_instr[19:15];
    wire [4:0] rs2    = IF_ID_instr[24:20];
    wire [2:0] funct3 = IF_ID_instr[14:12];
    wire       funct7 = IF_ID_instr[30];
    wire [31:0] imm ;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc;
    wire [1:0] ALUOp;

    // Register file
    Register_Bank RF (
        .clk(clk),
        .reset(reset),
        .RegWrite(WB_RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(MEM_WB_rd),
        .Write_data(WB_WriteData),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    // Immediate generator
    Immediate_Generator IMM (
        .Opcode(opcode),
        .instruction(IF_ID_instr),
        .ImmExt(imm)
    );
    
    // Control unit
    wire unconnected_branch;
    Control_Unit CU (
        .Opcode(opcode),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .Branch(unconnected_branch)     // Unconnected coz no jump/branch yet
     );

    // ID/EX pipeline register
    ID_EX_hazard ID_EX_reg (
        .clk(clk),
        .reset(reset),
        .ID_EX_Flush(ID_EX_Flush),
        .rs1_data_in(rs1_data),
        .rs2_data_in(rs2_data),   
        .imm_in(imm),
        .rd_in(rd),
        .RegWrite_in(RegWrite),
        .MemRead_in(MemRead),
        .MemWrite_in(MemWrite),
        .MemtoReg_in(MemtoReg),
        .ALUSrc_in(ALUSrc),
        .ALUOp_in(ALUOp),
        .rs1_data_out(ID_EX_rs1_data),
        .rs2_data_out(ID_EX_rs2_data), 
        .imm_out(ID_EX_imm),
        .rd_out(ID_EX_rd),
        .RegWrite_out(ID_EX_RegWrite),
        .MemRead_out(ID_EX_MemRead),
        .MemWrite_out(ID_EX_MemWrite),
        .MemtoReg_out(ID_EX_MemtoReg),
        .ALUSrc_out(ID_EX_ALUSrc),
        .ALUOp_out(ID_EX_ALUOp),
        .funct3_in(funct3),
        .funct7_in(funct7),
        .funct3_out(ID_EX_funct3),
        .funct7_out(ID_EX_funct7),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rs1_out(ID_EX_rs1),
        .rs2_out(ID_EX_rs2)                        
    );
endmodule
