`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Parametre CLKS_PER_BIT aşağıdaki gibi ayarlanır:
// CLKS_PER_BIT = (i_Clock Frekansı)/(UART Frekansı)
// Örnek: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

module transmitter(
   input       i_Clock,        // Sistem saat sinyali
   input       i_Tx_DV,        // Veri geçerli işareti (Data Valid)
   input [7:0] i_Tx_Byte,      // Gönderilecek 8-bitlik veri
   output      o_Tx_Active,    // Gönderim devam ediyor işareti
   output reg  o_Tx_Serial,    // UART seri çıkış
   output      o_Tx_Done,      // Gönderim tamamlandı işareti
   output [7:0] o_Tx_Data_dbg  // Debug için: gönderilen veriyi dışarı aktar
   );
  
  parameter CLKS_PER_BIT   = 2;        // Bir bit için gereken clock sayısı
  parameter s_IDLE         = 3'b000;   // Boşta (Idle) durum
  parameter s_TX_START_BIT = 3'b001;   // Başlangıç biti (Start bit)
  parameter s_TX_DATA_BITS = 3'b010;   // Veri bitleri gönderimi
  parameter s_TX_STOP_BIT  = 3'b011;   // Durdurma biti (Stop bit)
  parameter s_CLEANUP      = 3'b100;   // Temizlik durumu (Cleanup)
  
  reg [2:0]    r_SM_Main     = 0;      // Ana durum makinesi
  reg [7:0]    r_Clock_Count = 0;      // Clock sayacı
  reg [2:0]    r_Bit_Index   = 0;      // Gönderilen bit indeksi
  reg [7:0]    r_Tx_Data     = 0;      // Gönderilecek veri
  reg          r_Tx_Done     = 0;      // Gönderim tamam işareti
  reg          r_Tx_Active   = 0;      // Gönderim aktif işareti
     
  always @(posedge i_Clock)
    begin
       
      case (r_SM_Main)
        s_IDLE :
          begin
            o_Tx_Serial   <= 1'b1;         // Idle durumunda hat HIGH
            r_Tx_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (i_Tx_DV == 1'b1)           // Veri geçerli ise
              begin
                r_Tx_Active <= 1'b1;       // Gönderim aktif
                r_Tx_Data   <= i_Tx_Byte;  // Veriyi kaydet
                r_SM_Main   <= s_TX_START_BIT;
              end
            else
              r_SM_Main <= s_IDLE;
          end
         
        // Başlangıç biti gönder. Start bit = 0
        s_TX_START_BIT :
          begin
            o_Tx_Serial <= 1'b0;
             
            // Start bit için CLKS_PER_BIT kadar bekle
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_START_BIT;
              end
            else
              begin
                r_Clock_Count <= 0;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
          end
         
        // Veri bitlerini gönderme
        s_TX_DATA_BITS :
          begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
             
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count <= 0;
                 
                // Bütün bitler gönderildi mi?
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_TX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_TX_STOP_BIT;
                  end
              end
          end
         
        // Stop biti gönder. Stop bit = 1
        s_TX_STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1;
             
            // Stop bit için CLKS_PER_BIT kadar bekle
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_STOP_BIT;
              end
            else
              begin
                r_Tx_Done     <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
                r_Tx_Active   <= 1'b0;
              end
          end
         
        // 1 clock bekle, sonra Idle'a dön
        s_CLEANUP :
          begin
            r_Tx_Done <= 1'b1;
            r_SM_Main <= s_IDLE;
          end
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end
 
  assign o_Tx_Active   = r_Tx_Active;
  assign o_Tx_Done     = r_Tx_Done;
  assign o_Tx_Data_dbg = r_Tx_Data;
   
endmodule
