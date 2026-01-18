`timescale 1ns / 1ps

module rgb_sequencer_top_tb;

    // --- Parametreler ---
    localparam CLK_PERIOD = 100; // 100 ns (10MHz)

    // --- Sinyaller ---
    reg clk;
    reg n_rst;

    wire led_r;
    wire led_g;
    wire led_b;

    // --- DUT (Device Under Test) ---
    rgb_sequencer_top DUT (
        .clk(clk),
        .n_rst(n_rst),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
    );

    // --- Saat (Clock) Üreteci ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // --- Test Senaryosu (GÜNCELLENEN BLOK) ---
    initial begin
        $display("Testbench başlatıldı... (10MHz Saat, 100ns Periyot)");

        // 1. Reset Uygulaması
        n_rst = 1'b0; // Reset aktif
        $display("Zaman: %0t ns -> Reset uygulandı (n_rst=0).", $time);
        
        #(CLK_PERIOD * 3); 
        
        n_rst = 1'b1; // Reset bırakıldı
        $display("Zaman: %0t ns -> Reset bırakıldı (n_rst=1). State 1. kez 0'da.", $time);
        
        // FSM'nin 0'dan (S_RED) bir sonraki duruma geçmesini bekle
        // (Reset'ten sonraki ilk saat darbesinde state 0 olabilir, emin olmak için bekleyelim)
        @(posedge clk);
        wait (DUT.state != 0);
        $display("Zaman: %0t ns -> State 0'dan ayrıldı (S_GREEN'e geçti).", $time);

        // FSM'nin tüm döngüyü tamamlayıp 0'a (S_RED) geri dönmesini bekle
        // (Bu, state'in 0'a ikinci kez gelişi olacak)
        wait (DUT.state == 0);
        
        // $monitor'ın son durumu yazdırabilmesi için kısa bir an bekle
        #(CLK_PERIOD);
        
        $display("Zaman: %0t ns -> State 2. kez 0'a döndü (S_RED). Simülasyon durduruluyor.", $time);
        
        // 3. Simülasyonu Durdur
        $stop;
    end

    // --- Monitör ---
    // Sinyal değişikliklerini konsola yazar
    initial begin
        $monitor("ZAMAN: %0t ns | n_rst: %b | FSM Durumu (DUT.state): %d | Renk (DUT.current_rgb): %h",
                 $time, n_rst, DUT.state, DUT.current_rgb);
    end
    
    // --- Waveform Dökümü ---
    // 'waveform.vcd' dosyasına dalga formunu kaydeder
    initial begin
        $dumpfile("rgb_sequencer_top_tb.vcd");
        $dumpvars(0, rgb_sequencer_top_tb);
    end

endmodule