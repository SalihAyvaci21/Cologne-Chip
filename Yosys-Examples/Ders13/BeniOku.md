## UART RX LED Control

### 🎯 Amaç

Bu proje, UART üzerinden gelen seri veriye göre LED’lerin durumunu kontrol eder:

- **'1' (0x31) gönderildiğinde** → tüm LED’ler **sönük**
- **herhangi başka bir karakter geldiğinde** → tüm LED’ler **yanık**
LED’ler **aktif düşük** olarak bağlanmıştır (`0 = LED ON`, `1 = LED OFF`).

---

### ⚙️ Algoritma

1. UART üzerinden 1 byte alınır (`rx_byte`).
2. `rx_dv` (data valid) aktif olduğunda gelen byte kontrol edilir.
3. Eğer `'1' (0x31)` ise → `led_out = 8'b1111_1111` (tüm LED’ler OFF).
4. Değilse → `led_out = 8'b0000_0000` (tüm LED’ler ON).

---

### 📂 Proje Yapısı

Uart_rx_Led/  
│── src/ # Kaynak kod (.v)  
│── sim/ # Testbench dosyaları  
│── log/ # Simülasyon kayıtları  
│── Makefile # Build ayarları

---

### 🔧 Kullanım

1. PC’den FPGA’ya UART üzerinden veri gönder.
2. `'1'` gönderildiğinde LED’ler söner.
3. Başka bir karakter gönderildiğinde LED’ler yanar.

---

### 🖥️ Beklenen Simülasyon Çıktısı

>>> UART TX: '1'
LED Out = 11111111   // tüm LED’ler OFF
>>> UART TX: 'A'
LED Out = 00000000   // tüm LED’ler ON
>>> UART TX: '0'
LED Out = 00000000   // tüm LED’ler ON


GTKWAVE’de `rx_serial` hattında start, data, stop bitlerini ve `led_out` değişimini görebilirsin.
