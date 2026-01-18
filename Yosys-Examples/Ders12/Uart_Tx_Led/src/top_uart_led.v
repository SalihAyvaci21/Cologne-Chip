`timescale 1ns / 1ps

module top_uart_led (
    input  wire clk,        // 10 MHz sistem saati
    input  wire rst_n,      // aktif düşük reset
    input  wire button,     // push button girişi
    output wire uart_tx,    // UART TX çıkışı
    output wire [7:0] led_out // 8-bit LED çıkışı
);

    // -----------------------------
    // LED Bounce Counter Instance
    // -----------------------------
    led_bounce_up_down_counter u_ledcnt (
        .clk(clk),
        .push_button(button),
        .led_out(led_out)
    );

    // -----------------------------
    // UART Transmitter
    // -----------------------------
    reg       tx_dv   = 0;
    reg [7:0] tx_byte = 8'h00;
    wire      tx_done;
    wire      tx_active;

    transmitter #(
        .CLKS_PER_BIT(87) // 10 MHz / 115200 baud
    ) u_tx (
        .i_Clock(clk),
        .i_Tx_DV(tx_dv),
        .i_Tx_Byte(tx_byte),
        .o_Tx_Active(tx_active),
        .o_Tx_Serial(uart_tx),
        .o_Tx_Done(tx_done),
        .o_Tx_Data_dbg()
    );

    // -----------------------------
    // LED sayısını bul ve UART ile gönder
    // -----------------------------
    reg [7:0] prev_led = 8'hFF;
    reg state = 0;

    // yanan LED sayısını bul (aktif düşük olduğu için invert ediyoruz)
    function [3:0] count_leds(input [7:0] leds);
        integer i;
        reg [3:0] cnt;
        begin
            cnt = 0;
            for (i = 0; i < 8; i = i + 1) begin
                if (leds[i] == 1'b0) // aktif düşük => yanıyorsa 0
                    cnt = cnt + 1;
            end
            count_leds = cnt;
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_dv    <= 0;
            tx_byte  <= 8'h00;
            state    <= 0;
            prev_led <= 8'hFF;
        end else begin
            case (state)
                0: begin
                    tx_dv <= 0;
                    if (led_out != prev_led) begin
                        // Yanan LED sayısını ASCII'ye çevir
                        tx_byte  <= 8'h30 + count_leds(led_out); // '0' + sayı
                        tx_dv    <= 1;
                        prev_led <= led_out;
                        state    <= 1;
                    end
                end
                1: begin
                    tx_dv <= 0; // sadece 1 clock pulse
                    if (tx_done)
                        state <= 0;
                end
            endcase
        end
    end

endmodule
