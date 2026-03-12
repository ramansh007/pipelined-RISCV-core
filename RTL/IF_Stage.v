
// IF STAGE
`timescale 1ns / 1ps

module IF_Stage (
    input clk,
    input reset,
    input PCWrite,
    input IF_ID_Write,
    input        IF_ID_Flush,       // NEW: flushes IF/ID register when branch is taken
    input        branch_taken,      // NEW: from EX stage via HDU — selects branch target PC
    input [31:0] branch_target,     // NEW: PC + imm, computed in EX stage
    output [31:0] IF_ID_instr,
    output [31:0] IF_ID_pc4,
    output [31:0] IF_ID_pc          // NEW: raw PC of the instruction in IF/ID (needed in ID/EX for branch target)
);

    wire [31:0] PC_current;
    wire [31:0] PC_next;
    wire [31:0] PC_plus4;
    wire [31:0] instruction;

    // Program Counter 
    PC_hazard PC (
        .clk(clk),
        .reset(reset),
        .PCWrite(PCWrite),
        .PC_in(PC_next),
        .PC_out(PC_current)
    );

    PC_Plus_4 PC4 (
        .fromPC(PC_current),
        .NextoPC(PC_plus4)
    );

    assign PC_next = branch_taken ? branch_target : PC_plus4;
    Instruction_Memory IMEM (
        .reset(reset),
        .read_address(PC_current),
        .instruction_out(instruction)
    );

    // IF / ID pipeline register
    IF_ID_hazard IFID (
        .clk(clk),
        .reset(reset),
        .IF_ID_Write(IF_ID_Write),
        .IF_ID_Flush(IF_ID_Flush),  // NEW: connected to flush input
        .pc_in(PC_current),         // NEW: pass raw PC into register
        .pc_out(IF_ID_pc),          // NEW: expose raw PC to TOP
        .instr_in(instruction),
        .pc4_in(PC_plus4),
        .instr_out(IF_ID_instr),
        .pc4_out(IF_ID_pc4)
    );

endmodule