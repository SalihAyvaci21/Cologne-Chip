# **Uart Tx Led**

**Görev Tanımı:**  
Bu proje, **push button ile LED’leri kontrol eden bir sayaç** ve **UART transmitter ile LED durumunu bilgisayara gönderen bir sistem** içerir.  
Her buton basıldığında LED’ler aktif düşük olarak yanar ve **yandığı LED sayısı UART üzerinden ASCII formatında gönderilir**.

---

## 🎯 **Amaç**

- **LED kontrolü (aktif düşük)** → butona basıldıkça LED’lerin sırası değişir.
- **UART transmitter** ile LED sayısını bilgisayara göndermek.
- FSM ile **UART gönderim sürecini kontrol etmek**.
- Aktif düşük LED mantığında, **yanan LED sayısını doğru saymak**.

---

## **Algoritma**

### 1️⃣ Başlatma

- `rst_n = 0` olduğunda sistem sıfırlanır.
- LED’ler başlangıç değerine alınır (`8’hFF` = hepsi sönük).

### 2️⃣ LED Kontrol

- `led_bounce_up_down_counter` modülü, butona basıldıkça LED desenini değiştirir.
- LED çıkışı aktif düşük olduğundan, `0` bit = LED yanıyor.

### 3️⃣ Yanan LED Sayısını Bulma

- `count_leds` fonksiyonu, `led_out` üzerinde kaç tane `0` olduğunu sayar.
- Bu sayı ASCII’ye çevrilir (`8’h30 + count`).

### 4️⃣ UART Gönderimi

- Eğer `led_out` değişirse:
    - `tx_byte` = ASCII sayı atanır
    - `tx_dv = 1` yapılarak transmitter başlatılır
- UART transmitter `tx_done = 1` sinyali verdiğinde işlem tamamlanır.

---

## 🔧 Kullanım

- FPGA üzerinde butona bas → LED’ler değişir.
- Yanan LED sayısı (aktif düşük) UART üzerinden ASCII karakter olarak bilgisayara gönderilir.
- Örnek: 3 LED yanıyorsa → UART üzerinden `'3'` (ASCII 0x33) gönderilir.

---

## 📂 Proje Yapısı

Uart_Tx_Led/  
│── src/ # Kaynak kod (.v)  
│── sim/ # Testbench dosyaları  
│── log/ # Simülasyon kayıtları  
│── Makefile # Build ayarları

---

## 💡 Kod Yapısı

### Kullanılan Modüller

1. **`led_bounce_up_down_counter`**
    
    - Push button girişine göre LED desenini değiştirir.
    <a href="src/led_bounce_up_down_counter.v"><em>led_bounce_up_down_counter.v</em></a>

1. **`transmitter` (UART TX)**
    - `tx_dv` ve `tx_byte` girişleri ile başlatılır.
    - `tx_done` çıktısı ile gönderimin tamamlandığını bildirir.
    - `CLKS_PER_BIT = 87` → 10 MHz / 115200 baud.
    <a href="src/transmitter.v"><em>transmitter.v</em></a>

2. **`top_uart_led`**
    - LED sayaç + UART transmitter entegrasyonu.
    - LED sayısını hesaplar ve UART üzerinden gönderir.
<a href="src/top_uart_led.v"><em>top_uart_led.v</em></a>

---

### ⚡ Özet Akış

| Adım | İşlem                                             |
| ---- | ------------------------------------------------- |
| 1    | Reset sonrası LED başlangıç konumu atanır         |
| 2    | Buton ile LED deseni değişir                      |
| 3    | LED sayısı hesaplanır (`count_leds`)              |
| 4    | Sayı ASCII formatına çevrilip UART ile gönderilir |
| 5    | UART `tx_done` → FSM tekrar LED değişimi bekler   |

---

## 🔍 Beklenen Simülasyon

- **LED Çıkışı (led_out):** Butona bastıkça değişir.
- **UART TX (uart_tx):**
    - İlk buton → `'1'` gönderilir.
    - İkinci buton → `'2'` gönderilir.
    - Üçüncü buton → `'3'` gönderilir.
- GTKWAVE’de `uart_tx` sinyalini incelersen, 115200 baud hızında bit akışı görürsün.

	
