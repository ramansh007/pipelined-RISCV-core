
// IF_ID Register 
`timescale 1ns / 1ps

module IF_ID_hazard (
    input clk,
    input reset,    
    input IF_ID_Write,              // Stall control from Hazard Detection Unit
    input        IF_ID_Flush,       // NEW: flush on branch taken (from Hazard Detection Unit)
    input [31:0] pc_in,             // NEW: raw PC of fetched instruction (needed for branch target = PC + imm)
    output reg [31:0] pc_out,       // NEW: raw PC passed to ID stage
    input  [31:0] instr_in,
    input  [31:0] pc4_in,
    output reg [31:0] instr_out,
    output reg [31:0] pc4_out
);

    always @(posedge clk ) begin
        if (reset || IF_ID_Flush) begin          // CHANGED: was just "if (reset)" — now also flushes on branch taken
            instr_out <= 32'b0;
            pc4_out   <= 32'b0;
            pc_out    <= 32'b0;                  // NEW: reset pc_out
        end else if (IF_ID_Write) begin
            instr_out <= instr_in;
            pc4_out   <= pc4_in;
            pc_out    <= pc_in;                  // NEW: latch raw PC
        end
    end
endmodule