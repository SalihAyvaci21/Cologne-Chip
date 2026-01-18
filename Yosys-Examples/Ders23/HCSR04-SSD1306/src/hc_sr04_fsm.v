`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    hc_sr04_fsm
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// HC-SR04 ultrasonik mesafe sensörünü sürmek için kullanılan
// Durum Makinesi (FSM).
//
// I_ST (strobe) sinyali ile tetiklenir, sensöre 10uS'lik
// bir O_TRIG palsi gönderir, I_ECHO sinyalinin süresini
// ölçer ve mesafeyi 9-bit binary (O_DST) olarak çıkarır.
// Ölçüm bitince O_CONV sinyalini 1 pals üretir.
//----------------------------------------------------------------
module hc_sr04_fsm
    #(parameter MAX_RANGE  = 400,           // Maksimum ölçüm mesafesi (cm)
      parameter DST_SZ = $clog2(MAX_RANGE)) // Mesafe sayacı genişliği (9-bit)
    (CLK, RST_n, I_EN, I_ST, I_ECHO, 
     O_DST, O_CONV, O_TRIG, O_FL);
//-------------------------------------------------------    
    // Parametreler
    localparam CCL_TIME    = 1020; // 60 mS ölçüm döngüsü (58.82 uS * 1020)
    localparam CNT_CCL_TIME = $clog2(CCL_TIME); // 60ms sayacı için bit genişliği (10-bit)
    
    // FSM Durumları
    localparam ST_SZ      = 6; // Durum register genişliği
    localparam IDLE       = 6'b000001; // I_EN sinyalini bekleme durumu
    localparam TRIG       = 6'b000010; // Sensöre O_TRIG palsi gönderme durumu
    localparam WT_ECHO    = 6'b000100; // Sensörden I_ECHO sinyalinin gelmesini bekleme
    localparam CNT_ECHO   = 6'b001000; // I_ECHO sinyali '1' iken sayma durumu
    localparam CONV       = 6'b010000; // Ölçüm bitti, O_CONV (çevrimi başlat) palsi üret
    localparam WT_END_CCL = 6'b100000; // 60ms'lik ölçüm periyodunun dolmasını bekle
    
    // --- Giriş Sinyalleri ---
    input wire CLK;     // Sistem Saati (10MHz)
    input wire RST_n;   // Aktif-düşük Reset
    input wire I_EN;    // Ölçümü etkinleştir
    input wire I_ST;    // 58.82 uS'lik Strobe palsi (clk_div'den gelir)
    input wire I_ECHO;  // Sensörden gelen Echo sinyali
    
    // --- Çıkış Sinyalleri ---
    output reg [DST_SZ-1:0] O_DST;  // Ölçülen mesafe (Binary)
    output reg              O_CONV; // BCD çeviriciyi tetikleme sinyali (1 pals)
    output reg              O_TRIG; // Sensörü tetikleme palsi
    output reg              O_FL;   // Ölçüm bayrağı (Ölçüm sürerken '1')
    
    // --- Dahili Sinyaller ---
    reg [ST_SZ-1:0]        st;          // Mevcut durum
    reg [ST_SZ-1:0]        nx_st;       // Sonraki durum
    reg [CNT_CCL_TIME-1:0] cnt_i_st;    // 60ms'lik ana döngü sayacı
    reg [CNT_CCL_TIME-1:0] nx_cnt_i_st; //
    reg                    echo_d0;     // Echo sinyali için senkronizasyon register 1
    reg                    echo_sync;   // Senkronize edilmiş (metastability önlenmiş) Echo
    reg [DST_SZ-1:0]       cnt_echo;    // Echo süresini (mesafeyi) sayan sayaç
    reg [DST_SZ-1:0]       nx_cnt_echo; //
    reg                    nx_o_trig;   //
    reg [DST_SZ-1:0]       nx_o_dst;    //
    reg                    nx_o_conv;   //
    reg                    nx_o_fl;     //

    // --- Kombinasyonel Mantık (Sonraki Durum ve Çıkışlar) ---
    always @(*) begin
      // Değişiklik olmadıkça mevcut değerleri koru
      nx_st = st;
      nx_cnt_i_st = cnt_i_st;
      nx_o_trig = O_TRIG;
      nx_cnt_echo = cnt_echo;
      nx_o_conv = O_CONV;
      nx_o_dst = O_DST;
      nx_o_fl = O_FL;
      
      // FSM sadece 'I_ST' (Strobe) palsi geldiğinde çalışır
      if (I_ST)
        begin
          case (st)
             // Durum: BEKLEME
             IDLE: begin
                if (I_EN) begin // Ölçüm izni varsa
                    nx_o_trig = 1'b1; // Trigger'ı '1' yap
                    nx_o_fl = 1'b1;   // Ölçüm bayrağını kaldır
                    nx_st = TRIG;     // TRIG durumuna geç
                end
             end
             
             // Durum: TETİKLEME (10uS Palsi)
             // (Not: 1 strobe = 58.8uS. Bu pals > 10uS olduğu için yeterlidir)
             TRIG: begin
                nx_cnt_i_st = cnt_i_st + 1'b1; // 60ms sayacını ilerlet
                nx_o_trig = 1'b0; // Trigger'ı '0'a çek (pals bitti)
                nx_st = WT_ECHO;  // Echo bekleme durumuna geç
             end
             
             // Durum: ECHO BEKLEME
             WT_ECHO: begin
                nx_cnt_i_st = cnt_i_st + 1'b1; // 60ms sayacını ilerlet
                if (echo_sync) // Senkronize Echo sinyali '1' oldu mu?
                  nx_st = CNT_ECHO; // Sayma durumuna geç
             end
             
             // Durum: ECHO SAYMA
             CNT_ECHO: begin 
                nx_cnt_i_st = cnt_i_st + 1'b1; // 60ms sayacını ilerlet
                nx_cnt_echo = cnt_echo + 1'b1; // Mesafe sayacını ilerlet
                
                if (!echo_sync) begin // Echo sinyali '0'a düştü mü?
                    nx_cnt_echo = {DST_SZ{1'b0}}; // Mesafe sayacını sıfırla
                    nx_o_conv = 1'b1; // BCD çeviriciye 'çevir' sinyali gönder (1 pals)
                    nx_o_dst = cnt_echo + 1'b1; // Ölçülen mesafeyi çıkışa ata
                    nx_st = CONV; // Çevrim durumuna geç
                end
             end
             
             // Durum: ÇEVİRME (CONV)
             CONV: begin
                nx_cnt_i_st = cnt_i_st + 1'b1; // 60ms sayacını ilerlet
                nx_o_conv = 1'b0; // Çevirme sinyalini '0'a çek (pals bitti)
                nx_st = WT_END_CCL; // 60ms'lik döngünün bitişini bekle
             end
             
             // Durum: DÖNGÜ SONUNU BEKLEME
             WT_END_CCL: begin
                nx_cnt_i_st = cnt_i_st + 1'b1; // 60ms sayacını ilerlet
                
                // 60ms'lik süre (CCL_TIME) doldu mu?
                if (cnt_i_st == CCL_TIME - 1'b1) begin 
                    nx_cnt_i_st = {CNT_CCL_TIME{1'b0}}; // 60ms sayacını sıfırla
                    nx_o_fl = 1'b0;   // Ölçüm bayrağını indir
                    nx_st = IDLE;     // Başa (IDLE) dön
                end
             end
             
             // Varsayılan (Hata) Durumu
             default: begin
                nx_st = IDLE;
                nx_cnt_i_st = {CNT_CCL_TIME{1'b0}};
                nx_o_trig = 1'b0;
                nx_cnt_echo = {DST_SZ{1'b0}};
                nx_o_conv = 1'b0;
                nx_o_dst = {DST_SZ{1'b0}};
                nx_o_fl = 1'b0;
             end       
          endcase
        end
    end
    
    // --- Ardışıl Mantık (Register Güncelleme) ---
    always @(posedge CLK or negedge RST_n) begin
      if (!RST_n) begin // --- Reset Durumu ---
          st        <= IDLE;
          cnt_i_st  <= {CNT_CCL_TIME{1'b0}};
          O_TRIG    <= 1'b0;
          cnt_echo  <= {DST_SZ{1'b0}};
          O_CONV    <= 1'b0;
          O_DST     <= {DST_SZ{1'b0}};
          echo_d0   <= 1'b0;
          echo_sync <= 1'b0;
          O_FL      <= 1'b0;
      end
      else begin // --- Çalışma Durumu (Her CLK vuruşunda) ---
          // Kombinasyonel blokta hesaplanan değerleri register'lara ata
          st        <= nx_st;
          cnt_i_st  <= nx_cnt_i_st;
          O_TRIG    <= nx_o_trig;
          cnt_echo  <= nx_cnt_echo;
          O_CONV    <= nx_o_conv;
          O_DST     <= nx_o_dst;
          O_FL      <= nx_o_fl;
          
          // I_ECHO girişi için çift 'reg' ile senkronizasyon (Metastability önlemi)
          if (I_ST) begin // Sadece strobe palsi geldiğinde örnek al
              echo_d0   <= I_ECHO;
              echo_sync <= echo_d0;
            end
        end
    end

endmodule