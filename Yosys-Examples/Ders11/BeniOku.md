# **LED Brightness 3-Phase**

**Görev Tanımı:**  
Bu proje, **3 faz motor sürme mantığını LED’lerle simüle etmek** için tasarlanmıştır.  
Üç ayrı PWM sinyali üretilerek, LED’ler sırasıyla farklı duty cycle değerlerinde çalıştırılır:

1. Faz 1: %50, Faz 2: %100, Faz 3: %0
2. Faz 1: %0, Faz 2: %50, Faz 3: %100
3. Faz 1: %100, Faz 2: %0, Faz 3: %50

Her faz kombinasyonu **FSM (state machine)** tarafından sırayla 0.5 saniye boyunca uygulanır.

---

## 🎯 **Amaç**

- PWM kullanarak üç ayrı LED çıkışını kontrol etmek
- FSM ile 3 farklı duty cycle kombinasyonunu sırayla üretmek
- **3 faz motor sürme mantığını LED üzerinden test etmek**
- Donanım üzerinde PWM duty cycle etkilerini gözlemlemek

---

## **Algoritma**

### 1️⃣ Başlatma

- `rst_n = 0` → tüm sayıcı ve state sıfırlanır.
- Başlangıçta state = 0, duty cycle atanır.

### 2️⃣ FSM State Makinesi

- Her state 0.5 saniye boyunca aktif kalır.
- State arttıkça duty cycle değerleri değişir.
- State döngüsü: `0 → 1 → 2 → 0`.

### 3️⃣ PWM Üretimi

- Her LED için ayrı `pwm_generator` instance çalışır.
- `duty_cycle` FSM tarafından atanır.
- Sonuçta LED çıkışları PWM sinyali şeklinde yanar.

---

## 🔧 Kullanım

- FPGA’ya program yüklendiğinde LED’ler sırasıyla farklı parlaklıklarda yanıp söner.
- FSM her 0.5 saniyede bir state değiştirir.
- LED’ler şu şekilde yanar:

|State|LED1 Duty|LED2 Duty|LED3 Duty|
|---|---|---|---|
|0|%50|%100|%0|
|1|%0|%50|%100|
|2|%100|%0|%50|

---

## 📂 Proje Yapısı

led_brightness_3phase/  
│── src/ # Kaynak kod (.v)  
│── sim/ # Testbench dosyaları  
│── log/ # Simülasyon kayıtları  
│── Makefile # Build ayarları

---

## 💡 Kod Yapısı

### Kullanılan Modüller

1. **PWM Generator**
    - 10 MHz sistem clock ile 1 kHz PWM üretir.
    - 8-bit duty cycle kontrolü vardır.
    - ![[pwm_generator 1.v]]
2. **FSM (State Machine)**
    - 3 state döngüsü ile LED duty cycle’larını sırasıyla değiştirir.
    - Her state 0.5 saniye boyunca geçerlidir.

3. **Top Modül (`led_brightness_3phase`)**
    - FSM ve 3 adet PWM generator’ü birleştirir.
    - Sonuçta LED’ler üç faz motor sürme mantığına göre yanar.
![[led_brightness_3phase.v]]

---

### ⚡ Özet Akış

|Adım|İşlem|
|---|---|
|1|Reset → FSM state = 0|
|2|PWM duty değerleri atanır|
|3|LED’ler duty cycle ile yanar|
|4|Sayaç 0.5 sn dolunca FSM bir sonraki state’e geçer|
|5|Döngü sürekli devam eder|


---

## 🔍 Beklenen Simülasyon Dalga Şekli

- **LED1, LED2, LED3 PWM sinyalleri** duty cycle’lara göre farklı genişlikte pulse üretir.
- FSM state değiştikçe duty cycle kombinasyonları sırayla değişir:

Time(sec)   State   LED1 Duty   LED2 Duty   LED3 Duty
-----------------------------------------------------
0.0 – 0.5     0       %50         %100        %0
0.5 – 1.0     1       %0          %50         %100
1.0 – 1.5     2       %100        %0          %50
1.5 – 2.0     0       %50         %100        %0