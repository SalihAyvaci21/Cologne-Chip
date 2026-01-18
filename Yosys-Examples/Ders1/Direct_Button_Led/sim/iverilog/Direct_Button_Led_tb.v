`timescale 1ns / 1ps

module direct_button_led_tb;

    // Testbench Sinyalleri
    reg clk;
    reg push_button;
    wire led;

    // Test edilecek modülün (DUT - Device Under Test) örneği
    Direct_Button_Led dut (
        .clk(clk),
        .push_button(push_button),
        .led(led)
    );

    // Dalga biçimi (waveform) izleme için
    initial begin
        $dumpfile("direct_button_led_tb.vcd");
        $dumpvars(0, direct_button_led_tb);
    end

    // Clock Sinyali (DUT kullanmasa da, testbench'te bulunması iyi bir alışkanlıktır)
    initial clk = 0;
    always #5 clk = ~clk; // 10 ns periyotlu, 100 MHz clock

    // Stimulus (Test Senaryosu)
    initial begin
        // Başlangıç: Buton kapalı (0)
        push_button = 0;
        #100;

        // Butona bas
        push_button = 1;
        #200;

        // Butonu bırak
        push_button = 0;
        #100;

        // Simülasyonu sonlandır
        $finish;
    end
    
    // Değişiklikleri izlemek için monitor
    initial begin
      $monitor("Time=%0t ns | push_button=%b | led=%b", $time, push_button, led);
    end

endmodule
