// PC=+4 module
`timescale 1ns / 1ps


module PC_Plus_4(fromPC , NextoPC);
    input[31:0] fromPC ;
    output[31:0] NextoPC;
    assign NextoPC = 4+fromPC;
endmodule