`timescale 1ns / 1ps

module uart-hesap-makinesi (
    input  wire clk,        // 10 MHz sistem clock
    input  wire rst_n,      // aktif düşük reset
    input  wire rx_serial,  // UART RX
    output wire uart_tx     // UART TX
);

    // -----------------------------
    // UART Receiver
    // -----------------------------
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

    // -----------------------------
    // UART Transmitter
    // -----------------------------
    reg       tx_dv   = 0;
    reg [7:0] tx_byte = 8'h00;
    wire      tx_done;

    transmitter #(
        .CLKS_PER_BIT(87) // 10 MHz / 115200 baud
    ) u_tx (
        .i_Clock(clk),
        .i_Tx_DV(tx_dv),
        .i_Tx_Byte(tx_byte),
        .o_Tx_Active(),
        .o_Tx_Serial(uart_tx),
        .o_Tx_Done(tx_done),
        .o_Tx_Data_dbg()
    );

    // -----------------------------
    // A + B toplama FSM
    // -----------------------------
    reg [3:0] a_val = 0;
    reg [3:0] b_val = 0;
    reg [4:0] sum   = 0;   // 0–18 arası olabilir
    reg [1:0] state = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_dv   <= 0;
            tx_byte <= 8'h00;
            a_val   <= 0;
            b_val   <= 0;
            sum     <= 0;
            state   <= 0;
        end else begin
            case (state)
                0: begin
                    tx_dv <= 0;
                    if (rx_dv) begin
                        a_val <= rx_byte - 8'h30; // ASCII → decimal
                        state <= 1;
                    end
                end
                1: begin
                    if (rx_dv) begin
                        b_val <= rx_byte - 8'h30;
                        sum   <= a_val + (rx_byte - 8'h30);
                        state <= 2;
                    end
                end
                2: begin
                    // Tek haneli sonuç için direkt gönder
                    if (sum < 10) begin
                        tx_byte <= sum + 8'h30; // ASCII'ye çevir
                        tx_dv   <= 1;
                        state   <= 3;
                    end else begin
                        // Eğer 2 basamaklıysa önce onlar basamağı
                        tx_byte <= (sum/10) + 8'h30;
                        tx_dv   <= 1;
                        state   <= 4;
                    end
                end
                3: begin
                    tx_dv <= 0;
                    if (tx_done) state <= 0; // tekrar başa dön
                end
                4: begin
                    tx_dv <= 0;
                    if (tx_done) begin
                        tx_byte <= (sum%10) + 8'h30; // birler basamağı
                        tx_dv   <= 1;
                        state   <= 5;
                    end
                end
                5: begin
                    tx_dv <= 0;
                    if (tx_done) state <= 0; // tamamlandı
                end
            endcase
        end
    end

endmodule
