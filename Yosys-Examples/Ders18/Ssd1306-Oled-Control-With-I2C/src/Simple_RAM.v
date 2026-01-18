module Simple_RAM #(
    parameter DATA_WIDTH = 8,                 // RAM veri genişliği
    parameter ADDR_WIDTH = 10,                // RAM adres genişliği
    parameter HEX_FILE = "image_data.hex"     // Yüklenecek hafıza dosyası
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] dout
);
    // RAM hafıza bloğu
    // Boyut = 2^ADDR_WIDTH (Örn: 10 bit -> 1024 adet)
    // Derinlik = DATA_WIDTH (Örn: 8 bit)
    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    // Başlangıçta (simülasyon/başlatma anında) hafızayı hex dosyasından yükle
    initial begin
        $readmemh(HEX_FILE, ram);
    end

    // Senkron okuma bloğu
    // 'addr' girişine göre hafızadan veriyi okur ve 'dout' çıkışına atar.
    always @(posedge clk) begin
        dout <= ram[addr];
    end
endmodule