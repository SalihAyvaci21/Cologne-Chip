
**SerDes**, dijital sistemlerde **paralel veriyi seri hale getirip** ileten ve karşı tarafta tekrar **seri veriyi paralel hale çeviren** bir devre yapısıdır. Genellikle yüksek hızlı veri iletimi gereken yerlerde kullanılır.

---

###  Temel Görevi:

- **Serializer**: Paralel veriyi (örneğin 8-bit) tek bir hat üzerinden **seri** olarak gönderir.
- **Deserializer**: Gelen seri veriyi tekrar **paralel** hale getirir.

---

###  Neden Kullanılır?

- FPGA’lerde pin sayısı sınırlıdır. Çok sayıda veri hattı yerine **tek bir yüksek hızlı hat** kullanmak verimlidir.
- Özellikle **kamera, ağ, PCIe, HDMI, MIPI** gibi protokollerde kullanılır.

---

##  GateMate FPGA’de SerDes Özelliği

- Her yonga (die) içinde **1 adet SerDes arayüzü** bulunur.
- **5.0 Gb/s** hızında veri iletimi desteklenir.

---

##  SerDes Kullanım Senaryoları

|Uygulama|Açıklama|
|---|---|
|**PCIe**|Bilgisayarlar arası yüksek hızlı veri iletimi|
|**MIPI CSI/DSI**|Kamera ve ekran veri iletimi|
|**Ethernet (10G/25G)**|Ağ bağlantıları|
|**HDMI / DisplayPort**|Görüntü aktarımı|
|**FPGA-FPGA bağlantısı**|Yüksek bant genişlikli veri paylaşımı|

---

## ✅ Avantajları

- **Yüksek veri hızı**: 5.0 Gb/s gibi hızlar mümkündür.
- **Pin tasarrufu**: 8-bit paralel veri yerine tek hatla iletim yapılabilir.
- **Gürültü bağışıklığı**: Diferansiyel sinyalleme ile daha güvenilir iletim

---

## ❌ Dezavantajları

- **Tasarım karmaşıklığı**: Saat senkronizasyonu, veri hizalama, hata kontrolü gerekir.
- **Güç tüketimi**: Yüksek hızda çalıştığı için daha fazla güç harcar.
- **Protokol uyumluluğu**: Her uygulama için özel konfigürasyon gerekebilir.

---

##  Teknik Detaylar

|Özellik|Açıklama|
|---|---|
|**Line Rate**|5.0 Gb/s|
|**Encoding**|Genellikle 8b/10b veya 64b/66b|
|**Clocking**|PLL ile senkronize saat üretimi|
|**Differential Signaling**|LVDS veya CML kullanılır|