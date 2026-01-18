`timescale 1ns / 1ps

module SerialAdderTop (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] data_a,
    input  wire [7:0] data_b,
    output wire [8:0] result,
    output wire done
);

    // Ara sinyaller
    wire sum_out, carry_out;
    wire a_bit, b_bit;
    wire fsm_done;
    wire enable;

    // FSM + Seri Toplama
    Full_Adder_SR_FSM adder_fsm (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_a(data_a),
        .data_b(data_b),
        .sum_out(sum_out),
        .carry_out(carry_out),
        .done(fsm_done),
        .a_bit(a_bit),
        .b_bit(b_bit)
    );

    assign done = fsm_done;
    assign enable = fsm_done | 1'b1; // enable sinyali testbench için

    // 9-bit Shift Register Sonuç
    shift_register_9bit result_shift (
        .clk(clk),
        .rst(rst),
        .enable_i(enable),
        .bit_in(sum_out),
        .carry_in(carry_out),
        .shift_data(result)
    );

endmodule
