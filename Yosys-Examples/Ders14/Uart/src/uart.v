`timescale 1ns / 1ps

module uart (
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
    // RX -> TX Kontrol FSM
    // -----------------------------
    reg state = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_dv   <= 0;
            tx_byte <= 8'h00;
            state   <= 0;
        end else begin
            case (state)
                0: begin
                    tx_dv <= 0;
                    if (rx_dv) begin
                            tx_byte <= rx_byte;        
                            tx_dv   <= 1;
                            state   <= 1;
                    end
                end
                1: begin
                    tx_dv <= 0;
                    if (tx_done)
                        state <= 0;
                end
            endcase
        end
    end

endmodule
