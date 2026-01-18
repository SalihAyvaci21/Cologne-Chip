# Verilog RGB LED Sequencer (FSM)

Bu proje, bir FPGA üzerinde çalışan ve bir RGB LED'i önceden tanımlanmış 6 farklı renkte sırayla yakan bir FSM (Finite State Machine - Sonlu Durum Makinesi) tasarımıdır.

Tasarım rgb_sequencer_top.v adlı bir üst modül ve `RGBLed` adlı bir PWM (Pulse Width Modulation) alt modülünden oluşur.

## Özellikler

* Verilog HDL ile yazılmıştır.
* 6 Durumlu FSM (Kırmızı, Yeşil, Mavi, Mor, Sarı, Macenta).
* Ayarlanabilir durum geçiş süresi (Varsayılan: 1 saniye).
* `RgbLed` alt modülü ile 24-bit renk girişi üzerinden PWM kontrollü LED sürüşü .
* Aktif-düşük reset (`n_rst`) desteği.

## Modül Hiyerarşisi

* <a href="RGBLed/src/rgb_sequencer_top.v"><em> rgb_sequencer_top.v</em> </a>: Ana modül. FSM mantığını ve 1 saniyelik zamanlayıcıyı içerir.
* <a href="RGBLed/src/RGBLed.v"><em> RGBLed.v</em> </a>: 24-bit RGB renk kodunu alıp LED'ler için PWM sinyallerini dönüştüren alt modül.
* <a href="RGBLed\sim\iverilog"><em> rgb_sequencer_top_tb.v</em> </a>: Ana modül için testbench dosyası.

## 📂 Proje Dosya Yapısı ``` RGB_LED_Sequencer/ │ RGB_LED_Sequencer/
│
├── REGBLED
│		src/                  # Verilog kaynak kodları
│   ├── rgb_sequencer_top.v # Ana (Top) modül
│   ├── RGBLed.v            # RGB PWM sürücü modülü
│   └── rgb_sequencer_top.ccf # FPGA pin tanımlamaları
│
├── sim/iverilog
│   └── rgb_sequencer_top_tb.v # Testbench (simülasyon dosyası)
│
├── Images/               # Simülasyon ve çalışma görselleri
│   ├── iverilog-photo.png
│   ├── gtkwave.png
│   └── video.gif
│
└── README.md
## Çalışma Mantığı

Tasarım, `rgb_sequencer_top` modülü içindeki bir FSM tarafından yönetilir.

1.  Sisteme reset (`n_rst` = 0) uygulandığında, FSM `S_RED` durumuna geçer ve `current_rgb` register'ına `COLOR_RED` (24'hFF0000)  değerini yükler.
2.  Reset bırakıldığında (`n_rst` = 1), `timer_reg` sayacı her saat darbesinde (`clk`) artmaya başlar.
3.  Sayaç, `ONE_SECOND_COUNT - 1` değerine (10MHz saat için 9,999,999) ulaştığında, `timer_tick` sinyali bir darbe için '1' olur.
4.  Bu `timer_tick` sinyali, FSM'nin bir sonraki duruma geçmesini tetikler (örneğin `S_RED` -> `S_GREEN`) ve `current_rgb` değeri yeni renkle güncellenir.
5.  Döngü (Kırmızı -> Yeşil -> Mavi -> Mor -> Sarı -> Macenta -> Kırmızı)  bu şekilde sonsuza kadar devam eder.

---

## Yapılandırma: Geçiş Süresini 1 Saniyeye Ayarlama

Projenin renkler arasında ne kadar süre bekleyeceği, `rgb_sequencer_top.v` dosyasındaki **tek bir parametre** ile belirlenir:

```verilog
// --- Parametreler (10MHz) ---
localparam CLK_FREQ_HZ      = 10_000_000; 
localparam ONE_SECOND_COUNT = CLK_FREQ_HZ; 
```

Geçiş süresinin tam olarak **1 saniye** olması için, `CLK_FREQ_HZ` parametresinin, FPGA'nıza gelen saat sinyalinin frekansıyla (Hz cinsinden) **tam olarak eşleşmesi** gerekir.

* **10 MHz Saat Kullanıyorsanız (Varsayılan):**
    `localparam CLK_FREQ_HZ = 10_000_000;`
    Bu ayar, sayacın 10 milyon darbe saymasını (10,000,000 / 10,000,000 Hz = 1 saniye) sağlar.

* **27 MHz Saat Kullanıyorsanız:**
    `CLK_FREQ_HZ` değerini `27_000_000` olarak değiştirmeniz gerekir.
    `localparam CLK_FREQ_HZ = 27_000_000;`
    Bu ayar, sayacın 27 milyon darbe saymasını (27,000,000 / 27,000,000 Hz = 1 saniye) sağlar.

`ONE_SECOND_COUNT` parametresi zaten `CLK_FREQ_HZ`'ye eşitlendiği için başka bir değişiklik yapmanıza gerek yoktur.

---

## Simülasyon (Testbench)

Proje, `tb_rgb_sequencer_top.v` adlı bir testbench dosyası içerir. Bu testbench:
1.  10 MHz'lik bir saat sinyali (`CLK_PERIOD = 100ns`) üretir.
2.  Simülasyon başında `n_rst` sinyalini uygulayıp bırakır.
3.  FSM'nin (`state`) durumunu izler.
4.  FSM, `S_RED` (state 0) durumundan başlayıp tüm renkleri (1'den 5'e) gezdikten sonra `S_RED` (state 0) durumuna **ikinci kez** döndüğünde simülasyonu otomatik olarak durdurur.

![Simülasyon](Images/iverilog-photo.png)

### Testbench Görüntüleri

Aşağıda, GTKWave'de (veya benzeri bir dalga formu görüntüleyicide) 1 saniyelik ayar ile alınan simülasyon sonucu yer almaktadır. `DUT.state` sinyalinin her 1,000,000,000 ns (1 saniye) aralıkla değiştiği görülmektedir.


![Simülasyon Dalga Formu](Images/gtkwave.png)

---

## Uygulama ve Çalışma Görselleri

Tasarımın FPGA üzerinde çalışırken çekilmiş görüntüleri.
![FPGA Kırmızı LED](Images/video.gif)
## Pin Kısıtlamaları (Constraints)

Tasarım, (`.ccf` dosyasından) aşağıdaki pin kısıtlamaları ile test edilmiştir:

```verilog
# Clock input (10 MHz from onboard oscillator)
Net "clk"         LOC = "IO_SB_A8"; 

# Reset input (aktif düşük)
Net "n_rst"     LOC = "IO_EB_A0"; 

# RGB LED Çıkışları
Net "led_r"       LOC = "IO_NB_A5"; 
Net "led_g"       LOC = "IO_NB_A4"; 
Net "led_b"       LOC = "IO_NB_A6"; 
```

## 👤 Hazırlayan

Salih Tekin Ayvacı
Electrical & Electronics Engineer
