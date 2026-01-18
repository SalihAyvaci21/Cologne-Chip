module top_module (
    input wire clk,       // Sistem Saati (100 MHz)
    input wire reset,     // Reset
    output wire [7:0] led_out // 8 adet LED'e bağlanacak çıkışlar
);

    wire [7:0] sine_value; // sine_gen'den gelen sinüs parlaklık değeri (0-255)
    wire led_pwm_signal;   // pwm_driver'dan gelen tekli PWM sinyali

    // 1. Sinüs Üretici Modülünü Örnekleme
    sine_gen U_SINE_GEN (
        .clk        (clk),
        .reset      (reset),
        .sine_out   (sine_value) // 8-bit sinüs değeri (0-255)
    );
    
    // 2. PWM Sürücü Modülünü Örnekleme
    pwm_driver U_PWM_DRIVER (
        .clk        (clk),
        .reset      (reset),
        .sine_val   (sine_value),    // Sinüs değerini parlaklık hedefi olarak kullan
        .led_pwm_out(led_pwm_signal) // Tekli PWM sinyali
    );
    
    // PWM sinyalini 8 LED'in tamamına bağlama
    // Bu, tüm LED'lerin aynı anda parlaklıklarının sinüs dalgasına göre değişeceği anlamına gelir.
    assign led_out = ~{8{led_pwm_signal}}; 
    
endmodule