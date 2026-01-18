`timescale 1ns / 1ps

//******************************************************************
// DOSYA: top_tb.v
// 'top' modülü için testbench (10 saniyelik simülasyon)
//******************************************************************

module top_tb;

    // --- Parametreler ---
    localparam CLK_PERIOD = 100; // 10MHz Saat = 100ns Periyot

    // --- Testbench Sinyalleri ---
    reg CLK_IN;
    reg RESET_N_IN;
    wire buzzer_out;

    // --- DUT (Device Under Test) ---
    top DUT (
        .CLK_IN(CLK_IN),
        .RESET_N_IN(RESET_N_IN),
        .buzzer_out(buzzer_out)
    );

    // --- 1. Saat (Clock) Üreteci ---
    initial begin
        CLK_IN = 0;
        forever #(CLK_PERIOD / 2) CLK_IN = ~CLK_IN;
    end

    // --- 2. Test Senaryosu ---
    initial begin
        $display("Testbench Başlatıldı... (10MHz Saat)");
        RESET_N_IN = 1'b0; // Reset aktif
        #(CLK_PERIOD * 10); // 1000 ns (1us) resette tut
        RESET_N_IN = 1'b1; // Reseti bırak
        $display("Zaman: %0t ns -> Reset bırakıldı. Nota sıralayıcı başlıyor.", $time);
        
        // --- Simülasyon Süresi ---
        // Her nota 1 saniye sürer. 9 durum (8 nota + 1 duraklama) var.
        // Toplam döngü = 9 * 1s = 9 saniye.
        // Başa döndüğünü görmek için 10 saniye çalıştıralım.
        // 10 saniye = 10,000,000,000 ns
        #(10_000_000_000);

        $display("Zaman: %0t ns -> 10 saniyelik simülasyon tamamlandı. Durduruluyor.", $time);
        $stop; // Simülasyonu durdur
    end

    // --- 3. Konsol Monitörü ---
    // Vivado Tcl konsolunda simülasyonu izlemek için
    initial begin
        $monitor("Zaman: %0t ns | Nota Durumu (state): %d | Yarım Periyot: %d",
                 $time, DUT.note_state_reg, DUT.current_note_half_period);
    end

    // --- 4. Dalga Formu (VCD) Dökümü ---
    // (Opsiyonel: Eğer Vivado dışında GTKWave kullanmak isterseniz)
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb); 
    end

endmodule

