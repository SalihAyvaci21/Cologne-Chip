`timescale 1ns/1ps

module uart_hesap_makinesi_tb;

    reg clk;
    reg rst_n;
    reg rx_serial;
    wire tx_serial;

    // Saat üret
    initial begin
        clk = 0;
        forever #50 clk = ~clk;  // 10 MHz clock (100ns per cycle)
    end
initial begin
    $dumpfile("uart_hesap_makinesi_tb.vcd"); // Specify dump file name
    $dumpvars(0, uart_hesap_makinesi_tb); // Dump all signals in the testbench
end
    // DUT (Device Under Test)
    uart_hesap_makinesi dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .uart_tx(tx_serial)
    );

    // Reset
    initial begin
        rst_n = 0;
        rx_serial = 1;   // idle state (UART line high)
        #200;
        rst_n = 1;
    end

    // -------------------------------
    // UART Send Task (8N1, 115200 baud)
    // -------------------------------
    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx_serial = 0;
            #(8680); // 1/115200 sec ≈ 8680ns

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i+1) begin
                rx_serial = data[i];
                #(8680);
            end

            // Stop bit
            rx_serial = 1;
            #(8680);
        end
    endtask

    // Test sequence
    initial begin
        @(posedge rst_n);
        #100000;

        // Gönder: "46+12="
        uart_send_byte("4");
        uart_send_byte("6");
        uart_send_byte("a");
        uart_send_byte("1");
        uart_send_byte("2");
        #200000;
        uart_send_byte("b");

        #200000;
#200000;
#200000;
#200000;

        // Simülasyonu bitir
        $stop;
    end

endmodule
