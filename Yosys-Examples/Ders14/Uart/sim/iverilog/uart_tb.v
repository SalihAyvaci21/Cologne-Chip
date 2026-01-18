`timescale 1ns / 1ps

module uart_tb;

    reg clk;
    reg rst_n;
    reg rx_serial;
    wire uart_tx;

    // DUT
    uart dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .uart_tx(uart_tx)
    );

    // Clock generation (10 MHz → 100 ns period)
    always #50 clk = ~clk;

    // UART TX Task to simulate sending data
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
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        clk = 0;
        rst_n = 0;
        rx_serial = 1; // idle line
        #500;

        rst_n = 1;
        #1000;

        // "A" karakterini gönder
        $display(">>> UART RX: 'A'");
        uart_tx_byte(8'h41); // ASCII 'A'
        #20000;
        $display("Check waveform: uart_tx should echo 'A'");

        // "1" karakterini gönder
        $display(">>> UART RX: '1'");
        uart_tx_byte(8'h31); // ASCII '1'
        #20000;
        $display("Check waveform: uart_tx should echo '1'");

        $finish;
    end

endmodule
