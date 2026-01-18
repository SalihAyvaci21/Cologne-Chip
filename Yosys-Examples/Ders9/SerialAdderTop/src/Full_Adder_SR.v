`timescale 1ns / 1ps

module Full_Adder_SR (
    input  wire clk,
    input  wire rst,
    input  wire load_a,
    input  wire load_b,
    input  wire enable,
    input  wire [7:0] data_a,
    input  wire [7:0] data_b,
    output wire sum_out,
    output wire carry_out,
    output wire a_bit,
    output wire b_bit
);

    // ------------------------
    // Shift Register A
    // ------------------------
    shift_register_8bit shift_a (
        .clk(clk),
        .rst(rst),
        .load_i(load_a),
        .enable_i(enable),
        .data_i(data_a),
        .shift_register_out(a_bit)
    );

    // ------------------------
    // Shift Register B
    // ------------------------
    shift_register_8bit shift_b (
        .clk(clk),
        .rst(rst),
        .load_i(load_b),
        .enable_i(enable),
        .data_i(data_b),
        .shift_register_out(b_bit)
    );

    // ------------------------
    // Carry register (D Flip-Flop)
    // ------------------------
    reg carry_q;

    always @(posedge clk or posedge rst) begin
        if (rst)
            carry_q <= 0;
        else if (enable)
            carry_q <= carry_bit; // D-FF: c_o ? c_i
    end

    // ------------------------
    // Full Adder
    // ------------------------
    wire sum_bit;
    wire carry_bit;

    Fulladder fa (
        .a_i(a_bit),
        .b_i(b_bit),
        .c_i(carry_q),   // D-FF ile geri besleme
        .sum_o(sum_bit),
        .c_o(carry_bit)
    );

    assign sum_out = sum_bit;
    assign carry_out = carry_bit;

endmodule
