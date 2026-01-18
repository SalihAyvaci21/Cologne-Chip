`timescale 1ns / 1ps

module led_brightness_3phase_tb;

    // Testbench sinyalleri
    reg clk;
    reg rst_n;
    wire led1, led2, led3;

    // -----------------------------
    // DUT Instance
    // -----------------------------
    led_brightness_3phase dut (
        .clk(clk),
        .rst_n(rst_n),
        .led1(led1),
        .led2(led2),
        .led3(led3)
    );

    // -----------------------------
    // Clock üretimi (10 MHz → 100 ns period)
    // -----------------------------
    initial clk = 0;
    always #50 clk = ~clk; // 100 ns period → 10 MHz clock

    // -----------------------------
    // Test Senaryosu
    // -----------------------------
    initial begin
        // VCD dump (simülasyon dalga kaydı için)
        $dumpfile("led_brightness_3phase_tb.vcd");
        $dumpvars(0, led_brightness_3phase_tb);

        // Başlangıç
        rst_n = 0;
        #200;
        rst_n = 1;

        // Simülasyonu 5 saniye çalıştır
        #5_000_000_000;  // 5 saniye @ 1ns sim units
        $finish;
    end

endmodule
