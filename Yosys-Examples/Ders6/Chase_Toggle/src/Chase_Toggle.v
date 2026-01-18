`timescale 1ns / 1ps
// DEMSAY ELEKTRONİK - ARGE
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module Chase_Toggle(
    input  wire clk,           // 10 MHz sistem clock girişi
    input  wire rst,           // reset (aktif düşük) sinyali
    input  wire push_button,   // buton girişi (LED aç/kapa kontrolü)
    output reg  [7:0] led_out  // 8-bit LED çıkışı (aktif düşük LED'ler)
);

    // =======================
    // Debounce modülü bağlantısı
    // =======================
    wire debounced_button;     // butonun temizlenmiş hali (sıçramalar giderilir)
    wire out_valid;            // butona tek basıştan çıkan 1 clock genişlikli pulse

    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000), // Sistem clock frekansı = 10 MHz
        .SHIFT_LEN(3),            // debounce için kullanılan shift register uzunluğu
        .IS_PULLUP(0)             // buton pull-down bağlı olduğunu belirtiyor
    ) debounce_inst (
        .clk(clk),                // clock girişi
        .push_button(push_button),// ham buton girişi
        .out_valid(out_valid),    // geçerli buton pulse çıkışı
        .debounced_button(debounced_button) // kararlı buton çıkışı
    );

    reg [26:0] counter;        // uzun sayaç (0.5 saniye vb. zaman üretmek için kullanılabilir)
    reg toggle;                // LED desenini değiştirmek için kullanılan bit
    reg toggle_mode;           // 0=normal mod, 1=toggle mod (buton ile değişir)

    // ======================
    // Sayaç
    // ======================
    always @(posedge clk or negedge rst) begin
        if (!rst)               // reset aktifken sayaç sıfırlanır
            counter <= 0;
        else
            counter <= counter + 1'b1; // her clockta sayaç artar
    end

    // =======================
    // Toggle Mode (buton ile)
    // =======================
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            toggle_mode <= 0;          // reset → normal mod
        end else if (out_valid) begin
            toggle_mode <= ~toggle_mode; // butona basıldığında mod değiştir
        end
    end


    // =======================
    // LED çıkış kontrolü (tek block!)
    // =======================
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            led_out <= 8'b1111_1111; // reset → tüm LED'ler kapalı
        end else if (toggle_mode) begin
            // Toggle mod aktif olduğunda: LED’ler toggle’a göre değişir
case (toggle)
    1'b0: begin 
        if (toggle == 1'b0) begin
            led_out <= 8'b0000_0000; // tüm LED’ler yanar
        end 
        if (out_valid == 1'b1) begin
            toggle  <= 1'b1;        // butona tekrar basılırsa toggle 1 yapılır
        end
    end
    1'b1: begin 
        if (toggle == 1'b1) begin
            led_out <= 8'b1111_1111; // tüm LED’ler kapanır
        end 
        if (out_valid == 1'b1) begin
            toggle  <= 1'b0;        // butona tekrar basılırsa toggle 0 yapılır
        end
    end
endcase

        end else begin
            // Normal modda: LED0 ↔ LED7 arasında yanıp sönüyor
            if (counter[26] == 1'b1)
                led_out <= 8'b1111_0000; // LED0..3 kapalı, LED4..7 açık
            else
                led_out <= 8'b0000_1111; // LED0..3 açık, LED4..7 kapalı
        end
    end

endmodule
