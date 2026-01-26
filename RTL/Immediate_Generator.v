////// Immediate Generator
`timescale 1ns / 1ps


module Immediate_Generator(Opcode , instruction , ImmExt);
    input [6:0]Opcode;
    input [31:0]instruction;
    output reg [31:0] ImmExt;
    
    localparam OPCODE_LOAD   = 7'b0000011; // I-type
    localparam OPCODE_STORE  = 7'b0100011; // S-type
    localparam OPCODE_BRANCH = 7'b1100011; // B-type
    localparam OPCODE_OPIMM  = 7'b0010011; // I-type (ADDI)
    localparam OPCODE_JAL    = 7'b1101111; // J-type
    localparam OPCODE_JALR   = 7'b1100111; // I-type
 
    always @(*) begin
        case (Opcode)
            OPCODE_LOAD,OPCODE_OPIMM,OPCODE_JALR: ImmExt = {{20{instruction[31]}} ,instruction[31:20]};                                 // I-Type
            OPCODE_STORE: ImmExt = {{20{instruction[31]}},instruction[31:25] , instruction[11:7]};                                      // S-Type
            OPCODE_BRANCH: ImmExt = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};   // B-Type       
            OPCODE_JAL: ImmExt = {{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};    // (J-type)
            default: ImmExt = 32'b0;  
        endcase
    end
    
endmodule