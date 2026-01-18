`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    bin2ascii (v2 - Sentez Dostu Sürüm)
// Yazar:    Gemini (Salih Ayvaci için)
// Tarih:    24.10.2025
//
// Açıklama:
// v2: / (bölme) ve % (mod) operatörleri, sentezleme
//     hatalarına neden olduğu için kaldırıldı.
//     Yerine tekrarlı çıkarma yöntemi kullanıldı.
//----------------------------------------------------------------
module bin2ascii(
    input wire [7:0] din, // 0-255 arası binary giriş
    
    output reg [6:0] ascii_tens, // Onlar basamağı ASCII
    output reg [6:0] ascii_ones  // Birler basamağı ASCII
);

    reg [3:0] tens; // Onlar basamağı (BCD)
    reg [7:0] temp; // Çıkarma işlemi için 8-bit geçici register
    
    always @(*) begin
        tens = 0;
        temp = din;
        
        // Önce 99'dan büyükse sınırı koy (99 olarak kabul et)
        if (temp > 99) begin
            temp = 99;
        end
        
        // Bölme yerine tekrarlı çıkarma (daha güvenli)
        // (Bu yapı, sentezleyici tarafından bir öncelik kodlayıcıya (priority encoder) dönüştürülür)
        if (temp >= 90) begin temp = temp - 90; tens = 9; end
        else if (temp >= 80) begin temp = temp - 80; tens = 8; end
        else if (temp >= 70) begin temp = temp - 70; tens = 7; end
        else if (temp >= 60) begin temp = temp - 60; tens = 6; end
        else if (temp >= 50) begin temp = temp - 50; tens = 5; end
        else if (temp >= 40) begin temp = temp - 40; tens = 4; end
        else if (temp >= 30) begin temp = temp - 30; tens = 3; end
        else if (temp >= 20) begin temp = temp - 20; tens = 2; end
        else if (temp >= 10) begin temp = temp - 10; tens = 1; end
        
        // Çıkarma işleminden geriye kalan 'temp' değeri,
        // 0-9 arasında bir sayıdır ve "birler" basamağını temsil eder.
        
        // BCD'yi ASCII'ye çevir (0x30 ekle)
        ascii_tens = tens + 7'h30;
        ascii_ones = temp[3:0] + 7'h30; // 'temp'in son 4 biti 'ones' basamağıdır
    end

endmodule