
**FIFO (First-In, First-Out)**, yani “İlk Giren İlk Çıkar”, dijital sistemlerde veri akışını sıraya koymak için kullanılan bir bellek yapısıdır. Bu yapı, verilerin geldiği sırayla işlenmesini sağlar. FPGA gibi donanım tabanlı sistemlerde, farklı hızlarda çalışan modüller arasında veri alışverişini düzenlemek için sıklıkla kullanılır.

---

## Ne İşe Yarar?

FIFO, özellikle **veri tamponlama** (buffering) amacıyla kullanılır. Örneğin, bir modül saniyede 1000 veri üretiyor, ancak diğer modül bu verileri saniyede 500 veri olarak işleyebiliyorsa, FIFO araya girerek bu hız farkını dengeler. Böylece veri kaybı yaşanmaz ve sistem kararlı çalışır.

---

## Nerelerde Kullanılır?

- **Veri iletim sistemleri** (UART, SPI, Ethernet gibi protokollerde)
- **Görüntü işleme** (kamera verisinin geçici olarak saklanması)
- **Ses işleme** (örneğin ses örneklerinin sırayla işlenmesi)
- **Çok saatli sistemler** (clock domain crossing - CDC)
- **DMA (Direct Memory Access)** işlemlerinde
- **FPGA ile mikrodenetleyici arasında veri alışverişi**

---

## Avantajları

- **Zamanlama farklarını dengeleme**: Farklı hızlarda çalışan modüller arasında veri kaybını önler.
- **Basit kontrol mantığı**: FIFO yapısı genellikle sadece yazma ve okuma işaretleriyle kontrol edilir.
- **Paralel çalışmaya uygun**: FPGA’de çok sayıda FIFO aynı anda çalışabilir.
- **Kaynak verimliliği**: FPGA’nin dahili RAM blokları (BRAM) kullanılarak verimli şekilde uygulanabilir.

---

## Dezavantajları

- **Sınırlı kapasite**: FIFO’nun boyutu sınırlıdır, aşırı veri gelirse taşma (overflow) olabilir.
- **Gecikme (latency)**: FIFO doluysa veya boşsa, veri akışında gecikmeler yaşanabilir.
- **Kontrol karmaşıklığı**: Çoklu FIFO’lar arasında senkronizasyon gerektiğinde kontrol mantığı karmaşıklaşabilir.
- **Kaynak tüketimi**: Büyük boyutlu FIFO’lar FPGA kaynaklarını (BRAM, LUT) yoğun şekilde kullanabilir.