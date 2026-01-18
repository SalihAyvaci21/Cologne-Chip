module db_dht11
    #(parameter BYTE_SZ  = 8,           // widht byte
      parameter VALUE_SZ = 2 * BYTE_SZ) // widht value  
    (CLK, I_SW, I_KEY, 
     O_LEDR, 
     IO_DHT11);

    
//  input signals
    input wire       CLK;
    input wire       I_SW;
    input wire [1:0] I_KEY;
//  output signals
    output reg [9:0] O_LEDR;
//  bidirectional signals
    inout wire       IO_DHT11; // data line   
//  internal signals
    wire [VALUE_SZ-1:0] value;
    wire [9:0]          ledr;
    wire                RST_n;

//----------------------------------------------------------    
    top_dht11 top_dht11
        (   
         .CLK(CLK), 
         .RST_n(RST_n), 
         .I_EN(~I_KEY[0]), 
         .O_VALUE(value), 
         .O_ERR(ledr[9]),
         .O_BUSY(ledr[8]), 
         .O_CONV(), 
         .IO_DHT11(IO_DHT11)
        );      
    
//----------------------------------------------------------   
    assign RST_n = I_KEY[1];
    assign ledr[7:0] = I_SW ? value[BYTE_SZ+:BYTE_SZ] : value[BYTE_SZ-1:0];

//----------------------------------------------------------     
    always @(posedge CLK or negedge RST_n) begin
      if (!RST_n)
        begin
          O_LEDR <= 10'b0;
        end
      else
        begin
          O_LEDR <= ledr;
        end
    end      

    
endmodule