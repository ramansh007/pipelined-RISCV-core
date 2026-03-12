// ID_EX REGISTER
`timescale 1ns / 1ps

module ID_EX_hazard (
    input clk,
    input reset,
    input ID_EX_Flush,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [31:0] imm_in,
    input [4:0]  rd_in,
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemtoReg_in,
    input ALUSrc_in,
    input [1:0] ALUOp_in,
    input [2:0] funct3_in,
    input       funct7_in,    
    input  [4:0] rs1_in,
    input  [4:0] rs2_in,
    input        Branch_in,         // NEW: Branch control signal from Control Unit
    input  [31:0] pc_in,            // NEW: PC of the branch instruction (used for branch_target = PC + imm)
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,    
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rd_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemtoReg_out,
    output reg ALUSrc_out,
    output reg [1:0] ALUOp_out,
    output reg [2:0] funct3_out,
    output reg       funct7_out,
    output reg       Branch_out,    // NEW: pipelined Branch signal to EX stage
    output reg [31:0] pc_out        // NEW: pipelined PC to EX stage
);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            imm_out      <= 32'b0;
            rd_out       <= 5'b0;    
            rs1_out      <= 5'b0;
            rs2_out      <= 5'b0;    
            RegWrite_out <= 1'b0;
            MemRead_out  <= 1'b0;
            MemWrite_out <= 1'b0;
            MemtoReg_out <= 1'b0;
            ALUSrc_out   <= 1'b0;
            ALUOp_out    <= 2'b0;
            funct3_out   <= 3'b0;
            funct7_out   <= 1'b0;
            Branch_out   <= 1'b0;   // NEW: reset Branch signal
            pc_out       <= 32'b0;  // NEW: reset PC
    
        end else if (ID_EX_Flush) begin
            rs1_data_out <= 32'b0;                           // Bubble insertion (NOP)
            rs2_data_out <= 32'b0;
            imm_out      <= 32'b0;
            rd_out       <= 5'b0;   
            rs1_out      <= 5'b0;
            rs2_out      <= 5'b0;    
            RegWrite_out <= 1'b0;
            MemRead_out  <= 1'b0;
            MemWrite_out <= 1'b0;
            MemtoReg_out <= 1'b0;
            ALUSrc_out   <= 1'b0;
            ALUOp_out    <= 2'b0;
            funct3_out   <= 3'b0;
            funct7_out   <= 1'b0;
            Branch_out   <= 1'b0;   // NEW: flush Branch signal to 0 (no spurious branches)
            pc_out       <= 32'b0;  // NEW: flush PC
    
        end else begin
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out      <= imm_in;
            rd_out       <= rd_in;    
            rs1_out      <= rs1_in;
            rs2_out      <= rs2_in;    
            RegWrite_out <= RegWrite_in;
            MemRead_out  <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemtoReg_out <= MemtoReg_in;
            ALUSrc_out   <= ALUSrc_in;
            ALUOp_out    <= ALUOp_in;
            funct3_out   <= funct3_in;
            funct7_out   <= funct7_in;
            Branch_out   <= Branch_in;  // NEW: latch Branch control signal
            pc_out       <= pc_in;      // NEW: latch PC of this instruction
        end
    end
endmodule