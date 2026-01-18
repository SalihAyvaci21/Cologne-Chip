`timescale 1ns / 1ps

module top_module_tb;

    // Testbench Parametreleri
    // 100 MHz clock için periyot = 10 ns
    localparam CLK_PERIOD = 10;

    // Testbench Sinyalleri
    reg  clk_tb;
    reg  reset_tb;
    wire [7:0] led_out_tb;

    // Gözlem için dahili sinyallere erişim (Opsiyonel)
    wire [7:0] sine_wave_internal;
    wire       pwm_signal_internal;

    // 1. Modül Örneklemesi (DUT - Device Under Test)
    top_module dut (
        .clk        (clk_tb),
        .reset      (reset_tb),
        .led_out    (led_out_tb)
    );
    initial begin
        // VCD dump (simülasyon dalga kaydı için)
        $dumpfile("top_module_tb.vcd");
        $dumpvars(0, top_module_tb);
    end
    // Dahili sinyalleri testbench'e bağlama (Debug için)
    assign sine_wave_internal  = dut.sine_value;
    assign pwm_signal_internal = dut.led_pwm_signal;


    // 2. Saat Üreticisi (Clock Generator)
    // 100 MHz (10 ns periyot)
    initial begin
        clk_tb = 0;
        // #5 ns -> 5 ns'de bir clk_tb'yi tersle
        forever # (CLK_PERIOD / 2) clk_tb = ~clk_tb;
    end

    // 3. Simülasyon Akışı
    initial begin
        $display("Simulasyon Baslatildi: top_module_tb");
        
        // Başlangıç durumu: Sistemi resete sok (Aktif Düşük Reset)
        reset_tb = 0;
        
        // 10 saat döngüsü boyunca resette tut
        repeat (10) @(posedge clk_tb);
        
        $display("Reset serbest birakildi, sistem calisiyor...");
        // Reseti serbest bırak
        reset_tb = 1;

        // Simülasyonun bir süre çalışmasını bekle.
        // En az bir tam "nefes alma" döngüsünü görmek için 0.1 saniye çalıştır.
        #(100_000_000); 

        $display("Simulasyon 100ms (1 tam sinüs periyodu) calisti.");
        $finish;
    end

    // 4. (Opsiyonel) Monitör
    // Çıkışları ve dahili sinüs değerini gözlemle
    initial begin
        // Reset bittikten sonra izlemeye başla
        wait (reset_tb == 1);
        $display("Izleme basladi (reset sonrasi)...");
        
        // $timeformat ayarı (ns cinsinden, 2 ondalık basamak)
        $timeformat(-9, 2, " ns", 10);

        // Sinüs değeri her değiştiğinde (yavaş değişir) konsola yazdır
        forever @(posedge dut.U_SINE_GEN.lut_index)
        begin
             $display("T = %t | new sin value = %d | LED_out (Toggled) = %b", 
                      $realtime, sine_wave_internal, led_out_tb);
        end
    end

endmodule