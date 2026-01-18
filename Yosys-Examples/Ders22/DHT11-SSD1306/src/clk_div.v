module clk_div               // clk div 50 MHz to 1 МHz
    #(parameter CCL_SZ = 50) // T = 1 uS
    (CLK, RST_n, 
     O_ST);


//-----------------------------------------------------------
    localparam CNT_SZ = $clog2(CCL_SZ); // counter clock width
//  input signals
    input wire       CLK;     // clk 50 MHz
    input wire       RST_n;   // asynchronous reset
//  output signals
    output reg       O_ST;    // clock enable (strobe)
//  internal signals
    reg [CNT_SZ-1:0] cnt_clk; // current state counter clk

//  counter clk
    always @(posedge CLK or negedge RST_n) begin
      if (!RST_n)
        begin
          cnt_clk <= {CNT_SZ{1'b0}};
          O_ST <= 1'b0;
        end
      else
        begin
          if (cnt_clk == CCL_SZ - 1'b1)
            begin
              cnt_clk <= {CNT_SZ{1'b0}};
              O_ST <= 1'b1;
            end
          else 
            begin
              cnt_clk <= cnt_clk + 1'b1;
              O_ST <= 1'b0;            
            end
        end
    end


endmodule