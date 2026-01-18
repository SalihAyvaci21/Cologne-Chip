# **Serial Adder Top**

**Görev Tanımı:**  
İki adet 8-bit sayıyı seri toplama yöntemiyle toplar.  
Bu proje, **shift register ile bit bit veri kaydırma, full adder seri toplama ve FSM kontrollü akış** içerir.  
Toplama tamamlandığında, **9-bit shift register kullanılarak toplam binary’den decimal’e dönüştürülür.**

---

## 🎯 **Amaç**

- 8-bit sayıları bit bit işleyerek seri toplama mantığını anlamak
- **FSM** ile paralel yükleme, kaydırma ve işlem kontrolünü deneyimlemek
- **Carry bit** geri beslemeli D flip-flop ile toplamın doğru hesaplanmasını görmek
- Seri toplamanın sonucunu **9-bit shift register ile toplayıp decimal olarak elde etmek**

---
## **Algoritma**

## 1️⃣ Başlatma

1. `start` sinyali **1** yapılır.
2. FSM `IDLE` durumundan `LOAD` durumuna geçer.
3. Shift register A ve B, girişteki 8-bit sayılarla **paralel olarak yüklenir** load_a = 1`, `load_b = 1

---

## 2️⃣ Seri Toplama Döngüsü

1. FSM `ADD` durumuna geçer, `enable = 1`.
2. Shift register A ve B **her clock ile 1 bit kaydırılır**:
    - `a_bit` = A kaydırma çıkışı (LSB)
    - `b_bit` = B kaydırma çıkışı (LSB)
3. Full Adder modülü bu 2 bit ve önceki carry (`carry_q`) ile **1 bitlik toplam ve yeni carry** üretir:
    - `sum_bit = a_bit XOR b_bit XOR carry_q`
    - `carry_bit = (a_bit & b_bit) | (b_i & carry_q) | (a_bit & carry_q)`
4. `carry_q` D flip-flop ile bir sonraki toplama turuna aktarılır.
    

---

## 3️⃣ Sonuç Shift Register’a Yazma

1. Her clockta Full Adder’dan gelen `sum_bit` ve `carry_bit` **9-bit shift register** içine kaydırılır:
    
    - `shift_data[7:0]` → bit bit toplama sonucu
    - `shift_data[8]` → son carry biti
    
2. Böylece **binary toplam 9-bit olarak elde edilir**.
    

---

## 4️⃣ Toplamın Tamamlanması

1. FSM bit sayacı (`bit_count`) 8’e ulaşınca `FIN` durumuna geçer.
2. `done = 1` ile toplamın tamamlandığı ve `shift_data` değerinin artık güvenilir olduğu bildirilir.
3. Kullanıcı bu noktada `result` değerini okuyabilir (0–255 + carry = 0–511 arası decimal değer).
    

---

## 5️⃣ Özet Akış

| Durum | İşlem                                                                             |
| ----- | --------------------------------------------------------------------------------- |
| IDLE  | Start beklenir                                                                    |
| LOAD  | Shift register A/B yüklenir                                                       |
| ADD   | Seri toplama başlar, carry DFF ile geri beslenir, 9-bit shift register kaydırılır |
| FIN   | Toplama tamamlandı, `done = 1`, `result` güvenilir                                |


---

## **Blok Şeması Açıklaması**

Blok şema, iki adet 8-bit sayının seri toplamasını ve kontrol akışını gösterir. Modülün ana bileşenleri ve veri yolları aşağıdaki gibidir:

<p align="center">

<img src="Images/Pasted image 20250908165833.png" style="display: block; margin: auto;">

<br>
</p>
---


💡 **Not:**

- Toplama süresince shift register sürekli kaydırılır, `enable = 1`.
- `done = 1` olana kadar `result` okunmamalıdır, aksi halde eksik veya yanlış değer alınır.

---

## 📂 Proje Yapısı

serial_adder_top/  
│── log/ # Log kayıtları  
│── net/ # Netlist dosyaları  
│── sim/ # Testbench dosyaları  
│── src/ # Kaynak kod (.v)  
│── Makefile # Build ayarları  
│── run.bat # Çalıştırma scripti

---

## 💡 Kod Yapısı

## Kullanılan Modüller

1. **2-bit Full Adder (carry dahil)**
    - Seri toplama işlemini gerçekleştirir.
    - `sum_o = a_i XOR b_i XOR c_i`
    - `c_o = (a_i & b_i) | (b_![[shift_register_8bit_tb.v]]i & c_i) | (a_i & c_i)`

<p align="center">

<img src="Images/Pasted image 20250908163203.png" style="display: block; margin: auto;">

<br>

<a href="Led-Bounce-Up-Down-Counter/Led-Bounce-Up-Down-Counter/src/FullAdder.v">
<em style="display:flex;justify-content:center">Fulladder.v kod görüntüsü</em>
</a>	
</p>

**Shift Register (8-bit)**

- Girişteki 8-bit sayı, **seri kaydırma yöntemiyle binary** formata dönüştürülür.
- Her clockta bir bit çıkar ve Full Adder’a gönderilir.

<p align="center">

<img src="Images/Pasted image 20250908163408.png" style="display: block; margin: auto;">

<br>

<a href="/SerialAdderTop/src/shift_register_8bit.v">
<em style="display:flex;justify-content:centerShift Register kod görüntüsü</em>
</a>	
</p>


- 8-bit verileri **seri olarak işleyerek toplam** elde etmek
- Carry bilgisini **D flip-flop ile geri besleyerek** doğru seri toplama sağlamak
- **FSM (Finite State Machine)** ile paralel yükleme, seri toplama ve tamamlanma süreçlerini kontrol etmek
- Seri toplama sonucunu **9-bit shift register ile kaydetmek**

<p align="center">

<img src="Images/Pasted image 20250908164046.png" style="display: block; margin: auto;">

<br>

<a href="/SerialAdderTop/src/Full_Adder_SR_FSM_tb.v">
<em style="display:flex;justify-content:center">Full Adder SR kod görüntüsü</em>
</a>	
</p>

---

- **9-bit Shift Register (Sonuç Kaydı)**
- Full Adder’dan gelen her bit ve carry ile birlikte 9-bitlik sonucu kaydeder.
- `result[7:0]` → toplam bitleri, `result[8]` → carry biti.
<p align="center">

<img src="Images/Pasted image 20250908162928.png" style="display: block; margin: auto;">

<br>

<a href="/SerialAdderTop/src/shift_register_9bit.v">
<em style="display:flex;justify-content:center">Son Shift Register kod görüntüsü</em>
</a>	
</p>
## ⚠️ Gözlenen Özellikler

- **Serial toplama:**  
    İki 8-bit sayı bit bit toplanır, D flip-flop ile carry geri beslenir.
    
- **FSM kontrollü akış:**
    
    - `start` ile işlem başlar
    - `load_a` ve `load_b` paralel yükleme sinyallerini tetikler
    - `enable` ile shift register kaydırılır
    - `done` toplamanın bittiğini belirtir
    
- **9-bit shift register:**
    
    - Toplamın LSB’den MSB’ye kaydırılması
    - Son carry biti dahil edilerek 9-bit binary sonuç
    
- **Decimal görünüm:**
    
    - 9-bit shift register sayesinde binary sonuç decimal olarak okunabilir

---

## 🔧 Kullanım

- `start = 1` ile toplama başlatılır
- `done = 1` olunca, `result` doğru toplam değerini gösterir
- Testbench ile 2 sayıyı (`data_a`, `data_b`) verip, sonucu `result` üzerinden okuyabilirsiniz

---

	📌 Bu proje özellikle **seri toplama mantığını, FSM kontrollü veri akışını ve binary → decimal dönüşümü** göstermek için tasarlanmıştır.














