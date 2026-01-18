`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    Top_OLED
// Yazar:    Salih Tekin Ayvaci - DEMSAY ELEKTRONİK - ARGE
// Tarih:    12.06.2025
//
// Açıklama:
// Bu modül, projenin en üst seviye (top) modülüdür.
// Bir butondan (debounce edilmiş) gelen girişe göre iki farklı
// görüntü arasında geçiş yapılmasını sağlar.
//
// İçerdiği Alt Modüller:
// 1. debounce_ip_core: Buton sinyalindeki gürültüyü temizler.
// 2. Simple_RAM (x2): İki farklı görüntü verisini tutar.
// 3. OLED: RAM'den seçilen veriyi I2C üzerinden OLED ekrana
//    gönderen kontrolcüdür.
//----------------------------------------------------------------

module Top_OLED (
    // --- Giriş/Çıkış Portları (CCF Dosyasına Göre) ---
    
    // Global Sinyaller
    input wire clk,         // 10MHz Sistem Saati [cite: 48, 125]
    input wire reset_n,   // Aktif-düşük (Active-low) Reset [cite: 48, 126]
    
    // Buton Girişi
    input wire button,     // Aktif-düşük (Active-low) Buton [cite: 48, 127]
    
    // OLED Arayüzü
    output wire SCL,         // I2C Saat [cite: 48, 129]
    output wire SDA,       
  // I2C Veri [cite: 49, 128]
    output wire FPS,         // Frame Pulse (Görüntü tazeleme) [cite: 49, 130]
    
    // Debug LED'leri
    output wire [7:0] led    // Durum LED'leri [cite: 49, 131-137]
);

    // --- Dahili Sinyaller (Wires ve Regs) ---
    
    // Buton Sinyalleri
    wire btn_valid;       // Butona basılma anı (1 saat döngüsü)
    wire btn_stable;      // Butonun gürültüden arınmış kararlı durumu (0 = basılı) [cite: 51]
    
    // Görüntü Seçim Sinyalleri
    reg image_select = 0;
// 0 = Görüntü 1 (image_data.hex), 1 = Görüntü 2 (image2.hex)
    
    // RAM Arayüz Sinyalleri
    wire [9:0] ram_addr;
// OLED kontrolcüsünden gelen adres [cite: 53]
    wire [7:0] ram1_dout;
// 1. RAM'den gelen veri [cite: 54]
    wire [7:0] ram2_dout;
// 2. RAM'den gelen veri [cite: 55]
    wire [7:0] ram_mux_out;
// Seçilen RAM verisi (OLED'e gider) [cite: 56]

    //-------------------------------------------------
    // MODÜL İNSTANTIASYONLARI
    //-------------------------------------------------

    // --- Debouncer Modülü ---
    // Buton girişini gürültüden arındırır.
    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000), // 10MHz saat [cite: 57, 48]
        .SHIFT_LEN(3),
        .IS_PULLUP(1)            // Buton aktif-düşük (pull-up'lı) [cite: 57, 48]
    ) btn_debounce (
        .clk(clk),
        .rst_n(reset_n),      
 // Global reset [cite: 57]
        .push_button(button),    // Fiziksel buton girişi [cite: 57]
        .out_valid(btn_valid),
        .debounced_button(btn_stable)
    );

    // --- Görüntü Değiştirme Mantığı ---
    // Butona basıldığı anda (düşen kenarda: valid=1 ve stable=0)
    // 'image_select' register'ını tersle (toggle).
always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            image_select <= 0; // Reset durumunda ilk görüntüyü seç
end else if (btn_valid && !btn_stable) begin // Düşen kenar algılandı [cite: 60]
            image_select <= ~image_select; // Görüntüyü değiştir (0->1 veya 1->0)
end
    end

    // --- RAM Modülleri ---
    // Görüntü 1 (image_data.hex)
    Simple_RAM #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(10),
        .HEX_FILE("image_data.hex")
    ) ram1 (
        .clk(clk),
        .addr(ram_addr),    // Adres OLED kontrolcüsünden gelir
        .dout(ram1_dout)    // Veri MUX'a gider
    );

    // Görüntü 2 (image2.hex)
    Simple_RAM #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(10),
        .HEX_FILE("image2.hex")
    ) ram2 (
        .clk(clk),
        .addr(ram_addr),    // Adres OLED kontrolcüsünden gelir
        .dout(ram2_dout)    // Veri MUX'a gider
    );

    // --- RAM Seçici MUX ---
    // 'image_select' bitine göre iki RAM çıkışından birini seçer.
assign ram_mux_out = image_select ? ram2_dout : ram1_dout;

    // --- OLED Kontrolcüsü ---
    // Seçilen RAM verisini alır, RAM'e adres gönderir ve
    // I2C pinlerini sürer.
    OLED oled_controller (
        .clk(clk),
        .ram_dout(ram_mux_out), // MUX'tan gelen seçili veri [cite: 65]
        .addr(ram_addr),        // RAM'lere giden adres [cite: 65]
        
        .SCL(SCL),              // I2C Saat çıkışı [cite: 65]
        .SDA(SDA),              // I2C Veri çıkışı [cite: 65]
        .FPS(FPS)               // Frame Pulse çıkışı [cite: 65]
    );

    // --- Debug LED'leri ---
    // (CCF dosyasına göre [cite: 131-137])
    assign led[0] = reset_n;      // Reset durumu (0 = Reset'te) [cite: 67]
    assign led[1] = btn_stable;   // Buton durumu (0 = Basılı) [cite: 68]
    assign led[2] = btn_valid;    // Buton değişimi (1 clock pulse) [cite: 69]
    assign led[3] = image_select; // Seçili resim (0 = 1. resim, 1 = 2. resim) [cite: 70]
    assign led[4] = SCL;          // I2C Saat [cite: 71]
    assign led[5] = SDA;          // I2C Veri [cite: 71]
    assign led[6] = FPS;          // Frame Pulse [cite: 71]
    assign led[7] = 1'b0;         // Kullanılmıyor (CCF'te D8) [cite: 71]

endmodule