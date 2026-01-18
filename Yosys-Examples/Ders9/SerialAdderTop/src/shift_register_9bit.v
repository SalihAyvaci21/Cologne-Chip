`timescale 1ns / 1ps

module shift_register_9bit (
    input  wire clk,
    input  wire rst,
    input  wire enable_i,       // shift kontrol
    input  wire bit_in,         // seri toplam biti
    input  wire carry_in,       // en son carry biti
    output reg  [8:0] shift_data // paralel çıkış (9 bit result)
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            shift_data <= 9'b0;
        else if (enable_i)
            shift_data <= {carry_in, bit_in, shift_data[7:1]}; 
            // MSB = carry_in, LSB = bit_in, diğer bitler kaydırılıyor
    end

endmodule
