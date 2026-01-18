# **LED Brightness Toggle**

**Görev Tanımı:**  
Bu proje, **8-bit LED çıkışlarını PWM ile kontrol ederek parlaklık toggle** işlemi yapar.  
LED’ler başlangıçta %50 parlaklıkta yanar. **Butona basıldığında parlaklık %100’e çıkar**, tekrar basıldığında %50’ye geri döner.

---

## 🎯 **Amaç**

- PWM kullanarak LED parlaklığını kontrol etmek
- Buton girişleri ile parlaklığı toggle etmek
- **Debounce IP** kullanarak buton gürültüsünü önlemek
- FPGA üzerinde PWM sinyalini gözlemleyerek duty cycle etkisini anlamak


---

## **Algoritma**

### 1️⃣ Başlatma

1. FPGA resetlenir (`rst_n = 0`).
2. LED’ler başlangıçta **%50 parlaklıkta** yanar (`toggle = 0`).
3. PWM generator duty cycle hesaplanır: `duty = toggle ? 230 : 25`


---

### 2️⃣ Buton Tespiti ve Toggle

1. `debounce_ip_core` modülü buton sinyalini temizler ve `db_valid` ile **değişim anını bildirir**.
2. Eğer `db_valid = 1` olursa, `toggle` register tersine döner:
    - toggle = 0 → %50 parlaklık
    - toggle = 1 → %100 parlaklık

---

### 3️⃣ PWM Hesaplama

- `duty_reg` register’ı toggle durumuna göre güncellenir:
    - `%50` → 25/255 (8-bit çözünürlükte yaklaşık 50%)
    - `%100` → 230/255 (8-bit çözünürlükte yaklaşık 90–100%)
- `pwm_generator` modülü duty cycle değerine göre PWM sinyali üretir.
- PWM çıkışı `pwm_signal` tüm LED’lere uygulanır: `led_out = {8{pwm_signal}}`

---

### 4️⃣ LED Çıkışı

- Tüm LED’ler aynı PWM sinyali ile kontrol edilir.
- Duty cycle değiştikçe LED parlaklığı artar veya azalır.
- Butona her basışta LED’ler **toggle mantığıyla parlaklık değiştirir**.


---

## 🔧 Kullanım

- FPGA’ya programlama yapıldıktan sonra:
    1. Başlangıçta LED’ler %50 parlaklıkta yanar.
    2. Butona basıldığında LED parlaklığı %100 olur.
    3. Tekrar basıldığında %50 parlaklığa döner.

---

## 📂 Proje Yapısı

led_brightness_toggle/  
│── src/ # Kaynak kodlar (.v)  
│── sim/ # Testbench dosyaları  
│── log/ # Simülasyon logları  
│── Makefile # Build ayarları

---

## 💡 Kod Yapısı

### Kullanılan Modüller

1. **Debounce IP Core**
    - Buton girişlerini temizler ve değişim anını `db_valid` ile verir.
<a href="src/debounce_ip_core.v"><em>debounce_ip_core.v</em></a>

2. **PWM Generator**
    - 10 MHz sistem clock ve 1 kHz PWM frekansı ile LED’i kontrol eder.
    - Duty cycle register’ına göre çıkış sinyali üretir.
<a href="src/pwm_generator.v"><em>pwm_generator.v</em></a>

3. **Top Modül (`led_brightness_toggle`)**
    - Debounce ve PWM modüllerini birleştirir.
    - Toggle mantığı ile LED parlaklığını değiştirir.
<a href="src/led_brightness_toggle.v"><em>led_brightness_toggle.v</em></a>
---

### ⚡ Özet Akış

| Adım | İşlem                                        |
| ---- | -------------------------------------------- |
| 1    | FPGA resetlenir, LED %50 parlaklıkta yanar   |
| 2    | Buton basıldı mı kontrol edilir (`db_valid`) |
| 3    | Toggle register güncellenir                  |
| 4    | PWM duty cycle ayarlanır                     |
| 5    | PWM çıkışı tüm LED’lere uygulanır            |
