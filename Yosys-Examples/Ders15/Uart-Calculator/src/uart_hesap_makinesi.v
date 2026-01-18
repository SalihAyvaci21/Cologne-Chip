`timescale 1ns / 1ps

module uart_hesap_makinesi (
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
    // Değişkenler
    // -----------------------------
    reg [15:0] a_val = 0;
    reg [15:0] b_val = 0;
    reg [15:0] sum   = 0;
    reg [3:0]  state = 0;

    // -----------------------------
    // FSM
    // -----------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_dv   <= 0;
            tx_byte <= 0;
            a_val   <= 0;
            b_val   <= 0;
            sum     <= 0;
            state   <= 0;
        end else begin
            case (state)
                //-----------------------------------------
                // İlk sayıyı oku (a)
                //-----------------------------------------
                0: begin
                    tx_dv <= 0;
                    if (rx_dv) begin
                        if (rx_byte >= "0" && rx_byte <= "9") begin
                            a_val <= (a_val * 10) + (rx_byte - "0");
                        end else if (rx_byte == "+") begin
                            state <= 1; // ikinci sayıya geç
                        end
                    end
                end
                //-----------------------------------------
                // İkinci sayıyı oku (b)
                //-----------------------------------------
                1: begin
                    if (rx_dv) begin
                        if (rx_byte >= "0" && rx_byte <= "9") begin
                            b_val <= (b_val * 10) + (rx_byte - "0");
                        end else if (rx_byte == "=") begin
                            sum   <= a_val + b_val;
                            state <= 2; // sonucu gönder
                        end
                    end
                end
//-----------------------------------------
// Sonucu gönder
//-----------------------------------------
2: begin
    if (sum < 10) begin
        tx_byte <= sum + "0"; // tek hane
        tx_dv   <= 1;
        state   <= 3;
    end else if (sum < 100) begin
        tx_byte <= (sum/10) + "0"; // onlar
        tx_dv   <= 1;
        state   <= 4;
    end else begin
        tx_byte <= (sum/100) + "0"; // yüzler
        tx_dv   <= 1;
        state   <= 6;
    end
end

//-----------------------------------------
// Tek hane
//-----------------------------------------
3: begin
    tx_dv <= 0;
    if (tx_done) begin
        a_val <= 0;
        b_val <= 0;
        state <= 0;
    end
end

//-----------------------------------------
// 2 basamaklı sayı
//-----------------------------------------
4: begin
    tx_dv <= 0;
    if (tx_done) begin
        tx_byte <= (sum%10) + "0"; // birler
        tx_dv   <= 1;
        state   <= 5;
    end
end
5: begin
    tx_dv <= 0;
    if (tx_done) begin
        a_val <= 0;
        b_val <= 0;
        state <= 0;
    end
end

//-----------------------------------------
// 3 basamaklı sayı
//-----------------------------------------
6: begin
    tx_dv <= 0;
    if (tx_done) begin
        tx_byte <= ((sum/10)%10) + "0"; // onlar
        tx_dv   <= 1;
        state   <= 7;
    end
end
7: begin
    tx_dv <= 0;
    if (tx_done) begin
        tx_byte <= (sum%10) + "0"; // birler
        tx_dv   <= 1;
        state   <= 8;
    end
end
8: begin
    tx_dv <= 0;
    if (tx_done) begin
        a_val <= 0;
        b_val <= 0;
        state <= 0;
    end
end
        endcase
    end   
    end

endmodule
