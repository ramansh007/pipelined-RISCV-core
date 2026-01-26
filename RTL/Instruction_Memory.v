// Instruction Memory
`timescale 1ns / 1ps


module Instruction_Memory( reset , read_address , instruction_out);
    input  reset ;
    input [31:0] read_address;
    output  [31:0] instruction_out;
    reg [31:0] I_Mem[63:0];

    initial begin   // Program initialization
        $readmemh("memfile2.mem", I_Mem);
    end
    
    assign instruction_out = (reset) ? 32'b0 : I_Mem[read_address[7:2]];   // Asynchronous read (ROM)
endmodule    


