`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    Sensor_Display_Top (FINAL)
// Yazar:    Gemini (Salih Ayvaci için)
// Tarih:    24.10.2025
//
// Açıklama:
// DHT11 Sensör Projesi ile OLED Ekran Projesini birleştirir.
// - DHT11'den (top_dht11)  Nem ve Sıcaklık verisini alır.
// - Veri hazır olduğunda (O_CONV), ekran FSM'ini tetikler.
// - 8-bit binary veriyi (bin2ascii) ASCII'ye çevirir.
// - Veriyi 180 derece dönmüş olarak OLED ekrana yazar.
//----------------------------------------------------------------

module Sensor_Display_Top (
    // Global Sinyaller
    input wire clk,       // 10MHz Sistem Saati
    input wire reset_n,   // Aktif-düşük Reset
    
    // DHT11 Arayüzü
    inout wire IO_DHT11,   // Sensör Veri Hattı [cite: 78]
    
    // OLED Arayüzü
    output wire SCL,       // I2C Saat
    output wire SDA,       // I2C Veri
    output wire FPS        // Frame Pulse
);
    
    // --- DHT11 Sinyalleri ---
    wire [15:0] dht_value;   // {Nem[15:8], Sıcaklık[7:0]} [cite: 76, 194]
    wire        dht_o_conv;  // DHT11 Dönüşüm Tamamlandı Sinyali 
    wire        dht_o_busy;  // DHT11 Meşgul
    wire        dht_o_err;   // DHT11 Hata
    
    // --- Frame Buffer (R/W RAM) Sinyalleri ---
    wire [9:0] oled_read_addr;
    wire [7:0] oled_read_data;
    
    reg [9:0]  fsm_write_addr;
    reg [7:0]  fsm_write_data;
    reg        fsm_write_enable;
    
    // --- Font ROM Sinyalleri ---
    reg [9:0]  font_read_addr;
    wire [7:0] font_read_data;
    
    // --- Binary -> ASCII Dönüşüm Sinyalleri ---
    wire [7:0] humidity_bin;
    wire [7:0] temp_bin;
    wire [6:0] hum_tens_ascii, hum_ones_ascii;
    wire [6:0] temp_tens_ascii, temp_ones_ascii;
    
    // --- FSM Tetikleme Sinyali ---
    reg dht_conv_d0, dht_conv_d1;
    wire dht_conv_rising_edge;


    //-------------------------------------------------
    // MODÜL İNSTANTIASYONLARI
    //-------------------------------------------------

    // --- 1. DHT11 Sensör Çekirdeği ---
    // (Bu modül kendi içinde clk_div [cite: 86] ve dht11_fsm'i [cite: 87] barındırır)
    top_dht11 dht_sensor (
        .CLK(clk),
        .RST_n(reset_n),
        .I_EN(1'b1), // dht11_fsm [cite: 173] otomatik başladığı için '1'e bağlanabilir
        .O_VALUE(dht_value), // {Hum, Temp} [cite: 76, 194]
        .O_ERR(dht_o_err),
        .O_BUSY(dht_o_busy),
        .O_CONV(dht_o_conv), // FSM'i tetikleyecek sinyal 
        .IO_DHT11(IO_DHT11)
    );

    // --- 2. Frame Buffer (Okuma/Yazma RAM) ---
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

    // --- 3. Font ROM ---
    Font_ROM #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(10)
    ) font_rom (
        .clk(clk),
        .addr(font_read_addr),
        .dout(font_read_data)
    );

    // --- 4. OLED Kontrolcüsü (I2C'yi içinde barındırır) ---
    OLED oled_controller (
        .clk(clk),
        .ram_dout(oled_read_data),
        .addr(oled_read_addr),
        .SCL(SCL),
        .SDA(SDA),
        .FPS(FPS)
    );
    
    // --- 5. Binary -> ASCII Dönüştürücüler ---
    assign humidity_bin = dht_value[15:8]; // Nem verisi
    assign temp_bin = dht_value[7:0];     // Sıcaklık verisi
    
    bin2ascii hum_converter (
        .din(humidity_bin),
        .ascii_tens(hum_tens_ascii),
        .ascii_ones(hum_ones_ascii)
    );
    
    bin2ascii temp_converter (
        .din(temp_bin),
        .ascii_tens(temp_tens_ascii),
        .ascii_ones(temp_ones_ascii)
    );

    //-------------------------------------------------
    // DİNAMİK YAZMA FSM (DHT_O_CONV ile tetiklenen)
    //-------------------------------------------------
    
    // O_CONV sinyalinin yükselen kenarını algıla
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            dht_conv_d0 <= 1'b0;
            dht_conv_d1 <= 1'b0;
        end else begin
            dht_conv_d0 <= dht_o_conv;
            dht_conv_d1 <= dht_conv_d0;
        end
    end
    assign dht_conv_rising_edge = dht_conv_d0 & ~dht_conv_d1;
    
    // --- FSM Durumları ve Mantığı ---
    localparam S_IDLE = 0;
    localparam S_CLEAR_FB_LOOP = 1;
    localparam S_SET_CHAR_PARAMS = 2;
    localparam S_FETCH_CHAR_READ = 3;
    localparam S_FETCH_CHAR_WAIT = 4;
    localparam S_FETCH_CHAR_STORE = 5;
    localparam S_TRANSPOSE_WRITE = 6;
    localparam S_NEXT_CHAR = 7;
    localparam S_DONE = 8;

    reg [3:0] state = S_IDLE;
    reg [2:0] byte_index = 0;
    reg [9:0] clear_counter = 0;
    
    reg [7:0] reg_row0, reg_row1, reg_row2, reg_row3, reg_row4, reg_row5, reg_row6, reg_row7;
    
    reg [6:0] current_ascii;
    reg [9:0] current_col_base;
    
    reg [4:0] char_index = 0; // 0-18 arası sayaç

    // ASCII Kodları
    localparam ASCII_n = 7'h6E; // n
    localparam ASCII_e = 7'h65; // e
    localparam ASCII_m = 7'h6D; // m
    localparam ASCII_COLON = 7'h3A; // :
    localparam ASCII_SPACE = 7'h20; // (boşluk)
    
    localparam ASCII_s = 7'h73; // s
    localparam ASCII_i = 7'h69; // i (ı yerine)
    localparam ASCII_c = 7'h63; // c
    localparam ASCII_a = 7'h61; // a
    localparam ASCII_k = 7'h6B; // k
    localparam ASCII_l = 7'h6C; // l
    
    // Ekran Konumları
    localparam PAGE_TOP = 2;
    localparam PAGE_BOT = 4;
    localparam START_COL = 10;
    localparam CHAR_WIDTH = 8;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= S_IDLE; // Reset'te bekle
            fsm_write_enable <= 0;
            byte_index <= 0;
            clear_counter <= 0;
            char_index <= 0;
        end else begin
            
            fsm_write_enable <= 0;
            
            case (state)
                S_IDLE: begin
                    // DHT11'den yeni veri geldiğinde FSM'i başlat
                    if (dht_conv_rising_edge) begin
                        clear_counter <= 0;
                        char_index <= 0;
                        state <= S_CLEAR_FB_LOOP;
                    end
                end
                
                S_CLEAR_FB_LOOP: begin
                    fsm_write_enable <= 1;
                    fsm_write_addr <= clear_counter;
                    fsm_write_data <= 8'h00;
                    
                    if (clear_counter == 1023) begin
                        clear_counter <= 0;
                        state <= S_SET_CHAR_PARAMS;
                    end else begin
                        clear_counter <= clear_counter + 1;
                    end
                end
                
                S_SET_CHAR_PARAMS: begin
                    byte_index <= 0;
                    
                    case (char_index)
                        // Satır 1: "nem: "
                        5'd0:  begin current_ascii <= ASCII_n; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 0); state <= S_FETCH_CHAR_READ; end
                        5'd1:  begin current_ascii <= ASCII_e; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 1); state <= S_FETCH_CHAR_READ; end
                        5'd2:  begin current_ascii <= ASCII_m; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 2); state <= S_FETCH_CHAR_READ; end
                        5'd3:  begin current_ascii <= ASCII_COLON; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 3); state <= S_FETCH_CHAR_READ; end
                        5'd4:  begin current_ascii <= ASCII_SPACE; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 4); state <= S_FETCH_CHAR_READ; end
                        // --- DİNAMİK VERİ (NEM) ---
                        5'd5:  begin current_ascii <= hum_tens_ascii; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 5); state <= S_FETCH_CHAR_READ; end
                        5'd6:  begin current_ascii <= hum_ones_ascii; current_col_base <= (PAGE_TOP * 128) + START_COL + (CHAR_WIDTH * 6); state <= S_FETCH_CHAR_READ; end
                        
                        // Satır 2: "sicaklik: "
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
                        // --- DİNAMİK VERİ (SICAKLIK) ---
                        5'd17: begin current_ascii <= temp_tens_ascii; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 10); state <= S_FETCH_CHAR_READ; end
                        5'd18: begin current_ascii <= temp_ones_ascii; current_col_base <= (PAGE_BOT * 128) + START_COL + (CHAR_WIDTH * 11); state <= S_FETCH_CHAR_READ; end
                        
                        // Bitti
                        default: begin
                            state <= S_DONE;
                        end
                    endcase
                end

                S_FETCH_CHAR_READ: begin
                    font_read_addr <= {current_ascii, byte_index};
                    state <= S_FETCH_CHAR_WAIT;
                end
                
                S_FETCH_CHAR_WAIT: begin
                    state <= S_FETCH_CHAR_STORE;
                end
                
                S_FETCH_CHAR_STORE: begin
                    case (byte_index)
                        3'd0: reg_row0 <= font_read_data; 3'd1: reg_row1 <= font_read_data;
                        3'd2: reg_row2 <= font_read_data; 3'd3: reg_row3 <= font_read_data;
                        3'd4: reg_row4 <= font_read_data; 3'd5: reg_row5 <= font_read_data;
                        3'd6: reg_row6 <= font_read_data; 3'd7: reg_row7 <= font_read_data;
                    endcase
                    
                    if (byte_index == 7) begin
                        byte_index <= 0;
                        state <= S_TRANSPOSE_WRITE;
                    end else begin
                        byte_index <= byte_index + 1;
                        state <= S_FETCH_CHAR_READ;
                    end
                end

                S_TRANSPOSE_WRITE: begin
                    fsm_write_enable <= 1;
                    fsm_write_addr <= current_col_base + byte_index;
                    
                    case (byte_index) // 180 Derece Dönüş Mantığı
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
                
                S_NEXT_CHAR: begin
                    char_index <= char_index + 1;
                    state <= S_SET_CHAR_PARAMS;
                end
                
                S_DONE: begin
                    // Yazma bitti. Bir sonraki dht_conv_rising_edge'i beklemek için S_IDLE'a dön.
                    state <= S_IDLE;
                end
                
                default: state <= S_IDLE;
                
            endcase
        end
    end

endmodule