`timescale 1ns / 1ps

module fullAdder_tb;

// Declare testbench signals
reg a, b, c_in;
wire sum, carry_out;

// Instantiate the full adder module
full_adder dut (
    .a(a),
    .b(b),
    .c_in(c_in),
    .sum(sum),
    .carry_out(carry_out)
);

// Dumpfile and dumpvars for waveform generation
initial begin
    $dumpfile("full_adder_tb.vcd"); // Specify dump file name
    $dumpvars(0, fullAdder_tb); // Dump all signals in the testbench
end

// Apply test stimulus
initial begin
    $display("Testing Full Adder");

    // Print header for the test cases
    $display("a   b   c_in | sum carry_out");
    $display("--------------------------");

    // Use $monitor to continuously display changes
    $monitor("%b   %b   %b    | %b   %b", a, b, c_in, sum, carry_out);

    // Apply all 8 test cases for a full adder
    a = 0; b = 0; c_in = 0; #10;
    a = 0; b = 0; c_in = 1; #10;
    a = 0; b = 1; c_in = 0; #10;
    a = 0; b = 1; c_in = 1; #10;
    a = 1; b = 0; c_in = 0; #10;
    a = 1; b = 0; c_in = 1; #10;
    a = 1; b = 1; c_in = 0; #10;
    a = 1; b = 1; c_in = 1; #10;

    #20; // Wait a little extra time to see the last result
    $finish;
end

endmodule

// You would need to include the full_adder module definition here or in a separate file.
/*
module full_adder(
    input a,
    input b,
    input c_in,
    output sum,
    output carry_out
);
    assign sum = a ^ b ^ c_in;
    assign carry_out = (a & b) | (b & c_in) | (a & c_in);
endmodule
*/