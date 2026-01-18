// src/sine_gen_index.v
`timescale 1ns / 1ps

module sine_gen_index (
    input wire clk,             // Clock input (100 MHz)
    input wire reset,           // Reset signal
    output reg [7:0] master_index // Ana LUT indeksi (0-255)
);

    // 10 Hz sinüs frekansı için gereken bölücü eşiği (100_000_000 / 256 / 10 - 1 = 39061)
    parameter CLK_DIVIDER_MAX = 39061; 
    
    reg [15:0] clk_divider = 0; 
    reg [7:0] lut_index = 0;   
    
    // Saat bölücü ve indeks kontrolü
    always @(posedge clk) begin
        if (~reset) begin
            clk_divider <= 0;
            lut_index <= 0;
        end else begin
            if (clk_divider == CLK_DIVIDER_MAX) begin 
                clk_divider <= 0;
                // Ana indeksi artır: 255'ten sonra otomatik 0'a döner
                lut_index <= lut_index + 1;  
            end else begin
                clk_divider <= clk_divider + 1;
            end
        end
    end

    // Ana indeksi dışarıya bağla
    assign master_index = lut_index;

endmodule