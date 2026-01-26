//  REGISTER BANK
`timescale 1ns / 1ps


module Register_Bank (
    input         clk,
    input         reset,
    input         RegWrite,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] Write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

    reg [31:0] Registers [31:0];
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                Registers[i] <= 32'b0;
        end else begin
            if (RegWrite && (rd != 5'b0))
                Registers[rd] <= Write_data;
                
            Registers[0] <= 32'b0;
        end
    end

    assign read_data1 = (rs1 == 5'b0) ? 32'b0 : Registers[rs1];
    assign read_data2 = (rs2 == 5'b0) ? 32'b0 : Registers[rs2];
endmodule
