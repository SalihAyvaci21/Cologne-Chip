`timescale 1ns / 1ps

module SerialAdderTop_tb;

    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg [7:0] data_a;
    reg [7:0] data_b;
    wire [8:0] result;
    wire done;

    // Top modül
    SerialAdderTop dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_a(data_a),
        .data_b(data_b),
        .result(result),
        .done(done)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("SerialAdderTop_tb.vcd");
        $dumpvars(0, SerialAdderTop_tb);

        rst = 1; start = 0; data_a = 8'd0; data_b = 8'd0;
        #20;
        rst = 0;

        // Test 1
        data_a = 8'd128;
        data_b = 8'd128;
        start = 1;
        #10 start = 0;

        // 200 clk bekle
        #1000;
        
          wait(done == 1);
         $display("Result (decimal): %d", result);

        $finish;
    end

endmodule
