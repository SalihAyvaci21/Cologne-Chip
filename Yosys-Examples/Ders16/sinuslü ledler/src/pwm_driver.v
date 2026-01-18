module pwm_driver (
    input wire clk,           // Sistem Saati
    input wire reset,         // Reset
    input wire [7:0] sine_val, // Sinüs üreticiden gelen 8-bit parlaklık değeri (0-255)
    output reg led_pwm_out    // LED PWM Çıkışı (8 LED'in tamamı için aynı sinyal)
);
    
    // 8-bit sayaç (0'dan 255'e sayar)
    reg [7:0] pwm_counter = 0;

    // PWM Sayacı
    // 8-bit bir sayaç olduğu için 256 saat döngüsünde bir döngü tamamlar.
    // Bu, LED'in titrememesi için yeterince hızlı olmalıdır.
    always @(posedge clk) begin
        if (~reset) begin
            pwm_counter <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1; // Her saat vuruşunda sayacı artır
        end
    end

    // PWM Üretimi (Parlaklık Kontrolü)
    // Eğer sayaç değeri, sinüs değerinden küçükse sinyali YÜKSEK yap.
    always @(*) begin
        if (pwm_counter < sine_val) begin
            // Parlaklık YÜKSEK: LED yanıyor
            led_pwm_out = 1'b1;
        end else begin
            // Parlaklık DÜŞÜK: LED sönük
            led_pwm_out = 1'b0;
        end
    end

endmodule