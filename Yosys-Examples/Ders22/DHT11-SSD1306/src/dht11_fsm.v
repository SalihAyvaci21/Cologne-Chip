module dht11_fsm
    #(parameter DATA_SZ  = 40,          // data width
      parameter BYTE_SZ  = 8,           // byte width
      parameter VALUE_SZ = 2 * BYTE_SZ) // value width
    (CLK, RST_n, I_EN, I_ST, I_RIS, I_FALL, 
     O_DHT11, O_BUSY, O_ERR, O_VALUE, O_CONV);
//------------------------------------------------------------------
    localparam CNT_DATA_SZ = $clog2(DATA_SZ);   // counter data width
    localparam IDLE_V      = 1_000_000;
// minimum polling time DHT11 = 1 S (for FPGA)
    // localparam IDLE_V      = 1_000;
// minimum polling time DHT11 = 1 mS (for simulation)   
    localparam MSTR_LW_V   = 20_000;
// FPGA pulls the line low = 20 mS
    localparam MSTR_HG_V   = 20;
// FPGA pulls the line high = 20 uS
    localparam SEND_1      = 60;
// DHT11 sending 1           
    localparam CNT_I_ST_SZ = $clog2(IDLE_V);
// strobe counter depth
    localparam MSTR_LW_ST  = 50;
// FPGA pulls signal low = 50 uS (stop of transaction)
    localparam CNT_LINE_SZ = $clog2(MSTR_LW_V);
// line counter depth           
//  description states FSM       
    localparam ST_SZ   = 8;
// number of states FSM  
    localparam IDLE    = 8'b00000001;
// idle = 1 S
    localparam READY   = 8'b00000010;
// ready to start a transaction
    localparam MSTR_LW = 8'b00000100;
// FPGA pulls the line low = 20 mS 
    localparam MSTR_HG = 8'b00001000;
// FPGA pulls the line high = 20 uS
    localparam SLV_LW  = 8'b00010000;
// DHT11 pulls the line   low = 80 uS
    localparam SLV_HG  = 8'b00100000;
// DHT11 pulls the line hight = 80 uS
    localparam DATA_TR = 8'b01000000;
// data transfer from DHT11 (40 bit)
    localparam STOP    = 8'b10000000;
// analysis of the received data and stop  of transaction      
//  input signals
    input wire                CLK;
// clk 50 MHz
    input wire                RST_n;
// asynchronous reset
    input wire                I_EN;
// starts sensor polling
    input wire                I_ST;
// clock enable (strobe)
    input wire                I_RIS;
// rising edge of the data line from DHT11
    input wire                I_FALL;
// falling edge of the data line from DHT11
//  output signals
    output reg                O_DHT11;
// command for O_DHT11
    output reg                O_BUSY;
// busy   
    output reg                O_ERR;
// received data error flag
    output reg [VALUE_SZ-1:0] O_VALUE;
// data Temperature & Humidity
    output reg                O_CONV;
// signal start converting binary to BCD       
//  intertal signals
    reg [ST_SZ-1:0]       st;
// current state of FSM
    reg [ST_SZ-1:0]       nx_st;
// next state of FSM 
    reg [CNT_I_ST_SZ-1:0] cnt_i_st;
// counter pulse strobe
    reg [CNT_I_ST_SZ-1:0] nx_cnt_i_st;  // next counter pulse strobe;
reg                   nx_o_dht11;
// next command for O_DHT11 
    reg                   nx_o_busy;
// next busy
    reg [CNT_LINE_SZ-1:0] cnt_line;     // line status counter 
    reg [CNT_LINE_SZ-1:0] nx_cnt_line;
// next line status counter
    reg                   send;
// data transfer status
    reg                   nx_send;
// next data transfer status
    reg [CNT_DATA_SZ-1:0] cnt_data;
// counter transfer data from DHT11
    reg [CNT_DATA_SZ-1:0] nx_cnt_data;
// next counter transfer data from DHT11
    reg [DATA_SZ-1:0]     buff_data;
// received data from DHT11
    reg [DATA_SZ-1:0]     nx_buff_data;
// next received data from DHT11
    reg                   nx_o_err;
// next received data error flag
    reg [VALUE_SZ-1:0]    nx_o_value;
// next data Temperature & Humidity
    reg                   nx_o_conv;
// next signal start converting binary to BCD

   
//  determining next state of FSM and signals
    always @(*) begin
      nx_st        = st;
nx_cnt_i_st  = cnt_i_st;
      nx_o_dht11   = O_DHT11;
      nx_o_busy    = O_BUSY;
nx_send      = send;
      nx_cnt_data  = cnt_data;
      nx_o_err     = O_ERR;
nx_o_value   = O_VALUE;
      nx_buff_data = buff_data;
      nx_o_conv    = O_CONV;
      nx_cnt_line  = cnt_line;
if (I_ST)
        begin   
          case (st)
             IDLE     : begin
                          nx_cnt_i_st = cnt_i_st + 1'b1;
nx_cnt_line = {CNT_LINE_SZ{1'b0}};
                          nx_send = 1'b0;
                          
                          // --- DÜZELTME BURADA ---
                          // O_CONV sinyalini '0'a çek ki bir sonraki
                          // yükselen kenarı algılayabilelim.
                          nx_o_conv = 1'b0; 
                          // ---------------------
                          
                          if (cnt_i_st == IDLE_V - 1'b1)
                            begin
                              nx_cnt_i_st = {CNT_I_ST_SZ{1'b0}};
nx_o_busy = 1'b0;
                              nx_st = READY;
                            end
                        end
             READY    : begin
                          // if (I_EN)  <-- KOŞUL KALDIRILDI, OTOMATİK BAŞLATMA AKTİF
                 
       
                             begin
                              nx_o_dht11 = 1'b0;
nx_o_busy = 1'b1;
                              nx_o_err = 1'b0;
                              nx_st = MSTR_LW; 
                            end
                        end
             MSTR_LW  : begin
                          nx_cnt_line = cnt_line + 1'b1;
if (cnt_line == MSTR_LW_V - 1'b1)
                            begin
                              nx_cnt_line = {CNT_LINE_SZ{1'b0}};
nx_o_dht11 = 1'b1;
                              nx_st = MSTR_HG;
                            end
                        end  
             MSTR_HG  : begin
                          nx_cnt_line = cnt_line + 1'b1;
if (cnt_line == MSTR_HG_V - 1'b1)
                            begin
                              nx_cnt_line = {CNT_LINE_SZ{1'b0}};
nx_st = SLV_LW;
                            end
                        end              
             SLV_LW   : begin
                          nx_cnt_i_st = cnt_i_st + 1'b1;
if (cnt_i_st == IDLE_V - 1'b1)
                            begin
                              nx_cnt_i_st = {CNT_I_ST_SZ{1'b0}};
nx_o_busy = 1'b0;
                              nx_o_err = 1'b1;
                              nx_st = READY;
                            end
                          if (I_RIS)
                            begin
                              nx_st = SLV_HG;
end
                        end
             SLV_HG   : begin
                          if (I_FALL)
                            begin
    

                              nx_cnt_data = DATA_SZ - 1'b1;
nx_buff_data = {DATA_SZ{1'b1}};
                              nx_st = DATA_TR;
                            end
                        end             
             DATA_TR  : begin   
                          if (!send)
           

                            begin
                              if (I_RIS) 
                                nx_send = 1'b1;
end
                          else
                            begin
                              nx_cnt_line = cnt_line + 1'b1;
if (I_FALL)
                                begin
                                  nx_cnt_data = cnt_data - 1'b1;
nx_cnt_line = {CNT_LINE_SZ{1'b0}};
                                  nx_send = 1'b0;
                                  if (cnt_line < SEND_1)
                                    nx_buff_data = {buff_data[DATA_SZ-2:0], 1'b0};
else 
                                    nx_buff_data = {buff_data[DATA_SZ-2:0], 1'b1};
end                            
                            end
                          if (&(!cnt_data) && I_FALL) 
              

                            begin
                              nx_cnt_data = DATA_SZ - 1'b1;
nx_cnt_line = {CNT_LINE_SZ{1'b0}};
                              nx_o_dht11 = 1'b0;
                              nx_st = STOP;
                            end                         
                        end             
             STOP     : begin
          

                          nx_cnt_line = cnt_line + 1'b1;
if (buff_data[4*BYTE_SZ+:BYTE_SZ] + buff_data[3*BYTE_SZ+:BYTE_SZ] +
                              buff_data[2*BYTE_SZ+:BYTE_SZ] + buff_data[BYTE_SZ+:BYTE_SZ] == buff_data[BYTE_SZ-1:0])
                            begin
                              nx_o_err = 1'b0;
nx_o_value = {buff_data[4*BYTE_SZ+:BYTE_SZ], buff_data[2*BYTE_SZ+:BYTE_SZ]};
                              nx_o_conv = 1'b1; // Sinyali '1' yap
                            end
                          else
                            begin
                              nx_o_value = {VALUE_SZ{1'b0}};
nx_o_err = 1'b1;
                              nx_o_conv = 1'b0;
                            end   
                          if (cnt_line == MSTR_LW_ST - 1'b1)
                            begin
                              nx_o_dht11 = 

                              1'b1;
nx_st = IDLE;
                            end
                        end
             default  : begin
                          nx_st = IDLE;
nx_cnt_i_st = {CNT_I_ST_SZ{1'b0}};
                          nx_o_dht11 = 1'b1;
                          nx_o_busy = 1'b0;
                          nx_send = 1'b0;
                          nx_cnt_line = {CNT_LINE_SZ{1'b0}};
end
          endcase
        end
    end

//  latching the next state of FSM and signals, every clock
    always @(posedge CLK or negedge RST_n) begin
      if (!RST_n)
        begin
          st       <= IDLE;
cnt_i_st <= {CNT_I_ST_SZ{1'b0}};
          O_DHT11  <= 1'b1;        
          O_BUSY   <= 1'b1;  
          O_ERR    <= 1'b0;
O_VALUE  <= {VALUE_SZ{1'b0}};
          O_CONV   <= 1'b0;
        end
      else if (I_ST)
        begin
          st       <= nx_st;
cnt_i_st <= nx_cnt_i_st;
          O_DHT11  <= nx_o_dht11;
          O_BUSY   <= nx_o_busy;
          O_ERR    <= nx_o_err;
O_VALUE  <= nx_o_value;
          O_CONV   <= nx_o_conv;
        end
    end
    always @(posedge CLK) begin
      cnt_line     <= nx_cnt_line;
send         <= nx_send;
      cnt_data     <= nx_cnt_data;
buff_data    <= nx_buff_data;
    end  
    
  
endmodule