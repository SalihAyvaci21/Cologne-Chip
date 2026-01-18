`timescale 1ns / 1ps

module Full_Adder_SR_FSM (
    input  wire clk,
    input  wire rst,
    input  wire start,          // FSM başlat sinyali
    input  wire [7:0] data_a,  // Paralel veri A
    input  wire [7:0] data_b,  // Paralel veri B
    output wire sum_out,        // Seri toplam çıkışı
    output wire carry_out,      // Son carry çıkışı
    output wire done,           // Seri toplama tamamlandığında
    output wire a_bit,          // Shift register A seri çıkışı
    output wire b_bit           // Shift register B seri çıkışı
);

    // ------------------------
    // FSM kontrol modülü
    // ------------------------
    wire load_a, load_b, enable;

    control_fsm fsm_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .load_a(load_a),
        .load_b(load_b),
        .enable(enable),
        .done(done)
    );

    // ------------------------
    // Full Adder Serial modülü
    // ------------------------
    Full_Adder_SR adder_sr_inst (
        .clk(clk),
        .rst(rst),
        .load_a(load_a),
        .load_b(load_b),
        .enable(enable),
        .data_a(data_a),
        .data_b(data_b),
        .sum_out(sum_out),
        .carry_out(carry_out),
        .a_bit(a_bit),
        .b_bit(b_bit)
    );

endmodule
