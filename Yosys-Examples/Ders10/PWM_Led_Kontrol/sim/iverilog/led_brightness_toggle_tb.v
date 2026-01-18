`timescale 1ns / 1ps

module led_brightness_toggle_tb;

    // Testbench sinyalleri
    reg clk;
    reg rst_n;
    reg button;
    wire [7:0] led_out;

    // -----------------------------
    // DUT Instance
    // -----------------------------
    led_brightness_toggle dut (
        .clk(clk),
        .rst_n(rst_n),
        .button(button),
        .led_out(led_out)
    );

    // -----------------------------
    // Clock üretimi (10 MHz → 100 ns period)
    // -----------------------------
    initial clk = 0;
    always #50 clk = ~clk; // 100 ns -> 10 MHz

    // -----------------------------
    // Test Senaryosu
    // -----------------------------
    initial begin
        // VCD dump (simülasyon dalga kaydı için)
        $dumpfile("led_brightness_toggle_tb.vcd");
        $dumpvars(0, led_brightness_toggle_tb);

        // Başlangıç değerleri
        rst_n   = 0;
        button  = 0;

        // Reset uygula
        #200;
        rst_n = 1;

        // Biraz bekle (%50 duty LED yanıyor olacak)
        #500_000;

        // Butona bas → toggle (%100 duty)
        $display(">>> Butona basiliyor: LED %100");
        button = 1; #100_000; button = 0;

        #2_000_000;

        // Tekrar bas → toggle (%50 duty)
        $display(">>> Butona tekrar basiliyor: LED %50");
        button = 1; #100_000; button = 0;

        #2_000_000;

        // Tekrar bas → %100
        $display(">>> Butona tekrar basiliyor: LED %100");
        button = 1; #100_000; button = 0;

        #2_000_000;

        $finish;
    end

endmodule
