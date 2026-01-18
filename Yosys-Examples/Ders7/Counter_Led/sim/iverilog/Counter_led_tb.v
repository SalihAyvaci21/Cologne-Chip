`timescale 1ns / 1ps

module Counter_led_tb;

    // Testbench sinyalleri
    reg clk;
    reg rst;
    reg push_button;
    wire [7:0] led_out;

    // Clock üretimi (10 MHz → 100 ns periyot)
    initial clk = 0;
    always #50 clk = ~clk;

    // DUT (Device Under Test) örnekleniyor
    Counter_led uut (
        .clk(clk),
        .rst(rst),
        .push_button(push_button),
        .led_out(led_out)
    );

    // Simülasyon başlangıcı
    initial begin
        // VCD dosyası oluştur (dalga analizi için)
        $dumpfile("Counter_led_tb");
        $dumpvars(0, Counter_led_tb);

        // Başlangıç değerleri
        rst = 0;
        push_button = 0;

        // Reset aktif
        #200;
        rst = 1;

        // Bir süre normal modda çalışsın (1 saniyelik hızda)
        #2_000_000;

        // Butona bas → 0.5 saniyelik moda geç
        simulate_button_press();
        #2_000_000;

        // Butona bas → 0.25 saniyelik moda geç
        simulate_button_press();
        #2_000_000;

        // Butona bas → tekrar 1 saniyelik moda dön
        simulate_button_press();
        #2_000_000;

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