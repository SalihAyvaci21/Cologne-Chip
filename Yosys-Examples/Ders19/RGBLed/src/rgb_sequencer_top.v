`timescale 1ns / 1ps
//----------------------------------------------------------------
// Modül:    rgb_sequencer_top
// Saat:     10MHz olarak ayarlı
// DEĞİŞİKLİK: FSM artık 1 saniye yerine her 100ns'de (her saat darbesi)
//             durum değiştirecek şekilde güncellendi.
//----------------------------------------------------------------

module rgb_sequencer_top (
    input  wire clk,     // Saat girişi (10 MHz)
    input  wire n_rst,   // Aktif-düşük reset
    
    output wire led_r,
    output wire led_g,
    output wire led_b
);

    // --- Parametreler (10MHz) ---
    localparam CLK_FREQ_HZ      = 10_000_000;
    // localparam ONE_SECOND_COUNT = CLK_FREQ_HZ; //
    
    // Renk Kodları (24-bit: RRGGBB)
    localparam COLOR_RED     = 24'hFF0000;
    localparam COLOR_GREEN   = 24'h00FF00;
    localparam COLOR_BLUE    = 24'h0000FF;
    localparam COLOR_PURPLE  = 24'h800080;
    localparam COLOR_YELLOW  = 24'hFFFF00;
    localparam COLOR_MAGENTA = 24'hFF00FF;
    
    // FSM Durumları
    localparam S_RED     = 0;
    localparam S_GREEN   = 1;
    localparam S_BLUE    = 2;
    localparam S_PURPLE  = 3;
    localparam S_YELLOW  = 4;
    localparam S_MAGENTA = 5;

    // --- Register'lar ---
    // reg [23:0] timer_reg; // *** KALDIRILDI ***
    reg [2:0]  state;       
    reg [23:0] current_rgb; 

    // --- Sinyaller ---
    // wire timer_tick; // *** KALDIRILDI ***
    // assign timer_tick = (timer_reg == (ONE_SECOND_COUNT - 1)); // *** KALDIRILDI ***


    // --- FSM Mantığı (Her 100ns'de bir güncellenen) ---
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            // timer_reg   <= 0; // *** KALDIRILDI ***
            state       <= S_RED;
            current_rgb <= COLOR_RED;
        end else begin
            
            // 'if (timer_tick)' bloğu kaldırıldı.
            // Artık sayaç yok, FSM her saat darbesinde (100 ns) güncellenir.
            
            case (state)
                S_RED:     begin state <= S_GREEN;   current_rgb <= COLOR_GREEN;   end
                S_GREEN:   begin state <= S_BLUE;    current_rgb <= COLOR_BLUE;    end
                S_BLUE:    begin state <= S_PURPLE;  current_rgb <= COLOR_PURPLE;  end
                S_PURPLE:  begin state <= S_YELLOW;  current_rgb <= COLOR_YELLOW;  end
                S_YELLOW:  begin state <= S_MAGENTA; current_rgb <= COLOR_MAGENTA; end
                S_MAGENTA: begin state <= S_RED;     current_rgb <= COLOR_RED;     end
                default:   begin state <= S_RED;     current_rgb <= COLOR_RED;     end
            endcase
                
            // 'else' (sayaç artırma) bloğu kaldırıldı.
            // end else begin
            //    timer_reg <= timer_reg + 1;
            // end
        end
    end
    
    
    // --- RgbLed Modülünü Çalıştırma ---
    RgbLed u_rgb_pwm (
        .clk(clk),
        .n_rst(n_rst),
        
        // Göz kırpmayı (blink_en) kapatıyoruz, 
        // böylece RgbLed içindeki BLINK_PERIOD sayacı kullanılmıyor.
        .blink_en(1'b0), 
     
        .rgb(current_rgb), // Her 100ns'de bir güncellenen renk
        
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
    );
endmodule