`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül: RgbLed (Düzeltilmiş Sürüm)
// Açıklama:
// "Multiple edge" hatasını düzeltmek için ilk always bloğundaki
// hatalı reset mantığı (|| ~blink_en) düzeltildi.
//----------------------------------------------------------------
module RgbLed # (
    parameter BLINK_PERIOD = 31'd2700_0000, // 1.0 s (27MHz için)
    parameter VALUE_ON     = 1'b0 
) (
    input       clk,      // 10MHz veya 27MHz olabilir
    input       n_rst,    // Reset, active low
    input       blink_en, // Blink enable
    input [23:0] rgb,     // RGB value
    output      led_r,
    output      led_g,
    output      led_b
);

localparam VALUE_OFF = ~VALUE_ON;

reg [31:0] counter;   // Blink counter
reg [7:0]  cycle;     // PWM cycle
reg        blink_cur; // Current blink state
reg [2:0]  led;       // LED output

// --- DÜZELTİLMİŞ BLOK ---
// 'blink_en' mantığı, asenkron reset'ten ayrıldı.
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        // Sadece asenkron reset
        blink_cur <= 1'b0;
    end 
    else begin
        // Saatli (clocked) mantık
        if (~blink_en) begin
            blink_cur <= 1'b0; // blink_en=0 ise sönük kal
        end
        else if (counter < BLINK_PERIOD / 2) begin
            blink_cur <= 1'b0;
        end
        else begin
            blink_cur <= 1'b1;
        end
    end
end
// --- DÜZELTME SONU ---

// Bu ikinci blokta hata yoktu, AYNI KALIYOR.
always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        counter <= 31'd0;
        cycle <= 8'd0;
        led <= {3{VALUE_OFF}};
    end
    else begin
        // Red PWM
        if (cycle < rgb[23:16])
            led[2] <= VALUE_ON ^ blink_cur; 
        else
            led[2] <= VALUE_OFF;

        // Green PWM
        if (cycle < rgb[15:8])
            led[1] <= VALUE_ON ^ blink_cur; 
        else
            led[1] <= VALUE_OFF;

        // Blue PWM
        if (cycle < rgb[7:0])
            led[0] <= VALUE_ON ^ blink_cur; 
        else
            led[0] <= VALUE_OFF;

        // Update PWM cycle
        if (cycle == 8'd254)
            cycle <= 8'd0;
        else
            cycle <= cycle + 1'd1;

        // Update blink counter
        // DİKKAT: 10MHz saat kullanıyorsanız ve RgbLed modülünün
        // kendi blink_period'unu kullanacaksanız, BLINK_PERIOD
        // parametresini 10_000_000 olarak değiştirmeniz gerekir.
        // (Ancak biz top modülde blink_en=0 yapıyoruz, bu yüzden sorun değil)
        if (counter == BLINK_PERIOD - 1)
            counter <= 31'd0;
        else
            counter <= counter + 1'd1;
    end
end

assign led_r = led[2];
assign led_g = led[1];
assign led_b = led[0];

endmodule