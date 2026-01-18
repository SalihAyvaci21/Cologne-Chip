`timescale 1ns / 1ps

module pwm_generator #(
    parameter CLK_FREQ = 10_000_000,   // 10 MHz sistem clock
    parameter PWM_FREQ = 1000          // 1 kHz PWM frekansı
)(
    input  wire clk,        // Sistem clock
    input  wire rst_n,      // Aktif düşük reset
    input  wire [7:0] duty_cycle, // Duty cycle (0–255)
    output reg  pwm_out     // PWM çıkışı
);

    // -----------------------------
    // PWM Sayaç
    // -----------------------------
    localparam integer PERIOD = CLK_FREQ / PWM_FREQ;  // bir PWM periyodu kaç clock
    reg [$clog2(PERIOD)-1:0] counter = 0;

    // Duty karşılaştırma için 8-bit değer → clock periyoduna ölçekle
    wire [$clog2(PERIOD)-1:0] duty_count;
    assign duty_count = (duty_cycle * PERIOD) >> 8;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            pwm_out <= 0;
        end else begin
            if (counter >= PERIOD-1)
                counter <= 0;
            else
                counter <= counter + 1;

            // PWM karşılaştırma
            if (counter < duty_count)
                pwm_out <= 1;
            else
                pwm_out <= 0;
        end
    end

endmodule
