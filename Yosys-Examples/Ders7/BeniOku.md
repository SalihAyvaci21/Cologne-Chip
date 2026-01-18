# **Counter_LED**

**Görev Tanımı:**  
FPGA üzerinde LED dizisini **ileri-geri chase (kayma)** efektinde kontrol etmek. Default modda LED’ler **1 saniye arayla** yanıp söner. Push-button ile debounce IP core kullanılarak hız modları değiştirilir:

- **1 saniye**
- **1. Basış → 0.5 saniye**
- **2. Basış → 0.25 saniye**
- **3. Basış → tekrar 1 saniye**
    

---

## 🎯 **Amaç**

- Clock divider (clock bölücü) mantığını öğrenmek
- LED dizisinde ileri-geri chase efekti uygulamak
- Butonla **çoklu hız kontrolü** sağlamak
- Debounce IP core ile buton gürültüsünü temizlemek
- Tek pulse üretip kontrol işlevi sağlamak

---

## Algoritma Adımları

1. **Debounce IP Core**
    
    - Butonun mekanik sıçramalarını engellemek için debounce modülü kullanıldı.
        
    - `out_valid` sinyali ile her butona basışta tek pulse üretilir.
        
2. **Hız Modu (Speed Mode)**
    
    - 0 → 1 saniye
    - 1 → 0.5 saniye
    - 2 → 0.25 saniye
    - Butona her basıldığında mod 0 → 1 → 2 → 0 olarak döngü yapar.
    
3. **Clock Divider**
    
    - Sayaç ile seçilen moda göre clock pulse üretilir.
    - Pulse geldiğinde LED kayma işlemi yapılır.
    
4. **LED Chase İleri-Geri**
    
    - `led_index` aktif LED konumunu belirler.
    - `dir` yön bilgisini tutar (0=ileri, 1=geri).
    - LED en sağa ulaştığında geri döner, en sola geldiğinde tekrar ileri gider.

---

## 📂 Proje Yapısı

counter_led/  
│── log/ # Log kayıtları  
│── net/ # Sentez sonucu netlist dosyaları  
│── sim/ # Testbench dosyaları (Icarus Verilog / iverilog için)  
│── src/ # Kaynak kodlar (.v / .vhd) + .ccf constraints dosyaları  
│── Makefile # Build ayarları  
│── run.bat # Çalıştırma scripti

**Not:**

- `Makefile` içindeki `TOP` değişkeni **top modul** ismiyle aynı olmalıdır.
- `.ccf` dosyası da top modul ismiyle birebir aynı olmalıdır.

---

## ⚙️ Makefile İçeriği

include ../config.mk

TOP = Counter_led

PRFLAGS += -ccf src/$(TOP).ccf -cCP


---

## ⚡ Run.bat İçeriği

:: toolchain
set YOSYS=../../bin/yosys/yosys.exe
set PR=../../bin/p_r/p_r.exe
set OFL=../../bin/openFPGALoader/openFPGALoader.exe

:: project name and sources
set TOP=Counter_led
set SRC=src/Counter_led.v src/debounce_ip_core.v
set VHDL_SRC=
set LOG=0


---

## 💡 Örnek Kod: Counter_led

`timescale 1ns / 1ps
// DEMSAY ELEKTRONİK - ARGE
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module Counter_led (
    input  wire clk,           // 10 MHz sistem clock girişi
    input  wire rst,           // reset (aktif düşük) sinyali
    input  wire push_button,   // hız değiştirmek için buton girişi
    output reg  [7:0] led_out  // 8-bit LED çıkışı (aktif düşük LED’ler)
);
    ...
endmodule


![[Counter_led.v]]

---

## 📌 Constraints Dosyası (`.ccf`)

**Clock input (e.g., 10 MHz from onboard oscillator)**
Net "clk"         Loc = "IO_SB_A8";      # Clock pin

**Push-button input (SW3)**
Net "push_button" Loc = "IO_EB_B0";      # Active-low mechanical button

**8-bit active-low LED outputs**
Net "led_out[0]"  Loc = "IO_EB_B1";      # D1
Net "led_out[1]"  Loc = "IO_EB_B2";      # D2
Net "led_out[2]"  Loc = "IO_EB_B3";      # D3
Net "led_out[3]"  Loc = "IO_EB_B4";      # D4
Net "led_out[4]"  Loc = "IO_EB_B5";      # D5
Net "led_out[5]"  Loc = "IO_EB_B6";      # D6
Net "led_out[6]"  Loc = "IO_EB_B7";      # D7
Net "led_out[7]"  Loc = "IO_EB_B8";      # D8

![[Counter_led.ccf]]
