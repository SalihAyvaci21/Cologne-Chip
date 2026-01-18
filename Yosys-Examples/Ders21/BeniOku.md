# FPGA SSD1306 OLED Sürücüsü (I2C)

Bu proje, 128x64 piksel çözünürlüğe sahip SSD1306 OLED ekranları I2C protokolü üzerinden sürmek için geliştirilmiş bir Verilog projesidir. Proje, bir "frame buffer" (görüntü tamponu) mimarisi kullanır.
## Temel Özellikler

- **Ekran Desteği:** 128x64 SSD1306 OLED.
- **Arayüz:** I2C (Yaklaşık 833kHz @ 10MHz sistem saati).
- **Mimari:** Frame buffer tabanlı. `OLED` modülü görüntü tamponundan sürekli okuma yaparken , ana FSM bu tampona yazar.
- **Font Desteği:** `font8x8.hex` dosyasından yüklenen 8x8 bitmap font desteği.
- **Otomatik Başlatma:** Reset sonrası otomatik olarak başlar, ekranı temizler ve metni yazar.
- **Metin Döndürme:** Metinler, frame buffer'a 180 derece döndürülerek yazılır.

## Proje Dosyaları

- <a href="SSD1306/src/Top_OLED.v.v"><em> Top_OLED.v.v</em> </a>: Ana üst seviye modül. Tüm alt modülleri birbirine bağlar.    
- <a href="SSD1306/src/OLED.v"><em>OLED.v</em> </a>: SSD1306 kontrolcüsü. Ekranı başlatır ve frame buffer'dan okuduğu veriyi I2C üzerinden ekrana sürekli gönderir .

- <a href="SSD1306/src/I2C.v"><em> I2C.v</em> </a>: Düşük seviye I2C Master modülü. `OLED.v` modülünden gelen komut ve verileri fiziksel SDA/SCL hatlarına iletir.

- <a href="SSD1306/src/Frame_Buffer.v"><em> Frame_Buffer.v</em> </a> (Modül adı `Simple_RAM`): 1024x8 (1KB) çift portlu RAM. Bir portu `OLED.v` tarafından okunur , diğer portu `Top_OLED.v` FSM'i tarafından yazılır.

- <a href="SSD1306/src/Font_ROM.v"><em> Font_ROM.v</em> </a>: 1024x8 ROM. `font8x8.hex` dosyasını sentez zamanında hafızaya yükler.

- <a href="SSD1306/font8x8.v"><em> font8x8.v</em> </a>: 8x8 karakterler için bitmap verilerini içeren hafıza dosyası.

- <a href="SSD1306/src/debounce_ip_core.v"><em> debounce_ip_core.v</em> </a> Butonlar için bir "ark önleyici" (debounce) modülü. (Not: Bu modül projede aktif olarak kullanılmamaktadır ).
    
- <a href="SSD1306/src/Top_OLED.ccf"><em> Top_OLED.ccf</em> </a>: FPGA pin atamalarını içeren kısıtlama dosyası (Constraint File).
## Nasıl Çalışır?

Proje iki ana paralel süreçten oluşur:

**1. Süreç: Metin Yazma FSM'i (`Top_OLED.v`)** Bu süreç, reset sonrası yalnızca bir kez çalışır:

1. **Başlangıç:** Sistem resetlendiğinde, FSM otomatik olarak `S_CLEAR_FB_LOOP` durumuna geçer.
    
2. **Temizleme:** FSM, `Simple_RAM` (frame buffer) içindeki 1024 adresin tamamına `8'h00` (siyah) yazar.
    
3. **Karakter Seçimi:** Temizleme bitince, `S_SET_CHAR_PARAMS` durumuna geçer. `char_index` sayacına göre "nem: 25" ve "sicaklik: 36" metinlerindeki karakterleri sırayla seçer.
    
4. **Font Okuma:** Seçilen karakterin ASCII kodunu kullanarak `Font_ROM`'dan 8 adet yatay satır verisini (`reg_row0` ... `reg_row7`) okur .
    
5. **Döndürme ve Yazma:** Okunan 8 adet 8-bit'lik yatay veriyi, 180 derece döndürerek 8 adet 8-bit'lik dikey sütun verisine çevirir . Bu dikey verileri `Simple_RAM`'e (frame buffer) yazar.
    
6. **Döngü:** Tüm karakterler yazılana kadar 3-5. adımları tekrarlar.
    
7. **Bitiş:** Tüm metin yazıldığında, `S_DONE` ve ardından `S_IDLE` durumuna geçerek beklemede kalır.
    

**2. Süreç: Ekran Yenileme (`OLED.v`)** Bu süreç, reset sonrası başlar ve **sürekli** olarak çalışır:

1. **Başlatma (Init):** `OLED` modülü, `I2C` modülünü kullanarak SSD1306'ya bir dizi başlatma komutu gönderir (Ekranı aç , kontrastı ayarla , adresleme modunu ayarla, vb.).
    
2. **Yenileme Döngüsü:** Başlatma bitince (adım 25'ten itibaren ), modül sonsuz bir döngüye girer.
    
3. **Okuma:** `addr` sayacını 0'dan 1023'e kadar artırarak `Simple_RAM` (frame buffer) içindeki tüm verileri sırayla okur.
    
4. **Gönderme:** Okuduğu her bir baytı (`ram_dout` ) `I2C` modülü aracılığıyla OLED ekrana gönderir . Bu, ekranın sürekli olarak frame buffer'daki görüntüyü yansıtmasını sağlar.
    
5. **FPS Sinyali:** 1024 baytın tamamı gönderildiğinde (bir tam kare), `FPS` çıkış sinyalinin durumunu değiştirir (toggle).
    
## Gereksinimler

Sentezleme işlemi için `font8x8.hex` dosyasının `Font_ROM.v` modülünün erişebileceği bir konumda (genellikle projenin ana dizininde) bulunması gerekmektedir.
