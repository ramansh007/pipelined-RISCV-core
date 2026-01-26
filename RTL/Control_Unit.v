// Control UNIT
`timescale 1ns / 1ps


module Control_Unit(Opcode , Branch , MemRead , MemtoReg , ALUOp , MemWrite , ALUSrc , RegWrite );
    input [6:0] Opcode ;
    output reg Branch , MemRead , MemtoReg, MemWrite,ALUSrc , RegWrite;
    output reg [1:0] ALUOp;
    
    localparam OPCODE_RTYPE  = 7'b0110011;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_OPIMM  = 7'b0010011;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111;
    
    always @(*)
        begin
            case(Opcode)
            OPCODE_RTYPE:  {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b00100010;
            OPCODE_LOAD:   {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b11110000;
            OPCODE_STORE:  {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b10001000;
            OPCODE_BRANCH: {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b00000101;
            OPCODE_OPIMM:  {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b10100000; 
            OPCODE_JAL:    {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b10100000;
            OPCODE_JALR:   {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b10100000; 
            default:       {ALUSrc , MemtoReg , RegWrite,MemRead , MemWrite,Branch,ALUOp}=8'b0; 
            endcase
        end
endmodule