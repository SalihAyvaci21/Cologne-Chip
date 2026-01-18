`timescale 1ns / 1ps
// DEMSAY ELEKTRONİK - ARGE
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module Blink8_1(
    input  wire clk,          // 10 MHz sistem clock
    input  wire rst,          // reset (aktif düşük)
    input  wire push_button,  // buton girişi
    output reg  [7:0] led     // aktif-low LED çıkışları
);

    // ======================
    // PLL (10 MHz → 100 MHz)
    // ======================
    reg [26:0] counter;


    // ======================
    // Sayaç
    // ======================
    always @(posedge clk) begin
        if (!rst)
            counter <= 0;
        else
            counter <= counter + 1'b1;
    end

    // ======================
    // LED Kontrol
    // ======================
    always @(*) begin
        if (!rst) begin
            led = 8'b1111_1111;  // reset → hepsi sönük
        end else if (counter[26] == 1'b1) begin
            led = 8'b0000_0000;  // normal durumda → tüm LED yanık
        end else begin
            led = 8'b1111_1110;  // normal durumda → sadece LED0 yanık
        end
    end

endmodule
