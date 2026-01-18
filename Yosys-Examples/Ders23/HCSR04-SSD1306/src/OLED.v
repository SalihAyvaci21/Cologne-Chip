`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    OLED
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// SSD1306 kontrolcülü 128x64 I2C OLED ekranı süren modül.
//
// Başlangıçta (reset sonrası) ekrana başlatma (init) komutlarını
// gönderir. Ardından sonsuz bir döngüye girerek, 1024 byte'lık
// Frame Buffer (RAM) içeriğini sürekli olarak ekrana
// (Sayfa Sayfa) yazar.
//----------------------------------------------------------------
module OLED(
    input  wire clk,            // Sistem Saati (10MHz)
    input  wire [7:0] ram_dout, // Frame Buffer RAM'den gelen veri
    output wire SCL,            // I2C Saat Sinyali
    output wire SDA,            // I2C Veri Sinyali
    output wire FPS,            // Frame Pulse (Her kare tamamlandığında 'toggle' olur)
    output reg [9:0] addr = 0   // RAM'e gönderilen okuma adresi
);
// --- Parametreler ---
    localparam T = 5; // I2C komutları arası bekleme süresi
    
    // Ekran Geometrisi (128x64)
    localparam SCREEN_WIDTH = 128; // 128 Sütun
    localparam SCREEN_HEIGHT = 64;  // 64 Satır
    localparam PAGE_COUNT = SCREEN_HEIGHT / 8; // 8 Sayfa (64 / 8)
    localparam MAX_COL = SCREEN_WIDTH - 1;     // Maksimum Sütun İndeksi (127)
    localparam MAX_PAGE = PAGE_COUNT - 1;      // Maksimum Sayfa İndeksi (7)

// --- Dahili Sinyaller ve Registerlar ---
    wire Busy;        // I2C modülünün meşgul sinyali
    reg Start = 0;    // I2C başlatma sinyali
    reg DCn = 0;      // I2C Veri (1) / Komut (0) seçimi
    reg [7:0] DATA = 0; // I2C'ye gönderilecek veri baytı

    reg [7:0] d = 0; // RAM'den okunan veriyi tutan ara register
    reg [12:0] delay = 0; // Genel gecikme sayacı
    reg [6:0] col = 0;   // Mevcut Sütun sayacı (0 - 127)
    reg [5:0] step = 0;  // Ana durum makinesi (state machine)
    reg [2:0] page = 0;  // Mevcut Sayfa sayacı (0 - 7)
    reg fps = 0;         // FPS çıkış pini

//----------- I2C Master Modülü -----------
// I2C modülünü projeye dahil et
I2C Mod(.clk(clk), .start(Start), .DCn(DCn), .Data(DATA), .busy(Busy), .scl(SCL), .sda(SDA));

// RAM'den gelen veriyi her zaman (negedge clk) 'd' register'ına al
// (OLED FSM'i posedge'de, I2C negedge'de çalışır, bu senkronizasyonu sağlar)
always @(negedge clk) begin
    d <= ram_dout;
end

// --- Ana Kontrolcü Durum Makinesi (FSM) ---
always @(posedge clk) begin
    if (delay != 0) begin      // Gecikme sayacı aktifse, bekle
        delay <= delay - 1;
    end else if (Busy) begin   // I2C modülü meşgulse, bekle
        Start <= 0;
        delay <= T;
    end else begin             // Hazır, bir sonraki adıma geç
        case(step)
            // --- Adım 0-24: OLED Başlatma (Initialization) Sekansı ---
            // Bu komutlar SSD1306 datasheet'inden alınmıştır.
            0:  begin DATA<=8'hAE; DCn<=0; Start<=1; step<=1;  delay<=T; end // 0: Ekranı Kapat
            1:  begin DATA<=8'hD5; DCn<=0; Start<=1; step<=2;  delay<=T; end // 1: Saat Bölücü/Osilatör Frekansı
            2:  begin DATA<=8'h80; DCn<=0; Start<=1; step<=3;  delay<=T; end // 2: -> Değer
            3:  begin DATA<=8'hA8; DCn<=0; Start<=1; step<=4;  delay<=T; end // 3: MUX Oranını Ayarla
            4:  begin DATA<=8'h3F; DCn<=0; Start<=1; step<=5;  delay<=T; end // 4: -> 64 MUX (128x64 ekran)
            5:  begin DATA<=8'hD3; DCn<=0; Start<=1; step<=6;  delay<=T; end // 5: Ekran Kaydırmayı (Offset) Ayarla
            6:  begin DATA<=8'h00; DCn<=0; Start<=1; step<=7;  delay<=T; end // 6: -> Kaydırma yok
            7:  begin DATA<=8'h40; DCn<=0; Start<=1; step<=8;  delay<=T; end // 7: Başlangıç Satırını Ayarla (0)
            8:  begin DATA<=8'h8D; DCn<=0; Start<=1; step<=9;  delay<=T; end // 8: Şarj Pompası (Charge Pump)
            9:  begin DATA<=8'h14; DCn<=0; Start<=1; step<=10; delay<=T; end // 9: -> Şarj Pompasını Aktif Et
            10: begin DATA<=8'h20; DCn<=0; Start<=1; step<=11; delay<=T; end // 10: Hafıza Adresleme Modu
            11: begin DATA<=8'h00; DCn<=0; Start<=1; step<=12; delay<=T; end // 11: -> Yatay Adresleme Modu
            12: begin DATA<=8'hA1; DCn<=0; Start<=1; step<=13; delay<=T; end // 12: Segment Yeniden Eşle (Sütun 127 = SEG0)
            13: begin DATA<=8'hC8; DCn<=0; Start<=1; step<=14; delay<=T; end // 13: COM Çıkış Tarama Yönü (Terslenmiş)
            14: begin DATA<=8'hDA; DCn<=0; Start<=1; step<=15; delay<=T; end // 14: COM Pin Konfigürasyonu
            15: begin DATA<=8'h12; DCn<=0; Start<=1; step<=16; delay<=T; end // 15: -> Alternatif COM pin konfig.
            16: begin DATA<=8'h81; DCn<=0; Start<=1; step<=17; delay<=T; end // 16: Kontrastı Ayarla
            17: begin DATA<=8'hCF; DCn<=0; Start<=1; step<=18; delay<=T; end // 17: -> Kontrast değeri
            18: begin DATA<=8'hD9; DCn<=0; Start<=1; step<=19; delay<=T; end // 18: Ön-Şarj (Pre-charge) Periyodu
            19: begin DATA<=8'hF1; DCn<=0; Start<=1; step<=20; delay<=T; end // 19: -> Değer
            20: begin DATA<=8'hDB; DCn<=0; Start<=1; step<=21; delay<=T; end // 20: VCOMH Deselect Seviyesi
            21: begin DATA<=8'h40; DCn<=0; Start<=1; step<=22; delay<=T; end // 21: -> Değer
            22: begin DATA<=8'hA4; DCn<=0; Start<=1; step<=23; delay<=T; end // 22: Tüm Ekranı Aç (RAM'den devam et)
            23: begin DATA<=8'hA6; DCn<=0; Start<=1; step<=24; delay<=T; end // 23: Normal Ekran (Terslenmemiş)
            24: begin DATA<=8'hAF; DCn<=0; Start<=1; step<=25; delay<=T; end // 24: Ekranı Aç

            // --- Adım 25-30: 128x64 Görüntü Yazma Döngüsü ---
            
            // Adım 25: Yeni Sayfa Kurulumu
            25: begin
                col  <= 0;   // Sütun sayacını sıfırla (0)
                step <= 26;  // Adres ayarlama adımlarına git
            end

            // Adım 26, 27, 28: OLED İmleç Konumunu Ayarla (Sayfa ve Sütun)
            26: begin DATA<=8'hB0+page; DCn<=0; Start<=1; step<=27; delay<=T; end // Sayfa adresini ayarla (B0 - B7)
            27: begin DATA<=8'h00;       DCn<=0; Start<=1; step<=28; delay<=T; end // Sütun adresi alt nibble (0)
            28: begin DATA<=8'h10;       DCn<=0; Start<=1; step<=29; delay<=T; end // Sütun adresi üst nibble (0)
            
            // Adım 29: RAM'den Gelen Veriyi Gönder
            29: begin
                DATA <= d;    // RAM'den (negedge'de) okunan veriyi I2C'ye ver
                DCn <= 1;     // Mod: Veri gönderiliyor
                Start <= 1;   // I2C transferini başlat
                delay <= T;
                step <= 30;   // Adres güncelleme adımına git
            end

            // Adım 30: Adresleme ve Döngü Kontrolü
            30: begin
                // Sayfanın sonuna gelindi mi (Sütun 127)?
                if (col == MAX_COL) begin
                    // Ekranın sonuna gelindi mi (Sayfa 7)?
                    if (page == MAX_PAGE) begin
                        page <= 0;        // Sayfayı başa sar (0)
                        addr <= 0;        // RAM adresini başa sar (0)
                        fps <= ~fps;      // Kare bitti, FPS sinyalini tersle
                    end else begin        // Sadece sayfa bitti
                        page <= page + 1; // Bir sonraki sayfaya geç
                        addr <= addr + 1; // RAM adresini artır (RAM'de de sonraki sayfaya geçer)
                    end
                    step <= 25; // Yeni sayfa kurulumuna dön
                end else begin            // Sayfa bitmedi
                    col <= col + 1;   // Sütun sayacını artır
                    addr <= addr + 1; // RAM adresini artır
                    step <= 29; // Veri göndermeye dön
                end
            end

            // Beklenmedik bir durumda başa dön
            default: begin
                step <= 0;
            end
        endcase
    end
end

// Dahili fps register'ını çıkış portuna ata
assign FPS = fps;

endmodule