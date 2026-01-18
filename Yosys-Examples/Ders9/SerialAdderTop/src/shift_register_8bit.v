`timescale 1ns / 1ps

module shift_register_8bit (
    input  wire clk,
    input  wire rst,
    input  wire load_i,             // paralel yükleme kontrolü
    input  wire enable_i,           // kaydırma kontrolü
    input  wire [7:0] data_i,       // paralel giriş
    output wire shift_register_out  // seri çıkış (LSB)
);
    reg [7:0] reg_data;

    assign shift_register_out = reg_data[0]; // LSB seri çıkış

    always @(posedge clk or posedge rst) begin
        if (rst)
            reg_data <= 8'b0;
        else if (load_i)
            reg_data <= data_i;
        else if (enable_i)
            reg_data <= {1'b0, reg_data[7:1]};
    end
endmodule
