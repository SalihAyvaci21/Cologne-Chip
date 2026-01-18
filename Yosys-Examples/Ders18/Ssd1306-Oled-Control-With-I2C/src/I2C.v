module I2C(
    input clk,                     // Sistem saati
    input start,                   // İletişimi başlat sinyali
    input DCn,                     // 1 -> Veri (Data) / 0 -> Komut (Command)
    input [7:0] Data,              // Gönderilecek 8-bit veri/komut
    output reg busy = 0,           
    // I2C meşgul bayrağı
    output reg scl = 1,             // I2C Seri Saat (Serial Clock)
    output reg sda = 1              // I2C Seri Veri (Serial Data)
);
// --- Parametreler ---
    parameter SLAVE_ADDR = 8'h78;  // OLED Slave Adresi (8'b01111000)
    parameter CTRL_CMD   = 8'h80;  // Komut için kontrol baytı (Co=1, D/C=0)
    parameter CTRL_DATA  = 8'h40;  // Veri için kontrol baytı (Co=0, D/C=1)

    // Not: T_WAIT, 10MHz saat hızı ile ~900kHz I2C hızı üretir.
    // (10MHz / (2 * T_WAIT)) -> 10 / (2*6) ~= 833kHz
    // Daha yavaş 400kHz için: T_WAIT = (10_000_000 / 400_000) / 2 = 12.5 (12 veya 13)
    // Daha yavaş 100kHz için: T_WAIT = (10_000_000 / 100_000) / 2 = 50
    localparam T_WAIT = 6;         // [cite: 4] SCL periyodu için bekleme süresi

// --- Durum Makinesi (State Machine) Durumları ---
    parameter IDEL  = 0;
    parameter START = 1;
    parameter ADDR  = 2;
    parameter CBYTE = 3;
parameter DATA  = 4;
    parameter STOP  = 5;
    // T_WAIT parametresi yukarı taşındı

// --- Dahili Register ve Sinyaller ---
    reg DCn_r = 0;                 // DCn girişinin kayıtlı hali
    reg [2:0] state = 0;           
    // Ana durum makinesi
    reg [3:0] i = 0;               // Bit sayacı (0-8)
    reg [3:0] step = 0;            // Alt durum makinesi adımları
    reg [12:0] delay = 1;          // Saat döngüsü sayacı
    // slave, cbyte, dbyte parametre olarak yukarı taşındı
reg [7:0] data = 0;              // Gönderilecek veriyi tutan register

always @(posedge clk)
begin
    if (delay != 1)                // Gecikme sayacı aktifse
    begin
        delay <= delay - 1;
end else begin                 // Gecikme tamamlandıysa, state machine çalışır
        case(state)
            
            // --- DURUM 0: BEKLEME (IDLE) ---
            IDEL: begin
                scl <= 1;
sda <= 1;
                busy <= 0;             // [cite: 46] Meşgul bayrağını temizle
                if (start) 
                begin                  // 'start' sinyali alındığında
                    DCn_r <= DCn;      
    // Komut/Veri modunu kaydet
                    data <= Data;      
    // Gönderilecek baytı kaydet
                    busy <= 1;         
    // Meşgul bayrağını kur
                    state <= START;    
    // Başlangıç durumuna geç
                    step <= 0;
end
            end
      
            // --- DURUM 1: START KONDİSYONU ---
            START: begin
case(step)
                    0: begin
                        sda <= 0;          // SCL yüksekken SDA'yı düşür
                        delay <= T_WAIT;
step <= step + 1;      
                    end
                    1: begin
                        scl <= 0;          // SCL'yi düşür
state <= ADDR;       // Adres gönderme durumuna geç
step <= 0;
                    end
                endcase
            end

            // --- DURUM 2: SLAVE ADRESİ GÖNDERME ---
            ADDR: begin
                case(step)
                    0: begin // Bit göndermeye başla (SCL Low)
                        if (i < 8) begin     // 8 bit adres gönderilecek
                            scl <= 0;
step <= 1;
                        end else if (i == 8) begin // 9. bit (ACK) için hazırlan
                            scl <= 0;
                            sda <= 0;        // ACK için SDA'yı serbest bırak (normalde 1 olmalı)
                            delay <= T_WAIT;
i <= i + 1;
                            step <= 2;
                        end
                    end
                    1: begin // Veri bitini SDA'ya koy
                        sda <= SLAVE_ADDR[7-i]; // Parametreden adresi al [cite: 20]
                        delay <= T_WAIT - 1;
                        i <= i + 1;            // Bit sayacını artır
                        step <= 2;
end
                    2: begin // SCL'yi Yükselt (Veri okuma/yazma)
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
                    3: begin // SCL'yi düşür (ACK sonrası)
                        scl <= 0;
sda <= 0;
                        delay <= T_WAIT;
                        step <= 4;
end
                    4: begin // Kontrol baytına geç
                        step <= 0;
                        i <= 0;            // Bit sayacını sıfırla
                        state <= CBYTE;
end
                endcase
            end
      
            // --- DURUM 3: KONTROL BAYTI (CBYTE) GÖNDERME ---
            CBYTE: begin
                case(step)
                    0: begin // Bit göndermeye başla (SCL Low)
                        if (i < 8) begin
                            scl <= 0;
step <= 1;
                        end else if (i == 8) begin // 9. bit (ACK)
                            scl <= 0;
                            sda <= 0;
                            delay <= T_WAIT;
                            i <= i + 1;
                            step <= 2;
end
                    end
                    1: begin // Veri bitini SDA'ya koy
                        if (DCn_r)
                            sda <= CTRL_DATA[7-i];  // Parametreden Veri Kontrol Baytı [cite: 30]
                        else
                            sda <= CTRL_CMD[7-i];   // Parametreden Komut Kontrol Baytı [cite: 30]
                        delay <= T_WAIT - 1;
                        i <= i + 1;
                        step <= 2;
end
                    2: begin // SCL'yi Yükselt
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
                    3: begin // SCL'yi düşür (ACK sonrası)
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
            DATA: begin
                case(step)
                    0: begin // Bit göndermeye başla (SCL Low)
                        if (i < 8) begin
                            scl <= 0;
step <= 1;
                        end else if (i == 8) begin // 9. bit (ACK)
                            scl <= 0;
                            sda <= 0;
                            delay <= T_WAIT;
                            i <= i + 1;
                            step <= 2;
end
                    end
                    1: begin // Veri bitini SDA'ya koy
                        sda <= data[7-i];      // Kayıtlı 'data' register'ından [cite: 38]
                        delay <= T_WAIT - 1;
                        i <= i + 1;
                        step <= 2;
end
                    2: begin // SCL'yi Yükselt
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
                    3: begin // SCL'yi düşür (ACK sonrası)
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
                        scl <= 1;          // SCL'yi yükselt [cite: 43]
                        sda <= 0;          // SDA'yı düşük tut [cite: 44]
                        delay <= T_WAIT;
step <= step + 1;
                    end
                    1: begin
                        sda <= 1;          // SCL yüksekken SDA'yı yükselt
                        state <= IDEL;     // Başa dön [cite: 45]
                        // 'busy' IDEL durumunda sıfırlanıyor [cite: 46]
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