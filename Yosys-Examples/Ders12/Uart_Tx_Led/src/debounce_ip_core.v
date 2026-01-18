`timescale 1ns / 1ps
// DEMSAY ELEKTRONİK - ARGE 
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER 
// 12.06.2025

module debounce_ip_core #(
    parameter CLK_FREQ_HZ = 10_000_000, // Sistem saat frekansı (Hz)
    parameter SHIFT_LEN   = 3,          // shift register uzunluğu
    parameter IS_PULLUP   = 0           // 1 = pull-up, 0 = pull-down
)(
    input  wire clk,
    input  wire rst_n,          // aktif düşük reset
    input  wire push_button,
    output reg  out_valid,      // değişim anında 1 clock için 1
    output reg  debounced_button // kararlı buton durumu
);

    // Shift register
    reg [SHIFT_LEN-1:0] shift_reg;
    
    // XOR sonucu (kararlı mı değil mi?)
    wire xor_out;
    assign xor_out = ^(shift_reg ^ {SHIFT_LEN{shift_reg[0]}});

    // Sayaç (yaklaşık 0.5ms debounce için)
    localparam integer MAX_COUNT = CLK_FREQ_HZ / 2000;
    reg [17:0] counter;

    // Senkronizasyon FF zinciri
    reg sync_0, sync_1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // IS_PULLUP değeriyle başlatma
            shift_reg        <= {SHIFT_LEN{IS_PULLUP[0]}};
            debounced_button <= IS_PULLUP[0];
            counter          <= 0;
            sync_0           <= IS_PULLUP[0];
            sync_1           <= IS_PULLUP[0];
            out_valid        <= 0;
        end 
        else begin
            // senkronize et
            sync_0 <= push_button;
            sync_1 <= sync_0;

            // shift register kaydır
            shift_reg <= {shift_reg[SHIFT_LEN-2:0], sync_1};

            // XOR sonucu sabitse sayaç çalışır
            if (xor_out == 1'b0) begin
                if (counter < MAX_COUNT) begin
                    counter   <= counter + 1;
                    out_valid <= 0;
                end 
                else if (debounced_button != shift_reg[0]) begin
                    debounced_button <= shift_reg[0]; // yeni stabil değer
                    out_valid        <= 1; // sadece değişim anında 1 clock
                end 
                else begin
                    out_valid <= 0;
                end
            end 
            else begin
                counter   <= 0;
                out_valid <= 0;
            end
        end
    end

endmodule