`timescale 1ns / 1ps

module full_adder(

input  a,

input  b,

input  c_in,

output wire sum,

output wire carry_out

);

// Assign sum using XOR for efficient bitwise addition

assign sum = a ^ b ^ c_in;

// Assign carry based on two-bit product terms for clarity

assign carry_out = (a & b) | (a & c_in) | (c_in & b);

endmodule