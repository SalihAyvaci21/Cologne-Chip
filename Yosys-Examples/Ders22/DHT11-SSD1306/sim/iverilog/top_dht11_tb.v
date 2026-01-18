`timescale 10 ns/ 1 ns
module top_dht11_tb;
     parameter BYTE_SZ  = 8;           // byte genişliği
     parameter VALUE_SZ = 2 * BYTE_SZ; // değer genişliği
    
//------------------------------------------------------------------------

initial begin
  $dumpfile("top_dht11_tb.vcd");
  $dumpvars(0, top_dht11_tb);
end

//------------------------------------------------------------------------       
    reg                        CLK;          // 10 MHz saat sinyali
    reg                        RST_n;        // asenkron sıfırlama (reset)
    reg                        I_EN;         // sensör okumasını başlatır
    wire                       strobe;       // saat etkinleştirme (strobe)
    wire                       IO_DHT11;     // veri hattı
    wire                       rs_dht11_in;  // DHT11'den gelen veri hattının yükselen kenarı
    wire                       fl_dht11_in;  // DHT11'den gelen veri hattının düşen kenarı
    wire signed [VALUE_SZ-1:0] O_VALUE;      // Sıcaklık & Nem verisi
    wire                       O_ERR;        // alınan veri hata bayrağı
    wire                       O_CONV;       // ikili'den BCD'ye dönüştürmeyi başlatan sinyal
    wire                       O_BUSY;       // meşgul sinyali
    reg                        en_dht_slv;   // DHT11'i etkinleştir (simülasyon için)
    reg                        dht_slv;      // DHT11'den aktarım (simülasyon için)
//------------------------------------------------------------------------       
    assign IO_DHT11 = en_dht_slv ? dht_slv : 1'b1;
    assign strobe   = dut.strobe;
    assign rs_dht11_in      = dut.rs_dht11_in;   
    assign fl_dht11_in     = dut.fl_dht11_in;

//------------------------------------------------------------------------       
    top_dht11 dut // "dut" = Device Under Test (Test Edilen Cihaz)
        (
         .CLK(CLK),
         .RST_n(RST_n),
         .I_EN(I_EN),
         .O_VALUE(O_VALUE),
         .O_ERR(O_ERR),
         .O_CONV(O_CONV),
         .O_BUSY(O_BUSY),
         .IO_DHT11(IO_DHT11)
        );

//------------------------------------------------------------------------       
    initial begin
      CLK = 1'b1;
      RST_n = 1'b1;
      I_EN = 1'b0;    
      en_dht_slv = 1'b0;
      dht_slv = 1'b0;
//    sıfırlamayı başlat
      #1; RST_n = 0;
//    sıfırlamayı durdurs
      #2; RST_n = 1; 
      #100099; I_EN = 1'b1;
      #2; I_EN = 1'b0;      
      en_dht_slv = 1'b1; dht_slv = 1'b0;
      #2000000; en_dht_slv = 1'b0;
      #2000; en_dht_slv = 1'b1; dht_slv = 1'b0;
      #8000; en_dht_slv = 1'b0;
      #8000; en_dht_slv = 1'b1; dht_slv = 1'b0;
      
//    birinci byte'ın aktarımı 8'b0101_0101;
      repeat (4)
        begin
          #5000; en_dht_slv = 1'b0; dht_slv = 1'b1;
          #2800; en_dht_slv = 1'b1; dht_slv = 1'b0;
          #5000; en_dht_slv = 1'b0; dht_slv = 1'b1;
          #7000; en_dht_slv = 1'b1; dht_slv = 1'b0;           
        end 

//    ikinci byte'ın aktarımı 8'b0000_0000;
      repeat (8)
        begin
          #5000; en_dht_slv = 1'b0; dht_slv = 1'b1;
          #2800; en_dht_slv = 1'b1; dht_slv = 1'b0;
        end

//    üçüncü byte'ın aktarımı 8'b1010_1010;     
      repeat (4)
        begin
          #5000; en_dht_slv = 1'b0; dht_slv = 1'b1;
          #7000; en_dht_slv = 1'b1; dht_slv = 1'b0;
          #5000; en_dht_slv = 1'b0; dht_slv = 1'b1;
          #2800; en_dht_slv = 1'b1; dht_slv = 1'b0;
        end
         
//    dördüncü byte'ın aktarımı 8'b1010_1010;
      repeat (8)
        begin
          #5000; en_dht_slv = 1'b0; dht_slv = 1'b1;
          #2800; en_dht_slv = 1'b1; dht_slv = 1'b0;
        end 
         
//    beşinci byte'ın aktarımı 8'b1010_1010;
      repeat (8)
        begin
          #5000; en_dht_slv = 1'b0; dht_slv = 1'b1;
          #7000; en_dht_slv = 1'b1; dht_slv = 1'b0;
        end
      
      #5000; en_dht_slv = 1'b0; 
    end
    
    always #1 CLK = ~CLK;
    
    initial begin
      #2510000 $finish;
    end   

    
endmodule