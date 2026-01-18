`timescale 1ns / 1ps

module control_fsm (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg load_a,
    output reg load_b,
    output reg load_c,
    output reg enable,
    output reg done
);
    parameter IDLE = 2'b00,
              LOAD = 2'b01,
              ADD  = 2'b10,
              FIN  = 2'b11;

    reg [1:0] state, next_state;
    reg [3:0] bit_count;

    // State register
    always @(posedge clk or posedge rst)
        if (rst) state <= IDLE;
        else state <= next_state;

    // FSM logic
    always @(*) begin
        load_a = 0;
        load_b = 0;
        load_c = 0;
        enable = 0;
        done   = 0;
        next_state = state;

        case (state)
            IDLE: if (start) next_state = LOAD;
            LOAD: begin
                load_a = 1;
                load_b = 1;
                load_c = 1;
                next_state = ADD;
            end
            ADD: begin
                enable = 1;
                if (bit_count >= 8) next_state = FIN;
            end
            FIN: begin
                done = 1;
                next_state = IDLE;
            end
        endcase
    end

    // Counter
    always @(posedge clk or posedge rst) begin
        if (rst)
            bit_count <= 0;
        else if (state == ADD && enable)
            bit_count <= bit_count + 1;
        else if (state != ADD)
            bit_count <= 0;
    end
endmodule
