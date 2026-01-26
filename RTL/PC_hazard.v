// Program Counter
`timescale 1ns / 1ps


module PC_hazard(clk , reset ,PC_in , PCWrite ,  PC_out );
    input clk , reset, PCWrite;
    input[31:0] PC_in;
    output reg [31:0] PC_out;
    
    always @(posedge clk or posedge reset) begin
        if(reset) PC_out<=32'b00; 
        else if(PCWrite) PC_out<=PC_in;
    end
endmodule