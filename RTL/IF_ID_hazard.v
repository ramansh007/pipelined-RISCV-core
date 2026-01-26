// IF_ID Register 
`timescale 1ns / 1ps


module IF_ID_hazard (
    input clk,
    input reset,    
    input IF_ID_Write,    //stall control from Hazard Detection Unit
    input [31:0] instr_in,
    input [31:0] pc4_in,
    output reg [31:0] instr_out,
    output reg [31:0] pc4_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instr_out <= 32'b0;
            pc4_out   <= 32'b0;
        end else if (IF_ID_Write) begin
            instr_out <= instr_in;
            pc4_out   <= pc4_in;
        end
    end
endmodule
