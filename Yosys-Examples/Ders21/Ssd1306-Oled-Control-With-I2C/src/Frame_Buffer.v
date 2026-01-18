// Modül: Frame_Buffer
// Açıklama: 1024x8 (1KB) Okuma/Yazma RAM.
//           OLED.v [cite: 72] buradan sürekli okuma yapar.
//           Top_OLED modülü  buraya dinamik olarak yazar.
module Simple_RAM #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10
    // HEX_FILE parametresi kaldırıldı, artık dinamik
)(
    input wire clk,
    
    // Port A (Okuma Portu - OLED.v [cite: 168] için)
    input wire [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] dout,
    
    // Port B (Yazma Portu - Top_OLED FSM'i için)
    input wire [ADDR_WIDTH-1:0] w_addr,
    input wire [DATA_WIDTH-1:0] din,
    input wire we // Write Enable (Yazma İzni)
);

    // 1024 adet 8-bit'lik RAM hafıza bloğu
    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    // Senkron Okuma Bloğu (Port A)
    // (OLED.v modülünün [cite: 168] okuma yapacağı port)
    always @(posedge clk) begin
        dout <= ram[addr];
    end
    
    // Senkron Yazma Bloğu (Port B)
    // (Bizim "35" yazdıracağımız port)
    always @(posedge clk) begin
        if (we) begin
            ram[w_addr] <= din;
        end
    end
    
    // Başlangıçta tüm hafızayı temizle (siyah ekran)
    initial begin
        integer i;
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            ram[i] = 8'h00;
        end
    end
    
endmodule