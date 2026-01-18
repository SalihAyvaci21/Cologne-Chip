FPGA Verilog Çalışmaları

Açıklama:
Bu repo, FPGA üzerinde Verilog tasarımları ve çeşitli LED kontrol uygulamalarını içermektedir.
Projeler Yosys (RTL sentez), Cologne Chip P&R (place & route) ve openFPGALoader (FPGA’ya yükleme) toolchain’i ile geliştirilmiştir.

🎯 Amaç

FPGA üzerinde temel Verilog projeleri geliştirmek

Yosys & Cologne Chip toolchain kullanımını öğrenmek

Clock divider, debounce, LED chase efektleri gibi temel FPGA kavramlarını uygulamalı çalışmak

Açık kaynak donanım geliştirme pratiği kazanmak

⚙️ Kullanılan Toolchain

Projeler aşağıdaki açık kaynak araçlarla geliştirilmiştir:

Yosys
 → RTL sentez

Cologne Chip P&R
 → Place & Route

openFPGALoader
 → FPGA’ya bitstream yükleme

Not: Her alt projede Makefile ve run.bat ile otomatik build ve yükleme scriptleri yer almaktadır.

📂 Repo Yapısı
fpga-verilog-examples/
│── README.md              # Ana açıklama (bu dosya)
│── LICENSE                # Lisans (MIT)
│── .gitignore             # Geçici dosyalar
│
│── counter_led/           # LED ileri-geri chase + hız kontrolü
│   │── src/               # Kaynak kodlar
│   │── sim/               # Testbench dosyaları
│   │── log/               # Log kayıtları
│   │── net/               # Netlist dosyaları
│   │── Makefile
│   │── run.bat
│   │── README.md
│
│── chase_toggle/          # LED chase & toggle modu
│   │── src/
│   │── sim/
│   │── ...

🚀 Projeler
🔹 Counter_led

LED’ler ileri-geri chase efekti ile yanar.

Buton ile hız değiştirilir: 1s → 0.5s → 0.25s → tekrar 1s.

Debounce IP core kullanılmıştır.

🔹 Chase&Toggle

Default modda LED’ler ileri-geri yanıp söner.

Butona basıldığında toggle moda geçilir ve tüm LED’ler açılır/kapanır.

▶️ Çalıştırma

Yosys, CologneChip toolchain ve openFPGALoader kurulu olmalıdır.

İlgili projeye girin (örn: cd counter_led/)

Aşağıdaki komutla sentez ve yükleme yapın:

make


ya da Windows için:

run.bat

📜 Lisans

Bu repo MIT Lisansı ile açık kaynak olarak paylaşılmıştır.
