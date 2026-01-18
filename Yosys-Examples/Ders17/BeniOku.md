# ⚡ FPGA Sinüs Dalgası PWM - Faz Kaymalı “Kayan Işık” Efekti

### 🎓 **Verilog ile Donanımsal Sinüs PWM Deneyimi**

---

## 🎯 Proje Özeti

Bu proje, bir **FPGA üzerinde sinüs tabanlı PWM kontrolü** kullanarak  
8 adet LED üzerinde **“kayan ışık” (wave/chase)** efektini oluşturur.

Her LED’in parlaklığı, 256 adımlı bir **Sinüs Look-Up Table (LUT)**’tan alınır.  
100 MHz sistem saatinden üretilen yaklaşık **10 Hz’lik sinüs frekansı** sayesinde, LED’ler sinüs dalgasına uygun şekilde yumuşakça yanıp söner.  
Her LED 32 adımlık faz farkıyla ilerlediği için sistemde **dalga gibi akan bir ışık efekti** oluşur.

---

## 🧠 Proje Amaçları

✅ Verilog ile 8-bit çözünürlüklü bir **Sinüs LUT** tasarlamak  
✅ 100 MHz sistem saatinden **yavaş indeks üretmek (~10 Hz)**  
✅ 8 LED için **faz farkı (PHASE_SHIFT = 32)** uygulamak  
✅ Her LED’in parlaklığını **PWM duty cycle** üzerinden kontrol etmek  
✅ FPGA üzerinde **akıcı, senkronize bir ışık dalgası** oluşturmak

---

## ⚙️ Sistem Mimarisi

### 🟦 1. Ana İndeks Üreteci
<p><a href="sinüslü kayan ledler/src/sine_gen_index.v"><em> sine_gen_index.v</em> </a></p>
- 100 MHz saat sinyalini alır.
    
- `CLK_DIVIDER_MAX = 39061` değeriyle yaklaşık **10 Hz** hızında sayaç oluşturur.
    
- 0 – 255 arası `master_index` çıkışı üretir.
    
- Bu çıkış, LUT adreslemesinde temel alınır.
    

📈 **Zamanlama:**

`clk (100 MHz)  └──► clk_divider (0→39061)         └──► lut_index++ → master_index (0–255, 10 Hz)`

---

### 🟨 2. PWM Üreteci ve Faz Kaydırma
<p><a href="sinüslü kayan ledler/src/pwm_gen.v"><em> pwm_gen.v</em> </a></p>
#### 🔹 Sinüs LUT

256 noktalı, 8-bit genlik değerleri içeren LUT (0–255 arası).

#### 🔹 PWM Sayaç

100 MHz saat ile 0–255 arası sayar.  
Bu sayaç PWM sinyalinin frekansını belirler (~390 kHz).

#### 🔹 Faz Kaydırma

Her LED için LUT indeksi şu şekilde hesaplanır:

`index_i = master_index + (i * PHASE_SHIFT)`

Faz farkı = 32 adım.

#### 🔹 PWM Karşılaştırma

`if (pwm_counter < sine_value[i])      LED[i] = 1;  else      LED[i] = 0;`

#### 🔹 Çıkış İnvertörü

LED’ler **aktif-düşük** (active-low) olduğundan:

`assign led_pwm_out = ~led_pwm_out_reg;`

---

## 🔄 Çalışma Akışı

1. `reset` düşük → sayaçlar sıfır.
    
2. `reset` yüksek → sistem çalışmaya başlar.
    
3. `pwm_counter` hızlı sayarken, `master_index` yavaş artar.
    
4. Her LED’in parlaklığı sinüs tablosuna göre değişir.
    
5. Faz farkı sayesinde LED’ler birbirini takip eder.
    
6. Sonuç: **Dalga gibi akan ışık efekti.**
    

---

## 🔧 Donanım Bilgileri

| Bileşen              | Açıklama                                           |
| -------------------- | -------------------------------------------------- |
| **FPGA Kartı**       | GateMate ccgm1a1 EvaBoard V3.2A _(örnek uygulama)_ |
| **Sistem Saati**     | 10 MHz                                             |
| **Reset**            | Aktif-düşük (`IO_EB_B0`)                           |
| **Sinüs LUT Boyutu** | 256 örnek                                          |
| **PWM Frekansı**     | ≈ 390 kHz                                          |
| **Sinüs Frekansı**   | ≈ 10 Hz                                            |
| **PWM Çözünürlüğü**  | 8 bit                                              |
| **LED Sayısı**       | 8 (aktif-düşük)                                    |
| **Faz Kayması**      | 32 adım                                            |

---

## 🎬 Görseller ve Videolar

<p align="center">
<img src="Images/Kosan-Led-Gif.gif" style="display: block; margin: auto;">
</p>
---

## 🧪 Simülasyon Ortamı

- **Simülatör:** Icarus Verilog / GTKWave
    
- **Komutlar:**
    
    `iverilog -o sim_out src/*.v sim/tb_pwm_gen.v vvp sim_out gtkwave waveform.vcd`
    

---

## 🧑‍🔧 Geliştirici

**Salih Tekin Ayvacı**  
**DEMSAY ELEKTRONİK – AR-GE**  
