# **Led Blink8_1**

**Görev Tanımı:**  
FPGA üzerinde temel LED yakma-söndürme pratiği yapmak. İlk olarak tek LED, ardından 8-bit LED dizisi kontrol edilecektir.

## 🎯  **Amaç**

- ToolChain kullanımını öğrenmek
- Bit seviyesinde LED kontrolünü öğrenmek
- Constraints dosyasıyla LED pinlerini tanımlamak
- Temel Verilog modül yapısına alışmak
- Buton gürültüsünü debouncer ile temizlemek
- Edge detect ile tek pulse üretip LED kontrolü sağlamak

---

## 📂 Proje Yapısı

Blink8_1/
│── log/      # Log kayıtları
│── net/      # Sentez sonucu netlist dosyaları
│── sim/      # Testbench dosyaları (Icarus Verilog / iverilog için)
│── src/      # Kaynak kodlar (.v / .vhd) + .ccf constraints dosyaları
│── Makefile  # Build ayarları
│── run.bat   # Çalıştırma scripti


 **Not:**

- `Makefile` içindeki `TOP` değişkeni **top modul** ismiyle aynı olmalıdır.
- `.ccf` dosyası da top modul ismiyle birebir aynı olmalıdır.

---

## ⚙️ Makefile İçeriği

include ../config.mk

PRFLAGS += -ccf src/$(TOP).ccf -cCP
TOP = Blink8_1


---

## ⚡ Run.bat İçeriği

@echo off

:: toolchain
set YOSYS=../../bin/yosys/yosys.exe
set PR=../../bin/p_r/p_r.exe
set OFL=../../bin/openFPGALoader/openFPGALoader.exe

:: project name and sources
set TOP=Blink8_1
set VLOG_SRC=src/Blink8_1.v
set LOG=0

:: Place&Route arguments
set PRFLAGS=--ccf src/%TOP%.ccf -cCP


 Eğer proje birden fazla dosyadan oluşuyorsa:

set VLOG_SRC=src/top.v src/ip_core.v src/ip_corex.v
set VHDL_SRC=src/top.vhd src/ip_core.vhd src/ip_corex.vhd


---

## ▶️ Kullanım

###  Sentez

`run.bat synth`

- FPGA kaynak dosyaları sentezlenir.
- `net/` klasöründe sentez sonrası **netlist** dosyaları oluşur.
- Kullanılan LUT’lar, flip-flop’lar gibi kaynak bilgileri buradan görülebilir.

###  Implementasyon

`run.bat impl`

- Implementasyon başlar.
- `top_00.cfg` dosyası oluşur.
- Eğer hata alırsanız `log/` klasöründen hataları kontrol edin.

###  FPGA’ya Yükleme

- **JTAG ile:**
    
    run.bat jtag
	SW1 → 11XX
    ![[WhatsApp Image 2025-08-26 at 11.33.28 (1).jpeg]]
- **SPI ile:**
    
    `run.bat spi`
    
    SW1 → `01XX`
    ![[WhatsApp Image 2025-08-26 at 11.33.28.jpeg]]
- **Flash’a Yazmak (kalıcı):**
    
    `run.bat jtag-flash run.bat spi-flash`
    Flash yazımı tamamlandıktan sonra FPGA’yı resetleyin, kod otomatik başlatılır.

---

##  Örnek Kod: Blink8_1

`timescale 1ns / 1ps
// DEMSAY ELEKTRONİK - ARGE
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module Blink8_1(
    input  wire clk,          // 10 MHz sistem clock
    input  wire rst,          // reset (aktif düşük)
    input  wire push_button,  // buton girişi
    output reg  [7:0] led     // aktif-low LED çıkışları
);

    // ======================
    // Debounce Modülü
    // ======================
    wire debounced_button;
    wire out_valid;

    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000), // 10 MHz sistem clock
        .SHIFT_LEN(3),            // 3 bit filtre
        .IS_PULLUP(0)             // pull-down buton
    ) debounce_inst (
        .clk(clk),
        .push_button(push_button),
        .out_valid(out_valid),          // butona basıldığında pulse
        .debounced_button(debounced_button) // kararlı buton değeri
    );

    // ======================
    // PLL (10 MHz → 100 MHz)
    // ======================
    reg [26:0] counter;

    wire clk270, clk180, clk90, clk0, usr_ref_out;
    wire usr_pll_lock_stdy, usr_pll_lock;

    CC_PLL #(
        .REF_CLK("10.0"),
        .OUT_CLK("100.0"),
        .PERF_MD("ECONOMY"),
        .LOW_JITTER(1),
        .CI_FILTER_CONST(2),
        .CP_FILTER_CONST(4)
    ) pll_inst (
        .CLK_REF(clk), .CLK_FEEDBACK(1'b0), .USR_CLK_REF(1'b0),
        .USR_LOCKED_STDY_RST(1'b0), .USR_PLL_LOCKED_STDY(usr_pll_lock_stdy), .USR_PLL_LOCKED(usr_pll_lock),
        .CLK270(clk270), .CLK180(clk180), .CLK90(clk90), .CLK0(clk0), .CLK_REF_OUT(usr_ref_out)
    );

    // ======================
    // Sayaç
    // ======================
    always @(posedge clk0) begin
        if (!rst)
            counter <= 0;
        else
            counter <= counter + 1'b1;
    end

    // ======================
    // LED Kontrol
    // ======================
    always @(*) begin
        if (!rst) begin
            led = 8'b1111_1111;  // reset → hepsi sönük
        end else if (counter[26] == 1'b1) begin
            led = 8'b0000_0000;  // normal durumda → tüm LED yanık
        end else begin
            led = 8'b1111_1110;  // normal durumda → sadece LED0 yanık
        end
    end

endmodule


// ============================================================
// Açıklama:
// - Bu tasarımda PLL kullanılarak 10 MHz giriş clock 100 MHz'e çıkarıldı.
// - Sayaç sayesinde LED belirli aralıklarla yanıp söner.
// - Reset butonuna basıldığında sayaç sıfırlanır ve LED yeniden başlar.
// ============================================================


![[Blink8_1.v]]
 Bu örnek:

- FPGA üzerinde LED blink yapılmasını sağlar.
- Buton reset görevi görür.

---
## Constraints Dosyası (`.ccf`)

FPGA tasarımında **Verilog/VHDL kodunuzun sinyalleri**, donanımdaki gerçek pinlere bağlanmazsa LED’ler, butonlar veya UART gibi çevre birimleri çalışmaz.  
Bu eşleştirmeyi yapmak için **Constraint Configuration File (.ccf)** kullanılır.

###  Örnek: `Blink8_1.ccf`

 Clock input (e.g., 10 MHz from onboard oscillator)
Net "clk"         Loc = "IO_SB_A8";      # Clock pin

 Push-button input (SW3)
Net "push_button" Loc = "IO_EB_B0";      # Active-low mechanical button

 8-bit active-low LED outputs
Net "led_out[0]"  Loc = "IO_EB_B1";      # D1
Net "led_out[1]"  Loc = "IO_EB_B2";      # D2
Net "led_out[2]"  Loc = "IO_EB_B3";      # D3
Net "led_out[3]"  Loc = "IO_EB_B4";      # D4
Net "led_out[4]"  Loc = "IO_EB_B5";      # D5
Net "led_out[5]"  Loc = "IO_EB_B6";      # D6
Net "led_out[6]"  Loc = "IO_EB_B7";      # D7
Net "led_out[7]"  Loc = "IO_EB_B8";      # D8

![[Blink8_1.ccf]]
 
 Açıklamalar:

- `Net "clk"` → FPGA üzerindeki **sistem clock pinini** tanımlar (örneğin 10 MHz harici kristal).
- `Net "rst"` → Board üzerindeki **SW3 butonuna** bağlanır. Reset sinyali olarak kullanılır.
- `Net "led"` → FPGA üzerindeki **D1 LED çıkışına** bağlanır.

Burada isimlerin (`clk`, `rst`, `led`) **Verilog top module’deki port isimleriyle birebir aynı** olması gerekir.
