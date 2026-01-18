`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Parametre CLKS_PER_BIT aşağıdaki gibi ayarlanır:
// CLKS_PER_BIT = (i_Clock Frekansı)/(UART Frekansı)
// Örnek: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

module receiver(
   input        i_Clock,       // Sistem saat sinyali
   input        i_Rx_Serial,   // UART seri giriş
   output       o_Rx_DV,       // Veri geçerli işareti (Data Valid)
   output [7:0] o_Rx_Byte      // Alınan 8-bitlik veri
   );
    
  parameter CLKS_PER_BIT   =87;      // Bir bit için gereken clock sayısı
  parameter s_IDLE         = 3'b000; // Boşta (Idle) durum
  parameter s_RX_START_BIT = 3'b001; // Start bit durumu
  parameter s_RX_DATA_BITS = 3'b010; // Veri bitlerini alma durumu
  parameter s_RX_STOP_BIT  = 3'b011; // Stop bit durumu
  parameter s_CLEANUP      = 3'b100; // Temizlik durumu
  
  reg           r_Rx_Data_R = 1'b1; // Çift register, metastabilite önleme
  reg           r_Rx_Data   = 1'b1; 
  
  reg [7:0]     r_Clock_Count = 0;  // Clock sayacı
  reg [2:0]     r_Bit_Index   = 0;  // Bit indeksi (8 bit toplam)
  reg [7:0]     r_Rx_Byte     = 0;  // Alınan veri
  reg           r_Rx_DV       = 0;  // Veri geçerli işareti
  reg [2:0]     r_SM_Main     = 0;  // Ana durum makinesi
  
  // Amaç: Giriş verisini çift register üzerinden geçirmek
  // Bu, UART RX Clock Domaininde güvenli kullanım sağlar
  // (Metastabilite sorunlarını ortadan kaldırır)
  always @(posedge i_Clock)
    begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
  
  // Amaç: RX durum makinesini kontrol etmek
  always @(posedge i_Clock)
    begin
      case (r_SM_Main)
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (r_Rx_Data == 1'b0)      // Start biti tespit edildi
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end
         
        // Start bitin ortasını kontrol et, hâlâ LOW mi?
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // Sayacı sıfırla, ortası bulundu
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;  // Start biti yanlış, Idle'a dön
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // s_RX_START_BIT
         
        // Seri veriyi CLKS_PER_BIT kadar bekleyerek al
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Tüm bitler alındı mı?
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // s_RX_DATA_BITS
     
        // Stop biti al. Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Stop biti için CLKS_PER_BIT kadar bekle
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;  // Veri geçerli
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // s_RX_STOP_BIT
     
        // 1 clock bekle, sonra Idle'a dön
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end
         
        default :
          r_SM_Main <= s_IDLE;
      endcase
    end   
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule
