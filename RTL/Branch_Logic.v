// BRANCH LOGIC
`timescale 1ns / 1ps


module Branch_Logic(branch , zero , funct3 , branch_taken);
    input branch , zero;
    input [2:0] funct3;
    output reg branch_taken;
    
    always @(*) begin
        if (branch) begin
            case(funct3)
                3'b000 : branch_taken = zero;       // BEQ: Branch if Zero is 1
                3'b001 : branch_taken = ~zero;      // BNE: Branch if Zero is 0
                default: branch_taken = 1'b0;
            endcase 
        end
        else branch_taken = 1'b0;   
     end
endmodule