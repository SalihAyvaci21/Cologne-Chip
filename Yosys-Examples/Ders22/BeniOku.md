# FPGA ile DHT11 Sensör Verilerini SSD1306 OLED Ekranda Gösterme

Bu proje, bir FPGA kullanarak DHT11 sıcaklık ve nem sensöründen veri okur ve bu verileri I2C protokolü üzerinden bir SSD1306 (128x64) OLED ekranda gösterir.

Proje, gelen 8-bit binary sensör verisini (örn: 25 C) alır, bunu "2" ve "5" gibi ASCII karakterlere dönüştürür ve 8x8'lik bir font ROM'u kullanarak ekrana basar. Ekran, fiziksel montajı telafi etmek için 180 derece dönmüş olarak ayarlanmıştır .

## Görseller

### Çalışma Görseli (FPGA ve OLED)

(Buraya projenin GateMate FPGA kartı üzerinde DHT11 ve OLED ile çalışırken çekilmiş bir fotoğrafını ekleyebilirsiniz)

### Simülasyon (GTKWave)

`dht11_fsm_tb.v` testbench'i çalıştırıldığında, DHT11 sensörünün 1-wire protokol simülasyonunu ve FSM'nin buna verdiği yanıtı gösteren GTKWave dalga formu.
![[Images/gtkwave.png]]
## Proje Mimarisi

Proje, `Sensor_Display_Top.v` modülü altında birleştirilmiş birkaç çekirdekten oluşur:

1. **DHT11 Çekirdeği (`top_dht11`):**
    
    - `clk_div` kullanarak 10MHz'lik ana saati 1MHz'lik (1µs) bir 'strobe' sinyaline böler.
        
    - `dht11_fsm` , bu 1µs'lik strobe'u kullanarak 1-wire protokolünü yönetir, sensörden 40-bit veriyi okur ve checksum doğrulaması yapar.
        
    - Veri başarıyla okunduğunda, 16-bitlik `{Nem[15:8], Sıcaklık[7:0]}` verisini çıkarır ve bir saat döngüsü boyunca `O_CONV` sinyalini '1' yapar.
        
2. **Ekran Yazma FSM (`Sensor_Display_Top`):**
    
    - `O_CONV` sinyalinin yükselen kenarını algılayarak tetiklenir.
        
    - İlk olarak, tüm `Frame_Buffer`'ı (RAM) temizler (siyah ekran).
        
    - `dht_value` verisini `bin2ascii` modüllerine göndererek onlar ve birler basamağı için ASCII kodlarını alır.
        
    - "nem:", "sicaklik:" gibi statik metinler ve sensörden gelen dinamik ASCII karakterler için `Font_ROM`'dan ilgili 8x8 font verisini okur.
        
    - `S_TRANSPOSE_WRITE` durumunda, bu font verisini 180 derece döndürerek `Frame_Buffer`'a (RAM) yazar .
        
3. **OLED Sürücüsü (`OLED`):**
    
    - Bu modül, `Sensor_Display_Top` FSM'inden bağımsız olarak sürekli çalışır.
        
    - `Frame_Buffer`'ı (RAM) adres 0'dan 1023'e kadar sürekli tarar .
        
    - Okuduğu her 8-bitlik (1 sütun) veriyi, `I2C` modülü aracılığıyla SSD1306 ekrana gönderir.
        
    - Bu sürekli yenileme, ekrandaki görüntünün statik kalmasını sağlar.
        

## Modül Açıklamaları

- <a href="DHT11-SSD1306/src/Sensor_Display_Top.v"><em> Sensor_Display_Top.v</em> </a>: Tüm modülleri birleştiren ve ekran yazma FSM'ini içeren ana (top) modül.   
    
- <a href="DHT11-SSD1306/src/top_dht11.v"><em> top_dht11.v</em> </a>: `clk_div` ve `dht11_fsm`'i birleştiren DHT11 sensör sarmalayıcı modülü.
    
- <a href="DHT11-SSD1306/src/dht11_fsm.v"><em> dht11_fsm.v</em> </a>: DHT11 1-wire protokolünü ve veri okumayı yöneten çekirdek durum makinesi.
    
- <a href="DHT11-SSD1306/src/clk_div.v"><em> clk_div.v</em> </a>: Girdi saatini (CLK_FREQ_HZ) istenen 'strobe' sinyaline böler.
    
- <a href="DHT11-SSD1306/src/OLED.v"><em> OLED.v</em> </a>: SSD1306 başlatma komutlarını gönderen ve `Frame_Buffer`'dan ekrana sürekli veri aktaran sürücü.
    
- <a href="DHT11-SSD1306/src/I2C.v"><em> I2C.v</em> </a>: `OLED.v` modülü tarafından kullanılan, I2C master iletişimini yürüten modül.
    
- <a href="DHT11-SSD1306/src/Frame_Buffer.v"><em> Frame_Buffer.v</em> </a> (`Simple_RAM`): Ekran görüntüsünün tutulduğu 1024x8 (1KB) çift portlu RAM.
    
- <a href="DHT11-SSD1306/src/Font_ROM.v"><em> Font_ROM.v</em> </a>: 8x8 boyutunda ASCII karakter fontlarını içeren ROM.
    
- <a href="DHT11-SSD1306/src/bin2ascii.v"><em> bin2ascii.v</em> </a>: Sentez dostu (bölme operatörü içermeyen) 8-bit binary sayıyı 2 basamaklı ASCII'ye çeviren modül .
    
- <a href="DHT11-SSD1306/src/debounce_ip_core.v"><em> debounce_ip_core.v</em> </a>: (Opsiyonel) Buton sinyalleri için ark önleyici modül.
    
- <a href="DHT11-SSD1306/src/db_dht11.v"><em> db_dht11.v</em> </a>: (Alternatif Top) Projenin, veriyi OLED yerine LED'lerde gösteren daha basit bir versiyonu.
    

### Testbench

- <a href="DHT11-SSD1306/sim/iverilog/dht11_fsm_tb.v"><em> dht11_fsm_tb.v</em> </a>: Yalnızca `dht11_fsm` modülünü test etmek için kullanılır. Başarılı bir veri okuma senaryosunu (Nem=44, Sıcaklık=25) simüle eder ve `O_CONV` sinyalinin '1' olup olmadığını kontrol eder.
    

## Donanım ve Kısıtlamalar

Bu proje bir **Cologne Chip GateMate CCGM1A1 V3.2A** FPGA kartı için hedeflenmiştir.

- Pin atamaları <a href="DHT11-SSD1306/src/Sensor_Display_Top.ccf"><em> Sensor_Display_Top.ccf</em> </a> dosyasında mevcuttur.
    
- Sistem saati 10MHz'dir.
    
- SSD1306 OLED pinleri: `SCL` (IO_NB_A1), `SDA` (IO_NB_A0) .
    
- DHT11 veri pini: `IO_DHT11` (IO_NB_A7).
    

## **Uygulama ve Çalışma Görselleri**

Tasarımın FPGA üzerinde çalışırken çekilmiş videosu. Ekranda 
"nem: xx
sicaklik: xx"
yazısı ve sensörün önündeki sıcaklık ve nem değerinin değişimi görülmektedir.

![FPGA Çalışma Fotografi](Images/DHT11gorsel.jpg)


![FPGA Çalışma Videosu](Images/DHT11working.gif)

