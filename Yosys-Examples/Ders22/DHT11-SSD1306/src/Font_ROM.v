// Modül: Font_ROM
// Açıklama: font8x8.hex dosyasını yükleyen 1024x8 ROM.
//           Adres: {ASCII_Kodu[6:0], Byte_Indeksi[2:0]}
module Font_ROM #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    parameter HEX_FILE = "font8x8.hex" // Yeni font dosyamız
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] dout
);

    // RAM hafıza bloğu
    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    // Hafızayı hex dosyasından yükle
    initial begin
        $readmemh(HEX_FILE, ram);
    end

    // Senkron okuma bloğu
    always @(posedge clk) begin
        dout <= ram[addr];
    end
endmodule