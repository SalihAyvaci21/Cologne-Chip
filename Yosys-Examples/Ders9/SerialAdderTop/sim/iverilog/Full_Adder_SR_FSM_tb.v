`timescale 1ns / 1ps

module Full_Adder_SR_FSM_tb;

    // -----------------------------------
    // Testbench sinyalleri
    // -----------------------------------
    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg [7:0] data_a = 0;
    reg [7:0] data_b = 0;

    wire sum_out;
    wire carry_out;
    wire done;
    wire a_bit;
    wire b_bit; 
	initial begin
   	 $dumpfile("Full_Adder_SR_FSM_tb.vcd"); // Specify dump file name
   	 $dumpvars(0, Full_Adder_SR_FSM_tb); // Dump all signals in the testbench
	end
    // -----------------------------------
    // Instantiate Full_Adder_SR_FSM
    // -----------------------------------
    Full_Adder_SR_FSM uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_a(data_a),
        .data_b(data_b),
        .sum_out(sum_out),
        .carry_out(carry_out),
        .done(done),
        .a_bit(a_bit),
        .b_bit(b_bit)
    );

    // -----------------------------------
    // Clock generation (100 MHz)
    // -----------------------------------
    always #5 clk = ~clk;

    // -----------------------------------
    // Test sequence
    // -----------------------------------
    initial begin
        // -------------------------------
        // Dump waves for Vivado simulation
        // -------------------------------


        // -------------------------------
        // Reset
        // -------------------------------
        rst = 1;
        #20;
        rst = 0;
        #20;

        // -------------------------------
        // Test Case 1: A=8'b10101010, B=8'b01010101
        // -------------------------------
        data_a = 8'b10101010;
        data_b = 8'b01010101;
        start = 1; // FSM başlat
        #10;
        start = 0;

        // Wait until done
        wait(done == 1);
        #20;

        // -------------------------------
        // Test Case 2: A=8'b11110100, B=8'b00101111
        // -------------------------------
        data_a = 8'b11110100;
        data_b = 8'b00101111;
        start = 1;
        #10;
        start = 0;

        wait(done == 1);
        #20;

        // -------------------------------
        // Testbench finished
        // -------------------------------
        $display("Simulation finished!");
        $stop;
    end

endmodule
