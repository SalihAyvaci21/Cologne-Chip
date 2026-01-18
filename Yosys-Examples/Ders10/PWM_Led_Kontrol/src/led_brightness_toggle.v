`timescale 1ns / 1ps

module led_brightness_toggle (
    input  wire clk,
    input  wire rst_n,
    input  wire button,
    output wire [7:0] led_out
);

    // -----------------------------
    // Debounce IP
    // -----------------------------
    wire db_valid;
    wire db_button;

    debounce_ip_core u_db (
        .clk(clk),
        .rst_n(rst_n),
        .push_button(button),
        .out_valid(db_valid),
        .debounced_button(db_button)
    );

    // -----------------------------
    // Duty Cycle Toggle
    // -----------------------------
    reg toggle = 0; // 0 → %10, 1 → %90
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            toggle <= 0;
        else if (db_valid) // değişim anında toggle
            toggle <= ~toggle;
    end

    // -----------------------------
    // PWM Generator Instance
    // -----------------------------
    reg [7:0] duty_reg;
    always @(*) begin
        duty_reg = (toggle) ? 8'd230 : 8'd25; // %90 veya %10
    end

    wire pwm_signal;
    pwm_generator #(
        .CLK_FREQ(10_000_000),
        .PWM_FREQ(1000)
    ) u_pwm (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty_reg),
        .pwm_out(pwm_signal)
    );

    // -----------------------------
    // LED Output
    // -----------------------------
    assign led_out = {8{pwm_signal}}; // tüm LED’ler PWM ile kontrol ediliyor

endmodule
