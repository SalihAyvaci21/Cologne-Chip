`timescale 1ns/100ps
//----------------------------------------------------------------
// Modül:    bcd_encoder
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// "Double Dabble" (Shift-and-add-3) algoritmasını kullanarak
// 9-bit'lik binary (ikilik) bir sayıyı, 3 haneli (12-bit)
// BCD (Onluk) koda çevirir.
//
// I_CONV sinyali ile tetiklenir, çevrim süresince O_BUSY
// sinyalini '1' yapar ve bitince O_BCD çıkışına sonucu yazar.
//----------------------------------------------------------------
module bcd_encoder 
    #(parameter BINARY_LEN = 9,            // Giriş Binary veri genişliği
      parameter BCD_DIGITS = 3,            // Çıkış BCD hane sayısı
      parameter BCD_LEN  = BCD_DIGITS * 4) // Çıkış BCD veri genişliği (3*4 = 12 bit)
    (CLK, RST_n, I_CONV, I_BIN,
     O_BUSY, O_BCD);
//-------------------------------------------------------
    // Parametreler
    // 'scratch' register'ı BCD ve BINARY veriyi bir arada tutar
    localparam SCRATCH_LEN = BINARY_LEN + BCD_LEN; // 9 + 12 = 21 bit
    localparam SCNT_WIDTH = $clog2(BINARY_LEN); // Kaydırma sayacı genişliği ($clog2(9)=4 bit)

    // --- Giriş Sinyalleri ---
    input wire                  CLK;     // Sistem Saati
    input wire                  RST_n;   // Aktif-düşük Reset
    input wire                  I_CONV;  // Çevrimi başlat (1 pals)
    input wire [BINARY_LEN-1:0] I_BIN;   // Çevrilecek 9-bit Binary veri
    
    // --- Çıkış Sinyalleri ---
    output wire               O_BUSY;  // Çevirici meşgul bayrağı
    output wire [BCD_LEN-1:0] O_BCD;   // Çevrilmiş 12-bit BCD veri
    
    // --- Dahili Sinyaller ---
    reg [SCNT_WIDTH-1:0]           scnt;      // Kalan kaydırma sayısını tutar (BINARY_LEN'den 0'a)
    reg [SCRATCH_LEN-1:0]          scratch;   // Double-Dabble algoritmasının ana çalışma register'ı
    wire [BCD_LEN-1:0]             bcd;       // 'scratch' register'ının BCD bölümü
    wire [BCD_LEN-1:0]             bcd_carry; // 'bcd' hanelerine +3 eklenecek ara değer
    reg                            running;   // Çevrim durumunu tutan bayrak (O_BUSY'ye bağlı)
    reg                            cr_i_conv; // I_CONV sinyalini yakalamak için (current)
    reg                            pr_i_conv; // I_CONV sinyalini yakalamak için (previous)
    wire                           rs_i_conv; // I_CONV sinyalinin yükselen kenarı (posedge)
//-------------------------------------------------------
    // 'scratch' register'ının üst (BCD) bölümünü 'bcd' çıkışına bağla
    assign bcd = scratch[SCRATCH_LEN-1:SCRATCH_LEN-BCD_LEN];
    // I_CONV sinyalinin yükselen kenarını algıla
    assign rs_i_conv = cr_i_conv & !pr_i_conv;

//-------------------------------------------------------
    // Double-Dabble Algoritması (Kombinasyonel):
    // Her BCD hanesini (4-bit) kontrol et.
    // Eğer hane > 4 (yani 5,6,7,8,9) ise, o haneye 3 ekle.
    genvar i;
    generate
        for (i = 0; i < BCD_DIGITS; i ++)
          begin : bcd_carry_adders
              assign bcd_carry[i*4+3:i*4] = bcd[i*4+3:i*4] + ((bcd[i*4+3:i*4] < 5) ? 0 : 3);
          end
    endgenerate

//-------------------------------------------------------
    // Ana FSM (Ardışıl Mantık)
    always @(posedge CLK or negedge RST_n)
      if (!RST_n) begin // --- Reset Durumu ---
        scratch <= {SCRATCH_LEN{1'b0}};
        scnt <= {SCNT_WIDTH{1'b0}};
        running <= 1'b0;
        cr_i_conv <= 1'b0;
        pr_i_conv <= 1'b0;
      end
      else begin // --- Çalışma Durumu ---
        
        // I_CONV sinyalinin yükselen kenarını yakala
        cr_i_conv <= I_CONV;
        pr_i_conv <= cr_i_conv;
        
        if (running) begin // --- Çevrim Sürüyor ---
            // Kaydırma sayacı 0'a ulaştı mı?
            if (scnt == {SCNT_WIDTH{1'b0}}) begin
                running <= 1'b0; // Çevrim bitti, meşgul bayrağını indir
            end
            else begin
                // Algoritma Adımı:
                // 1. (Kombinasyonel blokta) BCD hanelerine +3 eklendi (bcd_carry).
                // 2. 'scratch' register'ını 1 bit sola kaydır.
                scratch <= {bcd_carry[BCD_LEN-2:0], scratch[BINARY_LEN-1:0], 1'b0};
                scnt <= scnt - 1'b1; // Kaydırma sayacını azalt
            end
        end
        else begin // --- Bekleme Durumu ---
            // 'I_CONV' palsi geldi mi? (rs_i_conv = 1)
            if (rs_i_conv) begin
                // Başlangıç: Binary veriyi 'scratch' register'ının alt (BINARY) bölümüne yükle
                scratch[BINARY_LEN-1:0] <= I_BIN;
                scratch[SCRATCH_LEN-1:SCRATCH_LEN-BCD_LEN] <= {BCD_LEN{1'b0}}; // BCD bölümünü sıfırla
                scnt <= BINARY_LEN; // Kaydırma sayacını BINARY_LEN (9) olarak ayarla
                running <= 1'b1; // Meşgul bayrağını kaldır
            end
        end             
      end
        
//-------------------------------------------------------
    // Çıkışları ata
    assign O_BUSY = running; // Meşgul bayrağı
    assign O_BCD = bcd;      // Çevrilmiş BCD veri

endmodule