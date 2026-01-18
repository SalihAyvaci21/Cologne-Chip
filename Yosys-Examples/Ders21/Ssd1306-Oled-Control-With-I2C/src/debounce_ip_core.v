`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    debounce_ip_core
// Yazar:    Salih Tekin Ayvaci - DEMSAY ELEKTRONİK - ARGE
// Tarih:    12.06.2025
//
// Açıklama:
// Mekanik butonlardaki ark (zıplama) sorununu donanımsal
// olarak filtreleyen bir modüldür.
//----------------------------------------------------------------
module debounce_ip_core #(
    parameter CLK_FREQ_HZ = 10_000_000, // Sistem saat frekansı (Hz)
    parameter SHIFT_LEN   = 3,          // Filtre için shift register uzunluğu
    parameter IS_PULLUP   = 0           // 1 = pull-up (aktif-düşük), 0 = pull-down (aktif-yüksek)
)(
    input  wire clk,
    input  wire rst_n,           // Aktif düşük reset
    input  wire push_button,
    output reg  out_valid,       // Değişim anında 1 clock için '1' olur
    output reg  debounced_button // Butonun kararlı (filtrelenmiş) durumu
);
    // Shift register, buton durumunu örnekler
    reg [SHIFT_LEN-1:0] shift_reg;
    
    // Shift register'daki tüm bitler aynıysa '0' olur (kararlı)
    wire xor_out;
    assign xor_out = ^(shift_reg ^ {SHIFT_LEN{shift_reg[0]}});

    // Kararlılık süresini saymak için sayaç
    // (Örn: 10MHz / 2000 = 5000 clock = 0.5ms)
    localparam integer MAX_COUNT = CLK_FREQ_HZ / 2000;
    reg [17:0] counter; // MAX_COUNT'u tutacak kadar bit

    // Buton girişini sistem saatine senkronize etmek için 2 FF
    reg sync_0, sync_1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // --- Reset Durumu ---
            shift_reg        <= {SHIFT_LEN{IS_PULLUP[0]}}; // Pull-up/down durumuna göre başlat
            debounced_button <= IS_PULLUP[0];             //
            counter          <= 0;                         //
            sync_0           <= IS_PULLUP[0];             //
            sync_1           <= IS_PULLUP[0];             //
            out_valid        <= 0;                         //
        end 
        else begin
            // --- Çalışma Durumu ---
            
            // Adım 1: Girişi senkronize et (Metastability önlemi)
            sync_0 <= push_button;
            sync_1 <= sync_0;     

            // Adım 2: Senkronize girişi shift register'a kaydır
            shift_reg <= {shift_reg[SHIFT_LEN-2:0], sync_1};
            
            // Adım 3: Kararlılık kontrolü
            if (xor_out == 1'b0) begin
                // Durum kararlı (tüm bitler aynı)
                if (counter < MAX_COUNT) begin
                    // Kararlılık süresi dolana kadar say
                    counter   <= counter + 1;
                    out_valid <= 0;
                end 
                else if (debounced_button != shift_reg[0]) begin
                    // Süre doldu VE durum değişti
                    debounced_button <= shift_reg[0]; // Yeni kararlı durumu ata
                    out_valid        <= 1;        // Değişim olduğunu 1 clock bildir
                end 
                else begin
                    // Süre doldu ama durum aynı (basılı tutuluyor)
                    out_valid <= 0;
                end
            end 
            else begin
                // Durum kararsız (zıplama algılandı)
                counter   <= 0; // Sayacı sıfırla
                out_valid <= 0;
            end
        end
    end

endmodule