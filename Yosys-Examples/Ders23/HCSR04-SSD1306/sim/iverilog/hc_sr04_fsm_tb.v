`timescale 1ns / 1ps

module hc_sr04_fsm_tb;

    // --- Parametreler ---
    // 10MHz Saat = 100ns Periyot
    localparam CLK_PERIOD = 100;
    
    // 58.8us Strobe Periyodu = 58800 ns
    // (clk_div modülünün ürettiği sinyal)
    localparam STROBE_PERIOD_NS = 58800; 

    // --- Testbench Sinyalleri ---
    // DUT'a girişler 'reg' olmalıdır
    reg CLK;
    reg RST_n;
    reg I_EN;
    reg I_ST;
    reg I_ECHO;

    // DUT'tan çıkışlar 'wire' olmalıdır
    wire [8:0] O_DST; // 9-bit mesafe verisi
    wire       O_CONV;
    wire       O_TRIG;
    wire       O_FL;

    // --- Simüle Edilecek Mesafe ---
    reg [8:0] simulated_distance_cm;

    // --- DUT (Device Under Test) ---
    // Yalnızca hc_sr04_fsm modülünü başlatıyoruz
    hc_sr04_fsm #(
        .MAX_RANGE(400),
        .DST_SZ(9)
    ) DUT (
        .CLK(CLK),
        .RST_n(RST_n),
        .I_EN(I_EN),
        .I_ST(I_ST),
        .I_ECHO(I_ECHO),
        .O_DST(O_DST),
        .O_CONV(O_CONV),
        .O_TRIG(O_TRIG),
        .O_FL(O_FL)
    );

    // --- 1. Saat (Clock) Üreteci (10MHz) ---
    initial begin
        CLK = 0;
        forever #(CLK_PERIOD / 2) CLK = ~CLK;
    end

    // --- 2. Strobe (I_ST) Üreteci (58.8us periyotlu) ---
    // Bu blok, clk_div modülünü taklit eder.
    initial begin
        I_ST = 1'b0;
        forever begin
            // 58.8us (eksi 1 saat darbesi) bekle
            #(STROBE_PERIOD_NS - CLK_PERIOD);
            
            // 1 saat darbesi (100ns) boyunca pals üret
            I_ST = 1'b1;
            #(CLK_PERIOD);
            I_ST = 1'b0;
        end
    end

    // --- 3. Ana Simülasyon Senaryosu ---
    initial begin
        $display("Testbench başlatıldı... (Sadece hc_sr04_fsm testi)");

        // Başlangıç değerleri
        simulated_distance_cm = 9'd34; // 34 cm'yi simüle et
        RST_n = 1'b0; // Resette başlat
        I_EN = 1'b0;
        I_ECHO = 1'b0;
        
        #(CLK_PERIOD * 10); // 1000 ns reset'te tut
        RST_n = 1'b1; // Reseti bırak
        $display("Zaman: %0t ns -> Reset bırakıldı.", $time);
        
        I_EN = 1'b1; // Modülü etkinleştir
        $display("Zaman: %0t ns -> I_EN=1. Ölçümler başlıyor...", $time);

        // Simülasyonu 200 ms çalıştır (yaklaşık 3 ölçüm döngüsü)
        #(200_000_000);
        
        $display("Zaman: %0t ns -> 200ms simülasyon tamamlandı.", $time);
        $stop;
    end

    // --- 4. Echo (I_ECHO) Simülatörü ---
    // FSM'den 'O_TRIG' geldiğinde, belirlenen mesafeye göre
    // 'I_ECHO' palsi üretir.
    always @(posedge O_TRIG) begin
        $display("Zaman: %0t ns -> O_TRIG (Trigger) algılandı.", $time);
        
        // Sensör gecikmesini (sesin gitme süresi) taklit et
        #150_000; // 150us bekle

        // 'I_ECHO' palsini başlat
        I_ECHO <= 1'b1;
        $display("Zaman: %0t ns -> I_ECHO palsi BAŞLADI (Hedef: %d cm).", $time, simulated_distance_cm);

        // hc_sr04_fsm tasarımı, O_DST = cnt_echo + 1 olarak çalışır.
        // Bu yüzden (Mesafe - 1) adet strobe periyodu kadar beklemeliyiz.
        #((simulated_distance_cm - 1) * STROBE_PERIOD_NS); 
        
        // 'I_ECHO' palsini bitir
        I_ECHO <= 1'b0;
        $display("Zaman: %0t ns -> I_ECHO palsi BİTTİ.", $time);
    end


    // --- 5. Konsol Monitörü ---
    initial begin
        $monitor("ZAMAN: %0t ns | TRIG: %b | ECHO: %b | CONV: %b | Mesafe (O_DST): %d",
                 $time, O_TRIG, I_ECHO, O_CONV, O_DST);
    end

    // --- 6. Dalga Formu (VCD) Dökümü ---
    initial begin
        $dumpfile("hc_sr04_fsm_tb.vcd");
        $dumpvars(0, hc_sr04_fsm_tb);
    end

endmodule