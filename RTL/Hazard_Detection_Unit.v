// HAZARD DETECTION UNIT 
`timescale 1ns / 1ps


module Hazard_Detection_Unit (
    input        ID_EX_MemRead,
    input [4:0]  ID_EX_rd,
    input [4:0]  IF_ID_rs1,
    input [4:0]  IF_ID_rs2,
    output reg   PCWrite,
    output reg   IF_ID_Write,
    output reg   ID_EX_Flush
);

always @(*) begin
    // Default: no stall
    PCWrite     = 1'b1;
    IF_ID_Write = 1'b1;
    ID_EX_Flush = 1'b0;

    // LW-use hazard
    if (ID_EX_MemRead &&
       ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) && (ID_EX_rd != 0)) begin
            PCWrite     = 1'b0;  // freeze PC
            IF_ID_Write = 1'b0;  // freeze IF/ID
            ID_EX_Flush = 1'b1;  // insert bubble
        end
end
endmodule
