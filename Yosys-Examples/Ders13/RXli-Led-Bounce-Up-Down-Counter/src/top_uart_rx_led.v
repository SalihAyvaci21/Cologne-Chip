`timescale 1ns / 1ps

module top_uart_rx_led (
    input  wire clk,         // 10 MHz sistem clock
    input  wire rst_n,       // aktif düşük reset
    input  wire rx_serial,   // UART RX (PC'den gelen veri)
    output reg  [7:0] led_out // 8-bit LED çıkışı (aktif düşük)
);

    // UART Receiver
    wire       rx_dv;
    wire [7:0] rx_byte;

    receiver #(
        .CLKS_PER_BIT(87) // 10 MHz / 115200 baud
    ) u_rx (
        .i_Clock(clk),
        .i_Rx_Serial(rx_serial),
        .o_Rx_DV(rx_dv),
        .o_Rx_Byte(rx_byte)
    );

    // LED kontrol
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_out <= 8'b0100_0000;  // başlangıçta hepsi yanık (aktif düşük LED → 0 = yanık)
        end else begin
            if (rx_dv) begin
                case (rx_byte)
                    8'h31: led_out <= 8'b1111_1111; // ASCII '1' geldi → hepsi sönük, D4 dahil
                    default: led_out <= 8'b0000_0000; // diğer durumlarda hepsi yanık
                endcase
            end
        end
    end

endmodule
