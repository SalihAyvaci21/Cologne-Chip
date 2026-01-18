
module OLED(
    input  wire clk,
    input  wire [7:0] ram_dout, // Top modüldeki RAM'den gelen veri
    output wire SCL,
    output wire SDA,
    output wire FPS,            // Frame Pulse (Kare Senkronizasyonu)
    output reg [9:0] addr = 0   // RAM'e gönderilen okuma adresi [cite: 72]
);
// --- Parametreler ---
    localparam T = 5;                  // I2C komutları arası bekleme süresi [cite: 73]
    
    // Ekran Geometrisi (128x64)
    localparam SCREEN_WIDTH = 128;
    localparam SCREEN_HEIGHT = 64;
    localparam PAGE_COUNT = SCREEN_HEIGHT / 8; // 8 Sayfa (64 / 8)
    localparam MAX_COL = SCREEN_WIDTH - 1;     // 127
    localparam MAX_PAGE = PAGE_COUNT - 1;      // 7

// --- Dahili Sinyaller ve Registerlar ---
    wire Busy;                  // I2C modülünün meşgul sinyali
    reg Start = 0;             // I2C başlatma sinyali
    reg DCn = 0;               // I2C Veri/Komut seçimi
    reg [7:0] DATA = 0;        // I2C'ye gönderilecek veri

    reg [7:0] d = 0;           // RAM'den okunan veriyi tutan register [cite: 74, 79]
    reg [12:0] delay = 0;       // Genel gecikme sayacı
    reg [6:0] col = 0;         // Sütun sayacı (0 - 127) [cite: 75]
    reg [5:0] step = 0;        // Ana durum makinesi (state machine)
    reg [2:0] page = 0;        // Sayfa sayacı (0 - 7) [cite: 76]
    reg fps = 0;               // FPS çıkış pini

//----------- I2C Master Modülü -----------
I2C Mod(.clk(clk), .start(Start), .DCn(DCn), .Data(DATA), .busy(Busy), .scl(SCL), .sda(SDA));

// RAM'den gelen veriyi her zaman (negedge clk) 'd' register'ına al
always @(negedge clk) begin
    d <= ram_dout;
end

// --- Ana Kontrolcü Durum Makinesi ---
always @(posedge clk) begin
    if (delay != 0) begin      // Gecikme sayacı aktifse bekle
        delay <= delay - 1;
end else if (Busy) begin   // I2C modülü meşgulse bekle
        Start <= 0;
        delay <= T;
end else begin             // Hazır, bir sonraki adıma geç
        case(step)
            // --- Adım 0-24: OLED Başlatma (Initialization) Sekansı ---
            0: begin DATA<=8'hAE; DCn<=0; Start<=1; step<=1;  delay<=T; end // 0: Ekranı Kapat (Display OFF) [cite: 82]
            1: begin DATA<=8'hD5; DCn<=0; Start<=1; step<=2;  delay<=T; end // 1: Saat Bölücü/Osilatör Frekansını Ayarla [cite: 83]
            2: begin DATA<=8'h80; DCn<=0; Start<=1; step<=3;  delay<=T; end // 2: -> Önerilen değer [cite: 84]
            3: begin DATA<=8'hA8; DCn<=0; Start<=1; step<=4;  delay<=T; end // 3: MUX Oranını Ayarla (Set MUX Ratio) [cite: 85]
            4: begin DATA<=8'h3F; DCn<=0; Start<=1; step<=5;  delay<=T; end // 4: -> 64 MUX (128x64 ekran için) [cite: 86]
            5: begin DATA<=8'hD3; DCn<=0; Start<=1; step<=6;  delay<=T; end // 5: Ekran Kaydırmayı (Offset) Ayarla [cite: 87]
            6: begin DATA<=8'h00; DCn<=0; Start<=1; step<=7;  delay<=T; end // 6: -> Kaydırma yok [cite: 88]
            7: begin DATA<=8'h40; DCn<=0; Start<=1; step<=8;  delay<=T; end // 7: Başlangıç Satırını Ayarla (Set Start Line, 0) [cite: 89]
            8: begin DATA<=8'h8D; DCn<=0; Start<=1; step<=9;  delay<=T; end // 8: Şarj Pompası (Charge Pump) Ayarı [cite: 90]
            9: begin DATA<=8'h14; DCn<=0; Start<=1; step<=10; delay<=T; end // 9: -> Şarj Pompasını Aktif Et (Enable) [cite: 91]
            10: begin DATA<=8'h20; DCn<=0; Start<=1; step<=11; delay<=T; end // 10: Hafıza Adresleme Modunu Ayarla [cite: 92]
            11: begin DATA<=8'h00; DCn<=0; Start<=1; step<=12; delay<=T; end // 11: -> Yatay Adresleme Modu (Not: Kod Sayfa Modu gibi çalışıyor) [cite: 93]
            12: begin DATA<=8'hA1; DCn<=0; Start<=1; step<=13; delay<=T; end // 12: Segment Yeniden Eşle (Remap) -> Sütun 127 = SEG0 [cite: 94]
            13: begin DATA<=8'hC8; DCn<=0; Start<=1; step<=14; delay<=T; end // 13: COM Çıkış Tarama Yönü -> Terslenmiş (Remapped) [cite: 95]
            14: begin DATA<=8'hDA; DCn<=0; Start<=1; step<=15; delay<=T; end // 14: COM Pin Konfigürasyonunu Ayarla [cite: 96]
            15: begin DATA<=8'h12; DCn<=0; Start<=1; step<=16; delay<=T; end // 15: -> Alternatif COM pin konfig. [cite: 97]
            16: begin DATA<=8'h81; DCn<=0; Start<=1; step<=17; delay<=T; end // 16: Kontrastı Ayarla [cite: 98]
            17: begin DATA<=8'hCF; DCn<=0; Start<=1; step<=18; delay<=T; end // 17: -> Kontrast değeri [cite: 99]
            18: begin DATA<=8'hD9; DCn<=0; Start<=1; step<=19; delay<=T; end // 18: Ön-Şarj (Pre-charge) Periyodunu Ayarla [cite: 100]
            19: begin DATA<=8'hF1; DCn<=0; Start<=1; step<=20; delay<=T; end // 19: -> Değer [cite: 101]
            20: begin DATA<=8'hDB; DCn<=0; Start<=1; step<=21; delay<=T; end // 20: VCOMH Deselect Seviyesini Ayarla [cite: 102]
            21: begin DATA<=8'h40; DCn<=0; Start<=1; step<=22; delay<=T; end // 21: -> Değer [cite: 103]
            22: begin DATA<=8'hA4; DCn<=0; Start<=1; step<=23; delay<=T; end // 22: Tüm Ekranı Aç (Açma/Kapama) -> RAM'den devam et [cite: 104]
            23: begin DATA<=8'hA6; DCn<=0; Start<=1; step<=24; delay<=T; end // 23: Normal/Ters (Inverse) Ekran -> Normal (A6) [cite: 105]
            24: begin DATA<=8'hAF; DCn<=0; Start<=1; step<=25; delay<=T; end // 24: Ekranı Aç (Display ON) [cite: 106]

            // --- Adım 25-30: 128x64 Görüntü Yazma Döngüsü ---
            
            // Adım 25: Yeni Sayfa Kurulumu
            25: begin
                col  <= 0;                   // Sütun sayacını sıfırla (0) [cite: 107]
                step <= 26;                  // Adres ayarlama adımlarına git [cite: 108]
            end

            // Adım 26, 27, 28: OLED İmleç Konumunu Ayarla (Sayfa ve Sütun)
            26: begin DATA<=8'hB0+page; DCn<=0; Start<=1; step<=27; delay<=T; end // Sayfa adresini ayarla (B0 - B7) [cite: 109]
            27: begin DATA<=8'h00;      DCn<=0; Start<=1; step<=28; delay<=T; end // Sütun adresi alt nibble (0) [cite: 110]
            28: begin DATA<=8'h10;      DCn<=0; Start<=1; step<=29; delay<=T; end // Sütun adresi üst nibble (0) [cite: 111]
            
            // Adım 29: RAM'den Gelen Veriyi Gönder
            29: begin
                DATA <= d;                   // RAM'den (negedge'de) okunan veriyi gönder [cite: 112, 79]
                DCn <= 1;                    // Mod: Veri [cite: 113]
                Start <= 1;                  // I2C transferini başlat [cite: 113]
                delay <= T; 
                step <= 30;                  // Adres güncelleme adımına git
            end

            // Adım 30: Adresleme ve Döngü Kontrolü
            30: begin
                if (col == MAX_COL) begin    // Sayfanın sonuna gelindi (Sütun 127) [cite: 114]
                    if (page == MAX_PAGE) begin// Ekranın sonuna gelindi (Sayfa 7) [cite: 114]
                        page <= 0;           // Sayfayı başa sar [cite: 115]
                        addr <= 0;           // RAM adresini başa sar [cite: 115]
                        fps <= ~fps;         // FPS sinyalini toggle et [cite: 116]
                    end else begin             // Sadece sayfa bitti, ekran bitmedi
                        page <= page + 1;    // Bir sonraki sayfaya geç [cite: 117]
                        addr <= addr + 1;    // RAM adresini artır [cite: 118]
                    end
                    step <= 25;              // Yeni sayfa kurulumuna dön [cite: 119]
                end else begin                 // Sayfa bitmedi
                    col <= col + 1;          // Sütun sayacını artır [cite: 120]
                    addr <= addr + 1;        // RAM adresini artır [cite: 121]
                    step <= 29;              // Veri göndermeye dön [cite: 122]
                end
            end

            default: begin
                step <= 0; // Beklenmedik bir durumda başa dön
end
        endcase
    end
end

assign FPS = fps; // Dahili fps register'ını çıkışa ata

endmodule