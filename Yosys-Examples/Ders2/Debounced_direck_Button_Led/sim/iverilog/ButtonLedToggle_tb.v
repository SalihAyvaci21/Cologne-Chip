`timescale 1ns / 1ps

module button_led_toggle_tb;

    // ======================
    // Testbench Sinyalleri
    // ======================
    reg clk;
    reg rst_n;
    reg push_button;
    wire led_out;

    // ======================
    // DUT (Test Edilecek Modül)
    // ======================
    // ButtonLedToggle modülünü örnekle
    ButtonLedToggle dut (
        .clk(clk),
        .rst_n(rst_n),
        .push_button(push_button),
        .led_out(led_out)
    );

    // ======================
    // Simülasyon Ayarları
    // ======================
    initial begin
        // Dalga biçimi dosyası oluştur
        $dumpfile("button_led_toggle_tb.vcd");
        $dumpvars(0, button_led_toggle_tb);
    end

    // ======================
    // Clock Üretimi (10 MHz)
    // ======================
    initial clk = 0;
    always #50 clk = ~clk; // 100 ns periyot -> 10 MHz

    // ======================
    // Stimulus (Test Senaryosu)
    // ======================
    initial begin
        // Başlangıç değerleri
        push_button = 0;
        rst_n       = 0; // Aktif düşük reset sinyalini aktif et

        #200; // Reset sinyalinin bir süre aktif kalması için bekle

        rst_n       = 1; // Reset'i bırak
        #100;

        // 5 kez butona basıp bırakma döngüsü
        // Her döngüde butona basma ve bırakma simülasyonu yapılacak
        repeat (5) begin
            // Butona bas
            push_button = 1;
            #20_000_000; // 20 ms basılı tut (debounce süresinden uzun)

            // Butonu bırak
            push_button = 0;
            #1_000_000_000; // 1 sn bekle, bir sonraki basış için
        end

        // Simülasyonu sonlandır
        #1000;
        $finish;
    end

    // ======================
    // Debug için Çıktı Loglama
    // ======================
    initial begin
      $monitor("Time=%0t ns | rst_n=%b | push_button=%b | led_out=%b", $time, rst_n, push_button, led_out);
    end

endmodule
