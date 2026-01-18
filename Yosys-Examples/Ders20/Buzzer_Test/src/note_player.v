//******************************************************************
// DOSYA: note_player.v
// Dinamik frekans üreteci
//******************************************************************
`timescale 1ns / 1ps

/**
 * @module note_player
 * @brief  Girişten aldığı 'half_period_in' değerine göre
 * dinamik olarak frekans üreten modül.
 */
module note_player (
    input  wire clk,
    input  wire rst_n,
    
    // 'parameter' yerine 'input' kullanıyoruz.
    // Bu değer (CLOCK_FREQ / Nota_Frekansı) / 2 olmalıdır.
    // 0 gelirse, modül susar.
    input  wire [15:0] half_period_in, 
    
    output reg  buzzer_out
);

    // Sayaç, girişimizle aynı genişlikte
    localparam COUNTER_WIDTH = 16;
    reg [COUNTER_WIDTH-1:0] counter_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= 0;
            buzzer_out  <= 1'b0;
        end 
        else if (half_period_in == 0) begin 
            // Giriş 0 ise (HP_SILENT), sus.
            counter_reg <= 0;
            buzzer_out  <= 1'b0;
        end 
        else begin
            // Gelen 'half_period_in' değerine kadar say ve çıkışı tersle
            // (Değer değişse bile > testi sayesinde stabil çalışır)
            if (counter_reg >= half_period_in - 1) begin
                counter_reg <= 0;
                buzzer_out  <= ~buzzer_out;
            end else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end
endmodule
