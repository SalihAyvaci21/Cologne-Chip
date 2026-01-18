`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    Top_OLED
// Yazar:    Salih Tekin Ayvacı - DEMSAY ELEKTRONİK
// Tarih:    12.06.2025
//
// Açıklama:
// v11: FSM güncellendi. Ekrana "uzaklik: " ve "xxx (cm)"
//      yazacak şekilde iki satırlı hale getirildi.
//----------------------------------------------------------------

module Top_OLED (
    // --- Sistem Portları ---
    input wire clk,       // 10MHz Sistem Saati (Osilatörden)
    input wire reset_n,   // Aktif-düşük (Active-low) Reset Butonu
    
    // --- OLED Arayüzü ---
    output wire SCL,       // I2C Saat Sinyali
    output wire SDA,       // I2C Veri Sinyali
    output wire FPS,       // Frame Pulse (Kare Senkronizasyonu)
    
    // --- HCSR04 Arayüzü ---
    output wire trigger,   // Sensör Tetikleme Pini (Çıkış)
    input wire echo       // Sensör Echo Pini (Giriş)
);

    // --- Frame Buffer (RAM) Arayüz Sinyalleri ---
    wire [9:0] oled_read_addr;
    wire [7:0] oled_read_data;
    reg [9:0]  fsm_write_addr;
    reg [7:0]  fsm_write_data;
    reg        fsm_write_enable;
    
    // --- Font ROM Arayüz Sinyalleri ---
    reg [9:0]  font_read_addr;
    wire [7:0] font_read_data;
    
    // --- HCSR04 Ölçüm Motoru Ara Sinyalleri ---
    wire        sensor_strobe;
    wire        sensor_conv;
    wire [8:0]  sensor_dst;
    wire        sensor_busy;
    wire [11:0] sensor_bcd_dst;
    wire        sensor_flag;

//-------------------------------------------------
// MODÜL İNSTANTIASYONLARI
//-------------------------------------------------

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

    // --- 2. Font ROM (Yazı Tipi Hafızası) ---
    Font_ROM #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(10)
    ) font_rom (
        .clk(clk),
        .addr(font_read_addr),
        .dout(font_read_data)
    );

    // --- 3. OLED Kontrolcüsü ---
    OLED oled_controller (
        .clk(clk),
        .ram_dout(oled_read_data),
        .addr(oled_read_addr),
        .SCL(SCL),
        .SDA(SDA),
        .FPS(FPS)
    );

    // --- 4. Saat Bölücü (10MHz -> 17kHz Strobe) ---
    clk_div #(
        .CCL_SZ(588)
    ) sensor_clk_div (
        .CLK(clk),
        .RST_n(reset_n),
        .O_ST(sensor_strobe)
    );

    // --- 5. HCSR04 FSM (Ölçüm Yapar) ---
    hc_sr04_fsm #(
        .MAX_RANGE(400),
        .DST_SZ(9)
    ) sensor_fsm (
        .CLK(clk),
        .RST_n(reset_n),
        .I_EN(1'b1),
        .I_ST(sensor_strobe),
        .I_ECHO(echo),
        .O_DST(sensor_dst),
        .O_CONV(sensor_conv),
        .O_TRIG(trigger),
        .O_FL(sensor_flag)
    );

    // --- 6. Binary -> BCD Çevirici ---
    bcd_encoder #(
        .BINARY_LEN(9),
        .BCD_DIGITS(3),
        .BCD_LEN(12)
    ) sensor_bcd_encoder (
        .CLK(clk),
        .RST_n(reset_n),
        .I_CONV(sensor_conv),
        .I_BIN(sensor_dst),
        .O_BUSY(sensor_busy),
        .O_BCD(sensor_bcd_dst)
    );

//-------------------------------------------------
// OLED EKRANA YAZMA FSM (v11)
//-------------------------------------------------
    
    // FSM Durumları
    localparam S_IDLE            = 0;
    localparam S_CLEAR_FB_LOOP   = 1;
    localparam S_WAIT_BUSY_LOW = 2;
    localparam S_WAIT_BUSY_HIGH  = 3;
    localparam S_SET_CHAR_PARAMS = 4;
    localparam S_FETCH_CHAR_READ = 5;
    localparam S_FETCH_CHAR_WAIT = 6;
    localparam S_FETCH_CHAR_STORE= 7;
    localparam S_TRANSPOSE_WRITE = 8;
    localparam S_NEXT_CHAR       = 9;

    reg [3:0] state = S_IDLE;
    reg [2:0] byte_index = 0;
    reg [9:0] clear_counter = 0;
    
    // Font karakterinin 8 yatay satırını tutmak için
    reg [7:0] reg_row0, reg_row1, reg_row2, reg_row3, reg_row4, reg_row5, reg_row6, reg_row7;
    
    // Yazılacak karakteri ve konumu tutan registerlar
    reg [6:0] current_ascii;
    reg [9:0] current_col_base;
    
    // BCD verisini tutan register
    reg [11:0] bcd_data_reg = 0;
    
    // Yazılacak karakter indeksi (0-16 arası, toplam 17 karakter)
    // *** DEĞİŞİKLİK: [1:0] -> [4:0] ***
    reg [4:0] char_index = 0; 
    
    // --- Ekran Konumları ve ASCII Kodları ---
    localparam CHAR_WIDTH = 8;
    
    // Satır 1 ("uzaklik:")
    localparam PAGE_L1 = 3;
    localparam START_COL_L1 = 28; // (128 - 9*8) / 2 = 28
    
    // Satır 2 ("xxx (cm)")
    localparam PAGE_L2 = 4;
    localparam START_COL_L2 = 32; // (128 - 8*8) / 2 = 32
    
    // ASCII Kodları
    localparam ASCII_0 = 7'h30;
    localparam ASCII_u = 7'h75;
    localparam ASCII_z = 7'h7A;
    localparam ASCII_a = 7'h61;
    localparam ASCII_k = 7'h6B;
    localparam ASCII_l = 7'h6C;
    localparam ASCII_i = 7'h69; // 'ı' yerine 'i' kullanılıyor
    localparam ASCII_colon = 7'h3A;
    localparam ASCII_space = 7'h20;
    localparam ASCII_paren_L = 7'h28;
    localparam ASCII_c = 7'h63;
    localparam ASCII_m = 7'h6D;
    localparam ASCII_paren_R = 7'h29;
    

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= S_CLEAR_FB_LOOP;
            fsm_write_enable <= 0;
            byte_index <= 0;
            clear_counter <= 0;
            char_index <= 0;
            bcd_data_reg <= 0;
        end else begin
            
            fsm_write_enable <= 0;
            
            case (state)
                S_IDLE: begin
                    state <= S_CLEAR_FB_LOOP;
                end
                
                S_CLEAR_FB_LOOP: begin
                    fsm_write_enable <= 1;
                    fsm_write_addr <= clear_counter;
                    fsm_write_data <= 8'h00;
                    
                    if (clear_counter == 1023) begin
                        clear_counter <= 0;
                        state <= S_WAIT_BUSY_LOW;
                    end else begin
                        clear_counter <= clear_counter + 1;
                    end
                end

                S_WAIT_BUSY_LOW: begin
                    if (!sensor_busy) begin
                        bcd_data_reg <= sensor_bcd_dst;
                        char_index <= 0;
                        state <= S_SET_CHAR_PARAMS;
                    end
                end

                S_WAIT_BUSY_HIGH: begin
                    if (sensor_busy) begin
                        state <= S_WAIT_BUSY_LOW;
                    end
                end
                
                // *** DEĞİŞİKLİK: S_SET_CHAR_PARAMS durumu 17 karaktere çıkarıldı ***
                S_SET_CHAR_PARAMS: begin
                    byte_index <= 0;
                    
                    // 'char_index'e (karakter sırası) göre sıradaki karakteri seç
                    case (char_index)
                        // --- Satır 1 (Sayfa 3): "uzaklik: " (9 karakter) ---
                        5'd0:  begin current_ascii <= ASCII_u;     current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 0); state <= S_FETCH_CHAR_READ; end
                        5'd1:  begin current_ascii <= ASCII_z;     current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 1); state <= S_FETCH_CHAR_READ; end
                        5'd2:  begin current_ascii <= ASCII_a;     current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 2); state <= S_FETCH_CHAR_READ; end
                        5'd3:  begin current_ascii <= ASCII_k;     current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 3); state <= S_FETCH_CHAR_READ; end
                        5'd4:  begin current_ascii <= ASCII_l;     current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 4); state <= S_FETCH_CHAR_READ; end
                        5'd5:  begin current_ascii <= ASCII_i;     current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 5); state <= S_FETCH_CHAR_READ; end
                        5'd6:  begin current_ascii <= ASCII_k;     current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 6); state <= S_FETCH_CHAR_READ; end
                        5'd7:  begin current_ascii <= ASCII_colon; current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 7); state <= S_FETCH_CHAR_READ; end
                        5'd8:  begin current_ascii <= ASCII_space; current_col_base <= (PAGE_L1 * 128) + START_COL_L1 + (CHAR_WIDTH * 8); state <= S_FETCH_CHAR_READ; end

                        // --- Satır 2 (Sayfa 4): "xxx (cm)" (8 karakter) ---
                        5'd9:  begin current_ascii <= bcd_data_reg[11:8] + ASCII_0; current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 0); state <= S_FETCH_CHAR_READ; end // Hane 1 (Yüzler)
                        5'd10: begin current_ascii <= bcd_data_reg[7:4]  + ASCII_0; current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 1); state <= S_FETCH_CHAR_READ; end // Hane 2 (Onlar)
                        5'd11: begin current_ascii <= bcd_data_reg[3:0]  + ASCII_0; current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 2); state <= S_FETCH_CHAR_READ; end // Hane 3 (Birler)
                        5'd12: begin current_ascii <= ASCII_space;     current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 3); state <= S_FETCH_CHAR_READ; end // " "
                        5'd13: begin current_ascii <= ASCII_paren_L;   current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 4); state <= S_FETCH_CHAR_READ; end // "("
                        5'd14: begin current_ascii <= ASCII_c;         current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 5); state <= S_FETCH_CHAR_READ; end // "c"
                        5'd15: begin current_ascii <= ASCII_m;         current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 6); state <= S_FETCH_CHAR_READ; end // "m"
                        5'd16: begin current_ascii <= ASCII_paren_R;   current_col_base <= (PAGE_L2 * 128) + START_COL_L2 + (CHAR_WIDTH * 7); state <= S_FETCH_CHAR_READ; end // ")"
                        
                        // Bitti
                        default: begin
                            state <= S_WAIT_BUSY_HIGH; // 17 karakter bitti, yeni veriyi bekle
                        end
                    endcase
                end

                // --- Adım 5: 8x8 Karakteri Font ROM'dan Oku (8 Satır) ---
                S_FETCH_CHAR_READ: begin
                    font_read_addr <= {current_ascii, byte_index};
                    state <= S_FETCH_CHAR_WAIT;
                end
                
                S_FETCH_CHAR_WAIT: begin
                    state <= S_FETCH_CHAR_STORE;
                end
                
                S_FETCH_CHAR_STORE: begin
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
                    
                    if (byte_index == 7) begin
                        byte_index <= 0;
                        state <= S_TRANSPOSE_WRITE;
                    end else begin
                        byte_index <= byte_index + 1;
                        state <= S_FETCH_CHAR_READ;
                    end
                end

                // --- Adım 6: 8x8 Karakteri Frame Buffer'a YAZ (180 DERECE DÖNMÜŞ) ---
                S_TRANSPOSE_WRITE: begin
                    fsm_write_enable <= 1;
                    fsm_write_addr <= current_col_base + byte_index;
                    
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
                    
                    if (byte_index == 7) begin
                        state <= S_NEXT_CHAR;
                    end else begin
                        byte_index <= byte_index + 1;
                    end
                end
                
                // --- Adım 7: Sonraki Karaktere Geç ---
                S_NEXT_CHAR: begin
                    char_index <= char_index + 1; // Karakter sayacını artır
                    state <= S_SET_CHAR_PARAMS;
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end
    
endmodule