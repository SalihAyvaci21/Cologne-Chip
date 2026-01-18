### Temel Özellikleri:

- **İlk giren veri ilk çıkar** (First-In, First-Out mantığı).
    
- Veri yapısı bir kuyruk (queue) gibi davranır.
    
- Senkron veya asenkron çalışabilir.
    
- Donanımda genellikle **blok RAM** üzerinde uygulanır.
    

---

##  LIFO (Last-In, First-Out) Nedir?

LIFO, **son giren verinin ilk çıkarıldığı** bir bellek yapısıdır. Daha çok **yığın (stack)** işlemleri için kullanılır. FIFO’dan farklı olarak veri ters sırada alınır.

###  Temel Özellikleri:

- **Son giren veri ilk çıkar** (Last-In, First-Out mantığı).
- Veri yapısı bir yığın (stack) gibi çalışır.
- Çoğunlukla yazılım seviyesinde kullanılır.
- Donanımda daha az yaygındır.

---

##  FIFO vs. LIFO – Karşılaştırmalı Tablo

|Özellik|**FIFO**|**LIFO**|
|---|---|---|
|**Veri Çıkış Sırası**|İlk giren ilk çıkar|Son giren ilk çıkar|
|**Kullanım Alanı**|Veri akışı, tamponlama|Fonksiyon çağrı yığınları|
|**Donanım Uygulaması**|Evet (FPGA, RAM tabanlı)|Nadiren|
|**Saat Alanları Arası Geçiş**|Evet (Asenkron FIFO ile)|Hayır|
|**Veri Yapısı**|Kuyruk (Queue)|Yığın (Stack)|
|**FPGA Entegrasyonu**|Yaygın (Block RAM destekli)|Sınırlı|

---

## ✅ FIFO’nun LIFO’ya Göre Üstünlükleri

1. **Veri Akışı Yönetimi**: FIFO, sürekli veri akışı gereken sistemlerde (ör. seri iletişim) idealdir.
2. **Asenkron Destek**: Farklı saat frekanslarında çalışan iki sistem arasında veri aktarımı sağlar.
3. **Tampon Bellek**: Geçici depolama ile veri kayıplarını önler.
4. **Donanımda Kolay Uygulama**: Modern FPGA’lerde Block RAM üzerinde doğrudan desteklenir.
5. **Basit Erişim**: Sadece okuma (read) ve yazma (write) pointer’ları ile yönetilir.

---

## ❌ FIFO’nun Sınırlamaları

- **Rastgele Erişim Yok**: Verilere sadece sırayla erişilebilir; belirli bir indekse doğrudan erişim mümkün değildir.
- **Dolu/Boş Yönetimi**: FIFO’nun taşma (overflow) veya boş kalma (underflow) durumları dikkatle izlenmelidir.
- **Gecikme**: Uzun FIFO’larda ek okuma/yazma gecikmeleri oluşabilir.