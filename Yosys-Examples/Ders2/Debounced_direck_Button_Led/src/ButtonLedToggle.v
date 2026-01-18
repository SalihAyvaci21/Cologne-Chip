`timescale 1ns / 1ps
// DEMSAY ELEKTRONİK - ARGE
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module ButtonLedToggle (
    input  wire clk,          // 10 MHz sistem clock
    input  wire rst_n,        // reset (aktif düşük)
    input  wire push_button,  // ham buton girişi
    output reg  led_out       // LED çıkışı (aktif-low)
);

    // ======================
    // Debouncer
    // ======================
    wire debounced_button;
    wire out_valid; // buton değeri değiştiğinde 1 clock süresince "1"

    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000),
        .SHIFT_LEN(3),
        .IS_PULLUP(0)             // buton pull-down çalışıyor
    ) debounce_inst (
        .clk(clk),
        .rst_n(rst_n),
        .push_button(push_button),
        .out_valid(out_valid),
        .debounced_button(debounced_button)
    );

    // ======================
    // LED Toggle
    // ======================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_out <= 1'b1;  // Reset → LED kapalı (aktif-low)
        end 
        else if (out_valid && debounced_button) begin
            // sadece "butona basılma" (0→1 geçişi) geldiğinde toggle
            led_out <= ~led_out;
        end
    end

endmodule
