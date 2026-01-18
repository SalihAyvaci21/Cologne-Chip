module top_dht11
    #(parameter CCL_SZ   = 10,          // T = 1 uS
      parameter DATA_SZ  = 40,          // data width
      parameter BYTE_SZ  = 8,           // byte width
      parameter VALUE_SZ = 2 * BYTE_SZ) // value width
    (CLK, RST_n, I_EN, O_VALUE, 
     O_ERR, O_BUSY, O_CONV, 
     IO_DHT11);
        
        
//  input signals
    input wire                 CLK;      // clk 50 MHz
    input wire                 RST_n;    // asynchronous reset
    input wire                 I_EN;     // starts sensor polling 
//  output signals
    output wire                O_BUSY;   // busy
    output wire                O_ERR;    // received data error flag
    output wire [VALUE_SZ-1:0] O_VALUE;  // data Temperature & Humidity  
    output wire                O_CONV;   // signal start converting binary to BCD    
//  bidirectional signals
    inout wire                 IO_DHT11; // data line
//  internal signals
    wire strobe;      // clock enable (strobe)    
    wire dht11_in;    // input data line from DHT11
    wire dht11_out;   // output data line to DHT11
    wire rs_dht11_in; // rising edge of the data line from DHT11
    wire fl_dht11_in; // falling edge of the data line from DHT11
    reg  cr_dht11_in; // current line from DHT11
    reg  pr_dht11_in; // previous line from DHT11
    
//------------------------------------------------------------------------    
    clk_div 
        #(
         .CCL_SZ(CCL_SZ)
        )
    clk_div
        (
         .CLK(CLK),
         .RST_n(RST_n),
         .O_ST(strobe) 
        );

//------------------------------------------------------------------------        
    dht11_fsm 
        #(
         .DATA_SZ(DATA_SZ),
         .BYTE_SZ(BYTE_SZ),
         .VALUE_SZ(VALUE_SZ)
        )
    dht11_fsm
        (
         .CLK(CLK),
         .RST_n(RST_n),
         .I_ST(strobe),
         .I_EN(I_EN),
         .I_RIS(rs_dht11_in),
         .I_FALL(fl_dht11_in),
         .O_DHT11(dht11_out),
         .O_BUSY(O_BUSY),
         .O_ERR(O_ERR),
         .O_VALUE(O_VALUE),
         .O_CONV(O_CONV)
        );

//------------------------------------------------------------------------        
    assign dht11_in = IO_DHT11;
    assign IO_DHT11 = dht11_out ? 1'bz : 1'b0;
    assign fl_dht11_in = ~cr_dht11_in &  pr_dht11_in;
    assign rs_dht11_in =  cr_dht11_in & ~pr_dht11_in;
    
//------------------------------------------------------------------------      
    always @(posedge CLK or negedge RST_n) begin
      if (!RST_n)
        begin
          cr_dht11_in <= 1'b0;
          pr_dht11_in <= 1'b0;
        end
      else if (strobe)
        begin
          cr_dht11_in <= dht11_in;
          pr_dht11_in <= cr_dht11_in;     
        end
    end


endmodule