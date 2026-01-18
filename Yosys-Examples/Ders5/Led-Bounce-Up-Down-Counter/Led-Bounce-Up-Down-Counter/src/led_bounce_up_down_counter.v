`timescale 1ns / 1ps

module led_bounce_up_down_counter(
    input  wire clk,               // Sistem saat sinyali
    input  wire push_button,       // Buton girişi
    output reg  [7:0] led_out      // 8-bit LED çıkışı (aktif düşük)
);

    wire debounced_button;
    wire out_valid;

    localparam [7:0] LED_DEFAULT_STATE = 8'b1111_1111; // hepsi sönük (aktif düşük)

    // Debouncer modülü
    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000),
        .SHIFT_LEN(3),
        .IS_PULLUP(0)
    ) debounce_inst (
        .clk(clk),
        .rst_n(1'b1), // reset sinyali sabit 1 (aktif düşük reset kullanılmadığı için)
        .push_button(push_button),  
        .out_valid(out_valid),
        .debounced_button(debounced_button)
    );

    reg [3:0] led_index = 0; 
    reg [3:0] led_off   = 0; 
    reg init_done = 0;
    reg prev_button = 0;   // Önceki buton değeri

    always @(posedge clk) begin
        if (!init_done) begin
            led_out     <= LED_DEFAULT_STATE;
            led_index   <= 0;
            led_off     <= 0;
            prev_button <= 0;
            init_done   <= 1;
        end 
        else if (out_valid) begin
            if (prev_button && !debounced_button) begin
                case (1'b1)
                    // LED'leri sırayla yak
                    (led_index < 8 && led_off == 0): begin
                        led_out[led_index] <= 1'b0;
                        led_index <= led_index + 1;
                    end

                    // LED'leri sırayla söndür
                    (led_index == 8 && led_off < 8): begin
                        led_out[7 - led_off] <= 1'b1;
                        led_off <= led_off + 1;
                    end

                    // Döngü başa dönsün ve hemen devam etsin
                    (led_off == 8): begin
                        led_index <= 1;                    // direkt 1’e ayarla
                        led_off   <= 0;
                        led_out   <= LED_DEFAULT_STATE;    // hepsini kapat
                        led_out[0] <= 1'b0;                // ilk LED hemen yansın
                    end
                endcase
            end
        end

        // Önceki buton değerini güncelle
        prev_button <= debounced_button;
    end

endmodule