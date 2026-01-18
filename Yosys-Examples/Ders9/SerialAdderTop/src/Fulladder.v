`timescale 1ns / 1ps

module Fulladder (
    input  wire a_i,      // Shift register 1 seri çıkış
    input  wire b_i,      // Shift register 2 seri çıkış
    input  wire c_i,      // Önceki carry
    output wire sum_o,    // Toplamın seri çıkışı
    output wire c_o       // Carry çıkışı
);

    // Full adder
    assign sum_o = a_i ^ b_i ^ c_i;          // XOR ile toplam
    assign c_o   = (a_i & b_i) | (b_i & c_i) | (a_i & c_i); // Carry

endmodule
