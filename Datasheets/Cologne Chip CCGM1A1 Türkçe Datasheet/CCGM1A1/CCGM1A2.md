İki adet CCGM1A1 yongasının (die) tek bir pakette birleştirilmiş halidir. Bu iki yonga arasında **die-to-die bağlantılar** ile yönlendirme (routing) yapıları birbirine bağlanır.
- Daha fazla kaynak (mantık elemanı, I/O, saat vs.)
- Paralel işlem kapasitesi artar. buna karşın Die-to-die gecikmeleri olabilir.

**Her bir yonga (die) şunları içerir**:

- **20.480 programlanabilir eleman**: Hem kombinasyonel hem sekansiyel mantık için
- **20.480 adet 8 girişli LUT ağacı** veya **40.960 adet 4 girişli LUT**
- **40.960 adet latch / flip-flop** 
## Her Programlanabilir Eleman Şu Şekilde Yapılandırılabilir:
- **1-bit tam toplayıcı (full adder)**
- **2-bit tam toplayıcı**
- **2×2-bit çarpan (multiplier)**
//tablo ile kendi muadilleri ile karşılaştırarrak gate matein cpe lerinin daha esnek olduğunu vurgulamak önemli 
## GPIO (Giriş/Çıkış) Özellikleri

- **9 adet user GPIO**
- **162 kullanıcı tanımlı GPIO pini**
- Tüm GPIO’lar:
- **Tek uçlu (single-ended)** veya **farklı çift (Low Voltage Differential Signaling**) olarak 
- //low cost olduğunu vurgulamak önemli 
- yapılandırılabilir
- **DDR ( ki Kat Veri Hızı**) destekli 
- Kamera sensörleri için **MIPI D-PHY (CSI-2)** uyumlu 
- Geleneksel CMOS/TTL cihazlarla uyumlu **1.2V – 2.5V** arası voltaj desteği 
- önerilen 2.5v ama 3.3 ve 3.6v da da survive 


## Saat Üreteçleri (PLL)

- Her yonga içinde **4 adet PLL (Phase Locked Loop)** bulunur
- **1 GHz – 2.5 GHz** arası osilatör frekansı 

## PLL’in PAL’e Göre Üstünlükleri

1. **Saat Sinyali Üretimi**: PAL saat üretemez, PLL ise yüksek hassasiyetli saat sinyalleri üretir.
2. **Frekans Esnekliği**: PLL ile giriş saatine göre frekans çarpılabilir veya bölünebilir.
3. **Faz Kontrolü**: PLL, çıkış saatinin fazını ayarlayabilir (örneğin veri senkronizasyonu için).
4. **Jitter Azaltma**: PLL, saat sinyalindeki gürültüyü (jitter) azaltarak daha kararlı sinyal sağlar.
5. **Modern FPGA Entegrasyonu**: PLL’ler FPGA’lerde dahili olarak bulunur ve doğrudan HDL ile kontrol edilebilir.

## PLL’in Zorlukları

- **Tasarım karmaşıklığı**: PLL konfigürasyonu dikkat ister.
- **Gürültü hassasiyeti**: Analog bileşen içerdiği için dikkatli yerleşim gerekir.
- **Güç tüketimi**: Yüksek frekanslarda daha fazla güç harcar. 


### 5.0 Gb/s SerDes (Serializer / Deserializer) Kontrolcüsü 
 GateMate™ FPGA yongasında, **5.0 Gb/s hızında çalışan bir adet SerDes arayüzü** bulunmaktadır.
 - **Kullanım amacı**: Yüksek bant genişliği gerektiren veri iletiminde pin sayısını azaltmak.

- Yüksek veri aktarım hızı
- Daha az pin kullanımı ile daha fazla veri iletimi
- Gürültüye karşı dayanıklı diferansiyel sinyalleme
Ancak buna karşın; Güç tüketimi yüksektir ve protokol uyumluluğu için özel yapılandırma gerekebilir.

//serdes karta gömülü ama clk entegresi dışarıdan alınması lazım burada örnek link gncel verilerek fiyat olarakta gösterilsin serdes dahili clk harici olduğu gösterilmeli 
## **Esnek Bellek Kaynakları (Flexible Memory Resources)** 

###  Özellikler:

- Her yongada **1.310.720 bit RAM**, toplamda 32 adet **SRAM bloğu** içinde dağılmıştır.
- Her RAM bloğu:
    - **Tek bir 40 Kbit blok** olarak ya da
    - **İki bağımsız 20 Kbit blok** olarak yapılandırılabilir.
- **Çalışma modları**:
    - **Simple Dual Port (SDP)**: Aynı anda bir yazma, bir okuma portu
    - **True Dual Port (TDP)**: Aynı anda iki bağımsız okuma/yazma portu
    - **FIFO modu**: Veri sıralı olarak girer ve çıkar (First-In First-Out)
- **Veri genişliği**:
    - TDP modunda: 1–40 bit
    - SDP modunda: 1–80 bit
- **Bit bazlı yazma izni** (bit-wide write enable)
- **ECC (Error Correction Code)** desteği: Belirli veri genişliklerinde hata düzeltme

###  Avantajlar:

- Yüksek esneklik: RAM blokları farklı modlarda kullanılabilir
- FIFO ve çift port desteği ile yüksek performanslı veri akışı
- ECC ile veri güvenliği sağlanır

###  Dezavantajlar:

- ECC ve çift port kullanımı daha fazla kaynak tüketebilir
- Bellek bloklarının dikkatli yerleşimi gerekebilir


## **Esnek Cihaz Yapılandırması (Flexible Device Configuration)**

###  Özellikler:

- **Konfigürasyon bankası**, kullanıcı I/O olarak yeniden kullanılabilir
- **JTAG arayüzü**, SPI arayüzüne bypass edilebilir
- **SPI arayüzü**:
    - Aktif ve pasif modda çalışabilir
    - **Tekli, ikili ve dörtlü SPI modları** desteklenir
- **SPI Flash** üzerinden doğrudan konfigürasyon
- **Tek kaynaktan çoklu FPGA konfigürasyonu** (multi-chip config)

###  Avantajlar:

- Gelişmiş konfigürasyon seçenekleri
- Hızlı başlatma ve yeniden programlama imkânı
- Daha az pin kullanımı ile çoklu FPGA yapılandırması

###  Dezavantajlar:

- SPI modlarının doğru yapılandırılması gerekir
- JTAG/SPI geçişleri karmaşık olabilir

---

##  **Performans Modları**

###  Özellikler:

- Her yonga, **çekirdek voltajına göre** farklı modlarda çalışabilir:
    - **Low Power**: Düşük güç tüketimi
    - **Economy**: Dengeli mod
    - **Speed**: Maksimum performans
- **Çekirdek voltaj aralığı**: 0.9V – 1.1V

###  Avantajlar:

- Uygulamaya özel güç/perf. optimizasyonu
- Mobil veya batarya ile çalışan sistemler için ideal

###  Dezavantajlar:

- Voltaj kontrolü dikkatli yapılmalı
- Düşük voltajda performans sınırlı olabilir

| **Rel. Size** | **CPEs** | **8-Inp-LUT Tree** | **FF/Latches** | **Block RAM 20Kb** | **Block RAM 40Kb** | **PLLs** | **SERDES** | **I/Os (Single-ended)** | **I/Os (Differential)** | **Balls** | **Size (mm)** |
| ------------- | -------- | ------------------ | -------------- | ------------------ | ------------------ | -------- | ---------- | ----------------------- | ----------------------- | --------- | ------------- |
| **CCGM1A1**   | 1        | 20,480             | 20,480         | 40,960             | 64                 | 32       | 4          | 1                       | 162                     | 81        | 15x15         |
| **CCGM1A2**   | 2        | 40,960             | 40,960         | 81,920             | 128                | 64       | 8          | 2                       | 162                     | 81        | 15x15         |
| **CCGM1A4**   | 4        | 81,920             | 81,920         | 163,840            | 256                | 128      | 16         | 4                       | 162                     | 81        | 15x15         |
| **CCGM1A9**   | 9        | 184,320            | 184,320        | 368,640            | 576                | 288      | 36         | 9                       | TBD                     | TBD       | 27x27         |
| **CCGM1A16**  | 16       | 327,680            | 327,680        | 655,360            | 1024               | 512      | 64         | TBD                     | TBD                     | 676       | 27x27         |
| **CCGM1A25**  | 25       | 512,000            | 512,000        | 1,024,000          | 1600               | 800      | 100        | 25                      | TBD                     | TBD       | 35x35         |


- **CCGM1A1** ile **CCGM1A2** veya **CCGM1A4** çipleri arasında geçiş yapmak için yalnızca pin bağlantılarının doğru şekilde yapılması yeterlidir.
- **CPE Sayısı Artışı:** Çip geçişi yaparak **CPE sayısını 2 katına veya 4 katına** çıkarabilirsiniz. Bu sayede daha yüksek işlem kapasitesine ve performansa sahip bir sistem elde edebilirsiniz.

### **Avantajlar:**

- **Daha Yüksek Performans:** **CPE sayısının artırılması**, veri işleme ve paralel işlem kapasitesini önemli ölçüde artırır.
- **Esneklik:** Pin-to-pin uyumluluk sayesinde, sistem gereksinimlerine göre uygun çip kolayca seçilebilir.
- **Kolay Yükseltme:** Mevcut tasarımınızı değiştirmeden çip yükseltmesi yapmak mümkündür.

### **Flip-Chip ve Çoklu Yonga (Multi-Die) Konsepti**

geleneksel bağlantı yöntemlerinden farklı olarak yonganın aktif yüzeyini doğrudan alt tarafa yerleştirerek daha kompakt ve yüksek performanslı bir yapı sunar. Flip-chip yöntemi, özellikle yüksek hız ve düşük gecikme gerektiren uygulamalarda tercih edilir. Aynı zamanda **gelişmiş entegrasyon** ve **yüksek performanstır**. Flip-chip paketleme, genellikle **indüktans** ve **kapasitans** gibi parazitik etkilerin azalmasına yol açar. Bu da **yüksek frekanslarda sinyal bütünlüğünün** artmasını sağlar.

- **Daha iyi elektriksel performans:** Daha kısa bağlantı yolları sayesinde sinyal gecikmesi azalır.
- **Yüksek yoğunluk:** Daha fazla bağlantı noktası küçük alana sığdırılabilir.
- **Isı dağılımı:** Isı, doğrudan ara bağlantı elemanına iletilebilir, bu da soğutmayı kolaylaştırır.
- **Daha küçük form faktörü:** Daha kompakt tasarımlar mümkündür.


![[Pasted image 20250707095828.png]]


#### **Veri Akışının Optimize Edilmesi**

- **CPE array** (Configurable Processing Elements) merkezde yer alır çünkü tüm işlem gücü buradan sağlanır.
- Çevresel bileşenler (SerDes, GPIO, PLL vs.) bu işlem merkezine yakın konumlandırılarak veri akışı hızlandırılır.
- **Avantaj:** Daha kısa bağlantı yolları sayesinde sinyal gecikmesi azalır.

#### 2. **Paralel İşlem Gücünün Artırılması**

- CPE’ler 5 parçaya bölünmüş ve yatayda 32x128’lik diziler halinde düzenlenmiş. // 32x128 ne demek bunu açıklamak gerek 
- Bu yapı, aynı anda birden fazla işlemin yürütülmesini sağlar.
- **Avantaj:** Yüksek paralellik, daha hızlı işlem ve daha fazla görev eşzamanlı yürütülebilir. //
 //CPE lerinin her birinin işlemci gibi olması. 

#### 3. **Bellek Erişiminin Verimli Hale Getirilmesi**

- **Block RAM’ler**, CPE dizilerine yakın yerleştirilmiş (4 sütun halinde).
- Bu sayede işlem birimleri, belleğe hızlı ve düşük gecikmeli erişim sağlar.
- **Avantaj:** Veri işleme süresi kısalır, performans artar.


#### 4. **Saat ve Senkronizasyon Yönetimi**

- **PLL’ler**, yonganın farklı bölgelerine eşit uzaklıkta yerleştirilerek saat sinyallerinin dengeli dağıtımı sağlanır.
- **Avantaj:** Zamanlama hataları azalır, sistem kararlılığı artar.

#### 5. **Konfigürasyon ve Test Kolaylığı**

- **JTAG/SPI controller** ve **Configuration bank**, yonganın kenarına yerleştirilmiş.
- Bu, dış bağlantılarla kolay erişim sağlar.
- **Avantaj:** Programlama ve hata ayıklama işlemleri daha hızlı ve kolay yapılır.

![[Pasted image 20250707100111.png]]

Görselde gösterilen **CCGM1A2 mimarisi**, iki adet **CCGM1A1 yongasının** (Die 1A ve Die 1B) tek bir BGA paketinde doğrudan silikon üzerinde birbirine bağlandığı **çoklu yonga (multi-die)** yapısını göstermektedir. Bu yerleşim, belirli teknik nedenlerle bu şekilde tasarlanmıştır. 

- **CPE array** ve **Block RAM’ler**, her iki yongada da simetrik olarak yerleştirilmiş. Bu, işlem gücünün dengeli dağılmasını sağlar.
- **SerDes, PLL ve GPIO** gibi yüksek hızlı giriş/çıkış bileşenleri, her iki yonganın dış kenarlarına yerleştirilmiş. Bu, dış dünyayla bağlantıyı kolaylaştırır.
- **Konfigürasyon kontrolcüsü, JTAG/SPI ve konfigürasyon bankası**, alt kısımda merkezi bir noktada yer alıyor. Bu, her iki yonganın da ortak yapılandırma kaynaklarına eşit erişimini sağlar.
- **Die-to-die bağlantılar** (2.176 adet), iki yonga arasında doğrudan ve kısa yollarla veri alışverişi yapılmasını sağlar.

### **Avantajları**

1. **Yüksek Performanslı Paralel İşlem:** İki yonga sayesinde işlem gücü iki katına çıkar, CPE dizileri simetrik yerleştiği için yük dengeli dağılır.
2. **Düşük Gecikmeli İletişim:** Die-to-die bağlantılar doğrudan silikon üzerinde olduğu için sinyal gecikmesi minimumdur. //sinyal gecikmesi ile alakalı test sonuçları varsa eklensin 
3. **Yüksek Bant Genişliği:** 2.176 bağlantı sayesinde iki yonga arasında çok yüksek veri aktarım kapasitesi sağlanır.
4. **Isı Dağılımı:** İşlem yükü iki yongaya dağıldığı için termal yoğunluk azalır.
