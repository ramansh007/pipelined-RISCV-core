// ALU Unit
`timescale 1ns / 1ps

 
module ALU_Unit(A,B , alu_ctrl , ALU_result , zero);
    input [31:0] A,B;
    input [3:0]alu_ctrl;
    output reg [31:0] ALU_result;
    output reg zero;
    
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;
    
    always @(*)
        begin
            case(alu_ctrl)
                ALU_AND : begin zero=0; ALU_result=A&B; end
                ALU_OR : begin zero=0; ALU_result=A|B; end
                ALU_ADD : begin zero=0; ALU_result=A+B; end
                ALU_SUB : begin 
                            if(A==B) zero=1; 
                            else zero=0; ALU_result=A-B;
                          end
                ALU_SLT :  begin ALU_result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;zero = 0; end                                   
                default: begin zero = 1'b0; ALU_result = 32'b0; end
            endcase
        end
endmodule
