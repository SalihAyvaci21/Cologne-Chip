`timescale 1ns / 1ps

module shift_register_8bit_tb;

    // Testbench sinyalleri
    reg clk = 0;
    reg rst = 0;
    reg load_i = 0;
    reg enable_i = 0;
    reg [7:0] data_i = 8'b1010_0101;  // Örnek veri
    wire shift_register_out;

    // Clock üretimi (10 MHz = 100 ns periyot)
    always #50 clk = ~clk;

	initial begin
   	 $dumpfile("shift_register_8bit_tb.vcd"); // Specify dump file name
   	 $dumpvars(0, shift_register_8bit_tb); // Dump all signals in the testbench
	end

    // DUT instantiation
    shift_register_8bit uut (
        .clk(clk),
        .rst(rst),
        .load_i(load_i),
        .enable_i(enable_i),
        .data_i(data_i),
        .shift_register_out(shift_register_out)
    );

    // Test senaryosu
    initial begin
        // Reset uygula
        rst = 1;
        #50;
        rst = 0;

        // Load işlemi (reg_data sıfır olduğu için yükleyecek)
        load_i = 1;
        #100;
        load_i = 0;

        // Kaydırma başlat
        enable_i = 1;

        // Birkaç clock kaydır
        #800;

        // Kaydırmayı durdur
        enable_i = 0;

        // Yeni veri yükleme
        data_i = 8'b1010_0101;
        load_i = 1;
        #50;
        load_i = 0;

        // Kaydırmaya devam
        enable_i = 1;
        #800;

        // Simülasyonu bitir
        $finish;
    end

endmodule
