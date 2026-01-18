`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    I2C
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// OLED Sürücüsü (OLED.v) için I2C Master (Yönetici) modülü.
// 'start' sinyali geldiğinde, SSD1306'nın gerektirdiği formatta
// (Adres -> Kontrol Baytı -> Veri Baytı) 3 baytlık
// bir I2C transferi gerçekleştirir.
// İşlem süresince 'busy' bayrağını '1' yapar.
//----------------------------------------------------------------
module I2C(
    input clk,          // Sistem saati (10MHz)
    input start,        // İletişimi başlat sinyali (1 pals)
    input DCn,          // 1 -> Veri (Data) / 0 -> Komut (Command)
    input [7:0] Data,   // Gönderilecek 8-bit veri/komut
    output reg busy = 0, // I2C meşgul bayrağı
    output reg scl = 1,  // I2C Seri Saat (Serial Clock)
    output reg sda = 1   // I2C Seri Veri (Serial Data)
);
// --- Parametreler ---
    parameter SLAVE_ADDR = 8'h78; // OLED Slave Adresi (8'b01111000)
    parameter CTRL_CMD   = 8'h80; // Komut için kontrol baytı (Co=1, D/C=0)
    parameter CTRL_DATA  = 8'h40; // Veri için kontrol baytı (Co=0, D/C=1)

    // I2C Hız Ayarı (10MHz sistem saati için):
    // 100kHz için: T_WAIT = (10_000_000 / 100_000) / 2 = 50
    // 400kHz için: T_WAIT = (10_000_000 / 400_000) / 2 = 12.5 (13)
    // ~833kHz için: T_WAIT = 6
    localparam T_WAIT = 6; // SCL periyodu için yarım bekleme süresi

// --- Durum Makinesi (FSM) Durumları ---
    parameter IDEL  = 0; // Bekleme
    parameter START = 1; // Start Sinyali Üret
    parameter ADDR  = 2; // Slave Adresini Gönder
    parameter CBYTE = 3; // Kontrol Baytını Gönder
    parameter DATA  = 4; // Veri Baytını Gönder
    parameter STOP  = 5; // Stop Sinyali Üret
    
// --- Dahili Register ve Sinyaller ---
    reg DCn_r = 0;       // DCn girişinin kayıtlı hali
    reg [2:0] state = 0; // Ana durum makinesi
    reg [3:0] i = 0;     // Bit sayacı (0-8, 8 bit veri + 1 bit ACK)
    reg [3:0] step = 0;  // Alt durum makinesi adımları
    reg [12:0] delay = 1; // Saat döngüsü sayacı
    reg [7:0] data = 0;  // Gönderilecek veriyi tutan register

always @(posedge clk)
begin
    if (delay != 1) begin // Gecikme sayacı aktifse (T_WAIT süresince)
        delay <= delay - 1;
    end else begin        // Gecikme tamamlandıysa, state machine çalışır
        case(state)
            
            // --- DURUM 0: BEKLEME (IDLE) ---
            IDEL: begin
                scl <= 1;
                sda <= 1;
                busy <= 0; // Meşgul bayrağını temizle
                if (start) begin // 'start' sinyali alındı
                    DCn_r <= DCn;     // Komut/Veri modunu kaydet
                    data <= Data;     // Gönderilecek baytı kaydet
                    busy <= 1;        // Meşgul bayrağını kur
                    state <= START;   // Başlangıç durumuna geç
                    step <= 0;
                end
            end
      
            // --- DURUM 1: START KONDİSYONU ---
            START: begin
                case(step)
                    0: begin // SCL yüksekken SDA'yı düşür
                        sda <= 0;
                        delay <= T_WAIT;
                        step <= step + 1;      
                    end
                    1: begin // SCL'yi düşür
                        scl <= 0;
                        state <= ADDR; // Adres gönderme durumuna geç
                        step <= 0;
                    end
                endcase
            end

            // --- DURUM 2: SLAVE ADRESİ GÖNDERME ---
            ADDR: begin
                case(step)
                    0: begin // Adım 0: SCL'yi Düşür (Bit göndermeye başla)
                        if (i < 8) begin     // 8 bit adres gönderilecek
                            scl <= 0;
                            step <= 1;
                        end else if (i == 8) begin // 9. bit (ACK) için hazırlan
                            scl <= 0;
                            sda <= 0; // ACK için SDA'yı serbest bırak (pull-up ile '1' olmalı)
                            delay <= T_WAIT;
                            i <= i + 1;
                            step <= 2;
                        end
                    end
                    1: begin // Adım 1: Veri bitini SDA'ya koy
                        sda <= SLAVE_ADDR[7-i];
                        delay <= T_WAIT - 1;
                        i <= i + 1; // Bit sayacını artır
                        step <= 2;
                    end
                    2: begin // Adım 2: SCL'yi Yükselt (Veri okuma/yazma)
                        if (i < 9) begin   // Adres bitleri gönderilirken
                            scl <= 1;
                            delay <= T_WAIT;
                            step <= 0;
                        end else begin       // ACK biti sonrası
                            scl <= 1;
                            delay <= T_WAIT;
                            step <= 3;
                        end
                    end
                    3: begin // Adım 3: SCL'yi düşür (ACK sonrası)
                        scl <= 0;
                        sda <= 0;
                        delay <= T_WAIT;
                        step <= 4;
                    end
                    4: begin // Adım 4: Kontrol baytına geç
                        step <= 0;
                        i <= 0; // Bit sayacını sıfırla
                        state <= CBYTE;
                    end
                endcase
            end
      
            // --- DURUM 3: KONTROL BAYTI (CBYTE) GÖNDERME ---
            // (Adres durumu ile aynı mantıkta çalışır)
            CBYTE: begin
                case(step)
                    0: begin // SCL Low
                        if (i < 8) begin
                            scl <= 0;
                            step <= 1;
                        end else if (i == 8) begin // ACK
                            scl <= 0;
                            sda <= 0;
                            delay <= T_WAIT;
                            i <= i + 1;
                            step <= 2;
                        end
                    end
                    1: begin // Veri bitini SDA'ya koy
                        if (DCn_r) // Kayıtlı DCn'e göre seç
                            sda <= CTRL_DATA[7-i]; // Veri Kontrol Baytı
                        else
                            sda <= CTRL_CMD[7-i];  // Komut Kontrol Baytı
                        delay <= T_WAIT - 1;
                        i <= i + 1;
                        step <= 2;
                    end
                    2: begin // SCL High
                        if (i < 9) begin
                            scl <= 1;
                            delay <= T_WAIT;
                            step <= 0;
                        end else begin
                            scl <= 1;
                            delay <= T_WAIT;
                            step <= 3;
                        end
                    end
                    3: begin // SCL Low (ACK sonrası)
                        scl <= 0;
                        sda <= 0;
                        delay <= T_WAIT;
                        step <= 4;
                    end
                    4: begin // Veri baytına geç
                        step <= 0;
                        i <= 0;
                        state <= DATA;
                    end
                endcase
            end
      
            // --- DURUM 4: VERİ (DATA) GÖNDERME ---
            // (Adres durumu ile aynı mantıkta çalışır)
            DATA: begin
                case(step)
                    0: begin // SCL Low
                        if (i < 8) begin
                            scl <= 0;
                            step <= 1;
                        end else if (i == 8) begin // ACK
                            scl <= 0;
                            sda <= 0;
                            delay <= T_WAIT;
                            i <= i + 1;
                            step <= 2;
                        end
                    end
                    1: begin // Veri bitini SDA'ya koy
                        sda <= data[7-i]; // Başlangıçta kaydedilen 'data'
                        delay <= T_WAIT - 1;
                        i <= i + 1;
                        step <= 2;
                    end
                    2: begin // SCL High
                        if (i < 9) begin
                            scl <= 1;
                            delay <= T_WAIT;
                            step <= 0;
                        end else begin
                            scl <= 1;
                            delay <= T_WAIT;
                            step <= 3;
                        end
                    end
                    3: begin // SCL Low (ACK sonrası)
                        scl <= 0;
                        sda <= 0;
                        delay <= T_WAIT;
                        step <= 4;
                    end
                    4: begin // Durdurma durumuna geç
                        step <= 0;
                        i <= 0;
                        state <= STOP;
                    end
                endcase
            end   
            
            // --- DURUM 5: STOP KONDİSYONU ---
            STOP: begin
                case(step)
                    0: begin
                        scl <= 1; // SCL'yi yükselt
                        sda <= 0; // SDA'yı düşük tut
                        delay <= T_WAIT;
                        step <= step + 1;
                    end
                    1: begin // SCL yüksekken SDA'yı yükselt
                        sda <= 1;
                        state <= IDEL; // Başa (Bekleme) dön
                        step <= 0;
                    end
                endcase
            end    

            default: begin
                state <= IDEL;
                step <= 0;
                i <= 0;
            end

        endcase
    end
end

endmodule