`timescale 1ns / 1ps

module top_uart_rx_led_tb;

    reg clk;
    reg rst_n;
    reg rx_serial;
    wire [7:0] led_out;

    // DUT
    top_uart_rx_led dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .led_out(led_out)
    );

    // Clock generation (10 MHz → 100 ns period)
    always #50 clk = ~clk;

    // UART TX Task (simülasyonda RX’i beslemek için)
    task uart_tx_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            rx_serial <= 1'b0;
            #(87*100);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial <= data[i];
                #(87*100);
            end

            // Stop bit
            rx_serial <= 1'b1;
            #(87*100);
        end
    endtask

    initial begin
        $dumpfile("top_uart_rx_led_tb.vcd");
        $dumpvars(0, top_uart_rx_led_tb);

        clk = 0;
        rst_n = 0;
        rx_serial = 1; // idle line
        #500;

        rst_n = 1;
        #1000;

        // 1 gönder → LED’ler sönmeli
        $display(">>> UART TX: '1'");
        uart_tx_byte(8'h31);
        #5000;
        $display("LED Out = %b", led_out);

        // A gönder → LED’ler yanmalı
        $display(">>> UART TX: 'A'");
        uart_tx_byte(8'h41);
        #5000;
        $display("LED Out = %b", led_out);

        // 0 gönder → LED’ler yanmalı
        $display(">>> UART TX: '0'");
        uart_tx_byte(8'h30);
        #5000;
        $display("LED Out = %b", led_out);

        $finish;
    end

endmodule
