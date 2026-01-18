`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    Top_OLED (Dinamik Sürüm - v7 - Son Sürüm)
// Açıklama:
// v7: LED'ler ve Buton kaldırıldı.
//     FSM, reset sonrası (güç açıldığında) otomatik başlar,
//     ekranı temizler ve metni (180 derece dönmüş) yazar.
//----------------------------------------------------------------

module Top_OLED (
    // --- Giriş/Çıkış Portları (CCF Dosyasına Göre) ---
    input wire clk,       // 10MHz Sistem Saati
    input wire reset_n,   // Aktif-düşük Reset
    
    // OLED Arayüzü
    output wire SCL,       // I2C Saat
    output wire SDA,       // I2C Veri
    output wire FPS        // Frame Pulse
);
    
    // --- Frame Buffer (R/W RAM) Arayüz Sinyalleri ---
    wire [9:0] oled_read_addr;
    wire [7:0] oled_read_data;
    
    reg [9:0]  fsm_write_addr;
    reg [7:0]  fsm_write_data;
    reg        fsm_write_enable;
    
    // --- Font ROM Arayüz Sinyalleri ---
    reg [9:0]  font_read_addr;
    wire [7:0] font_read_data;

    //-------------------------------------------------
    // MODÜL İNSTANTIASYONLARI
    //-------------------------------------------------

    // --- (Debouncer modülü kaldırıldı) ---

    // --- 1. Frame Buffer (Okuma/Yazma RAM) ---
    Simple_RAM #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(10)
    ) frame_buffer (
        .clk(clk),
        .addr(oled_read_addr),
        .dout(oled_read_data),
        .w_addr(fsm_write_addr),
        .din(fsm_write_data),
        .we(fsm_write_enable)
    );

    // --- 2. Font ROM ---
    Font_ROM #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(10)
    ) font_rom (
        .clk(clk),
        .addr(font_read_addr),
        .dout(font_read_data)
    );

    // --- OLED Kontrolcüsü ---
    OLED oled_controller (
        .clk(clk),
        .ram_dout(oled_read_data),
        .addr(oled_read_addr),
        .SCL(SCL),
        .SDA(SDA),
        .FPS(FPS)
    );

    //-------------------------------------------------
    // DİZİ (STRING) YAZMAK İÇİN OTOMATİK BAŞLAYAN FSM
    //-------------------------------------------------
    
    // Durumlar (State)
    localparam S_IDLE = 0;
    localparam S_CLEAR_FB_LOOP = 1;
    localparam S_SET_CHAR_PARAMS = 2; // Yazılacak karakteri ve konumu ayarla
    localparam S_FETCH_CHAR_READ = 3;
    localparam S_FETCH_CHAR_WAIT = 4;
    localparam S_FETCH_CHAR_STORE = 5;
    localparam S_TRANSPOSE_WRITE = 6;
    localparam S_NEXT_CHAR = 7;       // Sonraki karaktere geç
    localparam S_DONE = 8;

    reg [3:0] state = S_IDLE;
    reg [2:0] byte_index = 0;      // 0-7 arası satır/sütun sayacı
    reg [9:0] clear_counter = 0;
    
    // Font karakterinin 8 yatay satırını tutmak için 8 register
    reg [7:0] reg_row0, reg_row1, reg_row2, reg_row3, reg_row4, reg_row5, reg_row6, reg_row7;
    
    // Yazılacak karakteri ve konumu tutan registerlar
    reg [6:0] current_ascii;
    reg [9:0] current_col_base; // Karakterin ekrandaki tam adresi (Sayfa * 128 + Sütun)
    
    // Yazılacak karakter dizisi için sayaç
    reg [4:0] char_index = 0; // 0'dan 18'e kadar (toplam 19 karakter)

    // ASCII Kodları
    localparam ASCII_n = 7'h6E; // n
    localparam ASCII_e = 7'h65; // e
    localparam ASCII_m = 7'h6D; // m
    localparam ASCII_COLON = 7'h3A; // :
    localparam ASCII_SPACE = 7'h20; // (boşluk)
    localparam ASCII_2 = 7'h32; // 2
    localparam ASCII_5 = 7'h35; // 5
    
    localparam ASCII_s = 7'h73; // s
    localparam ASCII_i = 7'h69; // i (ı yerine)
    localparam ASCII_c = 7'h63; // c
    localparam ASCII_a = 7'h61; // a
    localparam ASCII_k = 7'h6B; // k
    localparam ASCII_l = 7'h6C; // l
    localparam ASCII_3 = 7'h33; // 3
    localparam ASCII_6 = 7'h36; // 6
    
    // Ekran Konumları (Sayfa ve Sütun)
    localparam PAGE_TOP = 2;   // "nem: 25" için 2. sayfa
    localparam PAGE_BOT = 4;  // "sicaklik: 36" için 4. sayfa
    localparam START_COL = 10; // Başlangıç Sütunu
    localparam CHAR_WIDTH = 8; // Karakter genişliği (8 piksel/sütun)

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // --- DEĞİŞİKLİK BURADA ---
            // Reset durumunda S_IDLE yerine doğrudan S_CLEAR_FB_LOOP'a git.
            // Bu, FSM'nin otomatik başlamasını sağlar.
            state <= S_CLEAR_FB_LOOP;
            // ------------------------
            
            fsm_write_enable <= 0;
            byte_index <= 0;
            clear_counter <= 0;
            char_index <= 0;
        end else begin
            
            fsm_write_enable <= 0; // Varsayılan olarak yazmayı kapat
            
            case (state)
                S_IDLE: begin
                    // --- DEĞİŞİKLİK BURADA ---
                    // İşlem bitti (S_DONE'dan buraya gelindi).
                    // Bir sonraki resete kadar bekle.
                end
                
                S_CLEAR_FB_LOOP: begin
                    fsm_write_enable <= 1;
                    fsm_write_addr <= clear_counter;
                    fsm_write_data <= 8'h00;
                    
                    if (clear_counter == 1023) begin
                        clear_counter <= 0;
                        state <= S_SET_CHAR_PARAMS; // Temizlendi, yazmaya başla
                    end else begin
                        clear_counter <= clear_counter + 1;
                    end
                end
                
                // YENİ DURUM: char_index'e göre sıradaki karakteri ve konumunu ayarla
                S_SET_CHAR_PARAMS: begin
                    byte_index <= 0; // Satır/sütun sayacını sıfırla
                    
                    case (char_index)
                        // Satır 1: "nem: 25"
                        5'd0:  begin current_ascii <= ASCII_n; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 0); state <= S_FETCH_CHAR_READ; end
                        5'd1:  begin current_ascii <= ASCII_e; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 1); state <= S_FETCH_CHAR_READ; end
                        5'd2:  begin current_ascii <= ASCII_m; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 2); state <= S_FETCH_CHAR_READ; end
                        5'd3:  begin current_ascii <= ASCII_COLON; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 3); state <= S_FETCH_CHAR_READ; end
                        5'd4:  begin current_ascii <= ASCII_SPACE; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 4); state <= S_FETCH_CHAR_READ; end
                        5'd5:  begin current_ascii <= ASCII_2; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 5); state <= S_FETCH_CHAR_READ; end
                        5'd6:  begin current_ascii <= ASCII_5; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 6); state <= S_FETCH_CHAR_READ; end
                        
                        // Satır 2: "sicaklik: 36"
                        5'd7:  begin current_ascii <= ASCII_s; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 0); state <= S_FETCH_CHAR_READ; end
                        5'd8:  begin current_ascii <= ASCII_i; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 1); state <= S_FETCH_CHAR_READ; end
                        5'd9:  begin current_ascii <= ASCII_c; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 2); state <= S_FETCH_CHAR_READ; end
                        5'd10: begin current_ascii <= ASCII_a; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 3); state <= S_FETCH_CHAR_READ; end
                        5'd11: begin current_ascii <= ASCII_k; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 4); state <= S_FETCH_CHAR_READ; end
                        5'd12: begin current_ascii <= ASCII_l; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 5); state <= S_FETCH_CHAR_READ; end
                        5'd13: begin current_ascii <= ASCII_i; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 6); state <= S_FETCH_CHAR_READ; end
                        5'd14: begin current_ascii <= ASCII_k; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 7); state <= S_FETCH_CHAR_READ; end
                        5'd15: begin current_ascii <= ASCII_COLON; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 8); state <= S_FETCH_CHAR_READ; end
                        5'd16: begin current_ascii <= ASCII_SPACE; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 9); state <= S_FETCH_CHAR_READ; end
                        5'd17: begin current_ascii <= ASCII_3; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 10); state <= S_FETCH_CHAR_READ; end
                        5'd18: begin current_ascii <= ASCII_6; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 11); state <= S_FETCH_CHAR_READ; end
                        
                        // Bitti
                        default: begin
                            state <= S_DONE;
                        end
                    endcase
                end

                // --- Adım 1: 8 Yatay Satırı Oku (Aynı) ---
                S_FETCH_CHAR_READ: begin
                    font_read_addr <= {current_ascii, byte_index};
                    state <= S_FETCH_CHAR_WAIT;
                end
                
                S_FETCH_CHAR_WAIT: begin
                    state <= S_FETCH_CHAR_STORE;
                end
                
                S_FETCH_CHAR_STORE: begin
                    // Okunan yatay satırı ilgili register'a kaydet (Aynı)
                    case (byte_index)
                        3'd0: reg_row0 <= font_read_data;
                        3'd1: reg_row1 <= font_read_data;
                        3'd2: reg_row2 <= font_read_data;
                        3'd3: reg_row3 <= font_read_data;
                        3'd4: reg_row4 <= font_read_data;
                        3'd5: reg_row5 <= font_read_data;
                        3'd6: reg_row6 <= font_read_data;
                        3'd7: reg_row7 <= font_read_data;
                    endcase
                    
                    if (byte_index == 7) begin // 8 satır da okundu mu?
                        byte_index <= 0; // Sütun yazma için sayacı sıfırla
                        state <= S_TRANSPOSE_WRITE; // Döndürme/Yazma adımına git
                    end else begin
                        byte_index <= byte_index + 1;
                        state <= S_FETCH_CHAR_READ; // Sonraki satırı oku
                    end
                end

                // --- Adım 2: 8 Dikey Sütunu YAZ (180 DERECE DÖNMÜŞ) (Aynı) ---
                S_TRANSPOSE_WRITE: begin
                    fsm_write_enable <= 1;
                    fsm_write_addr <= current_col_base + byte_index; // Sütun adresini artır
                    
                    // 180 derece dönüş mantığı
                    case (byte_index) 
                        3'd0: fsm_write_data <= {reg_row7[0], reg_row6[0], reg_row5[0], reg_row4[0], reg_row3[0], reg_row2[0], reg_row1[0], reg_row0[0]};
                        3'd1: fsm_write_data <= {reg_row7[1], reg_row6[1], reg_row5[1], reg_row4[1], reg_row3[1], reg_row2[1], reg_row1[1], reg_row0[1]};
                        3'd2: fsm_write_data <= {reg_row7[2], reg_row6[2], reg_row5[2], reg_row4[2], reg_row3[2], reg_row2[2], reg_row1[2], reg_row0[2]};
                        3'd3: fsm_write_data <= {reg_row7[3], reg_row6[3], reg_row5[3], reg_row4[3], reg_row3[3], reg_row2[3], reg_row1[3], reg_row0[3]};
                        3'd4: fsm_write_data <= {reg_row7[4], reg_row6[4], reg_row5[4], reg_row4[4], reg_row3[4], reg_row2[4], reg_row1[4], reg_row0[4]};
                        3'd5: fsm_write_data <= {reg_row7[5], reg_row6[5], reg_row5[5], reg_row4[5], reg_row3[5], reg_row2[5], reg_row1[5], reg_row0[5]};
                        3'd6: fsm_write_data <= {reg_row7[6], reg_row6[6], reg_row5[6], reg_row4[6], reg_row3[6], reg_row2[6], reg_row1[6], reg_row0[6]};
                        3'd7: fsm_write_data <= {reg_row7[7], reg_row6[7], reg_row5[7], reg_row4[7], reg_row3[7], reg_row2[7], reg_row1[7], reg_row0[7]};
                    endcase
                    
                    if (byte_index == 7) begin // 8 sütun da yazıldı mı?
                        state <= S_NEXT_CHAR; // Sonraki karaktere geç
                    end else begin
                        byte_index <= byte_index + 1;
                    end
                end
                
                // --- Adım 3: Sonraki Karaktere Geç ---
                S_NEXT_CHAR: begin
                    char_index <= char_index + 1; // Sıradaki karaktere geç
                    state <= S_SET_CHAR_PARAMS; // O karakterin parametrelerini kur
                end
                
                S_DONE: begin
                    // Yazma bitti. S_IDLE'a git ve bekle.
                    state <= S_IDLE;
                end
                
                default: state <= S_IDLE;
                
            endcase
        end
    end

    // --- (Debug LED'leri kaldırıldı) ---

endmodule