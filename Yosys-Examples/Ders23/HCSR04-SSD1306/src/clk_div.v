`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    clk_div
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// 10MHz sistem saatini bölerek, hc_sr04_fsm modülünün
// ihtiyaç duyduğu 58.8uS periyotlu 'O_ST' (strobe)
// sinyalini üretir.
//
// Hesap: 10.000.000 Hz / 588 = 17.006 Hz
// Periyot: 1 / 17.006 Hz = 58.8 uS
//----------------------------------------------------------------
module clk_div
    #(parameter CCL_SZ = 588) // Bölme Değeri
    (CLK, RST_n, 
     O_ST);
//-------------------------------------------------------
    // Parametreler
    // $clog2(588) = 10. Sayaç genişliği 10-bit olmalıdır.
    localparam CNT_CCL_SZ = 10;
//-------------------------------------------------------
    // --- Giriş Sinyalleri ---
    input wire CLK;     // Sistem Saati (10 MHz)
    input wire RST_n;   // Aktif-düşük Reset
    
    // --- Çıkış Sinyalleri ---
    output reg O_ST;    // 1 clock süreli Strobe palsi (58.8uS'de bir)
    
    // --- Dahili Sinyaller ---
    reg [CNT_CCL_SZ-1:0] cnt_clk; // 0'dan 587'ye kadar sayan sayaç
    
//-------------------------------------------------------
    always @(posedge CLK or negedge RST_n) begin
      if (!RST_n) begin // --- Reset Durumu ---
          cnt_clk <= {CNT_CCL_SZ{1'b0}}; // Sayacı sıfırla
          O_ST    <= 1'b0; // Çıkışı sıfırla
      end
      else begin // --- Çalışma Durumu ---
          
          // Sayaç, CCL_SZ-1'e (587) ulaştı mı?
          if (cnt_clk == CCL_SZ - 1'b1) begin
              cnt_clk <= {CNT_CCL_SZ{1'b0}}; // Sayacı sıfırla
              O_ST    <= 1'b1; // 1 clock süreli pals üret
          end
          else begin
              cnt_clk <= cnt_clk + 1'b1; // Sayacı artır
              O_ST    <= 1'b0; // Palsi '0'da tut
          end
        end
    end
    
endmodule