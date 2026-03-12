
// HAZARD DETECTION UNIT 
`timescale 1ns / 1ps

module Hazard_Detection_Unit (
    input        ID_EX_MemRead,
    input [4:0]  ID_EX_rd,
    input [4:0]  IF_ID_rs1,
    input [4:0]  IF_ID_rs2,
    input        branch_taken,      // NEW: from EX stage — triggers pipeline flush
    output reg   PCWrite,
    output reg   IF_ID_Write,
    output reg   ID_EX_Flush,
    output reg   IF_ID_Flush        // NEW: separate flush signal for IF/ID register on branch taken
);

always @(*) begin
    // Default: no stall, no flush
    PCWrite     = 1'b1;
    IF_ID_Write = 1'b1;
    ID_EX_Flush = 1'b0;
    IF_ID_Flush = 1'b0;             // NEW: default no flush

    // -------------------------------------------------------
    // Priority 1: LW-use hazard (stall)
    // Stall if a load is in EX and its destination matches
    // the instruction currently in decode (rs1 or rs2)
    // -------------------------------------------------------
    if (ID_EX_MemRead &&
       ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) && (ID_EX_rd != 0)) begin
            PCWrite     = 1'b0;  // freeze PC
            IF_ID_Write = 1'b0;  // freeze IF/ID register
            ID_EX_Flush = 1'b1;  // insert bubble into ID/EX
    end

    // -------------------------------------------------------
    // Priority 2: Branch taken flush
    // Branch is resolved in EX stage. Two instructions have
    // been fetched from the wrong path:
    //   - instruction in IF stage  → flush IF/ID register
    //   - instruction in ID stage  → flush ID/EX register
    // Do NOT stall PC (PCWrite=1) — we redirect it instead.
    // Do NOT freeze IF_ID_Write — we want the flush to take effect.
    // -------------------------------------------------------
    if (branch_taken) begin
        IF_ID_Flush = 1'b1;  // NEW: kill wrong-path instruction in IF/ID
        ID_EX_Flush = 1'b1;  // NEW: kill wrong-path instruction in ID/EX
        // PCWrite and IF_ID_Write stay 1 so the branch target gets fetched
    end
end
endmodule