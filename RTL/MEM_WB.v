// MEM_WB REGISTER
`timescale 1ns / 1ps


module MEM_WB (
    input clk,
    input reset,
    input [31:0] mem_data_in,
    input [31:0] alu_result_in,
    input [4:0]  rd_in,
    input RegWrite_in,
    input MemtoReg_in,
    output reg [31:0] mem_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0]  rd_out,
    output reg RegWrite_out,
    output reg MemtoReg_out
);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_data_out   <= 0;
            alu_result_out <= 0;
            rd_out         <= 0;
            RegWrite_out   <= 0;
            MemtoReg_out   <= 0;
        end else begin
            mem_data_out   <= mem_data_in;
            alu_result_out <= alu_result_in;
            rd_out         <= rd_in;
            RegWrite_out   <= RegWrite_in;
            MemtoReg_out   <= MemtoReg_in;
        end
    end
    
endmodule
