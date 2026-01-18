## D Flip-Flop Nedir?

D Flip-Flop (Data veya Delay Flip-Flop), bir tür **kenar tetiklemeli (edge-triggered)** mantık devresidir. En basit anlamıyla **bir bitlik veri saklama elemanı** olarak çalışır. Girişindeki veri (D), saat sinyalinin (Clock, CLK) belirli bir kenarında (pozitif veya negatif) çıkışa (Q) aktarılır ve orada tutulur.

---

###  Temel Özellikleri

- **Giriş (D):** Saklanacak veri biti.
- **Çıkış (Q):** Saklanan veri.
- **Saat (CLK):** Verinin ne zaman saklanacağını belirler.
- **Reset (R) ve Set (S):** Çıkışı sıfırlamak veya 1 yapmak için opsiyonel girişler.

###  Ne İşe Yarar?

✅ **Veri Saklama:** Bir saat döngüsü boyunca 1 bitlik veriyi tutar.  
✅ **Senkronizasyon:** Giriş sinyalini saat sinyali ile hizalar.  
✅ **Kayıt (Register) Yapıları:** Birden fazla D Flip-Flop bir araya gelerek veri kayıt blokları oluşturur.  
✅ **Sayma ve Zamanlama:** Sayıcılar (counters) ve zamanlayıcılar (timers) için temel yapı taşıdır.



###  Kullanım Alanları

- **FPGA ve Mikrodenetleyici Tasarımı**
- **Veri Yolu Senkronizasyonu**
- **Durum Makinesi (FSM) Uygulamaları**
- **Saat Alanı Geçişleri (CDC)**

---

###  Görsel: D Flip-Flop Blok Diyagramı
![[Cologne Chip/Resimler/d-flip-flop.jpg]]


---

### ✅ Avantajları

- Basit ve kararlı bir yapı.
    
- Saat sinyaliyle senkronize çalışma.
    
- Her saat darbesinde yalnızca bir kez veri örnekler.
    

---

### ❌ Dezavantajları

- Her saat kenarında giriş değişimini örneklediği için hızlı giriş değişimlerine duyarlıdır (metastability riski).
    
- Asenkron reset/set kullanımı dikkat gerektirir.