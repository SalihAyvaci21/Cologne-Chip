// -------------------------------------------------------
// DEMSAY ELEKTRONİK - ARGE
// Salih Tekin Ayvacı - FIELD APPLICATION ENGINEER
// 12.09.2025
// -------------------------------------------------------
module Led_per_sec (
    input  CLK,        // E1 system clock 
    input  RESET,      // E1 user button
    output [7:0] LEDS, // E1 onboard LEDs
    input  RXD,        // UART receive
    output TXD         // UART transmit
);

   wire clk;    // internal clock
   wire resetn; // internal reset signal, goes low on reset
   
   // A blinker that counts on 5 bits, wired to 5 of 8 LEDs
   reg [4:0] count = 0;
   always @(posedge clk) begin
      count <= !resetn ? 0 : count + 1;
   end

   // Clock gearbox (to let you see what happens)
   // and reset circuitry
   clockworks #(
     .SLOW(21) // Divide clock frequency by 2^21
   )CW(
     .CLK(CLK),
     .RESET(~RESET), // gatemate RESET needs ~ to flip
     .clk(clk),
     .resetn(resetn)
   );
   
   // we assign 5 LEDS, and keep the remaining 3 off
   assign {LEDS[4:0], LEDS[7:5]} = {~count, 3'b111};
   assign TXD  = 1'b0; // not used for now   
endmodule