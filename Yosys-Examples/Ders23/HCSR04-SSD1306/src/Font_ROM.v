`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    Font_ROM
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// 1024x8 (1KB) Tek Portlu ROM.
// Sentezleme sırasında "font8x8.hex" dosyasını hafızaya yükler.
//
// Top_OLED FSM'i, BCD hanelerini ASCII'ye çevirip,
// bu ROM'dan 8x8 piksel karşılığını okur.
//
// Adresleme: {ASCII_Kodu[6:0], Byte_Indeksi[2:0]}
// Örnek: 'A' (7'h41) karakterinin 3. satırı (3'h02) için adres:
//        {7'h41, 3'h02} = 10'h20A
//----------------------------------------------------------------
module Font_ROM #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    parameter HEX_FILE = "font8x8.hex" // Yüklenecek hafıza dosyası
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr, // Okuma adresi
    output reg [DATA_WIDTH-1:0] dout  // Okunan 8-bit (1 satır) piksel verisi
);
    // 1024 adet 8-bit'lik ROM hafıza bloğu
    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];
    
    // --- Başlangıç Durumu ---
    // Sentezleme sırasında .hex dosyasını RAM'e yükle
    initial begin
        $readmemh(HEX_FILE, ram);
    end

    // --- Senkron Okuma Bloğu ---
    always @(posedge clk) begin
        dout <= ram[addr];
    end
endmodule