`timescale 1ns / 1ps

module tb_cpu_rtl;

    reg clk;
    reg reset;
    wire        wb_we;
    wire [4:0]  wb_rd;
    wire [31:0] wb_data;
    wire [31:0] instr;

    TOP dut (
        .clk(clk),
        .reset(reset),
        .debug_wb_we(wb_we),
        .debug_wb_rd(wb_rd),
        .debug_wb_data(wb_data),
        .debug_instr(instr)
    );

    always #5 clk = ~clk;
    integer cycle;
    initial begin
        clk   = 0;
        reset = 1;
        cycle = 0;

        // Reset
        #40;
        reset = 0;
        $display("\n================ RTL CPU TEST START ================\n");
        $display("Cycle | Instruction | Writeback");
        $display("----------------------------------------------");

        repeat (40) begin
            @(posedge clk);
            cycle = cycle + 1;

            if (wb_we) begin
                $display(
                    "%5d | %h | x%0d = %0d (0x%h)",
                    cycle,
                    instr,
                    wb_rd,
                    wb_data,
                    wb_data
                );
            end
        end

        $display("\nExpected behavior:");
        $display("addi x1,x0,5    -> x1 = 5");
        $display("addi x2,x0,10   -> x2 = 10");
        $display("add  x3,x1,x2   -> x3 = 15  (forwarding)");
        $display("lw   x4,0(x0)   -> x4 = 15");
        $display("add  x5,x4,x4   -> x5 = 30  (lw-use stall)");
        $display("addi x5,x5,1    -> x5 = 31");

        $display("\n================ RTL CPU TEST END ================\n");
        $finish;
    end

endmodule
