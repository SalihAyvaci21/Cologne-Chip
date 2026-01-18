`timescale 1ns / 1ps

module sine_gen (
    input wire clk,           // Clock input (100 MHz)
    input wire reset,         // Reset signal
    output reg [7:0] sine_out // 8-bit sine wave output
);

    reg [7:0] sine_lut [0:255]; // 256-point lookup table
    reg [7:0] lut_index = 0;   
    
    // Yeni sayaç genişliği: 39061 değerini tutmak için [15:0] yeterli (2^16 = 65536)
    reg [15:0] clk_divider = 0; 
    
    // YENİ EŞİK: 10 Hz sinüs frekansı için 39061 (100_000_000 / 256 / 10 - 1)
    parameter CLK_DIVIDER_MAX = 39061; 
    
    // the lookup table with precomputed sine wave values
    initial begin
        sine_lut[0] = 128;
        sine_lut[1] = 131;
        sine_lut[2] = 134;
        sine_lut[3] = 137;
        sine_lut[4] = 140;
        sine_lut[5] = 143;
        sine_lut[6] = 146;
        sine_lut[7] = 149;
        sine_lut[8] = 152;
        sine_lut[9] = 155;
        sine_lut[10] = 158;
        sine_lut[11] = 162;
        sine_lut[12] = 165;
        sine_lut[13] = 167;
        sine_lut[14] = 170;
        sine_lut[15] = 173;
        sine_lut[16] = 176;
        sine_lut[17] = 179;
        sine_lut[18] = 182;
        sine_lut[19] = 185;
        sine_lut[20] = 188;
        sine_lut[21] = 190;
        sine_lut[22] = 193;
        sine_lut[23] = 196;
        sine_lut[24] = 198;
        sine_lut[25] = 201;
        sine_lut[26] = 203;
        sine_lut[27] = 206;
        sine_lut[28] = 208;
        sine_lut[29] = 211;
        sine_lut[30] = 213;
        sine_lut[31] = 215;
        sine_lut[32] = 218;
        sine_lut[33] = 220;
        sine_lut[34] = 222;
        sine_lut[35] = 224;
        sine_lut[36] = 226;
        sine_lut[37] = 228;
        sine_lut[38] = 230;
        sine_lut[39] = 232;
        sine_lut[40] = 234;
        sine_lut[41] = 235;
        sine_lut[42] = 237;
        sine_lut[43] = 238;
        sine_lut[44] = 240;
        sine_lut[45] = 241;
        sine_lut[46] = 243;
        sine_lut[47] = 244;
        sine_lut[48] = 245;
        sine_lut[49] = 246;
        sine_lut[50] = 248;
        sine_lut[51] = 249;
        sine_lut[52] = 250;
        sine_lut[53] = 250;
        sine_lut[54] = 251;
        sine_lut[55] = 252;
        sine_lut[56] = 253;
        sine_lut[57] = 253;
        sine_lut[58] = 254;
        sine_lut[59] = 254;
        sine_lut[60] = 254;
        sine_lut[61] = 255;
        sine_lut[62] = 255;
        sine_lut[63] = 255;
        sine_lut[64] = 255;
        sine_lut[65] = 255;
        sine_lut[66] = 255;
        sine_lut[67] = 255;
        sine_lut[68] = 254;
        sine_lut[69] = 254;
        sine_lut[70] = 254;
        sine_lut[71] = 253;
        sine_lut[72] = 253;
        sine_lut[73] = 252;
        sine_lut[74] = 251;
        sine_lut[75] = 250;
        sine_lut[76] = 250;
        sine_lut[77] = 249;
        sine_lut[78] = 248;
        sine_lut[79] = 246;
        sine_lut[80] = 245;
        sine_lut[81] = 244;
        sine_lut[82] = 243;
        sine_lut[83] = 241;
        sine_lut[84] = 240;
        sine_lut[85] = 238;
        sine_lut[86] = 237;
        sine_lut[87] = 235;
        sine_lut[88] = 234;
        sine_lut[89] = 232;
        sine_lut[90] = 230;
        sine_lut[91] = 228;
        sine_lut[92] = 226;
        sine_lut[93] = 224;
        sine_lut[94] = 222;
        sine_lut[95] = 220;
        sine_lut[96] = 218;
        sine_lut[97] = 215;
        sine_lut[98] = 213;
        sine_lut[99] = 211;
        sine_lut[100] = 208;
        sine_lut[101] = 206;
        sine_lut[102] = 203;
        sine_lut[103] = 201;
        sine_lut[104] = 198;
        sine_lut[105] = 196;
        sine_lut[106] = 193;
        sine_lut[107] = 190;
        sine_lut[108] = 188;
        sine_lut[109] = 185;
        sine_lut[110] = 182;
        sine_lut[111] = 179;
        sine_lut[112] = 176;
        sine_lut[113] = 173;
        sine_lut[114] = 170;
        sine_lut[115] = 167;
        sine_lut[116] = 165;
        sine_lut[117] = 162;
        sine_lut[118] = 158;
        sine_lut[119] = 155;
        sine_lut[120] = 152;
        sine_lut[121] = 149;
        sine_lut[122] = 146;
        sine_lut[123] = 143;
        sine_lut[124] = 140;
        sine_lut[125] = 137;
        sine_lut[126] = 134;
        sine_lut[127] = 131;
        sine_lut[128] = 128;
        sine_lut[129] = 124;
        sine_lut[130] = 121;
        sine_lut[131] = 118;
        sine_lut[132] = 115;
        sine_lut[133] = 112;
        sine_lut[134] = 109;
        sine_lut[135] = 106;
        sine_lut[136] = 103;
        sine_lut[137] = 100;
        sine_lut[138] = 97;
        sine_lut[139] = 93;
        sine_lut[140] = 90;
        sine_lut[141] = 88;
        sine_lut[142] = 85;
        sine_lut[143] = 82;
        sine_lut[144] = 79;
        sine_lut[145] = 76;
        sine_lut[146] = 73;
        sine_lut[147] = 70;
        sine_lut[148] = 67;
        sine_lut[149] = 65;
        sine_lut[150] = 62;
        sine_lut[151] = 59;
        sine_lut[152] = 57;
        sine_lut[153] = 54;
        sine_lut[154] = 52;
        sine_lut[155] = 49;
        sine_lut[156] = 47;
        sine_lut[157] = 44;
        sine_lut[158] = 42;
        sine_lut[159] = 40;
        sine_lut[160] = 37;
        sine_lut[161] = 35;
        sine_lut[162] = 33;
        sine_lut[163] = 31;
        sine_lut[164] = 29;
        sine_lut[165] = 27;
        sine_lut[166] = 25;
        sine_lut[167] = 23;
        sine_lut[168] = 21;
        sine_lut[169] = 20;
        sine_lut[170] = 18;
        sine_lut[171] = 17;
        sine_lut[172] = 15;
        sine_lut[173] = 14;
        sine_lut[174] = 12;
        sine_lut[175] = 11;
        sine_lut[176] = 10;
        sine_lut[177] = 9;
        sine_lut[178] = 7;
        sine_lut[179] = 6;
        sine_lut[180] = 5;
        sine_lut[181] = 5;
        sine_lut[182] = 4;
        sine_lut[183] = 3;
        sine_lut[184] = 2;
        sine_lut[185] = 2;
        sine_lut[186] = 1;
        sine_lut[187] = 1;
        sine_lut[188] = 1;
        sine_lut[189] = 0;
        sine_lut[190] = 0;
        sine_lut[191] = 0;
        sine_lut[192] = 0;
        sine_lut[193] = 0;
        sine_lut[194] = 0;
        sine_lut[195] = 0;
        sine_lut[196] = 1;
        sine_lut[197] = 1;
        sine_lut[198] = 1;
        sine_lut[199] = 2;
        sine_lut[200] = 2;
        sine_lut[201] = 3;
        sine_lut[202] = 4;
        sine_lut[203] = 5;
        sine_lut[204] = 5;
        sine_lut[205] = 6;
        sine_lut[206] = 7;
        sine_lut[207] = 9;
        sine_lut[208] = 10;
        sine_lut[209] = 11;
        sine_lut[210] = 12;
        sine_lut[211] = 14;
        sine_lut[212] = 15;
        sine_lut[213] = 17;
        sine_lut[214] = 18;
        sine_lut[215] = 20;
        sine_lut[216] = 21;
        sine_lut[217] = 23;
        sine_lut[218] = 25;
        sine_lut[219] = 27;
        sine_lut[220] = 29;
        sine_lut[221] = 31;
        sine_lut[222] = 33;
        sine_lut[223] = 35;
        sine_lut[224] = 37;
        sine_lut[225] = 40;
        sine_lut[226] = 42;
        sine_lut[227] = 44;
        sine_lut[228] = 47;
        sine_lut[229] = 49;
        sine_lut[230] = 52;
        sine_lut[231] = 54;
        sine_lut[232] = 57;
        sine_lut[233] = 59;
        sine_lut[234] = 62;
        sine_lut[235] = 65;
        sine_lut[236] = 67;
        sine_lut[237] = 70;
        sine_lut[238] = 73;
        sine_lut[239] = 76;
        sine_lut[240] = 79;
        sine_lut[241] = 82;
        sine_lut[242] = 85;
        sine_lut[243] = 88;
        sine_lut[244] = 90;
        sine_lut[245] = 93;
        sine_lut[246] = 97;
        sine_lut[247] = 100;
        sine_lut[248] = 103;
        sine_lut[249] = 106;
        sine_lut[250] = 109;
        sine_lut[251] = 112;
        sine_lut[252] = 115;
        sine_lut[253] = 118;
        sine_lut[254] = 121;
        sine_lut[255] = 124;
    end

    // Clock divider to generate a 10 Hz sine wave
    always @(posedge clk) begin
        if (~reset) begin
            clk_divider <= 0;
            lut_index <= 0;
        end else begin
            if (clk_divider == CLK_DIVIDER_MAX) begin // YENİ EŞİK
                clk_divider <= 0;
                lut_index <= lut_index + 1;  // Move to the next sine wave point
            end else begin
                clk_divider <= clk_divider + 1;
            end
        end
    end

    // Output the sine wave value from the LUT
    always @(posedge clk) begin
        if (~reset) begin
            sine_out <= 8'd128;
        end else begin
            sine_out <= sine_lut[lut_index];
        end
    end

endmodule