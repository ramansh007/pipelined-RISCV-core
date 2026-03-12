// ============================================================
// bubble_sort_tb.v  —  Testbench for Bubble Sort
// ============================================================
// Array [5,3,8,1,9,2] sorted to [1,2,3,5,8,9]
// Uses: ADDI, ADD, SUB, SLT, LW, SW, BEQ
// ============================================================
`timescale 1ns / 1ps

module bubble_sort_tb;

    // ---- DUT signals ----
    reg         clk, reset;
    wire [31:0] debug_instr;
    wire        debug_wb_we;
    wire [4:0]  debug_wb_rd;
    wire [31:0] debug_wb_data;

    // ---- DUT ----
    TOP DUT (
        .clk           (clk),
        .reset         (reset),
        .debug_instr   (debug_instr),
        .debug_wb_we   (debug_wb_we),
        .debug_wb_rd   (debug_wb_rd),
        .debug_wb_data (debug_wb_data)
    );

    // ---- Clock ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Scoreboard ----
    integer pass_count, fail_count;
    initial begin pass_count = 0; fail_count = 0; end

    // ================================================================
    // check_mem: verify one data memory word
    // ================================================================
    task check_mem;
        input [31:0] byte_addr;
        input [31:0] expected;
        input [255:0] desc;
        reg   [31:0] actual;
        begin
            actual = DUT.MEM_STAGE.DMEM.D_Memory[byte_addr >> 2]; 
            if (actual === expected) begin
                $display("  PASS | mem[%0d] = %-4d (exp %-4d) | %s", byte_addr, actual, expected, desc);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL | mem[%0d] = %-4d (exp %-4d) | %s  <<<", byte_addr, actual, expected, desc);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ================================================================
    // check_reg: verify register file value
    // ================================================================
    task check_reg;
        input [4:0]   rn;
        input [31:0]  expected;
        input [255:0] desc;
        reg   [31:0]  actual;
        begin
            actual = DUT.ID_STAGE.RF.Registers[rn]; 
            if (actual === expected) begin
                $display("  PASS | x%-2d = %-4d (exp %-4d) | %s", rn, actual, expected, desc);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL | x%-2d = %-4d (exp %-4d) | %s  <<<", rn, actual, expected, desc);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ================================================================
    // Live monitors
    // ================================================================
    always @(posedge clk) begin
        if (!reset && debug_wb_we && debug_wb_rd != 5'd0)
            $display("[WB ] t=%0t  x%-2d <= %0d", $time, debug_wb_rd, debug_wb_data);
    end
    always @(posedge clk) begin
        if (!reset && DUT.branch_taken)
            $display("[BRN] t=%0t  branch_taken target=0x%08h", $time, DUT.branch_target);
    end

    // ================================================================
    // MAIN STIMULUS
    // ================================================================
    initial begin
        // --- Reset ---
        reset = 1;
        repeat(4) @(posedge clk);   // hold reset for 4 cycles

        // --- Load data memory BEFORE releasing reset ---
        DUT.MEM_STAGE.DMEM.D_Memory[0] = 32'd5;
        DUT.MEM_STAGE.DMEM.D_Memory[1] = 32'd3;
        DUT.MEM_STAGE.DMEM.D_Memory[2] = 32'd8;
        DUT.MEM_STAGE.DMEM.D_Memory[3] = 32'd1;
        DUT.MEM_STAGE.DMEM.D_Memory[4] = 32'd9;
        DUT.MEM_STAGE.DMEM.D_Memory[5] = 32'd2;

        // --- Release reset ---
        @(posedge clk);
        #1;
        reset = 0;

        $display("");
        $display("============================================================");
        $display("  Bubble Sort Testbench");
        $display("  Input:    [5, 3, 8, 1, 9, 2]");
        $display("  Expected: [1, 2, 3, 5, 8, 9]");
        $display("============================================================");

        // Wait for sort to complete (generous timeout)
        repeat(2000) @(posedge clk);
        #1;

        // ============================================================
        // CHECK 1: Sorted array in data memory
        // ============================================================
        $display("");
        $display("------------------------------------------------------------");
        $display("  CHECK 1: Data Memory (sorted array)");
        $display("------------------------------------------------------------");
        check_mem(32'd0,  32'd1, "arr[0]=1 (was 5)");
        check_mem(32'd4,  32'd2, "arr[1]=2 (was 3)");
        check_mem(32'd8,  32'd3, "arr[2]=3 (was 8)");
        check_mem(32'd12, 32'd5, "arr[3]=5 (was 1)");
        check_mem(32'd16, 32'd8, "arr[4]=8 (was 9)");
        check_mem(32'd20, 32'd9, "arr[5]=9 (was 2)");

        // ============================================================
        // CHECK 2: Control registers (confirm loop ran correctly)
        // ============================================================
        $display("");
        $display("------------------------------------------------------------");
        $display("  CHECK 2: Control Registers");
        $display("------------------------------------------------------------");
        check_reg( 1, 32'd0, "x1  = 0 (array base, unchanged)");
        check_reg( 2, 32'd6, "x2  = 6 (n)");
        check_reg( 3, 32'd5, "x3  = 5 (i at loop exit = n-1)");
        check_reg(11, 32'd4, "x11 = 4 (word size constant)");
        check_reg(20, 32'd5, "x20 = 5 (outer limit, unchanged)");

        // ============================================================
        // CHECK 3: x9 is valid SLT output (0 or 1, not X)
        // ============================================================
        $display("");
        $display("------------------------------------------------------------");
        $display("  CHECK 3: x9 (SLT result) is 0 or 1");
        $display("------------------------------------------------------------");
        begin : chec
            reg [31:0] v;
            v = DUT.ID_STAGE.RF.Registers[9]; // <-- ADJUST
            if (v === 32'd0 || v === 32'd1) begin
                $display("  PASS | x9 = %0d (valid)", v);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL | x9 = %0d (X/Z or unexpected)  <<<", v);
                fail_count = fail_count + 1;
            end
        end

        // ============================================================
        // SUMMARY
        // ============================================================
        $display("");
        $display("============================================================");
        $display("  RESULT: %0d PASSED   %0d FAILED", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("  >>> ALL PASSED — Bubble sort verified! <<<");
        end else begin
            $display("  >>> FAILED — Debug hints:");
            $display("    1. If CHECK 1 all fail with original values: DMEM");
            $display("       may be clearing on reset. Move init block AFTER");
            $display("       reset=0 in this testbench (marked with comment).");
            $display("    2. If only mem[0]/[4] fail: SLT→BEQ hazard. See .mem");
            $display("    3. If register checks pass but memory fails: SW addr bug");
        end
        $display("============================================================");
        $finish;
    end

    // ---- Watchdog ----
    initial begin
        #500000;
        $display("WATCHDOG timeout — possible infinite loop");
        $finish;
    end

endmodule