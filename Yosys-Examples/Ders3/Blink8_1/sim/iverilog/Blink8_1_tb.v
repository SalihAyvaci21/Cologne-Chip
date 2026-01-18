`timescale 1ns / 1ps

module Blink8_1_tb;

    // Testbench sinyalleri
    reg clk;
    reg rst;
    reg push_button;
    wire [7:0] led;

    // DUT (Device Under Test)
    Blink8_1 dut (
        .clk(clk),
        .rst(rst),
        .push_button(push_button),
        .led(led)
    );

   // Dumpfile and dumpvars for waveform generation
initial begin
    $dumpfile("Blink8_1_tb.vcd"); // Specify dump file name
    $dumpvars(0, Blink8_1_tb); // Dump all signals in the testbench
end

    // ======================
    // Clock üretimi (10 MHz)
    // ======================
    initial clk = 0;
    always #50 clk = ~clk;  
    // 100 ns periyot = 10 MHz

    // ======================
    // Stimulus
    // ======================
    initial begin
        // Başlangıç
        rst = 0;           // Reset aktif
        push_button = 0;   // Buton serbest
        #200;              // bir süre reset aktif

        rst = 1;           // Reset bırakıldı

        // Biraz daha bekle
        #1_000_000_000;

        $stop;
    end

endmodule
