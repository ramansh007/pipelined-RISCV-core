// ALU_Control
`timescale 1ns / 1ps


module ALU_Control(ALUOp , fun7 , fun3 , alu_ctrl);
    input [1:0] ALUOp;
    input fun7;
    input [2:0] fun3;
    output reg [3:0] alu_ctrl;
    
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_SLT = 4'b0111;
    
    always @(*) 
        begin
            case (ALUOp)
                2'b00: alu_ctrl = ALU_ADD;   // LW / SW → address calculation    
                2'b01: alu_ctrl = ALU_SUB;   // BEQ → subtraction for comparison 
                2'b10: begin
                        case ({fun7, fun3})                    
                            4'b0_000: alu_ctrl = ALU_ADD;    
                            4'b1_000: alu_ctrl = ALU_SUB;    
                            4'b0_111: alu_ctrl = ALU_AND;    
                            4'b0_110: alu_ctrl = ALU_OR;    
                            4'b0_010: alu_ctrl = ALU_SLT;    
                            default:  alu_ctrl = ALU_ADD;
                        endcase
                       end
            default: alu_ctrl = ALU_ADD;   // Default 
            endcase
        end
endmodule