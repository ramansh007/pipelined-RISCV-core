
// TOP MODULE
`timescale 1ns / 1ps

module TOP (
    input clk,
    input reset,
    output [31:0] debug_instr,
    output        debug_wb_we,
    output [4:0]  debug_wb_rd,
    output [31:0] debug_wb_data
);
    // =========================================================
    // IF → ID signals
    // =========================================================
    wire [31:0] IF_ID_instr;
    wire [31:0] IF_ID_pc4;
    wire [31:0] IF_ID_pc;           // NEW: raw PC of instruction in IF/ID (needed for branch_target = PC + imm)
    assign debug_instr = IF_ID_instr;

    // =========================================================
    // ID → EX signals
    // =========================================================
    wire [31:0] ID_EX_rs1_data;
    wire [31:0] ID_EX_rs2_data;
    wire [31:0] ID_EX_imm;
    wire [4:0]  ID_EX_rd;
    wire [4:0]  ID_EX_rs1;
    wire [4:0]  ID_EX_rs2;
    wire [2:0]  ID_EX_funct3;
    wire        ID_EX_funct7;
    wire        ID_EX_RegWrite;
    wire        ID_EX_MemRead;
    wire        ID_EX_MemWrite;
    wire        ID_EX_MemtoReg;
    wire        ID_EX_ALUSrc;
    wire [1:0]  ID_EX_ALUOp;
    wire        ID_EX_Branch;       // NEW: Branch control signal flowing into EX stage
    wire [31:0] ID_EX_pc;           // NEW: PC of instruction in ID/EX (for branch target computation)

    // =========================================================
    // EX → MEM signals
    // =========================================================
    wire [31:0] EX_MEM_alu_result;
    wire [4:0]  EX_MEM_rd;
    wire [31:0] EX_MEM_rs2_data;
    wire        EX_MEM_RegWrite;
    wire        EX_MEM_MemRead;
    wire        EX_MEM_MemWrite;
    wire        EX_MEM_MemtoReg;

    // =========================================================
    // MEM → WB signals
    // =========================================================
    wire [31:0] MEM_WB_mem_data;
    wire [31:0] MEM_WB_alu_result;
    wire [4:0]  MEM_WB_rd;
    wire        MEM_WB_RegWrite;
    wire        MEM_WB_MemtoReg;

    // =========================================================
    // WB → Register File signals
    // =========================================================
    wire [31:0] WB_WriteData;
    wire        WB_RegWrite;
    wire [4:0]  WB_rd;
    assign debug_wb_we   = WB_RegWrite;
    assign debug_wb_rd   = WB_rd;
    assign debug_wb_data = WB_WriteData;

    // =========================================================
    // Hazard / Branch control signals
    // =========================================================
    wire PCWrite;
    wire IF_ID_Write;
    wire ID_EX_Flush;
    wire IF_ID_Flush;               // NEW: flushes IF/ID register on branch taken
    wire branch_taken;              // NEW: from EX stage — 1 when branch condition is true
    wire [31:0] branch_target;      // NEW: from EX stage — PC to jump to

    // =========================================================
    // IF STAGE
    // =========================================================
    IF_Stage IF_STAGE (
        .clk(clk),
        .reset(reset),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .IF_ID_Flush(IF_ID_Flush),      // NEW: flush IF/ID register on branch taken
        .branch_taken(branch_taken),    // NEW: selects branch_target in PC MUX
        .branch_target(branch_target),  // NEW: branch PC from EX stage
        .IF_ID_pc(IF_ID_pc),            // NEW: raw PC output to pass through pipeline
        .IF_ID_instr(IF_ID_instr),
        .IF_ID_pc4(IF_ID_pc4)
    );
    
    // =========================================================
    // HAZARD DETECTION UNIT
    // =========================================================
    wire [4:0] IF_ID_rs1 = IF_ID_instr[19:15];
    wire [4:0] IF_ID_rs2 = IF_ID_instr[24:20];
    
    Hazard_Detection_Unit HDU (
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_rd(ID_EX_rd),
        .IF_ID_rs1(IF_ID_rs1),
        .IF_ID_rs2(IF_ID_rs2),
        .branch_taken(branch_taken),    // NEW: input from EX stage
        .IF_ID_Flush(IF_ID_Flush),      // NEW: output to IF_Stage for IF/ID flush
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .ID_EX_Flush(ID_EX_Flush)
    );
    
    // =========================================================
    // ID STAGE
    // =========================================================
    ID_Stage ID_STAGE (
        .clk(clk),
        .reset(reset),
        .ID_EX_Flush(ID_EX_Flush),
        .IF_ID_instr(IF_ID_instr),
        .IF_ID_pc(IF_ID_pc),            // NEW: raw PC of instruction in IF/ID
        .WB_RegWrite(WB_RegWrite),
        .MEM_WB_rd(WB_rd),
        .WB_WriteData(WB_WriteData),
        .ID_EX_rs1_data(ID_EX_rs1_data),
        .ID_EX_rs2_data(ID_EX_rs2_data), 
        .ID_EX_rs1(ID_EX_rs1), 
        .ID_EX_rs2(ID_EX_rs2),
        .ID_EX_imm(ID_EX_imm),
        .ID_EX_rd(ID_EX_rd),
        .ID_EX_funct3(ID_EX_funct3),
        .ID_EX_funct7(ID_EX_funct7),
        .ID_EX_RegWrite(ID_EX_RegWrite),
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_MemWrite(ID_EX_MemWrite),
        .ID_EX_MemtoReg(ID_EX_MemtoReg),
        .ID_EX_ALUSrc(ID_EX_ALUSrc),
        .ID_EX_ALUOp(ID_EX_ALUOp),
        .ID_EX_Branch(ID_EX_Branch),    // NEW: Branch control signal to EX stage
        .ID_EX_pc(ID_EX_pc)             // NEW: PC to EX stage for branch_target
    );

    // =========================================================
    // EX STAGE
    // =========================================================
    EX_Stage EX_STAGE (
        .clk(clk),
        .reset(reset),
        .ID_EX_rs1_data(ID_EX_rs1_data),
        .ID_EX_rs2_data(ID_EX_rs2_data),
        .ID_EX_imm(ID_EX_imm),
        .ID_EX_rd(ID_EX_rd),
        .ID_EX_funct3(ID_EX_funct3),
        .ID_EX_funct7(ID_EX_funct7),
        .ID_EX_RegWrite(ID_EX_RegWrite),
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_MemWrite(ID_EX_MemWrite),
        .ID_EX_MemtoReg(ID_EX_MemtoReg),
        .ID_EX_ALUSrc(ID_EX_ALUSrc),
        .ID_EX_ALUOp(ID_EX_ALUOp),
        .ID_EX_Branch(ID_EX_Branch),    // NEW: Branch control into EX
        .ID_EX_pc(ID_EX_pc),            // NEW: PC into EX for branch_target = PC + imm
        .branch_taken(branch_taken),    // NEW: output to IF_Stage and HDU
        .branch_target(branch_target),  // NEW: output to IF_Stage PC MUX
        .EX_MEM_alu_result(EX_MEM_alu_result),
        .EX_MEM_rd(EX_MEM_rd),
        .EX_MEM_rs2_data(EX_MEM_rs2_data),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .EX_MEM_MemRead(EX_MEM_MemRead),
        .EX_MEM_MemWrite(EX_MEM_MemWrite),
        .EX_MEM_MemtoReg(EX_MEM_MemtoReg),
        .ID_EX_rs1(ID_EX_rs1),
        .ID_EX_rs2(ID_EX_rs2),
        .EX_MEM_rd_in(EX_MEM_rd),
        .EX_MEM_RegWrite_in(EX_MEM_RegWrite),
        .EX_MEM_alu_result_in(EX_MEM_alu_result),            
        .MEM_WB_rd(MEM_WB_rd),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_WriteData(WB_WriteData)                
    );

    // =========================================================
    // MEM STAGE  (unchanged)
    // =========================================================
    MEM_Stage MEM_STAGE (
        .clk(clk),
        .reset(reset),
        .EX_MEM_alu_result(EX_MEM_alu_result),
        .EX_MEM_rd(EX_MEM_rd),
        .EX_MEM_rs2_data(EX_MEM_rs2_data),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .EX_MEM_MemRead(EX_MEM_MemRead),
        .EX_MEM_MemWrite(EX_MEM_MemWrite),
        .EX_MEM_MemtoReg(EX_MEM_MemtoReg),
        .MEM_WB_mem_data(MEM_WB_mem_data),
        .MEM_WB_alu_result(MEM_WB_alu_result),
        .MEM_WB_rd(MEM_WB_rd),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_MemtoReg(MEM_WB_MemtoReg)
    );

    // =========================================================
    // WB STAGE  (unchanged)
    // =========================================================
    WB_Stage WB_STAGE (
        .MEM_WB_mem_data(MEM_WB_mem_data),
        .MEM_WB_alu_result(MEM_WB_alu_result),
        .MEM_WB_rd(MEM_WB_rd),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_MemtoReg(MEM_WB_MemtoReg),
        .WB_rd(WB_rd),
        .WB_WriteData(WB_WriteData),
        .WB_RegWrite(WB_RegWrite)
    );       
endmodule