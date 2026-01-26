// IF STAGE
`timescale 1ns / 1ps


module IF_Stage (
    input clk,
    input reset,
    input PCWrite,
    input IF_ID_Write,
    output [31:0] IF_ID_instr,
    output [31:0] IF_ID_pc4
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
    assign PC_next = PC_plus4;   // No branch/jump yet

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
        .instr_in(instruction),
        .pc4_in(PC_plus4),
        .instr_out(IF_ID_instr),
        .pc4_out(IF_ID_pc4)
    );

endmodule
