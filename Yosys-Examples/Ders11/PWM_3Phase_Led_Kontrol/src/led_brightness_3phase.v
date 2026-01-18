`timescale 1ns / 1ps

module led_brightness_3phase (
    input  wire clk,
    input  wire rst_n,
    output wire led1,
    output wire led2,
    output wire led3
);

    // -----------------------------
    // PWM Generator Instances
    // -----------------------------
    pwm_generator #(
        .CLK_FREQ(10_000_000),
        .PWM_FREQ(1000)
    ) u_pwm1 (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty1),
        .pwm_out(led1)
    );

    pwm_generator #(
        .CLK_FREQ(10_000_000),
        .PWM_FREQ(1000)
    ) u_pwm2 (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty2),
        .pwm_out(led2)
    );

    pwm_generator #(
        .CLK_FREQ(10_000_000),
        .PWM_FREQ(1000)
    ) u_pwm3 (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty3),
        .pwm_out(led3)
    );


    // -----------------------------
    // PWM Duty değerleri
    // -----------------------------
    reg [7:0] duty1, duty2, duty3;

    // -----------------------------
    // State Machine
    // -----------------------------
    reg [1:0] state = 0;
    reg [23:0] counter = 0;
    localparam integer MAX_COUNT = 10_000_000; // 0.5 saniye @10MHz

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            state   <= 0;
        end else begin
            if (counter >= MAX_COUNT) begin
                counter <= 0;
                state   <= state + 1;
                if (state == 2)
                    state <= 0;
            end else begin
                counter <= counter + 1;
            end

            // -----------------------------
            // PWM Duty ataması
            // -----------------------------
            case (state)
                0: begin
                    duty1 <= 8'd128; // 50%
                    duty2 <= 8'd255; // 100%
                    duty3 <= 8'd0;   // 0%
                end
                1: begin
                    duty1 <= 8'd0;   // 0%
                    duty2 <= 8'd128; // 50%
                    duty3 <= 8'd255; // 100%
                end
                2: begin
                    duty1 <= 8'd255; // 100%
                    duty2 <= 8'd0;   // 0%
                    duty3 <= 8'd128; // 50%
                end
                default: begin
                    duty1 <= 8'd0;
                    duty2 <= 8'd0;
                    duty3 <= 8'd0;
                end
            endcase
        end
    end


endmodule
