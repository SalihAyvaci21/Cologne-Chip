## SerDes Mimarisi Genel Bakış

SerDes, veri iletimi için **seri (tek hat üzerinden) veri akışını** sağlayan bir bileşendir. Aynı zamanda, **seri veriyi paralel hale getirip işleme** yeteneğine sahiptir. Bu, yüksek hızlı veri iletimi sağlayan **serileştirme (serialization)** ve **deserileştirme (deserialization)** işlemlerini ifade eder.

###  GateMate™ SerDes Özellikleri

 **Hat Hızı:**
- Maksimum **5 Gbit/s** line rate desteği

**ADPLL (Analog/Digital PLL):** 
- Saat yönetimi

**Physical Coding Sublayer (PCS):
- **Yapılandırılabilir Veri Yolu Genişliği:**  16/20-bit, 32/40-bit veya 64/80-bit veriyolu konfigürasyonu (TX ve RX için)

- **8B/10B Kodlama ve Dekodlama:** Seri veri akışında veri bütünlüğünü korumak için kullanılır.

- **Virgül Tespiti ve Bayt Hizalama:** Veri akışında senkronizasyonu sağlar.

- **Saat ve Veri Kurtarma (CDR):** Alıcı tarafta veri ile saat senkronizasyonunu otomatik olarak düzeltir.

- **Pseudo-Random Bit Stream (PRBS) Jeneratör ve Kontrolörler:** Hata testleri için PRBS oluşturma ve doğrulama desteği

- **Faz Ayarlı FIFO (Elastic Buffer):** Saat düzeltme için faz kaymalarını dengeler.

- **Polarite Kontrolü:** TX ve RX sinyallerinde polariteyi otomatik olarak yönetir.

**Physical Media Attachment (PMA):**

 **3-Tap Karar feedback Eşitleyici (DFE):**
- Hat distorsiyonlarını düzeltir ve sinyal kalitesini artırır.
- Gönderici Ön ve Son Vurgulama (Pre/Post-Emphasis):
- Uzun izlerde sinyal kaybını telafi eder.
- Yapılandırılabilir Gönderici Sürücüsü.
- Farklı hat karakteristiklerine uyum sağlar.

###  Mimari Yapı

SerDes’in çekirdeği aşağıdaki bileşenlerden oluşur:

- **Gönderici (TX):** Veri serileştirme ve hat sürme
- **Alıcı (RX):** Seri veriyi paralel formata dönüştürme ve hata düzeltme

- **Konfigürasyon Arabirimi:**
- FPGA mantığı üzerinden erişilebilen entegre bir **register file** ile yapılandırılır.

SerDes’in basitleştirilmiş blok diyagramını göstermektedir:

- TX PMA ve RX PMA katmanları sinyalin fiziksel iletimi için optimize edilmiştir.
- TX PCS ve RX PCS katmanları veri kodlama, hizalama ve hata kontrol işlemlerini yönetir.

 **Not:** Bu entegre mimari, GateMate™ FPGA’larda düşük gecikmeli ve yüksek bant genişlikli seri bağlantılar için ideal bir çözüm sunar.

![[Cologne Chip/Resimler/Pasted image 20250710110732.png]]



####  **TX PMA (Transmitter Physical Media Attachment)**

- **TX OOB** (Out Of Band): Verinin senkronize edilmeden gönderilmesi işlemi. Diğer deyişle, verinin fiziksel arayüzde iletimi başlamadan önce sinyal hatları üzerinden iletilmesi.
    
- **TX Emph** (Transmitter Emphasis): Verinin iletiminden önce sinyale **güç artırma** ekler. Genellikle sinyalin daha güçlü ve net bir şekilde gönderilmesini sağlar.
    
- **PISO** (Parallel-In, Serial-Out): Paralel veriyi seri hale dönüştürür. Bu blok, veri paralel formatta alınır ve **seri (tek hat üzerinden)** iletilmeye uygun hale getirilir.
    

####  **TX PCS (Transmitter Physical Coding Sublayer)**

- **Phase adjust**: Gönderilen saat sinyali veya veriye faz düzeltmesi ekler, bu da veri iletiminin stabil olmasını sağlar.
    
- **Polarity**: Verinin yönünü kontrol eder, yani verinin ters veya doğru polaritede iletilmesini sağlar.
    
- **PRBS generator** (Pseudo-Random Bit Stream Generator): **PRBS** (psödo rastgele bit akışı), test sinyalleri ve hata kontrolü için kullanılır.
    
- **8B / 10B encoder**: 8 bitlik veriyi 10 bitlik veri formatına dönüştürür. Bu, iletim sırasında hata kontrolünü sağlar ve veri bütünlüğünü korur.
    

####  **RX PMA (Receiver Physical Media Attachment)**

- **RX EQ** (Receiver Equalizer): Alınan sinyali dengelemek ve distorsiyonları düzeltmek için kullanılır.
    
- **DFE** (Decision Feedback Equalizer): Karar geri beslemesi kullanılarak sinyal bozulmaları düzeltilir.
    
- **RX OOB**: Alınan verinin belirli bir zaman aralığında senkronizasyonu yoksa, alınan veriyi işlemeye başlar.
    

#### 4️⃣ **RX PCS (Receiver Physical Coding Sublayer)**

- **Comma detect & align**: Verinin hizalanmasını sağlamak ve veri akışında her şeyin doğru şekilde sıralandığını kontrol etmek için kullanılır.
    
- **PRBS checker**: PRBS sinyali doğrulayıcısı. Gelen sinyalleri kontrol eder ve veri hatalarını tespit eder.
    
- **8B / 10B decoder**: 10 bitlik veriyi 8 bitlik formata dönüştürür.
    
- **Elastic buffer**: Veri akışındaki gecikmeleri dengeler ve senkronizasyon hatalarını düzeltir.
    

#### 5️⃣ **ADPLL (Analog/Digital Phase-Locked Loop)**

- **ADPLL** modülü, saat sinyali üretimi ve senkronizasyonu için kullanılır. **SerDes**’teki zamanlama uyumsuzluklarını düzeltmek için faz kilitleme ve veri senkronizasyonu sağlar.
    

#### 6️⃣ **Register File**

- **Register File**, SerDes’in tüm parametrelerini yapılandırmak ve kontrol etmek için kullanılan hafızadır. Bu dosya, FPGA tasarımı üzerinden erişilebilir.
    

#### 7️⃣ **FPGA TX & RX Interfaces**

- **FPGA TX Interface:** Gönderici tarafında, verinin SerDes sistemi ile FPGA arasındaki bağlantısını sağlar.
    
- **FPGA RX Interface:** Alıcı tarafında, SerDes sistemi ile FPGA arasındaki veri akışını kontrol eder.
    

---

### **Genel Akış:**

1. **TX PMA**: Verinin paralel olarak alınması ve seri hale getirilmesi.
    
2. **TX PCS**: Veri kodlama ve faz düzeltmesi yapılır, ardından PRBS sinyali üretimi ve hata kontrolü sağlanır.
    
3. **RX PMA**: Alınan sinyalin iyileştirilmesi (eşitleme) ve analogdan dijitale dönüşüm yapılır.
    
4. **RX PCS**: Alınan sinyalin doğru hizalanması sağlanır ve verinin hatasız şekilde alınması için doğrulama yapılır.
    
5. **ADPLL**: Saat senkronizasyonu ve faz düzeltmesi yapılır.
    
6. **Register File**: Tüm ayarlar ve parametreler burada saklanır ve FPGA’dan kontrol edilebilir.
    

---

### **SerDes'in Kullanım Alanları:**

- **Veri iletimi:** Özellikle yüksek hızlı veri iletimi, video sinyalleri ve ağ iletişimi gibi uygulamalar için kullanılır.
    
- **FPGA iç iletişim:** FPGA tasarımlarında hızlı veri akışları ve senkronizasyon sağlar.
    
- **Seri iletişim protokolleri:** Örneğin, **Ethernet**, **PCIe** ve **Serial ATA** gibi protokoller, SerDes kullanarak veri iletimini gerçekleştirebilir.