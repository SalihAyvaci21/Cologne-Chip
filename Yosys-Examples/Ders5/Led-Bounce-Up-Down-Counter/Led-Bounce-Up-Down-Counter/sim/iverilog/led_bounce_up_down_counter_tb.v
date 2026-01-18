`timescale 1ns / 1ps

module led_bounce_up_down_counter_tb;

    reg clk;
    reg push_button;
    wire [7:0] led_out;

    // Saat üretimi (100ns periyod = 10MHz)
    initial clk = 0;
    always #50 clk = ~clk;

    // DUT (Device Under Test)
    led_bounce_up_down_counter uut (
        .clk(clk),
        .push_button(push_button),
        .led_out(led_out)
    );

    // ======================
    // Simülasyon Ayarları
    // ======================
    initial begin
        // Dalga biçimi dosyası oluştur
        $dumpfile("led_bounce_up_down_counter_tb.vcd");
        $dumpvars(0, led_bounce_up_down_counter_tb);
    end


    // Buton basma simülasyonu (debounce testine uygun şekilde)
    task press_button;
        begin
            // Buton bouncing simülasyonu
            push_button = 1;
            #200;
            push_button = 0;
            #100;
            push_button = 1;
            #150;
            push_button = 0;
            #100;
            push_button = 1;
            #1000; // stabil basılı
            push_button = 0;
        end
    endtask

    initial begin
        // Başlangıç
        push_button = 0;

        // Birkaç buton basma simülasyonu
        #1000;
        press_button; // 1. basış
        #5000;
        press_button; // 2. basış
        #5000;
        press_button; // 3. basış
        #5000;
        press_button; // 4. basış
        #5000;
        press_button; // 5. basış
        #10000;

        $finish;
    end

endmodule
