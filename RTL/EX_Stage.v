// EX STAGE
`timescale 1ns / 1ps

module EX_Stage (
    input clk,
    input reset,
    input [31:0] ID_EX_rs1_data,
    input [31:0] ID_EX_rs2_data,
    input [31:0] ID_EX_imm,
    input [4:0]  ID_EX_rd,
    input ID_EX_RegWrite,
    input ID_EX_MemRead,
    input ID_EX_MemWrite,
    input ID_EX_MemtoReg,
    input ID_EX_ALUSrc,
    input [1:0] ID_EX_ALUOp,
    input  [2:0] ID_EX_funct3,
    input        ID_EX_funct7,
    input        ID_EX_Branch,      // Branch control signal from ID/EX register
    input [31:0] ID_EX_pc,          // PC of branch instruction (for branch_target = PC + imm)
    output       branch_taken,      // Goes to PC MUX in IF_Stage and Hazard Detection Unit
    output [31:0] branch_target,    // PC + imm, goes to IF_Stage PC MUX
    output [31:0] EX_MEM_alu_result,
    output [4:0]  EX_MEM_rd,
    output [31:0] EX_MEM_rs2_data,
    output EX_MEM_RegWrite,
    output EX_MEM_MemRead,
    output EX_MEM_MemWrite,
    output EX_MEM_MemtoReg,        
    input [4:0] ID_EX_rs1,                       // Forwarding  
    input [4:0] ID_EX_rs2,        
    input [4:0]  EX_MEM_rd_in,                   // EX/MEM (previous instruction)
    input        EX_MEM_RegWrite_in,
    input [31:0] EX_MEM_alu_result_in,        
    input [4:0]  MEM_WB_rd,                      // MEM/WB (two cycles older)
    input        MEM_WB_RegWrite,
    input [31:0] MEM_WB_WriteData
);

    ////////////// FORWARDING UNIT ///////////////
    wire [1:0] ForwardA, ForwardB;
    Forwarding_Unit FU (
        .ID_EX_rs1(ID_EX_rs1),
        .ID_EX_rs2(ID_EX_rs2),   
        .EX_MEM_rd(EX_MEM_rd_in),
        .EX_MEM_RegWrite(EX_MEM_RegWrite_in),    
        .MEM_WB_rd(MEM_WB_rd),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),    
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );
    
    // Post-forwarding source values
    wire [31:0] ALU_srcA =
        (ForwardA == 2'b10) ? EX_MEM_alu_result_in :
        (ForwardA == 2'b01) ? MEM_WB_WriteData :
                              ID_EX_rs1_data;
                          
    wire [31:0] rs2_forwarded =
        (ForwardB == 2'b10) ? EX_MEM_alu_result_in :
        (ForwardB == 2'b01) ? MEM_WB_WriteData :
                              ID_EX_rs2_data;
    
    // ALUSrc=0 for branches → ALU_srcB = rs2_forwarded (correct for subtraction)
    // ALUSrc=1 for I-type/load/store → ALU_srcB = immediate
    wire [31:0] ALU_srcB =
        (ID_EX_ALUSrc) ? ID_EX_imm : rs2_forwarded;

    wire [3:0] ALU_Control_Signal;
    ALU_Control ALU_CTRL (
        .ALUOp(ID_EX_ALUOp),
        .fun7(ID_EX_funct7),
        .fun3(ID_EX_funct3),
        .alu_ctrl(ALU_Control_Signal)
    );

    wire [31:0] ALU_result;
    wire zero;              // CHANGED: was "wire zero_unused" — now connected to Branch_Logic
    ALU_Unit ALU (
        .A(ALU_srcA),
        .B(ALU_srcB),
        .alu_ctrl(ALU_Control_Signal),
        .ALU_result(ALU_result),
        .zero(zero)         // CHANGED: was ".zero(zero_unused)" — now wired to Branch_Logic
    );

    // Branch target: PC of branch instruction + sign-extended B-type immediate
    // Immediate_Generator already produces the correct B-type immediate
    assign branch_target = ID_EX_pc + ID_EX_imm;

    //     Branch_Logic module:
    //   - ALUOp=01 → ALU does SUB (A-B), sets zero=1 when A==B
    //   - ALUSrc=0 → ALU_srcB = rs2_forwarded (not the immediate)
    //   - Both ALU inputs are post-forwarding so BEQ/BNE work
    //     even when rs1/rs2 were written by the immediately preceding instruction
    Branch_Logic BL (
        .branch    (ID_EX_Branch),   // Is this a branch instruction?
        .zero      (zero),           // ALU zero flag (1 when rs1 == rs2 after SUB)
        .funct3    (ID_EX_funct3),   // Selects BEQ (000) or BNE (001)
        .branch_taken(branch_taken)  // 1 = redirect PC to branch_target
    );

    // EX/MEM pipeline register
    EX_MEM EX_MEM_reg (
        .clk(clk),
        .reset(reset),
        .alu_result_in(ALU_result),
        .rd_in(ID_EX_rd),
        .rs2_data_in(rs2_forwarded),
        .RegWrite_in(ID_EX_RegWrite),
        .MemRead_in(ID_EX_MemRead),
        .MemWrite_in(ID_EX_MemWrite),
        .MemtoReg_in(ID_EX_MemtoReg),
        .alu_result_out(EX_MEM_alu_result),
        .rd_out(EX_MEM_rd),
        .rs2_data_out(EX_MEM_rs2_data),
        .RegWrite_out(EX_MEM_RegWrite),
        .MemRead_out(EX_MEM_MemRead),
        .MemWrite_out(EX_MEM_MemWrite),
        .MemtoReg_out(EX_MEM_MemtoReg)
    );

endmodule