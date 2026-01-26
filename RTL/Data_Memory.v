// DATA MEMORY
`timescale 1ns / 1ps


module Data_Memory(clk  , MemWrite , MemRead , read_address , Write_data , MemData_out );
    input clk , MemWrite , MemRead ;
    input [31:0] read_address , Write_data;
    output [31:0] MemData_out;
    reg [31:0] D_Memory[63:0];

    initial begin
        $readmemh("datamem.mem", D_Memory);
        D_Memory[0] = 10;
    end

    always @(posedge clk) begin
        if (MemWrite)
            D_Memory[read_address[7:2]] <= Write_data;
    end
        
    assign MemData_out = MemRead ? D_Memory[read_address[7:2]] : 32'b00;
endmodule