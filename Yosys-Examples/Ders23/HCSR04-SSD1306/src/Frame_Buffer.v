`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    Simple_RAM (Frame_Buffer)
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// 1024x8 (1KB) Çift Portlu (Simple Dual Port) Blok RAM.
// 128x64 piksel / 8 bit/sayfa = 1024 Bayt.
//
// Bu modül, OLED ekranın görüntü hafızası (Frame Buffer)
// olarak kullanılır.
//
// Port A (Okuma Portu): OLED.v modülü buradan sürekli okuma yapar.
// Port B (Yazma Portu): Top_OLED.v FSM'i buraya veriyi (sayıları) yazar.
//----------------------------------------------------------------
module Simple_RAM #(
    parameter DATA_WIDTH = 8,  // Veri Genişliği (8-bit)
    parameter ADDR_WIDTH = 10  // Adres Genişliği (10-bit = 2^10 = 1024)
)(
    input wire clk,
    
    // --- Port A (Okuma Portu - OLED.v için) ---
    input wire [ADDR_WIDTH-1:0] addr, // Okuma adresi
    output reg [DATA_WIDTH-1:0] dout, // Okunan veri
    
    // --- Port B (Yazma Portu - Top_OLED FSM'i için) ---
    input wire [ADDR_WIDTH-1:0] w_addr, // Yazma adresi
    input wire [DATA_WIDTH-1:0] din,    // Yazılacak veri
    input wire we // Yazma İzni (Write Enable)
);

    // 1024 adet 8-bit'lik RAM hafıza bloğu
    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];
    
    // --- Senkron Okuma Bloğu (Port A) ---
    // (OLED.v modülünün okuma yapacağı port)
    always @(posedge clk) begin
        dout <= ram[addr];
    end
    
    // --- Senkron Yazma Bloğu (Port B) ---
    // (Top_OLED FSM'inin yazma yapacağı port)
    always @(posedge clk) begin
        if (we) begin // Yazma izni varsa
            ram[w_addr] <= din;
        end
    end
    
    // --- Başlangıç Durumu ---
    // Sentezleme sonrası FPGA'e yüklenirken RAM içeriğini
    // 8'h00 (siyah) olarak ayarla.
    initial begin
        integer i;
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            ram[i] = 8'h00;
        end
    end
    
endmodule