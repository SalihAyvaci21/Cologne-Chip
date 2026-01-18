`timescale 1ns / 1ps

module Chase_Toggle_tb;

    // Testbench sinyalleri
    reg clk;
    reg rst;
    reg push_button;
    wire [7:0] led_out;

    // Clock üretimi (10 MHz → 100 ns periyot)
    initial clk = 0;
    always #50 clk = ~clk;

    // DUT (Device Under Test) örnekleme
    Chase_Toggle uut (
        .clk(clk),
        .rst(rst),
        .push_button(push_button),
        .led_out(led_out)
    );

    // Test senaryosu
    initial begin
        // VCD dosyası oluştur (simülasyon dalga analizi için)
        $dumpfile("Chase_Toggle_tb.vcd");
        $dumpvars(0, Chase_Toggle_tb);

        // Başlangıç değerleri
        rst = 0;
        push_button = 0;

        // Reset aktif
        #200;
        rst = 1;

        // Bir süre normal modda çalışsın
        #500000;

        // Toggle moda geçmek için butona bas
        simulate_button_press();

        // Toggle modda LED'lerin değişimini gözlemle
        #500000;

        // Tekrar butona bas → toggle değişsin
        simulate_button_press();

        #500000;

        // Tekrar normal moda geçmek için butona bas
        simulate_button_press();

        #500000;

        // Simülasyonu bitir
        $finish;
    end

    // Buton basış simülasyonu (debounce ile uyumlu olacak şekilde)
    task simulate_button_press;
    begin
        push_button = 1;
        #1000; // 1 µs basılı tut
        push_button = 0;
        #100000; // debounce süresi kadar bekle
    end
    endtask

endmodule