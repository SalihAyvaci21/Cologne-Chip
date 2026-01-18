`timescale 1ns / 1ps

module pwm_gen(
    input wire clk,          // 100 MHz clock
    input wire reset,        // Reset input
    output reg pwm_out,      // PWM output (LED'e bağlanacak)
    output reg [7:0] sine_output // 8-bit sine wave output (Gözlem için)
);
    
    // sine_gen modülünden gelen 8-bit sinüs değeri
    wire [7:0] sine_wave; 
    
    // PWM için 8-bit sayıcı (0'dan 255'e)
    reg [7:0] counter_reg = 0; 

    // --- 1. SİNÜS ÜRETİCİSİ ÖRNEKLEMESİ (sine_gen modülünün var olduğu varsayılır) ---
    sine_gen sine_wave_gen (
        .clk(clk),
        .reset(reset),
        .sine_out(sine_wave) // sine_wave artık duty cycle'ı kontrol eder
    );
    
    // Gözlem çıkışını bağlama
    always @(*) begin
        sine_output <= sine_wave;
    end

    // --- 2. PWM SAYACI (SENKRON) ---
    // Sayacı her saat vuruşunda artır
    always @(posedge clk) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1; // 255'ten sonra otomatik 0'a döner
        end
    end
    
    // --- 3. PWM ÇIKIŞ MANTIĞI (ASENKRON) ---
    // Çıkışı, sayacın anlık değeri sinüs değeriyle karşılaştırılarak anında belirle
    always @(*) begin
        if (counter_reg < sine_wave) begin
            // Sayacımız hala sinüs değerinden küçükse, LED parlak kalır (HIGH)
            pwm_out = 1'b1; // Blocking atama kullanıldı, çünkü @(*) blok içindeyiz
        end else begin
            // Sayacımız sinüs değerine ulaşmışsa veya geçmişse, LED sönük kalır (LOW)
            pwm_out = 1'b0;
        end
    end
    
    // --- ILA Bağlantısı ---
    // ila_0'ın var olduğu varsayılıyor.
    ila_0 i1 (
        .clk(clk),       // input wire clk     
        .probe0(reset),  // input wire [0:0]  probe0   
        .probe1(pwm_out),// input wire [0:0]  probe1 
        .probe2(sine_output) // input wire [7:0]  probe2
    );
    
endmodule