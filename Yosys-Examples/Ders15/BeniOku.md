# **UART Hesap Makinesi**

### 🎯 Amaç

Bu proje, FPGA üzerinde basit bir **UART tabanlı hesap makinesi** uygulamasıdır.  
Kullanıcı, terminal (ör. PuTTY) üzerinden iki sayı ve işlem sembollerini gönderir:

`a + b =`

FPGA bu verileri alır, **toplama işlemini** gerçekleştirir ve sonucu tekrar UART üzerinden geri gönderir.

Örn:

`46+12=  ---> FPGA ---> 58`

---

### ⚙️ Algoritma

1. **UART RX**  
    PC’den gelen seri veri, `receiver` modülü ile 8-bit ASCII byte’a çevrilir (`rx_byte`, `rx_dv`).
    
2. **FSM (Finite State Machine)**
    
    - Sayı 1 okunur (ör. `46` → `a_val` içine).
    - `+` karakteri gelince ikinci sayıya geçilir.
    - Sayı 2 okunur (ör. `12` → `b_val` içine).
    - `=` karakteri geldiğinde `sum = a_val + b_val` hesaplanır.

3. **UART TX**  
    Sonuç sayısı **ASCII karakterlere bölünerek** `transmitter` modülü ile tekrar PC’ye gönderilir.
    
    - Tek haneli sonuç → `"5"`
    - İki haneli sonuç → `"58"`

---

### 📂 Proje Yapısı

UART_HesapMakinesi/
│── src/                  # Kaynak kodlar
│   ├── uart_hesap_makinesi.v
│   ├── receiver.v
│   ├── transmitter.v
│── sim/                  # Simülasyon dosyaları
│   ├── uart_hesap_makinesi_tb.v
│── doc/                  # Dokümantasyon, görseller
│── Makefile / .do file   # (opsiyonel) simülasyon/derleme ayarları


---

### 🔧 Donanım Bağlantısı (Constraint File)

 <p align="center">
<img src="Images/UART_Schema.drawio.png" style="display: block; margin: auto;">
<br>
</p>

 <p align="center">
<img src="Images/Whatsapp Image.jpeg" style="display: block; margin: auto;">
<br>
</p>

  <p align="center">
<a href="Uart-Calculator/src/uart_hesap_makinesi.ccf">
<em style="display:flex;justify-content:center">Constraint kod görüntüsü</em>
</a>	
</p>



⚠️ FT232H üzerinden bağlanırken TX ↔ RX çapraz bağlamayı unutma.

---

### 🧪 Testbench

Projeye ait **testbench** ile simülasyon yapılabilir:
 <p align="center">
<a href="Uart-Calculator/sim/iverilog/uart_hesap_makinesi_tb.v">
<em style="display:flex;justify-content:center">testbench kod görüntüsü</em>
</a>	
</p>

// Gönderilecek string: "46+12="
uart_send_byte("4");
uart_send_byte("6");
uart_send_byte("+");
uart_send_byte("1");
uart_send_byte("2");
uart_send_byte("=");

Beklenen çıktı:

`58`

📊 Simülasyonda izlenmesi gereken sinyaller:

- `rx_serial` → PC’den gelen UART
- `rx_byte` → alınan ASCII karakter
- `a_val`, `b_val`, `sum` → sayısal değerler
- `uart_tx` → FPGA’dan geri gönderilen veri
- `tx_byte`, `tx_dv`, `tx_done`
    

---

### 🖥️ Terminal Testi (PuTTY / YAT)

1. FPGA’yı PC’ye bağla (USB–UART).
2. Terminal programı ayarları:
    - **115200 baud**
3. Örnek:
    `Input  → 46+12= Output → 58`

 <p align="center">
<img src="Images/2025-10-03 16-44-23.gif" style="display: block; margin: auto;">
<br>
</p>

---

### ✅ Sonuç

Bu proje ile UART üzerinden **tam sayıları toplayan basit bir hesap makinesi** FPGA üzerinde başarıyla gerçekleştirildi.  
Proje, UART haberleşmesi, FSM tasarımı ve ASCII ↔ decimal dönüşümleri konusunda öğretici bir uygulamadır.
