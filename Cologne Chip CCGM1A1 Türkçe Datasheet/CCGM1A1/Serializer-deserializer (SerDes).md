## SerDes Mimarisi Genel Bakış   //özetle//

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

![[Pasted image 20250710110732.png]]



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


####  **RX PCS (Receiver Physical Coding Sublayer)**

- **Comma detect & align**: Verinin hizalanmasını sağlamak ve veri akışında her şeyin doğru şekilde sıralandığını kontrol etmek için kullanılır.
- **PRBS checker**: PRBS sinyali doğrulayıcısı. Gelen sinyalleri kontrol eder ve veri hatalarını tespit eder.
- **8B / 10B decoder**: 10 bitlik veriyi 8 bitlik formata dönüştürür.
- **Elastic buffer**: Veri akışındaki gecikmeleri dengeler ve senkronizasyon hatalarını düzeltir.


####  **ADPLL (Analog/Digital Phase-Locked Loop)**

- **ADPLL** modülü, saat sinyali üretimi ve senkronizasyonu için kullanılır. **SerDes**’teki zamanlama uyumsuzluklarını düzeltmek için faz kilitleme ve veri senkronizasyonu sağlar.

####  **Register File**

- **Register File**, SerDes’in tüm parametrelerini yapılandırmak ve kontrol etmek için kullanılan hafızadır. Bu dosya, FPGA tasarımı üzerinden erişilebilir.


####  **FPGA TX & RX Interfaces**

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


![[Pasted image 20250710111228.png]]
**SerDes**, yüksek hızlı seri veri iletimleri için kullanılan önemli bir bileşendir ve bu diyagramda **veri iletimi** ve **veri alımı** süreci açıklanmaktadır.

---

### **CC_SERDES Blok Diyagramı Bileşenleri**

#### ** Transmitter (Gönderici)**

Gönderici kısmı, verinin **seri hale dönüştürülmesi** ve iletilmesi işlemlerini yönetir.

- **TX_RESET**: Gönderici tarafını sıfırlama sinyali.
- **TX_PCS_RESET**: Transmitter Physical Coding Sublayer (PCS) kısmının sıfırlanması.
- **TX_PMA_RESET**: Transmitter Physical Media Attachment (PMA) kısmının sıfırlanması.
- **TX_POWER_DOWN**: Gönderici kısmının güç tasarrufu moduna alınması.
- **TX_CLK**: Gönderici için saat sinyali.
- **TX_POLARITY**: Gönderici veri polaritesini ayarlamak için kullanılır (tersten iletim için).
- **TX_PRBS_FORCE_ERR**: Gönderilen PRBS sinyalinde hata zorlaması yapar.
- **TX_8B10B_BYPASS**: 8B/10B kodlama bypass’ı sağlar.
- **TX_CHAR_IMS_K**: Sinyal karakteristiklerini ayarlayan parametre.
- **TX_CHAR_DISP_MSB, TX_CHAR_DISP_LSB**: Sinyal karakteristiklerini gösteren bitler.
- **TX_DATA**: Gönderilen veri (64-bit veri hattı).
- **TX_DETECT**: Veri algılama sinyali.

#### **Receiver (Alıcı)**

Alıcı kısmı, alınan veriyi **paralel formata dönüştürme** ve **hata kontrolü** işlemlerini yapar.

- **RX_RESET**: Alıcı kısmını sıfırlama sinyali.
- **RX_PMA_RESET**: Alıcı PMA kısmının sıfırlanması.
- **RX_EQA**: Alıcı eşitleme ayarı.
- **RX_CDR**: Clock Data Recovery (Saat ve veri kurtarma).
- **RX_PRBS_SEL**: Alıcı PRBS seçimi.
- **RX_POLARITY**: Alıcı veri polaritesini ayarlamak için kullanılır.
- **RX_PRBS_CHECKER**: PRBS doğrulama (hata kontrolü).
- **RX_COMMMA_ALIGN**: Komma hizalama (komut tespiti).
- **RX_DATA**: Alınan veri (64-bit veri hattı).

#### **Clock and Control**

- **PLL_RESET_I**: PLL sıfırlama sinyali.
- **ADPLL**: Analog/Dijital PLL, saat senkronizasyonunu sağlar.
- **PLL_CLK**: PLL çıkış saati.

#### **Register File (Kayıt Dosyası)**

Veri kontrolü ve ayarları için bir register dosyası bulunur:

- **REGFILE_CLK**: Kayıt dosyası saat sinyali.
- **REGFILE_WE**: Kayıt dosyasına yazma etkinleştirme sinyali.
- **REGFILE_ADDR[7:0]**: Kayıt adresi.
- **REGFILE_DI[15:0]**: Kayıt verisi.
- **REGFILE_MASK[15:0]**: Maskeleme verisi.
- **REGFILE_RDY**: Kayıt dosyasının hazır durumu.    

---

### **Çalışma Prensibi**

- **TX kısmı**, paralel veriyi alıp serileştirir ve seri olarak iletir.
- **RX kısmı**, alınan serili veriyi paralel hale getirir ve hata kontrolü yapar.
- **ADPLL** modülü, alıcı ve verici arasındaki saat uyumsuzluklarını düzeltir ve **clock recovery** sağlar.
- **PRBS (Pseudo-Random Bit Stream)** jeneratörleri ve kontrolörleri, sinyal doğruluğunu test etmek için kullanılır.

---

### **Bağlantılar ve Akış**

- **SerDes** modülü, **FPGA TX/RX interface** ile veri iletişimi sağlar.
- **LVDS** (Low Voltage Differential Signaling) kullanılarak yüksek hızda veri iletimi gerçekleştirilir.
- **Loopback (geri dönüş)** işlemleri, hem **near-end** hem de **far-end** test işlemleri için yapılabilir.


## SerDes: Veri Yolu Yapısı ve Çalışma Prensibi

**SerDes** modülü, FPGA’daki **bit hızında seri veri iletimi** ve **alımı** için kullanılan bir yapıdadır. **ADPLL** (Analog/Dijital Phase-Locked Loop), dış bir referans saat sinyalinden **seri iletim için bit hızında saat sinyali** üretir. Ayrıca, alıcı ve verici veri yollarının çalışması için gerekli saat sinyallerini de üretir.

---

###  Gönderici (Transmitter) Veri Yolu

SerDes’in **verici veri yolu**, aşağıdaki modüllerden oluşur:

- **8b / 10b Encoder:** Veriyi **8 bitlik** formattan **10 bitlik** formata dönüştürerek iletimdeki hata kontrolünü sağlar.
- **Pattern Generator (PRBS Jeneratörü):** **Pseudo-Random Bit Stream** (PRBS) üretir. Bu, test verisi ve hata kontrolü için kullanılır.
- **Polarity Inverter:** Gönderilen verinin polaritesini tersine çevirir.
- **Phase Adjust FIFO (Verici Buffırı):** Gönderici ve alıcı arasındaki **farklı saat alanlarında** (clock domains) oluşan **faz kaymalarını hizalar**. Bu adım, **paralel veriyi seri formata dönüştürmek** için gereklidir ve **PISO (Parallel-In Serial-Out)** fonksiyon bloğu ile yapılır.
- **Transmit Driver:** Veri iletimini sağlamak için **feed-forward equalization** (ileriye doğru eşitleme) kullanır ve iletim sürücüsünün **analog işletme parametreleri**, **register file** üzerinden yapılandırılabilir.


---

### Alıcı (Receiver) Veri Yolu

SerDes’in alıcı veri yolu da benzer modüllere sahiptir:

- **Polarity Inverter:** Alınan verinin polaritesini tersine çevirir.
- **PRBS Checker:** Alınan PRBS sinyalini kontrol eder ve veri doğruluğunu kontrol eder.
- **8b / 10b Decoder:** 10 bitlik veriyi tekrar 8 bitlik formata çevirir.
- **Comma Detection ve Symbol Alignment Unit:** Alınan verideki **virgül tespiti** ve **sembol hizalama** işlemlerini yapar.
- **Elastic Buffer:** Saat toleranslarını dengelemek için veriyi geçici olarak tamponlar.
- **Clock and Data Recovery (CDR):** Alıcı tarafında **saat ve veri uyumu** sağlamak için kullanılır.
- **Receiver PMA (Physical Media Attachment):** Alıcı ön uç (front-end) bileşeni, sinyali **lineer eşitleyici (receiver EQ)** ile iyileştirir ve sonrasında **DFE (Decision Feedback Equalizer)** ile optimize eder.


---

### Loopback Desteği

SerDes, **verici ve alıcı veri yolları arasında** doğrudan bağlantılar sağlayarak, **veri döngüsünü (loopback)** çeşitli seviyelerde test etmek için kullanılabilir.

---

- **SerDes Primitifi

SerDes modülünün temel bileşenleri ve işleyişi **Şekil 2.30**’da gösterilmektedir.

---

-  **Not:** SerDes, FPGA içinde yüksek hızlı veri iletim ve alım işlemlerini destekler. Veri doğruluğu, hata kontrolü ve sinyal kalitesini artırmaya yönelik çeşitli modüller ve fonksiyonlarla optimize edilmiştir.




## SerDes ADPLL (Analog/Dijital Phase-Locked Loop)

**ADPLL**, SerDes bloğunda hassas zamanlama kontrolü sağlamak amacıyla tasarlanmış düşük jitter’lı (düşük zamanlama sapması) ve yüksek performanslı bir saatleme modülüdür. **ADPLL**, özel bir referans saat girişi (**SER_CLK** ve **SER_CLK_N pinleri**) kullanarak çalışır. Bu giriş, **single-ended** veya **LVDS** (Low Voltage Differential Signaling) modlarına yapılandırılabilir ve **100 MHz ile 125 MHz** arasında bir referans saat frekans aralığını destekler.
**ADPLL**, SerDes için kritik zamanlama işlevlerini yerine getirir, yüksek hızda veri iletimi ve alımı için gerekli olan saat sinyallerini üretir ve bu sayede **FPGA içinde hassas saat uyumunu** sağlar.

---

###  ADPLL’in Fonksiyonu

- Sağlanan **referans saat sinyali** kullanılarak, **ADPLL**, **seri veri iletimi** için gereken **bit rate clock (BRC)** üretir.
- Ayrıca, alıcı ve verici veri yollarının çalışması için gerekli olan **data path clock (DPC)** saat sinyalini üretir. Bu saat, **PCS seviyesinde** kullanılır.

---

###  Saat Sinyali Dağıtımı

- **ADPLL**, **PLL_CLK_O** çıkış portu aracılığıyla **core clock** sinyalini sağlar.
- Bu saat sinyali, FPGA mantık yapısında **TX_CLK_I** ve **RX_CLK_I** portlarına bağlanmalıdır.
    - **TX_CLK_I** → Gönderici veri yolu (TX)
    - **RX_CLK_I** → Alıcı veri yolu (RX)

Daha fazla detay için aşağıdaki şekilden yararlanabilirsiniz, **data path** ile ilgili portlara başvurulabilir.

Alternatif olarak, alıcı veri yolunda, alınan veriden **clock sinyali** geri kazanılabilir. Bu sinyal **RX_CLK_O** portu üzerinden çıkış yapar.  
Daha fazla bilgi için aşağıdaki **Clock and Data Recovery (CDR)** kısmına bakılabilir.




![[Pasted image 20250711110104.png]]

## CC_SERDES PLL Port Tanımları

| **Port Adı**  | **Genişlik (bit)** | **Yön** | **Açıklama**             |
| ------------- | ------------------ | ------- | ------------------------ |
| `PLL_RESET_I` | 1                  | input   | Asynchronous ADPLL reset |
| `SER_CLK_I`   | 1                  | input   | SerDes clock input       |
| `PLL_CLK_O`   | 1                  | output  | Data path clock output   |

![[Pasted image 20250710112942.png]]


![[Pasted image 20250710113145.png]]

- **M1 ve M2**, saat sinyalinin geçebileceği iki farklı yol (path). M1 genelde varsayılan (default) yoldur.
- **FCNTRL_ALTPATH** register'ı, saat sinyalinin alternatif yoldan (M2) mı yoksa normal yoldan (M1) mı geçeceğini belirler.
- **Multiplexer** değeri, hangi yolun seçildiğini gösterir: `1` ise M2, `0` ise M1.
- **PLL_FCNTRL** register'ı, saat sinyalinin frekansını veya fazını kontrol eden ayarları içerir. Belirli değerlerdeyken M2 yolu aktif hale gelir.

![[Pasted image 20250710113240.png]]


## Mimariler: CCGM1A1 ve CCGM1A2 – Saat Frekanslarının Ayarlanması

###  Saat Frekansları

**Bit Rate Clock (BRC)** ve **Data Path Clock (DPC)** saat frekansları, seçilen **referans saat frekansı (fSER_CLK)**'na dayanarak belirlenir. Bu ayarlamalar,  **N1, N2, N3 ve M3** parametreleri ile yapılır. Bu parametrelerin her biri belirli bir **değer aralığına** sahiptir ve **SerDes**’in ilgili **register alanları** üzerinden yapılandırılabilir.

$f_{DPC}$ =  $f_{SER_CLK}$ ($N_{3}$ . $N_{3}$ . $N_{3}$)/($M_{3}$)

ve

$f_{DPC}$ =  $f_{SER_CLK}$ ($N_{3}$ . $N_{3}$ . $N_{3}$)/($M_{3}$) .  1/($M_{1}$ . $M_{4}$)  = $f_{BRC}$ /($M_{1}$ . $M_{4}$)

###  Parametre Ayarları

- **M1 bölücü değeri**, **PLL_FCNTRL** register alanı aracılığıyla ayarlanabilir.

   - **PLL_FCNTRL = 0** ve **PLL_FCNTRL = 1**: Bu iki durum, **M1** değerini **ayarlamaz**, ancak alternatif saat yolu için farklı bir kullanım sağlar.
   - **FCNTRL_ALTPATH** yapılandırması hakkında detaylar için **Tablo 2.16**'ya başvurulmalıdır.


###  64-Bit Veri Yolu Kullanımı

- Eğer **64-bit veri yolu** kullanılıyorsa, **TX_DATAPATH_SEL[1] = 1** değeri ayarlanır. Bu durumda, saat yoluna **ekstra bir M4 = 2 bölücüsü** eklenir.

- Diğer veri yolları için, ekstra bir bölücü eklenmesine gerek yoktur. Bu durumda, **TX_DATAPATH_SEL[1] = 0** olur ve **M3’ün çıkışı** doğrudan **PLL çıkışı PLL_CLK_O**'ya yönlendirilir.

###  Özet

- **fSER_CLK**, **BRC** ve **DPC** saat frekanslarını belirler.
- **M1** bölücü değeri **PLL_FCNTRL** ile yapılandırılır ve alternatif saat yolları için özel durumlar vardır.
- 64-bit veri yolu kullanılıyorsa, **M4 = 2** bölücüsü eklenir.



## ADPLL ve Saat Kayması Örneği

**ADPLL**, bit rate clock’a göre **faz kaydırılmış birkaç saat sinyali** üretir. Bu sinyaller, **SerDes** tarafından iletim hızını **iki katına çıkarmak** için kullanılır. Örneğin, **2.5 Gbit/s**'lik bir iletim hızı, **1.25 GHz**'lik bir frekansa ihtiyaç duyar. Bu, **denklem 2.1** ve aşağıdaki ayarlamalar kullanılarak elde edilebilir, **harici 100 MHz referans saati** ile:

---

###  İletim Hızı ve Saat Ayarları:

- **İletim Hızı:** 2.5 Gbit/s
- **Gerekli Frekans:** 1.25 GHz
- **Referans Saati:** 100 MHz (harici)

---

###  Denklemler ve Ayarlar

 Aşağıdaki formül kullanılarak, 1.25 GHz frekansının elde edilmesi için gerekli ayarları ve hesaplamaları gösterir.  
Bu hesaplama, **100 MHz referans saati** ile **ADPLL** tarafından sağlanan **faz kaydırma saat sinyalleri** kullanılarak yapılır.


$f_{DPC}$ =  $f_{SER_CLK}$ ($N_{3}$ . $N_{3}$ . $N_{3}$)/($M_{3}$) =>  100 MHz · (1 · 5 · 5)/2 = 1.25 GHz



- **İletim Hızı (Transfer Rate):**  2 $f_{BRC}$ = 2.5 Gbit

- **Hedef Frekans (Required Core Clock Frequency):**  
    Verilen bilgiye göre, iletim hızını sağlamak için gerekli olan **core clock** frekansını hesaplamamız gerekiyor.
###  Hesaplama:

**İletim Hızı (2.5 Gbit/s)**, **bit rate clock ($f_{BRC}$)** ile ilişkilidir. Bu durumda:

2$f_{BRC}$ =2.5 Gbit

$f_{BRC}$ = (2.5 Gbit/s)/2 = 1.25 Gbit/s

$f_{core}$​=($f_{BRC}$)​×64=(1.25GHz)×64 = 80GHz
    
Core clock için gerekli frekans: 80 MHz.

---

## 8B/10B Kodlaması ve Core Clock Hesaplaması

**8B/10B kodlaması** ile **64 bitlik veri**, aslında **80 bit** olarak iletilir. Bu, her 8-bit veri parçasının 10 bitlik veri ile gönderilmesi anlamına gelir. Bu kodlama yöntemi, veri iletiminde hata kontrolü sağlar ve senkronizasyonu düzenler.

- Saat frekansını denklem ve bölücüler **M1** kullanarak hesaplayabiliriz. Ayrıca, **M4 = 2** bölücüsü de dikkate alınmalıdır.

- **64 bit veri** → **80 bit iletim (8B/10B kodlama)**
	- **f₀ (core clock)** için gerekli olan saat frekansını bulmamız için:

$f_{core}$​=($f_{BRC}$​×Veri Yolu Genişliğ​i)/(Kodlama Farkı)​

$f_{core}$ = (1.25 Gbit/s x 64)/80 = 1GHz

- **Core clock** için gerekli olan frekans: **1 GHz**

### M4 = 2 Bölücüsü:

**M4 = 2** bölücüsü kullanıldığında, frekansın iki katına çıkması sağlanır. Bu da şu şekilde hesaplanır:

$f_{core}$ = (1 GHz)/$M_{4}$ = 1/2 GHz = 500 MHz


![[Pasted image 20250710132620.png]]

## ADPLL Entegre Kendiliğinden Kalibrasyon (BISC)

**ADPLL saat üreteci**, çalışma sırasında minimum jitter sağlamak amacıyla **loop filter (dönüşüm filtresi)** orantılı kazanç parametresi **CP** için iki entegre kalibrasyon şeması sunar. Bu kalibrasyon şemaları, **ADPLL’in çalışma doğruluğunu** ve **sinyal kararlılığını** artırmak için kullanılır.

###  Kalibrasyon Modları:

- **Mod A**:
    - Bu modda, jitter minimizasyonu için **ek bir PFD (Phase Frequency Detector)** kullanılır.
    - Ancak, bu mod **önerilmez** çünkü ek bileşenler ve karmaşıklıklar getirir.
    - Önerilmez.
    
- **Mod B**:
    - Bu modda, jitter minimizasyonu için **dahili PFD sinyali** kullanılır.
    - **Mod B**, daha **tercih edilen** yöntemdir çünkü daha basit ve daha verimli çalışır.
    - **Dahili PFD ile**: Tercih edilir.



![[Pasted image 20250710132942.png]]
Bu tablo, Gatemate FPGA işlemcisinin **PLL_BISC_MODE** adlı register'ının nasıl yapılandırıldığını gösteriyor. Bu register, **BISC (Built-In Self Calibration)** fonksiyonunun kontrolüyle ilgili. 


![[Pasted image 20250710133019.png]]
![[Pasted image 20250710133029.png]]
Bu yapılandırma sayesinde, kullanıcılar BISC fonksiyonunu uygulamanın ihtiyaçlarına göre **tek seferlik ölçüm**, **tek seferlik kalibrasyon**, **sürekli kalibrasyon** veya **gelişmiş kalibrasyon** modlarında çalıştırabilir. Özellikle **Mode A**, düşük kaynak tüketimi ve hızlı başlatma süresi gerektiren sistemler için uygundur.

## SerDes Sıfırlama (Reset)

 **SerDes**'in üzerinde bulunan ve FPGA fabric’i aracılığıyla erişilebilen **sıfırlama arabirimlerini** gösterir. Bu arabirimler, SerDes mimarisindeki çeşitli sıfırlama işlemlerini gerçekleştirmek için kullanılabilir.
###  Sıfırlama Sinyalleri

- **Sıfırlama Sinyalleri Asenkronik (Asynchronous)** olarak çalışır.
- **ADPLL** ve **verici (transmitter) ile alıcı (receiver) veri yollarının sıfırlanması** özellikle önemlidir.
- Her iki veri yolu için de, SerDes, mevcut sıfırlama durumunu belirten ek arabirimler sunar.

---

###  SerDes İşleyişi ve Resetleme İlişkisi

SerDes’in düzgün çalışabilmesi için, **bireysel bileşenlerin sıfırlamalarının içsel olarak bağlantılı olduğunu** bilmek önemlidir.

- **Verici veya alıcı veri yolunun sıfırlanması**, her zaman **ilgili PCS**, **PMA**, **CDR** ve **DFE** modüllerinin sıfırlanmasını tetikler.
- **Alıcı veri yolu** için, bu sıfırlama işlemi ayrıca **elastic buffer**'ı da içerir.


###  ADPLL ve Veri Yolları İlişkisi

**ADPLL’in durumu** ile **verici ve alıcı veri yolları** arasında özel bir ilişki vardır:

- **ADPLL**, **verici ve alıcı veri yollarını sıfır durumda tutar**.
- Bu sıfırlama durumu, **ADPLL’in kilitlenmesi (lock)** sağlanana kadar devam eder.
- **ADPLL’in sıfırlanması**, her zaman verici ve alıcı veri yollarının sıfırlanmasına yol açar.

---

###  Otomatik Sıfırlama Zinciri

FPGA sıfırlama işlemi ve **SerDes**'in ilgili yapılandırması, **otomatik sıfırlama zinciri** (automatic chaining of resets) şeklinde gerçekleştirilir:

- Bu işlem, **ADPLL’in etkinleştirilmesi** ile başlar. **PLL_EN_ADPLL_CTRL** register alanı kullanılarak yapılır (adres: **0x50 [0]**).
- Sonrasında, **TX_RESET_DONE_O** ve **RX_RESET_DONE_O** sinyallerinin **kenar değişiklikleri** (edge changes) ile tamamlanır.
- **Not:** Alıcı veri yolu, **verici veri yolundan sonra** bir zaman gecikmesiyle sıfırlanır.

## CC_SERDES Reset Arayüzleri

| **Port Adı**     | **Genişlik (bit)** | **Yön** | **Açıklama**                                                    |
| ---------------- | ------------------ | ------- | --------------------------------------------------------------- |
| `PLL_RESET_I`    | 1                  | input   | Asynchronous ADPLL reset                                        |
| `TX_RESET_I`     | 1                  | input   | Asynchronous transmitter data path reset                        |
| `TX_PCS_RESET_I` | 1                  | input   | Asynchronous transmitter PCS (Physical Coding Sublayer) reset   |
| `TX_PMA_RESET_I` | 1                  | input   | Asynchronous transmitter PMA (Physical Medium Attachment) reset |
| `RX_RESET_I`     | 1                  | input   | Asynchronous receiver data path reset                           |
| `RX_PCS_RESET_I` | 1                  | input   | Asynchronous receiver PCS reset                                 |
| `RX_CDR_RESET_I` | 1                  | input   | Asynchronous receiver CDR (Clock Data Recovery) reset           |
| `RX_EQA_RESET_I` | 1                  | input   | Asynchronous receiver DFE (Decision Feedback Equalizer) reset   |
## Loopback Testi ve SerDes Fonksiyonelliği Doğrulaması

**Loopback testi**, **SerDes fonksiyonelliğini** dışsal bağımlılıklar olmadan **kendiliğinden teşhis etme ve doğrulama** sağlamak için kullanılır. Bu test, verilerin iletim ve alım bütünlüğünü **iç devreler** içinde doğrular.

---

###  **Near-End Loopback (Yakın Uç Loopback)**

- **Near-end loopback**, iletilen sinyalin aynı cihazda, aynı iletişim bağlantısı tarafında (yani gönderme tarafında) alıcıya geri yönlendirilmesi durumudur.
- FPGA bağlamında, bu test, **SerDes çıkışını** alıp aynı **SerDes’in girişine** veya aynı FPGA içindeki başka bir **alıcı bloğuna (receiver block)** yönlendirmeyi içerir.
- Bu, **verici ve alıcı fonksiyonelliğini** test etmek için fiziksel olarak başka bir cihaza bağlanmaya gerek kalmadan yapılabilir.
    

---

###  **Avantajlar**

- **Fiziksel bağlantı gereksizdir:** **SerDes**'in verici ve alıcı fonksiyonlarını test etmek için başka bir cihazla bağlantı kurulmasına gerek yoktur.
- **İç Devre Testi:** Verinin iç devrelerdeki iletim ve alım bütünlüğü doğrudan test edilir, böylece FPGA tasarımının doğruluğu kontrol edilir.

### Loopback Türleri

Diyagramda dört farklı loopback türü gösterilmiş:

- **Near-end PCS loopback**: FPGA içindeki fiziksel kodlama katmanında (PCS) veri gönderilip alınır. Hızlı testler için idealdir.
- **Near-end PMA loopback**: Fiziksel ortam bağlantı katmanında (PMA) veri döngüsü yapılır. Analog sinyal yolu test edilir.
- **Far-end PCS loopback**: Uzak cihazın PCS katmanında veri döndürülür. FPGA'den çıkan veri karşı tarafa gider ve geri gelir.
- **Far-end PMA loopback**: En kapsamlı testtir. Analog kanal üzerinden tam yol test edilir.

###  GateMate FPGA Yapısı

GateMate FPGA tarafında şu bileşenler var:

- **Pattern Generator**: Test için veri üretir.
- **TX PCS / TX PMA**: Veriyi kodlayıp fiziksel ortama gönderir.
- **RX PMA / RX PCS**: Gelen veriyi alır ve çözümler.
- **Pattern Checker**: Gelen veriyi kontrol eder, hataları tespit eder.

### Loopback Etkinleştirme

Bir loopback’ı etkinleştirmek için, ilgili kodlama **LOOPBACK_I** girişine uygulanabilir.

###  Analog Kanal

GateMate FPGA ile uzak cihaz arasında bir analog kanal var. Bu kanal üzerinden gerçek sinyal iletimi test ediliyor. Özellikle **far-end loopback** testlerinde bu kanal kritik rol oynar.

###  Ne İçin Kullanılır?

- **Donanım doğrulama**: SERDES hatlarının doğru çalışıp çalışmadığını test etmek için.
- **Gürültü ve sinyal bütünlüğü analizi**: Analog kanalın kalitesini ölçmek için.
- **Geliştirme sürecinde hata ayıklama**: Veri kaybı, jitter, veya kodlama hatalarını bulmak için.
![[Pasted image 20250710135120.png]]

## Register File Üzerinden Loopback Yapılandırması

| **Adı**           | **Genişlik (bit)** | **Erişim** | **Varsayılan** | **Açıklama**                                                                                                                                                                                           |
| ----------------- | ------------------ | ---------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `TX_LOOPBACK_OVR` | 1                  | r/w        | 0              | SerDes test modundayken transmitter loopback işlemini yazılımsal olarak zorlar (overwrite).                                                                                                            |
| `TX_PMA_LOOPBACK` | 2                  | r/w        | 0              | `TX_LOOPBACK_OVR` aktifken verici **near-end PMA loopback** zorlanır. Aktif değilse, normal PMA loopback modu ayarlanır. `TX_PMA_LOOPBACK[1]` = `0`, `TX_PMA_LOOPBACK` = `01` → near-end PMA loopback. |
| `TX_PCS_LOOPBACK` | 1                  | r/w        | 0              | `TX_LOOPBACK_OVR` aktifken transmitter **near-end PCS loopback** zorlanır.                                                                                                                             |
| `RX_LOOPBACK_OVR` | 1                  | r/w        | 0              | SerDes test modundayken receiver loopback işlemini yazılımsal olarak zorlar (overwrite).                                                                                                               |
| `RX_PMA_LOOPBACK` | 2                  | r/w        | 0              | `RX_LOOPBACK_OVR` aktifken receiver **far-end PMA loopback** zorlanır.                                                                                                                                 |
| `RX_PCS_LOOPBACK` | 1                  | r/w        | 0              | `RX_LOOPBACK_OVR` aktifken receiver **far-end PCS loopback** zorlanır.                                                                                                                                 |

- **Far-end loopback**: İletilen veri, fiziksel bağlantı üzerinden alınıp tekrar vericiye gönderilir.
- **Near-end loopback**: Veri, aynı cihazın içindeki veri yollarında yönlendirilir ve test edilir.
- **PMA ve PCS katmanlarında yapılan loopback** testleri, her bir katmanın doğruluğunu ve veri iletiminin bütünlüğünü doğrulamaya yardımcı olur.


## **Transceiver Interface**


![[Pasted image 20250710135406.png]]


## **Transceiver Veri Yolu

## **Transceiver Arayüzü ve Veri Yolu Yapılandırması

**Verici arayüzü**, FPGA **fabric**'ine doğrudan bağlantıyı sağlar. Veri yolu genişliği, **TX_DATAPATH_SEL** (regfile 0x40 [4:3]) parametresi kullanılarak yapılandırılabilir.  
Port genişlikleri aşağıdaki seçeneklerde ayarlanabilir:

- **16 / 20 bit**
- **32 / 40 bit**
- **64 / 80 bit**
###  **8B / 10B Encoder Olmadığında:**

- **64-bit genişliğindeki giriş verisi (TX_DATA_I)**, **8-bit genişliğinde iki ek girişle** (TX_CHAR_DISPMODE_I ve TX_CHAR_DISPVAL_I) genişletilir. Bu, veri iletimindeki kodlama için ekstra bilgi sağlar.
- **TX_CHAR_DISPMODE_I** ve **TX_CHAR_DISPVAL_I** her biri 8-bit genişliğinde olup, verinin doğru şekilde iletilmesine yardımcı olur.

- Verici 8B /10B Kodlayıcı'nın nasıl çalıştığı açıklanmaktadır.    

---

###  **Saat Frekansı**

Verici saat frekansı şu faktörlere bağlı olarak belirlenir:

- **Verici hat hızı (line rate)**
- **Veri yolu genişliği**
- **8B/10B encoder** (Eğer etkinleştirilmişse)


###  **8B / 10B Kodlama**

**8B / 10B kodlama** hakkında daha fazla bilgi slaytın devamında bulunmaktadır. Bu kodlama, veri iletiminde hata kontrolü ve veri bütünlüğünü sağlamak için kullanılır.
Aşaağıda, ilgili verici arayüz bağlantı noktalarını göstermektedir.


| **Port Adı**         | **Genişlik (bit)** | **Yön** | **Açıklama**                                                                   |
| -------------------- | ------------------ | ------- | ------------------------------------------------------------------------------ |
| `TX_CLK_I`           | 1                  | input   | Transmitter data path clock sinyali. PLL’in `CLK_CORE_0` çıkışından gelebilir. |
| `TX_RESET_I`         | 1                  | input   | Transmitter data path için asenkron reset sinyali.                             |
| `TX_PCS_RESET_I`     | 1                  | input   | PCS (Physical Coding Sublayer) için asenkron reset sinyali.                    |
| `TX_RESET_DONE_O`    | 1                  | output  | Transmitter reset işleminin tamamlandığını gösteren durum sinyali.             |
| `TX_DATA_I`          | 64                 | input   | Transmitter input data bus.                                                    |
| `TX_CHAR_DISPMODE_I` | 8                  | input   | 8B/10B kodlayıcı devre dışıysa, veri yolu uzantısı olarak kullanılır.          |
| `TX_CHAR_DISPVAL_I`  | 8                  | input   | 8B/10B kodlayıcı devre dışıysa, veri yolu uzantısı olarak kullanılır.          |

8B / 10B kodlayıcı etkinleştirilmediğinde, verici veri yolu sıralaması aşağıda gösterildiği gibidir.

## Register File Üzerinden Verici (Transmitter) Yapılandırması

| **Adı**             | **Genişlik (bit)** | **Erişim** | **Varsayılan** | **Açıklama**                                                                                                                                    |
| ------------------- | ------------------ | ---------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `TX_DATAPATH_SEL`   | 2                  | r/w        | 3              | Transmitter data path genişliği seçimi:  <br>`00`: 16 / 20 bit  <br>`01`: 32 / 40 bit  <br>`1x`: 64 / 80 bit                                    |
| `TX_DATA_OVR`       | 1                  | r/w        | 0              | SerDes test modundayken Transmitter data üzerine yazma izni.                                                                                    |
| `TX_DATA_CNT`       | 3                  | r/w        | 0              | Transmitter data overwrite sırasında kullanılacak 16-bit kelime adres göstergesi.                                                               |
| `TX_DATA_VALID`     | 1                  | r/w        | 0              | `TX_DATA_OVR` aktifken datanın geçerli olduğunu belirtir.                                                                                       |
| `TX_DATA`           | 16                 | r/w        | 0              | `TX_DATA_CNT` ile belirlenen konuma yazılacak veri. Okuma/yazma ile `TX_DATA_CNT` otomatik artar. Data path genişliğine göre döngüsel davranır. |
| `TX_PCS_RESET_OVR`  | 1                  | r/w        | 0              | SerDes test modundayken PCS reset işlemini üzerine yazar.                                                                                       |
| `TX_PCS_RESET`      | 1                  | r/w        | 0              | `TX_PCS_RESET_OVR` aktifken uygulanacak PCS reset değeri.                                                                                       |
| `TX_PCS_RESET_TIME` | 5                  | r/w        | 3              | `CLK_CORE_TX_1` clock çevriminde PCS reset sinyalinin aktif kalacağı süre.                                                                      |
| `TX_RESET_OVR`      | 1                  | r/w        | 0              | SerDes test modundayken verici reset işlemini üzerine yazar.                                                                                    |
| `TX_RESET`          | 1                  | r/w        | 0              | `TX_RESET_OVR` aktifken                                                                                                                         |


| Name            | Width | Mode | Default | Description                                                                                                     |
| --------------- | ----- | ---- | ------- | --------------------------------------------------------------------------------------------------------------- |
| TX_DATAPATH_SEL | 2     | R/W  | 3       | Transmitter datapath width selection: <br>00:   16 bit / 20 bit <br>01: 32 bit / 40 bit <br>1X: 64 bit / 80 bit |
| TX_RESET_DONE   | 1     | r    | 0       | Transmitter reset status                                                                                        |

![[Pasted image 20250710135801.png]]

### **8B / 10B Kodlamasının Faydaları

1. **DC Bileşeninin Azaltılması:**  
	Bu kodlama yöntemi, iletimdeki **DC bileşenini** (sürekli bileşen) azaltarak daha temiz bir sinyal sağlar.
2. **Sinyal Bütünlüğünün Sağlanması:**  
	Hata tespiti ek bitleri sayesinde sinyalin **bütünlüğü** korunur. Veri kayıpları veya hatalar en aza indirilir.
3. **Kolay Senkronizasyon:**  
    **Verici ve alıcı arasındaki senkronizasyonu** sağlar. Bu, **yüksek hızlı iletişim sistemlerinde** kritik bir özelliktir.
4. **Yüksek Hızlı İletişim:**  
    Bu kodlama tekniği, yüksek hızda veri iletimi için gerekli olan **sinyal kararlılığını** ve **veri doğruluğunu** garanti eder.

---

###  **Özet:**

**8B / 10B kodlama**, yüksek hızlı veri iletimi için kritik bir tekniktir. Hem **hata tespiti** hem de **sinyal dengesini sağlama** işlevi görür ve böylece **verici ile alıcı arasında senkronizasyonu** kolaylaştırır. Bu, özellikle **yüksek hızda veri iletiminde** önemli bir avantaj sağlar.



![[Pasted image 20250710140326.png]]
![[Pasted image 20250710140335.png]]

## **8B / 10B Kodlayıcısının Etkinleştirilmesi ve Gecikme**

**8B / 10B kodlayıcısının etkinleştirilmesi**, verici yolundaki **gecikmeyi artırır**. Ancak, eğer **8B / 10B kodlama** gerekmiyorsa, bu kodlayıcı **devre dışı bırakılabilir** ve **bypass edilebilir**, böylece gecikme minimuma indirilebilir.
###  **Avantaj ve Dezavantajlar:**

|**Avantajlar**|**Dezavantajlar**|
|---|---|
|✅ **Daha Az Gecikme:** 8B / 10B kodlayıcısını devre dışı bırakmak, **verici yolundaki gecikmeyi azaltır**.|⚠ **Hata Kontrolü Kaybı:** Kodlayıcı devre dışı bırakıldığında, veri iletiminde **hata tespiti sağlanamaz**.|
|✅ **Performans Artışı:** Gereksiz kodlama işlemi yapılmazsa, yüksek hızda iletimde **performans artışı** sağlanır.|⚠ **Daha Az Sinyal Bütünlüğü:** Kodlama yapılmadığında, **sinyal bütünlüğü** daha düşük olabilir.|

---

 **Sonuç:**  
Eğer **düşük gecikme** isteniyorsa ve **hata tespiti önemli değilse**, **8B / 10B kodlayıcı devre dışı bırakılabilir**. Ancak, **hata kontrolü ve veri bütünlüğü** gibi gereksinimler söz konusu olduğunda, **8B / 10B kodlama** kullanılmalıdır.



### **Transceiver FIFO**

## SerDes Transceiver: Faz Ayarlama FIFO (Transmit Buffer)

**SerDes Transceiver**, **verici PCS** ve **PMA** domainleri arasındaki faz farklarını çözmek için yerleşik bir **faz ayarlama FIFO (Transmit Buffer)**'ya sahiptir. Bu FIFO, **saat kaymalarını (clock skew)** düzeltir ve veri iletiminin senkronize olmasını sağlar.

---

###  **Faz Ayarlama FIFO’nun Fonksiyonu:**

- **Faz Düzeltmesi:** Verici tarafındaki **PCS** ile **PMA** arasındaki **faz farklarını** düzeltir.
- **Elastic Buffer:** Bu FIFO, veri iletimindeki **gecikmeleri dengeler** ve saat toleranslarını dengeleyerek veri bütünlüğünü sağlar.
- **Yüksek Performans:** **Faz ayarlama FIFO** kullanılarak veri iletiminde daha **düşük gecikme** ve **yüksek doğruluk** elde edilir.

---

###  **Özet:**

**Faz Ayarlama FIFO**, SerDes’te saat senkronizasyonunu sağlamak ve verici ile alıcı arasındaki veri akışını dengelemek için kritik bir bileşendir.


## TX_8B10B_BYPASS / TX_CHAR_IS_K ile İlişkili Veri Baytları

| **TX_8B10B_BYPASS_I Bit** | **TX_CHAR_IS_K_I Bit** | **TX_DATA Baytı** |
| ------------------------- | ---------------------- | ----------------- |
| `TX_8B10B_BYPASS_I[0]`    | `TX_CHAR_IS_K_I[0]`    | `TX_DATA[7:0]`    |
| `TX_8B10B_BYPASS_I[1]`    | `TX_CHAR_IS_K_I[1]`    | `TX_DATA[15:8]`   |
| `TX_8B10B_BYPASS_I[2]`    | `TX_CHAR_IS_K_I[2]`    | `TX_DATA[23:16]`  |
| `TX_8B10B_BYPASS_I[3]`    | `TX_CHAR_IS_K_I[3]`    | `TX_DATA[31:24]`  |
| `TX_8B10B_BYPASS_I[4]`    | `TX_CHAR_IS_K_I[4]`    | `TX_DATA[39:32]`  |
| `TX_8B10B_BYPASS_I[5]`    | `TX_CHAR_IS_K_I[5]`    | `TX_DATA[47:40]`  |
| `TX_8B10B_BYPASS_I[6]`    | `TX_CHAR_IS_K_I[6]`    | `TX_DATA[55:48]`  |
| `TX_8B10B_BYPASS_I[7]`    | `TX_CHAR_IS_K_I[7]`    | `TX_DATA[64:56]`  |

### **CC_SERDES Interface for the Transmit Buffer**

| **Name**       | **Width** | **Direction** | **Description**                                                                                            |
| -------------- | --------- | ------------- | ---------------------------------------------------------------------------------------------------------- |
| `TX_BUF_ERR_O` | 1         | Output        | Buffer aşırı dolumu veya yetersiz dolumu durumunda yüksek. `TX_RESET_I` ve `RESET_CORE_TX_N_I ile silinir. |



### **Transmitter Desen Oluşturucu**

## SerDes: Yerleşik Pattern Jeneratörü

**SerDes** modülü, endüstri standartlarına uygun **psödo-rastgele bit akışı (PRBS)**, **2-UI**, **20 / 40 / 80 UI** kare dalga test desenleri üretmek için tasarlanmış yerleşik bir **pattern generator (desen üretici)** bloğuna sahiptir. Bu desenler, **yüksek hızlı bağlantıların sinyal bütünlüğünü** değerlendirmek için önemli araçlardır.

---

###  **PRBS ve UI Desenlerinin Kullanımı:**

- **PRBS (Pseudo-Random Bit Stream)**: Gerçek rastgele veriye benzer davranış sergileyen ancak **bağlantı kalitesi** ve **performansını değerlendirmek için belirgin özelliklere sahip olan** test desenleridir.
- **2-UI, 20/40/80 UI Kare Dalga Test Desenleri**: Bu desenler, iletim hattındaki **sinyal doğruluğunu**, **gecikmeleri**, **eşitleme** ve **sinyal kalitesini** analiz etmek için kullanılır.
    

---

###  **Test Desenlerinin Faydaları**

1. **Sinyal Bütünlüğü Değerlendirmesi**: Bu desenler, bağlantıdaki **gürültü, bozulma ve veri kaybını** test etmek için kullanılır.
2. **Yüksek Hızlı Bağlantılar**: **PRBS** ve **UI desenleri**, yüksek hızlı veri iletim hatlarında **sinyal kalitesinin** kontrol edilmesini sağlar.
3. **Performans Analizi**: Bu desenler, iletim hattının ne kadar **sağlam** ve **kararlı** çalıştığını belirlemek için kullanılır.

---

**Özet:** **Pattern generator**, SerDes modülündeki önemli bileşenlerden biridir ve test desenlerini **PRBS**, **2-UI**, **20/40/80 UI** gibi çeşitli formatlarda üretir. Bu desenler, yüksek hızlı veri bağlantılarının **sinyal bütünlüğü** ve **performansını** değerlendirmede kritik rol oynar.


![[Pasted image 20250710140823.png]]
![[Pasted image 20250710140831.png]]
## **Receiver Desen Üretici ve Alıcı Desen Doğrulayıcı

Yukarıda gösterildiği gibi, **verici desen üretici** (transmitter pattern generator) ve **alıcı desen doğrulayıcı** (receiver pattern checker) birleşik olarak kullanıldığında, **bağlantı kalitesi** ve **jitter toleransı** hakkında bilgi sağlar. Bu kombinasyon, veri iletim hattındaki **sinyal bozulmalarını**, **zamanlama hatalarını** ve **iletişim doğruluğunu** analiz etmek için oldukça faydalıdır.

---

###  **Receiver Pattern Checker**
Alıcı desen doğrulayıcı, alınan veri akışını inceleyerek iletim hattındaki **hata kontrolü** sağlar. Bu, iletim hattının performansını, **sinyal bozulmalarını** ve **jitter toleransını** değerlendirmek için kullanılır. Register bloklarına ve RAM bölgelerine slaytın devamında yer verilmiştir.

---

###  **Özet:**

- **Desen Üretici ve Doğrulayıcı Kombinasyonu**: Bağlantı kalitesini ve jitter toleransını değerlendirmek için kullanılır.
- **Receiver Pattern Checker**, alınan verinin doğruluğunu kontrol eder ve iletişim hattının **kararlılığını** test eder.
## Verici Polarite Kontrolü

**Verici arayüzü**, çıkıştaki diferansiyel verinin **polaritesinin tersine çevrilmesini** sağlar, böylece **PCB sinyalleriyle uyum sağlanır**. **TX_POLARITY_I** sinyali yüksek olduğunda, çıkış verisinin polaritesi tersine çevrilir.
###  **Verici Polarite Kontrolü İşlevi:**

- **TX_POLARITY_I** sinyali yüksek olduğunda, çıkıştaki veri polaritesi **tersine çevrilir**.
- Bu özellik, PCB tasarımındaki **ters polarite ile uyumlu veri iletimi** sağlar.

### **CC_SERDES Transmitter Polarity Control**

| **Name**        | **Width** | **Direction** | **Description**                                                                                                   |
| --------------- | --------- | ------------- | ----------------------------------------------------------------------------------------------------------------- |
| `TX_POLARITY_I` | 1         | Input         | Transmitter polarity inversion control,<br>`0`: Normal operation,<br>`1`: Invert polarity of outgoing data stream |


### **Transmitter Configurable Driver**
## Elektriksel Hat Sürücüsü (Line Driver) Mimarisi

Elektriksel hat sürücüsü, **anahtarlanmış akım yansıma (switched current mirror)** mimarisi kullanır. Bu mimari, çıkış sinyalinin **diferansiyel salınımı** (differential output swing) ve **ortak mod voltajı** (common-mode voltage) üzerinde etki yapan **birden fazla ölçekleme faktörü** ile çalışır.

Hat sürücüsü, **125 seçilebilir dal (branch)** içerir ve her biri **bireysel olarak etkinleştirilebilir**. Etkinleştirilen dal, çıkış sinyaline katkı sağlar. **Aktive edilmemiş dal** ise **pasif kalır** ve çıkış salınımına herhangi bir etkisi olmaz.

---

###  **Çalışma Prensibi:**

- **Akım Yansıma Yapısı:** Elektriksel hat sürücüsü, **akım yansıma** prensibiyle çalışır ve sinyal çıkışını **çekirdek akımın** çeşitli dallarına yönlendirir.
- **Dal Seçimi:** 125 dal arasından istenen dal aktif hale getirilerek çıkışa katkı sağlanır.
- **Daha Az Aktif Dal ile Daha Düşük Güç Tüketimi:** Gereksiz dallar pasif kalır, böylece enerji verimliliği sağlanır.


![[Pasted image 20250710141742.png]]

## Elektriksel Hat Sürücüsü ve Feed-Forward Eşitleme (FFE)

Bu dallar, **feed-forward eşitleme (FFE)** için **üç grup halinde düzenlenmiştir**. Bu yapı, verici tarafında **de-emphasis** (zayıflatma) ve **pre-emphasis** (ön vurgulama) işlemlerini kolaylaştırır.

---

###  **Dal Grupları:**

1. **Birinci Grup (63 Dal):**
    - Bu grup, ya **ana işaretleyiciye** (main cursor) katkı sağlar ya da **kapalı kalır**.
    
2. **İkinci Grup (31 Dal):**
    - Bu grup, ya **ana işaretleyiciye (main cursor)** ya da **ön işaretleyiciye (pre-cursor)** katkı sağlar veya **kapalı kalır**.
    
3. **Üçüncü Grup (31 Dal):**
    - Bu grup, ya **ana işaretleyiciye (main cursor)** ya da **sonraki işaretleyiciye (post-cursor)** katkı sağlar veya **kapalı kalır**.
    

---

###  **Çıkış Salınımı (Differential Output Swing)**

- Çıkıştaki diferansiyel salınım, **sürme akımının** etkili direncinden **akışını** sağlar. Bu direnç, verici **terminasyon** ve **hat empedansı** (tipik olarak **50 Ω diferansiyel**) paralel kombinasyonu tarafından belirlenir.
    
- **Aktif dalların sayısı ve bu dalların ön, ana ve sonrası işaretleyiciye atanması** ile **de-emphasis** ve **pre-emphasis** işlemleri etkili bir şekilde gerçekleştirilebilir.
### **Özet:**

- **Dallar, üç gruba ayrılarak** saat sinyalini iyileştirmek için **feed-forward eşitleme (FFE)** sağlanır.
    
- **Aktif dal sayısı** ve **işaretleyiciye atanan dallar**, **de-emphasis** ve **pre-emphasis** işlemlerini kontrol eder.


![[Pasted image 20250710142244.png]]
![[Pasted image 20250710142253.png]]

| Voltaj Seviyesi     | Tanımı                                                                                   |
| ------------------- | ---------------------------------------------------------------------------------------- |
| Va - Signal Voltage | Temel veri sinyali voltajıdır.                                                           |
| Vb - De-emphasized  | Sinyal seviyesini azaltma; önceki bitlerle karşılaştırıldığında düşük voltaj uygulaması. |
| Vc - Pre-emphasized | Ön vurgulama; yüksek voltaj ile sinyalin daha belirgin hale getirilmesi.                 |
| Vd - Boost Voltage  | Güçlendirme voltajı; zayıf sinyalin daha net algılanması için voltaj artırımı.           |

Zaman ekseni boyunca bu voltaj seviyeleri, verinin gönderilme şekline göre değişiyor. Böylece **kanaldaki kayıplar**, **yansımalar** ve **zayıflamalar** telafi edilmiş oluyor.


#### Aktif Akım Hesabı 

I_TX = (TX_TAIL_CASCADE + 10) · (TX_AMP + 1) · 9.375 μA

- **I_TX**, gönderici tarafındaki temel akımı belirtir.
- TX_TAIL_CASCADE ve TX_AMP, yapılandırılabilir parametrelerdir.


####  Dal Sayısı ve Akım Dağılımı 


N_BRA = TX_BRANCH_EN_PRE + TX_BRANCH_EN_MAIN + TX_BRANCH_EN_POST
N_PRE_CUR = TX_SEL_PRE
N_POST_CUR = TX_SEL_POST
N_MAIN_CUR = N_BRA - N_PRE_CUR - N_POST_CUR


- Her biri gönderici sürücüdeki bir zamanlama bölümünü kontrol eder: **PRE, MAIN, POST**
- Dal sayılarıyla akım, zaman bölgesine göre paylaştırılır.

####  Diferansiyel Voltaj Seviyeleri 

V_a = (N_MAIN_CUR - N_PRE_CUR + N_POST_CUR) · I_TX · 50Ω
V_b = (N_MAIN_CUR - N_PRE_CUR - N_POST_CUR) · I_TX · 50Ω
V_c = (N_MAIN_CUR + N_PRE_CUR - N_POST_CUR) · I_TX · 50Ω
V_d = (N_MAIN_CUR + N_PRE_CUR + N_POST_CUR) · I_TX · 50Ω


- Farklı sinyal seviyeleri, SerDes çıkış sinyalinin vurgulanma (emphasis) biçimini temsil eder.
- **50Ω**: Hat empedansı ile uyumluluk sağlar.

####  Ortak Mod Voltaj Regülasyonu

V_CM = V_DD + (14 + TX_CM_THRESHOLD) / 60

- Ortak mod voltaj aralığı, **TX_CM_THRESHOLD_0** ve **TX_CM_THRESHOLD_1** ile tanımlanır.
- Dijital bir PI regülatörü ile hedef voltaj penceresinde otomatik düzeltme yapılabilir.
- Ayrıca **SAR ADC** ile doğrudan ölçüm gerçekleştirilebilir.

###  Avantajlar

| Özellik                            | Avantajı                                                                                   |
| ---------------------------------- | ------------------------------------------------------------------------------------------ |
| **Yüksek esneklik**                | PRE-MAIN-POST akım dağılımı sayesinde sinyal şekli hassas kontrol edilebilir.              |
| **Sinyal bütünlüğü optimizasyonu** | Voltaj seviyeleri sayesinde emphasis (vurgulama) ayarı ile kayıp ve yansıma telafi edilir. |
| **Ortak mod regülasyonu**          | EMI (elektromanyetik girişim) azaltılır ve uyumluluk artar.                                |
| **Doğrudan dijital kontrol**       | Programlanabilir parametrelerle sistem dinamik olarak optimize edilebilir.                 |
| **Uyarlanabilir test imkanı**      | ADC ölçümü ve regülasyon sayesinde gerçek zamanlı kalibrasyon yapılabilir.                 |

## Transmitter Elektriksel Boşta Modu ve Ayarları

Tüm ayarlar, **elektriksel boşta mod** (electrical idle mode) için **bir kopya versiyon** olarak da mevcuttur. Elektriksel boşta modda, **daha az dal kullanılması** güç tüketimini azaltmaya yardımcı olur. Elektriksel boşta modda geçerli olan ayarlar, normal çalışmadaki ayarlarla aynı isimde olup, **_EI** eklenerek belirtilir.


## Uçtaki Alıcı Tespiti ve Ortak Mod Seviyesi

**Uçtaki alıcı tespiti (Far-End Receiver Detection)**, aşağıdaki şekilde yapılabilir:

1. **Sürücüye (driver)** farklı bir **ortak mod seviyesi** atanır.
2. Ardından, **çift hat üzerindeki gerçek akım mod voltajı** gözlemlenir.
Bu işlem, alıcının (receiver) doğru şekilde tespit edilmesini sağlar.

---

###  **Üçüncü Ayar Seti:**

- **Değiştirilen ortak mod çıkışı** süresince, **üçüncü bir ayar seti** aktif olur.
- Bu ayar seti, **modifiye edilmiş ortak mod çıkışına** göre uygulanır.

---

###  **Özet:**

- **Far-end receiver detection** işlemi, sürücüye farklı bir ortak mod seviyesi atanarak ve voltaj gözlemi yapılarak gerçekleştirilir.
- **Üçüncü ayar seti**, **ortak mod çıkışı değiştirilmiş** sürece aktif olur ve özel konfigürasyonları içerir.



# **Receiver Interface**

Diyagram iki ana bölüme ayrılmıştır:

![[Pasted image 20250711084543.png]]

### 1. **RX PMA (Physical Medium Attachment)** – Fiziksel Katman Bağlantısı

Bu katman, fiziksel ortamdan (örneğin kablo, PCB hattı) gelen analog sinyali alır ve dijital hale getirmek için ön işleme tabi tutar.

- **RX EQ (Equalizer)**:
    - Sinyal iletiminde oluşan bozulmaları (özellikle yüksek frekans zayıflaması) telafi eder.
    - Uzun mesafeli veya yüksek hızlı iletimlerde sinyal kalitesini artırır.

- **DFE (Decision Feedback Equalizer)**:
    - Önceki bitlerin etkisini azaltarak **inter-symbol interference (ISI)** problemini çözer.
    - Daha doğru kararlar alınmasını sağlar.

- **RX OOB (Out-of-Band Signaling)**:
    - Normal veri akışının dışında kalan kontrol sinyallerini işler (örneğin bağlantı kurulumu, durum bilgisi).

- **SISO (Single Input Single Output)**:
    - Bu blok, alınan sinyali tek bir veri akışı olarak işler ve PCS katmanına iletir.

---

### 2. **RX PCS (Physical Coding Sublayer)** – Fiziksel Kodlama Alt Katmanı

Bu katman, dijital hale gelen veriyi kod çözme, hizalama ve hata kontrolü gibi işlemlerden geçirir.

- **Multiplexer**:
    - Veri akışını yönlendirir; test veya normal çalışma modları arasında geçiş yapılabilir.

- **Polarity Correction**:
    - Sinyalin ters çevrilmiş (inverted) olup olmadığını algılar ve düzeltir.

- **PRBS Checker (Pseudo-Random Binary Sequence)**:
    - Test sırasında kullanılan rastgele veri dizilerini kontrol eder, hata oranını ölçer.

- **Comma Detect & Align**:
    - Veri akışında hizalama karakterlerini (comma) tespit eder ve veri çerçevesini doğru şekilde hizalar.

- **8B/10B Decoder**:
    - 10-bit kodlanmış veriyi 8-bit orijinal haline çevirir.
    - Bu kodlama, DC dengeleme ve hata tespiti sağlar.

- **Elastic Buffer**:
    - Giriş ve çıkış saatleri arasında küçük farkları dengelemek için veri tamponlar.
    - Veri kaybını önler.

---

### 3. **FPGA RX Interface**

- Tüm bu işlemlerden geçen veri, artık FPGA içinde kullanılmaya hazır hale gelir.
- Bu arayüz üzerinden kullanıcı mantığına (user logic) aktarılır.

---

##  Avantajları

- **Yüksek hızda güvenilir veri iletimi** sağlar.
- **Sinyal bozulmalarına karşı dayanıklıdır** (EQ ve DFE sayesinde).
- **Kodlama ve hizalama** ile veri bütünlüğü korunur.
- **Test ve hata kontrolü** için PRBS gibi yapılar içerir.
- **Esnek saat uyumu** için elastic buffer kullanılır.

---

##  Dezavantajları

- **Donanım karmaşıklığı**: Çok sayıda blok içerdiği için kaynak tüketimi fazladır.
- **Gecikme (latency)**: Her blok veri üzerinde işlem yaptığı için toplam gecikme artabilir.
- **Güç tüketimi**: Özellikle DFE ve PLL gibi bloklar yüksek güç tüketebilir.
- **Konfigürasyon karmaşıklığı**: Her blok doğru şekilde ayarlanmalıdır (örneğin EQ seviyeleri, PRBS modları).



## SerDes Alıcı Arayüzü (Receiver Interface)

SerDes alıcı arayüzü, alınan verinin FPGA mantığına (fabric) doğrudan aktarılmasını sağlayan bağlantı noktasıdır. Veri yolu genişliği, **`RX_DATAPATH_SEL`** parametresi ile yapılandırılabilir. Desteklenen port genişlikleri:
- **16 / 20 bit**
- **32 / 40 bit**
- **64 / 80 bit**

Eğer **8B/10B kod çözücü** devre dışı bırakılmışsa, 64-bit genişliğindeki `RX_DATA_O` portuna ek olarak, aşağıdaki 8-bit genişliğindeki portlar da aktif hale gelir:

- `RX_CHAR_IS_K_O`: Karakterin kontrol karakteri olup olmadığını belirtir.
- `RX_DISP_ERR_O`: DC dengesizlik veya kodlama hatası olup olmadığını gösterir.

Veri yolu saat frekansı (`PLL_CLK_O`), aşağıdaki faktörlere bağlı olarak belirlenir:

- Hat hızı (line rate)
- Veri yolu genişliği
- 8B/10B kodlama durumu

8B/10B kodlaması hakkında detaylı bilgi için **Bölüm 2.5.6.7**'ye başvurulmalıdır.

---

###  Tablo 2.37 – CC_SERDES Alıcı Veri Yolu İlgili Portlar

|**Port Adı**|**Genişlik**|**Yön**|**Açıklama**|
|---|---|---|---|
|`RX_CLK_I`|1 bit|Giriş|Alıcı veri yolu saati. PLL_CLK_0 veya RX_CLK_0 çıkışlarından gelebilir.|
|`RX_CLK_O`|1 bit|Çıkış|Alıcıdan geri kazanılan saat sinyali.|
|`RX_RESET_I`|1 bit|Giriş|Alıcı veri yolu için asenkron reset sinyali.|
|`RX_PCS_RESET_I`|1 bit|Giriş|PCS (Physical Coding Sublayer) için asenkron reset sinyali.|
|`RX_RESET_DONE_O`|1 bit|Çıkış|Reset işleminin tamamlandığını gösteren durum sinyali.|
|`RX_DATA_O`|64 bit|Çıkış|Alıcıdan çıkan veri yolu.|
|`RX_CHAR_IS_K_O`|8 bit|Çıkış|8B/10B kodlama devre dışıysa, kontrol karakteri bilgisi sağlar.|
|`RX_DISP_ERR_O`|8 bit|Çıkış|8B/10B kodlama devre dışıysa, kodlama hatası bilgisi sağlar.|

> Not: `RX_CHAR_IS_K_O` ve `RX_DISP_ERR_O` portları, **8B/10B kodlama kullanılmadığında** aktif hale gelir. Detaylı bilgi için yukarıdaki tabloyu inceleyebilirsiniz bakınız.


![[Pasted image 20250711090228.png]]
![[Pasted image 20250711090241.png]]
![[Pasted image 20250711090303.png]]




## Alıcı Analog Ön Uç (Receiver Analog Front-End)

SerDes alıcısının analog ön ucu, **yüksek hızlı akım modlu diferansiyel giriş tamponu (current-mode differential input buffer)** olarak tasarlanmıştır. Bu yapı, yüksek hızlı seri veri iletiminde sinyal bütünlüğünü korumak ve güvenilir veri alımı sağlamak amacıyla aşağıdaki özellikleri içerir:

### Özellikler:

- **Yapılandırılabilir Alıcı Sonlandırma Voltajları (Receiver Termination Voltages):**
    - Farklı sistem gereksinimlerine uyum sağlamak için sonlandırma voltajları ayarlanabilir.
    - Bu, sinyal yansımasını azaltarak veri bütünlüğünü artırır.

- **Kalibre Edilebilir Sonlandırma Dirençleri (Calibratable Termination Resistors):**
    - Direnç değerleri, üretim varyasyonlarını telafi etmek ve optimum sinyal uyumu sağlamak için kalibre edilebilir.
    - Bu, özellikle çok yüksek hızlarda sinyal kalitesini artırır.

- **Elektriksel Boşta Durum Algılayıcısı (Electrical Idle Detector):**
    - Veri hattında aktif sinyal olmadığında bunu algılar.
    - Güç tasarrufu ve bağlantı yönetimi için kullanılır.

---

###  Avantajları:

- **Yüksek hızda güvenilir sinyal alımı sağlar.**
- **Uyarlanabilir yapı** sayesinde farklı sistemlerle kolay entegrasyon yapılabilir.
- **Sinyal yansıması ve bozulmalarını azaltır.**
- **Güç yönetimi** açısından verimlidir (idle detection sayesinde).

---

### Dezavantajları:

- **Donanım karmaşıklığı**: Kalibrasyon ve yapılandırma gerektirir.
- **Alan ve güç tüketimi**: Analog devreler dijital devrelere göre daha fazla kaynak tüketebilir.
- **Hassas tasarım gerektirir**: Yüksek frekanslı analog sinyaller, dikkatli PCB tasarımı ister.


## Alıcı Ekolayzır (Receiver Equalizer)

GateMate™ SerDes alıcısı, entegre bir **3-tap Decision Feedback Equalizer (DFE)** ile donatılmıştır. Bu yapı, yüksek hızlı dijital iletişimde karşılaşılan **intersymbol interference (ISI)** etkilerini azaltmak amacıyla kullanılır.

###  ISI Nedir?

**Intersymbol Interference (ISI)**, iletim kanalındaki bozulmalar, gürültü veya bant genişliği sınırlamaları nedeniyle, ardışık sembollerin birbirine karışması durumudur. Bu durum, alınan sinyallerin doğru şekilde yorumlanmasını zorlaştırır.

---

###  3-Tap DFE Nasıl Çalışır?

DFE, daha önce algılanmış sembollerden elde edilen geri besleme bilgilerini kullanarak, gelen sinyali dinamik olarak düzeltir. Bu sayede orijinal gönderilen veri yeniden yapılandırılmaya çalışılır.

- **“3-tap”** ifadesi, DFE içinde kullanılan **üç adet ayarlanabilir gecikme elemanını (tap)** ifade eder.
- Her bir tap, daha önce alınan sembollere göre gelen sinyale uygulanan düzeltme katsayısını temsil eder.
- Bu yapı sayesinde DFE, hem geçmiş hem de gelecekteki sembolleri dikkate alarak sinyal kalitesini artırır.

---

###  Avantajları

- **ISI etkisini azaltır**, böylece daha doğru veri alımı sağlar.
- **Yüksek hızlı iletişimde sinyal bütünlüğünü korur.**
- **Uyarlanabilir yapı** sayesinde farklı kanal koşullarına otomatik olarak uyum sağlar.

---

###  Dezavantajları

- **Donanım karmaşıklığı**: Geri besleme ve katsayı hesaplamaları ek kaynak gerektirir.
- **Gecikme**: Geri besleme işlemi nedeniyle küçük bir işlem gecikmesi oluşabilir.
- **Güç tüketimi**: Aktif düzeltme işlemleri nedeniyle daha fazla enerji tüketebilir.


![[Pasted image 20250711090828.png]]
![[Pasted image 20250711090840.png]]
![[Pasted image 20250711090850.png]]
![[Pasted image 20250711090901.png]]
## Alıcı Marj Analizi (Receiver Margin Analysis)

Yüksek hızlı seri veri arayüzlerinin güvenilirliğini değerlendirmek için **alıcı marj analizi** kritik öneme sahiptir. Veri hızları arttıkça, alıcının **jitter**, **gürültü** ve diğer sinyal varyasyonlarına karşı dayanıklılığı sağlanmalıdır. Bu analiz, alıcının farklı koşullar altında nasıl performans gösterdiğini belirlemeye yardımcı olur ve veri bütünlüğünün korunmasını sağlar.

---

##  Eye Diagram (Göz Diyagramı)

**Eye diagram (göz diyagramı)**, bu analiz sürecinde kullanılan temel araçlardan biridir. Göz diyagramı, sinyal kalitesini görsel olarak temsil eder ve aşağıdaki kritik parametreleri ortaya koyar:

- **Eye Height (Göz Yüksekliği)**: Gürültü bağışıklığını gösterir. Ne kadar yüksekse, sinyal o kadar kararlıdır.
- **Eye Width (Göz Genişliği)**: Zamanlama toleransını gösterir. Genişlik arttıkça, sembollerin doğru algılanma olasılığı artar.

Bu parametreler, mühendislerin alıcı performansını değerlendirmesine ve optimize etmesine olanak tanır.

---

###  Avantajları

- **Sinyal kalitesinin görsel analizi** yapılabilir.
- **Zamanlama ve gürültü toleransı** hakkında doğrudan bilgi verir.
- **Sistem güvenilirliği** ve **veri bütünlüğü** için erken teşhis sağlar.

---

###  Dezavantajları

- **Ölçüm ekipmanı gerektirir** (osiloskop, test pattern generator vb.).
- **Yorumlama uzmanlık ister**: Göz diyagramı yorumlamak deneyim gerektirir.
- **Gerçek zamanlı analiz zordur**: Özellikle çok yüksek hızlarda.



#### **Alıcı Saat Veri Kurtarma (CDR)**

SerDes, gelen veri akışlarını alıcının dahili saatiyle senkronize etmek için Saat ve Veri Kurtarma (CDR) özelliğini içerir.

## Alıcı Polarite Kontrolü (Receiver Polarity Control)

SerDes alıcı arayüzü, gelen diferansiyel verinin yönünü (polaritesini) **ters çevirebilme (invert)** özelliğine sahiptir. Bu özellik, PCB üzerindeki sinyal yollarının yönü FPGA’nin beklediğiyle uyuşmadığında kullanılır.

- **`RX_POLARITY_I`** sinyali **‘1’ (high)** seviyesine getirildiğinde, gelen diferansiyel veri sinyalinin polaritesi ters çevrilir.
- Bu sayede, fiziksel bağlantıdaki hatalar veya yön uyuşmazlıkları yazılım yoluyla düzeltilebilir.

---

###  Avantajları

- **PCB tasarım esnekliği sağlar.**
- **Donanımsal yeniden yönlendirme ihtiyacını ortadan kaldırır.**
- **Hızlı hata düzeltme** ve sistem uyumluluğu sunar.

---

###  Dezavantajları

- Yanlış yapılandırıldığında veri yanlış yorumlanabilir.
- Her alıcı kanal için ayrı kontrol gerektirebilir.
![[Pasted image 20250711091302.png]]
![[Pasted image 20250711091311.png]]
CC_SERDES receiver polarity control

| **Name**      | **Width** | **Direction** | **Description**                                                                                                |
| ------------- | --------- | ------------- | -------------------------------------------------------------------------------------------------------------- |
| RX_POLARITY_I | 1         | Output        | Receiver polarity inversion control, <br>0: Normal çalışma, <br>1: Gelen veri akışının polaritesini ters çevir |

## Alıcı Bayt ve Kelime Hizalaması (Receiver Byte and Word Alignment)

Yüksek hızlı seri arayüzlerde, veriler sürekli bir bit akışı olarak iletilir. Bu verilerin doğru şekilde yorumlanabilmesi için, alıcı tarafında **bayt (byte)** ve **kelime (word)** sınırlarına hizalanması gerekir. Bu işlem, paralel veri işleme için kritik öneme sahiptir.

---

###  Hizalama Mekanizması

Veri hizalamasını kolaylaştırmak amacıyla, verici (transmitter) veri akışına özel bir tanımlayıcı dizi olan **comma karakteri** ekler. Bu karakter:

- Veri akışında **ayraç (delimiter)** görevi görür.
- Alıcı tarafından tanınarak, bayt sınırlarının belirlenmesini sağlar.
- Böylece, alınan bit akışı doğru bayt ve kelime yapısına dönüştürülür.

Alıcı, gelen veri akışında bu comma karakterini arar ve tespit ettiğinde veri hizalamasını gerçekleştirir. Bu işlem, **veri bütünlüğü** ve **doğru sembol çözümlemesi** için gereklidir.

---

###  Avantajları

- **Doğru veri çerçeveleme** sağlar.
- **Paralel veri işleme** için güvenilir temel oluşturur.
- **Kodlama sistemleriyle (ör. 8B/10B)** uyumlu çalışır.

---

###  Dezavantajları

- **Comma karakterinin yanlış algılanması**, hizalama hatalarına yol açabilir.
- **Ekstra donanım mantığı** gerektirir (comma detect & align blokları).
- **Veri gecikmesi** oluşturabilir (ilk hizalama sürecinde).

![[Pasted image 20250711091540.png]]

## Bayt ve Kelime Hizalamasında Comma Karakterinin Rolü

Alıcı, tespit edilen **comma karakterini** doğru bayt sınırına taşıyarak, alınan paralel verinin gönderilen veri formatıyla tam olarak eşleşmesini sağlar. Bu işlem:

- **Veri bütünlüğünü korumak**,
- **Veri yapısıyla senkronizasyon sağlamak**,
- **Hata oranını en aza indirmek**; amacıyla kritik öneme sahiptir.

Bu hizalama süreci, yüksek hızlı seri iletişimde **güvenilir veri aktarımı** için temel bir adımdır.

---

###  Özetle:

- **Comma karakteri**, veri akışında hizalama noktası olarak görev yapar.
- Alıcı, bu karakteri tespit edip veri çerçevesini doğru şekilde hizalar.
- Bu sayede, paralel veri FPGA içinde doğru şekilde işlenebilir hale gelir.

![[Pasted image 20250711091605.png]]
## Alıcı Pattern Denetleyicisi (Receiver Pattern Checker)

SerDes alıcı segmentinde yer alan **pattern checker**, endüstri standardı olan **pseudo-random bit sequence (PRBS)** desenlerini kullanarak alınan veri akışını doğrular ve hataları tespit eder. Desteklenen PRBS türleri:
- **PRBS-7**
- **PRBS-15**

Bu yapı, **kendinden senkronize (self-synchronizing)** çalışır ve kilitlenme durumunu **`RX_PRBS_LOCKED`** parametresi ile bildirir.

---

###  Hata Sayacı (Error Counter)

- **`RX_PRBS_ERR_CNT`**:
    - Alınan verideki **tek bitlik hataları** sayar.
    - Eğer sonraki veri doğruysa sayaç **otomatik olarak temizlenir**.
    - Hata tespit edildiğinde sayaç **artırılır**.

- Sayaç değeri **0x7FFF**'e ulaştığında durur.

- Sayaç, aşağıdaki sinyaller aktif olduğunda sıfırlanabilir:
    - `RX_PRBS_CNT_RESET_I`
    - `RX_PCS_RESET_I`

---

###  Avantajları

- **Gerçek zamanlı hata tespiti** sağlar.
- **Kendi kendine senkronize** olduğu için harici kontrol gerekmez.
- **PRBS testleri**, sistemin güvenilirliğini değerlendirmek için yaygın olarak kullanılır.

---

###  Dezavantajları

- **Yalnızca test modunda kullanılır**, normal veri iletiminde devre dışı bırakılır.
- **PRBS desenleri dışında** gelen verilerde yanlış pozitif hatalar oluşabilir.
- **Sayaç sınırı** (0x7FFF) aşılamaz, bu nedenle uzun süreli testlerde izleme yapılmalıdır.








![[Pasted image 20250711091739.png]]
![[Pasted image 20250711091753.png]]
![[Pasted image 20250711091804.png]]

## RX 8B/10B Kod Çözücü (Decoder)

GateMate™ SerDes alıcısı, entegre bir **8B/10B kod çözücü** içerir. **8B/10B kodlama/çözme**, yüksek hızlı veri iletiminde yaygın olarak kullanılan bir tekniktir ve güvenilir, dengeli iletişim sağlar.

###  8B/10B Kod Çözme Süreci

- Alıcı, gönderilen **10-bit kodlanmış veriyi** alır ve bunu orijinal **8-bit** haline dönüştürür.
- Bu işlem sırasında, kodlama sırasında eklenen bitler kullanılarak **hata tespiti ve düzeltme** yapılır.
- Kod çözme işlemi, iletilen verinin doğru şekilde geri kazanılmasını sağlar ve **veri bütünlüğünü** korur.

---

###  Gecikme ve Bypass Seçeneği

- 8B/10B kod çözücü aktif olduğunda, alıcı yolunda **ekstra gecikme (latency)** oluşur.
- Ancak, bu kodlama kullanılmıyorsa veya sistem gereksinimi düşük gecikme ise, **kod çözücü devre dışı bırakılabilir (bypass edilebilir)**.
- Bu sayede, **minimum gecikme** ile veri iletimi sağlanabilir.

---

###  Avantajları

- **Veri bütünlüğü ve hata tespiti** sağlar.
- **DC dengeleme** ile sinyal kalitesini artırır.
- **Standart uyumluluğu** (ör. PCIe, SATA gibi protokollerle uyumlu).

---

###  Dezavantajları

- **Ek gecikme** oluşturur.
- **Donanım kaynak tüketimi** artar.
- **Kodlama gereksizse**, sistem verimliliğini düşürebilir.

![[Pasted image 20250711092003.png]]

## RX Elastic Buffer (Esnek Alıcı Tamponu)

SerDes alıcı yolundaki **elastic buffer (esnek tampon)**, iki farklı saat alanı (clock domain) arasında veri aktarımını sağlamak amacıyla tasarlanmıştır. Bu yapı, **saat düzeltme (clock correction)** mekanizması içerir ve veri senkronizasyonunu garanti altına alır.

---

###  Temel Özellikler

- **Saat Alanı Köprüsü (Clock Domain Crossing)**:
    - Alıcı tarafındaki saat ile FPGA iç saat alanı farklıysa, elastic buffer bu farkı dengeleyerek veri kaybını önler.

- **Saat Düzeltme Mekanizması**:
    - Veri akışındaki küçük zamanlama farklarını telafi eder.
    - FIFO benzeri yapı ile veri akışını dengeler.

- **Bypass Seçeneği**:
    - Eğer saat alanları aynıysa veya gecikme kritikse, elastic buffer **devre dışı bırakılabilir (bypass edilebilir)**.
    - Bu sayede **alıcı yolundaki gecikme (latency)** azaltılır.

---

###  Avantajları

- **Farklı saat alanları arasında güvenli veri aktarımı sağlar.**
- **Veri senkronizasyonu ve bütünlüğü** korunur.
- **Saat kaymalarına karşı toleranslıdır.**

---

###  Dezavantajları

- **Ek gecikme (latency)** oluşturur.
- **Donanım kaynak tüketimi** artabilir.
- **Bypass edilirse**, saat uyumsuzluğu durumunda veri kaybı yaşanabilir.


## Register File Arayüzü (Register File Interface)

Register file, işlemci dostu bir arayüze sahiptir ve hem **FPGA fabric** üzerinden hem de **JTAG arayüzü** aracılığıyla erişilebilir. Eğer her iki erişim aynı anda gerçekleşirse, **öncelik JTAG arayüzüne** verilir. 

---

###  Yazma İşlemi (Write Operation)

Register file’a FPGA çekirdeğinden veri yazmak için aşağıdaki sinyallerin aktif olması gerekir:

- `REGFILE_WE_I` = 1 (write enable)
- `REGFILE_EN_I` = 1 (register file erişim izni)

Yazılacak 16-bit veri, `REGFILE_DI_I` portuna uygulanır ve `REGFILE_ADDR_I` ile belirtilen adrese yazılır. Yazma işlemi sırasında:

- `REGFILE_MASK_I`, hangi bitlerin yazılacağını belirleyen **write-enable maskesi** olarak kullanılır.
- Veri, **`CLK_REG_I` saat sinyalinin pozitif kenarında** yazılır.
- İki ardışık erişim arasında **en az 16 saat çevrimi** geçmelidir.

![[Pasted image 20250711092356.png]]

---

###  Durum Göstergesi (Status Output)

- `REGFILE_RDY_O`: Register file’ın hazır olup olmadığını gösterir.
![[Pasted image 20250711092321.png]]

---

###  Avantajları

- **Hem JTAG hem de FPGA mantığı üzerinden erişim** sağlar.
- **Maskeli yazma** desteği ile esnek veri güncelleme yapılabilir.
- **Saat senkronizasyonu** ile güvenilir veri yazımı sağlanır.

---

###  Dezavantajları

- **Erişim süresi sınırlıdır** (minimum 16 saat çevrimi).
- **JTAG önceliği**, eş zamanlı erişimlerde FPGA mantığını bekletebilir.
- **Yalnızca 16-bit veri genişliği** desteklenir.


# **SerDes register file**

| **Address** | **I/O** | **Range** | **Default** | **Name**                                |
| ----------- | ------- | --------- | ----------- | --------------------------------------- |
| 0x00        | r/w     | [4:0]     | 3           | RX_BUF_RESET_TIME                       |
| 0x00        | r/w     | [9:5]     | 3           | RX_PCS_RESET_TIME                       |
| 0x00        | r/w     | [14:10]   | 0           | RX_RESET_TIMER_PRESC                    |
| 0x00        | r/w     | [15]      | 0           | RX_RESET_DONE_GATE                      |
| 0x01        | r/w     | [4:0]     | 3           | RX_CDR_RESET_TIME                       |
| 0x01        | r/w     | [9:5]     | 3           | RX_EQA_RESET_TIME                       |
| 0x01        | r/w     | [14:10]   | 3           | RX_PMA_RESET_TIME                       |
| 0x01        | r/w     | [15]      | 1           | WAIT_CDR_LOCK                           |
| 0x02        | w/c     | [0]       | 0           | RX_CALIB_EN                             |
| 0x02        | r       | [1]       | 1           | RX_CALIB_DONE                           |
| 0x02        | r/w     | [2]       | 0           | RX_CALIB_OVR                            |
| 0x02        | r/w     | [6:3]     | 0           | RX_CALIB_VAL                            |
| 0x02        | r       | [10:7]    | 0           | RX_CALIB_CAL                            |
| 0x02        | r/w     | [13:11]   | 4           | RX_RTERM_VCMSEL                         |
| 0x02        | r/w     | [14]      | 0           | RX_RTERM_PD                             |
| 0x02        | r       | [15]      | 0           | Unused                                  |
| 0x03        | r/w     | [7:0]     | 0xA3        | RX_EQA_CKP_LF                           |
| 0x03        | r/w     | [15:8]    | 0xA3        | RX_EQA_CKP_HF                           |
| 0x04        | r/w     | [7:0]     | 0x01        | RX_EQA_CKP_OFFSET                       |
| 0x04        | r/w     | [8]       | 0           | RX_EN_EQA                               |
| 0x04        | r/w     | [12:9]    | 0           | RX_EQA_LOCK_CFG                         |
| 0x04        | r       | [13]      | 0           | RX_EQA_LOCKED                           |
| 0x04        | r       | [15:14]   | 0           | Unused                                  |
| 0x05        | r/w     | [4:0]     | 8           | RX_TH_MON1                              |
| 0x05        | r/w     | [5]       | 0           | RX_EN_EQA_EXT_VALUE[0]                  |
| 0x05        | r/w     | [10:6]    | 8           | RX_TH_MON2                              |
| 0x05        | r/w     | [11]      | 0           | RX_EN_EQA_EXT_VALUE[1]                  |
| 0x05        | r       | [15:12]   | 0           | Unused                                  |
| 0x06        | r/w     | [4:0]     | 8           | RX_TAPW                                 |
| 0x06        | r/w     | [5]       | 0           | RX_EN_EQA_EXT_VALUE[2]                  |
| 0x06        | r/w     | [10:6]    | 8           | RX_AFE_OFFSET                           |
| 0x06        | r/w     | [11]      | 0           | RX_EN_EQA_EXT_VALUE[3]                  |
| 0x06        | r       | [15:12]   | 0           | Unused                                  |
| 0x07        | r       | [4:0]     | 0           | RX_EQA_TAPW                             |
| 0x07        | r       | [9:5]     | 0           | RX_TH_MON                               |
| 0x07        | r       | [13:10]   | 0           | RX_OFFSET                               |
| 0x07        | r       | [15:14]   | 0           | Unused                                  |
| 0x08        | r/w     | [15:0]    | 0X01 C0     | RX_EQA_CONFIG                           |
| 0x09        | r/w     | [4:0]     | 16          | RX_AFE_PEAK                             |
| 0x09        | r/w     | [8:5]     | 8           | RX_AFE_GAIN                             |
| 0x09        | r/w     | [11:9]    | 4           | RX_AFE_VCMSEL                           |
| 0x09        | r       | [15:12]   | 0           | Unused                                  |
| 0x0A        | r/w     | [7:0]     | 4           | RX_AFE_VCMSEL                           |
| 0x0A        | r/w     | [15:8]    | 0           | Unused                                  |
| 0x0B        | r/w     | [8:0]     | 128         | RX_CDR_TRANS_TH                         |
| 0x0B        | r/w     | [14:9]    | 0X0B        | RX_CDR_LOCK_CFG                         |
| 0x0B        | r       | [15]      | 0           | RX_CDR_LOCKED                           |
| 0x0C        | r       | [14:0]    | 0           | RX_CDR_FREQ_ACC_VAL                     |
| 0x0C        | r       | [15]      | 0           | Unused                                  |
| 0x0D        | r       | [15:0]    | 0           | RX_CDR_PHASE_ACC_VAL                    |
| 0x0E        | r/w     | [14:0]    | 0           | RX_CDR_FREQ_ACC                         |
| 0x0E        | r       | [15]      | 0           | Unused                                  |
| 0x0F        | r/w     | [15:0]    | 0           | RX_CDR_PHASE_ACC                        |
| 0x10        | r/w     | [1:0]     | 0           | RX_CDR_SET_ACC_CONFİG                   |
| 0x10        | r/w     | [2]       | 0           | RX_CDR_FORCE_LOCK                       |
| 0x10        | r       | [15:3]    | 0           | Unused                                  |
| 0x11        | r/w     | [9:0]     | 0x2 83      | RX_ALIGN_MCOMMA_VALUE                   |
| 0x11        | r/w     | [10]      | 0           | RX_MCOMMA_ALIGN_OVR                     |
| 0x11        | r/w     | [11]      | 0           | RX_MCOMMA_ALIGN                         |
| 0x11        | r       | [13:12]   | 0           | Unused                                  |
| 0x12        | r/w     | [9:0]     | 0x1 7C      | RX_ALIGN_MCOMMA_ENABLE                  |
| 0x12        | r/w     | [10]      | 0           | RX_PCOMMA_ALIGN_OVR                     |
| 0x12        | r/w     | [11]      | 0           | X_PCOMMA_ALIGN                          |
| 0x12        | r/w     | [13:12]   | 0           | RX_ALIGN_MCOMMA_WORD                    |
| 0x12        | r       | [15:14]   | 0           | Unused                                  |
| 0x13        | r/w     | [9:0]     | 0x3 FF      | RX_ALIGN_COMMA_ENABLE                   |
| 0x13        | r/w     | [11:10]   | 0           | RX_SLİDE_MODE                           |
| 0x13        | r/w     | [12]      | 0           | RX_COMMA_DETECT_EN_OVR                  |
| 0x13        | r/w     | [13]      | 0           | RX_COMMA_DETECT_EN                      |
| 0x13        | r/w     | [14]      | 0           | RX_SLİDE[0]                             |
| 0x13        | w/c     | [15]      | 0           | RX_SLİDE[0]                             |
| 0x14        | w/c     | [0]       | 0           | X_EYE_MEAS_EN                           |
| 0x14        | r/w     | [15:1]    | 0           | RX_EYE_MEAS_CFG                         |
| 0x15        | r/w     | [5:0]     | 0           | RX_MON_PH_OFFSET                        |
| 0x15        | r       | [15:6]    | 0           | Unused                                  |
| 0x16        | r       | [15:0]    | 0           | RX_EYE_MEAS_CORRECT_11S                 |
| 0x17        | r       | [15:0]    | 0           | RX_EYE_MEAS_WRONG_11S                   |
| 0x18        | r       | [15:0]    | 0           | RX_EYE_MEAS_CORRECT_00S                 |
| 0x19`       | r       | [15:0]    | 0           | RX_EYE_MEAS_WRONG_00S                   |
| 0x1A        | r       | [15:0]    | 0           | RX_EYE_MEAS_CORRECT_001S                |
| 0x1B        | r       | [15:0]    | 0           | RX_EYE_MEAS_WRONG_001S                  |
| 0x1C        | r       | [15:0]    | 0           | RX_EYE_MEAS_CORRECT_110S                |
| 0x1D        | r       | [15:0]    | 0           | RX_EYE_MEAS_WRONG_110S                  |
| 0x1E        | r/w     | [3:0]     | 4           | RX_EI_BIAS                              |
| 0x1E        | r/w     | {7:4}     | 4           | RX_EI_BW_SEL                            |
| 0x1E        | r/w     | [8]       | 0           | RX_EN_EI_DETECTOR_OVR                   |
| 0x1E        | r/w     | [9]       | 0           | RX_EN_EI_DETECTOR                       |
| 0x1E        | r       | [10]      | 0           | RX_EN_EI                                |
| 0x1E        | r       | [15:11]   | 0           | Unused                                  |
| 0x1F        | r       | [14:0]    | 0           | RX_PRBS_ERR_CNT                         |
| 0x1F        | r       | [15]      | 0           | RX_PRBS_LOCKED                          |
| 0x20        | r/w     | [0]       | 0           | Read: RX_DATA[0],<br>Write: RX_DATA_SEL |
| 0x20        | r       | [15:1]    | 0           | RX_DATA[15:1]                           |
| 0x21        | r       | [15:0]    | 0           | RX_DATA[31:16]                          |
| 0x22        | r       | [15:0]    | 0           | RX_DATA[47:32]                          |
| 0x23        | r       | [15:0]    | 0           | RX_DATA[63:48]                          |
| 0x24        | r       | [15:0]    | 0           | RX_DATA[79:64]                          |
| 0x25        | r/w     | [0]       | 0           | RX_BUF_BYPAS                            |
| 0x25        | r/w     | [1]       | 0           | RX_CLKCOR_USE                           |
| 0x25        | r/w     | [7:2]     | 32          | RX_CLKCOR_MIN_LAT                       |
| 0x25        | r/w     | [13:8]    | 39          | RX_CLKCOR_MAX_LAT                       |
| 0x25        | r       | [15:14]   | 0           | Unused                                  |
| 0x26        | r/w     | [9:0]     | 0X1 F7      | RX_CLKCOR_SEQ_1_0                       |
| 0x26        | r       | [15:10]   | 0           | Unused                                  |
| 0x27        | r/w     | [9:0]     | 0X1 F7      | RX_CLKCOR_SEQ_1_1                       |
| 0x27        | r       | [15:10]   | 0           | Unused                                  |
| 0x28        | r/w     | [9:0]     | 0X1 F7      | RX_CLKCOR_SEQ_1_2                       |
| 0x28        | r       | [15:10]   | 0           | Unused                                  |
| 0x29        | r/w     | [9:0]     | 0X1 F7      | RX_CLKCOR_SEQ_1_3                       |
| 0x29        | r       | [15:10]   | 0           | Unused                                  |
| 0x2A        | r/w     | [0]       | 0           | RX_PMA_LOOPBACK                         |
| 0x2A        | r/w     | [1]       | 0           | RX_PCS_LOOPBACK                         |
| 0x2A        | r/w     | [3:2]     | 3           | RX_DATAPATH_SEL                         |
| 0x2A        | r/w     | [4]       | 0           | RX_PRBS_OVR                             |
| 0x2A        | r/w     | [7:5]     | 0           | RX_PRBS_SEL                             |
| 0x2A        | r/w     | [8]       | 0           | RX_LOOPBACK_OVR                         |
| 0x2A        | w/c     | [9]       | 0           | RX_PRBS_CNT_RESET                       |
| 0x2A        | r/w     | [10]      | 0           | RX_POWER_DOWN_OVR                       |
| 0x2A        | r/w     | [11]      | 0           | RX_POWER_DOWN_N                         |
| 0x2A        | r       | [12]      | 0           | RX_PRESENET                             |
| 0x2A        | r       | [13]      | 0           | RX_DETECT_DONE                          |
| 0x2A        | r       | [14]      | 0           | RX_BUF_ERR                              |
| 0x2A        | r       | [15]      | 0           | Unused                                  |
| 0x2B        | r/w     | [0]       | 0           | RX_RESET_OVR                            |
| 0x2B        | w/c     | [1]       | 0           | RX_RESET                                |
| 0x2B        | r/w     | [2]       | 0           | RX_PMA_RESET_OVR                        |
| 0x2B        | w/c     | [3]       | 0           | RX_PMA_RESET                            |
| 0x2B        | r/w     | [4]       | 0           | RX_EQA_RESER                            |
| 0x2B        | w/c     | [5]       | 0           | RX_EQA_RESET                            |
| 0x2B        | r/w     | [6]       | 0           | RX_CDR_RESET_OVR                        |
| 0x2B        | w/c     | [7]       | 0           | RX_CDR_RESET                            |
| 0x2B        | r/w     | [8]       | 0           | RX_PCS_RESET_OVR                        |
| 0x2B        | w/c     | [9]       | 0           | RX_RESET                                |
| 0x2B        | r/w     | [10]      | 0           | RX_BUF_RESET_OVR                        |
| 0x2B        | w/c     | [11]      | 0           | RX_BUF_RESET                            |
| 0x2B        | r/w     | [12]      | 0           | RX_POLARİTY_OVR                         |
| 0x2B        | r/w     | [13]      | 0           | RX_POLARİTY_                            |
| 0x2B        | r/w     | [14]      | 0           | RX_8B10B_EN_OV`                         |
| 0x2B        | r/w     | [15]      | 0           | RX_8B10B_EN                             |
| 0x2C        | r/w     | [7:0]     | 0           | RX_8B10BBYPASS                          |
| 0x2C        | r       | [8]       | 0           | RX_BYTE_IS_ALIGNED                      |
| 0x2C        | r/c     | [9]       | 0           | RX_BYTE_REALING                         |
| 0x2C        | r       | [10]      | 0           | RX_RESET_DONE                           |
| 0x2C        | r       | [15:11]   | 0           | Unused                                  |
| 0x2D        | r/w     | [0]       | 0           | RX_DBG_EN                               |
| 0x2D        | r/w     | [4:1]     | 0           | RX_DBG_SEL                              |
| 0x2D        | r/w     | [5]       | 0           | RX_DBG_MODE                             |
| 0x2D        | r/w     | [11:6]    | 0X05        | RX_DBG_SRAM_DELAY                       |
| 0x2D        | r/w     | [15:12]   | 0           | Unused                                  |
| 0x2E        | r/w     | [9:0]     | 0           | RX_DBG_ADDR                             |
| 0x2E        | r/w     | [10]      | 0           | RX_DBG_RE                               |
| 0x2E        | r/w     | [11]      | 0           | RX_DBG_WE                               |
| 0x2E        | r/w     | [15:12]   | 0           | RX_DBG_DATA[3:0]                        |
| 0x2F        | r/w     | [15:0]    | 0           | RX_DBG_DATA[19:4]                       |
| 0x30        | r/w     | [4:0]     | 0           | TX_SEL_PRE                              |
| 0x30        | r/w     | [9:5]     | 0           | TX_SEL_POST                             |
| 0x30        | r/w     | [14:10]   | 15          | TX_AMP                                  |
| 0x30        | r       | [15]      | 0           | Unused                                  |
| 0x31        | r/w     | [4:0]     | 0           | TX_BRANCH_EN_PRE                        |
| 0x31        | r/w     | [10:5]    | 0x 3F       | TX_BRANCH_EN_MAIN                       |
| 0x31        | r/w     | [15:11]   | 0           | TX_BRANCH_EN_POST                       |
| 0x32        | r/w     | [2:0]     | 4           | TX_TAIL_CASCODE                         |
| 0x32        | r/w     | [9:3]     | 63          | TX_DC_ENABLE                            |
| 0x32        | r/w     | [14:10]   | 0           | TX_DC_OFFSET                            |
| 0x32        | r       | [15]      | 0           | Unused                                  |
| 0x33        | r/w     | [4:0]     | 0           | TX_CM_RAISE                             |
| 0x33        | r/w     | [9:5]     | 14          | TX_CM_THRESHOLD_0                       |
| 0x33        | r/w     | [14:10]   | 16          | TX_CM_THRESHOLD_1                       |
| 0x33        | r       | [15]      | 0           | Unused                                  |
| 0x34        | r/w     | [4:0]     | 0           | TX_SEL_PRE_EI                           |
| 0x34        | r/w     | [9:5]     | 0           | TX_SEL_POST_EI                          |
| 0x34        | r/w     | [14:10]   | 15          | TX_AMP_EI                               |
| 0x34        | r       | [15]      | 0           | Unused                                  |
| 0x35        | r/w     | [4:0]     | 0           | TX_BRANCH_EN_PRE_EI                     |
| 0x35        | r/w     | [10:5]    | 0x 3F       | TX_BRANCH_EN_MAIN_EI                    |
| 0x35        | r/w     | [15:11]   | 0           | TX_BRANCH_EN_POST_EI                    |
| 0x36        | r/w     | [2:0]     | 4           | TX_TAIL_CASCODE_EI                      |
| 0x36        | r/w     | [9:3]     | 63          | TX_DC_ENABLE_EI                         |
| 0x36        | r/w     | [14:10]   | 0           | TX_DC_OFFSET_EI                         |
| 0x36        | r       | [15]      | 0           | Unused                                  |
| 0x37        | r/w     | [4:0]     | 0           | TX_CM_RAISE_EI                          |
| 0x37        | r/w     | [9:5]     | 14          | TX_CM_THRESHOLD_0_EI                    |
| 0x37        | r/w     | [14:10]   | 16          | TX_CM_THRESHOLD_1_EI                    |
| 0x37        | r       | [15]      | 0           | Unused                                  |
| 0x38        | r/w     | [4:0]     | 0           | TX_SEL_PRE_RXDET                        |
| 0x38        | r/w     | [9:5]     | 0           | TX_SEL_POST_RXDET                       |
| 0x38        | r/w     | [14:10]   | 15          | TX_AMP_RXDET                            |
| 0x38        | r       | [15]      | 0           | Unused                                  |
| 0x39        | r/w     | [4:0]     | 0           | TX_BRANCH_EN_PRE_RXDET                  |
| 0X39        | r/w     | [10:5]    | 0x 3F       | TX_BRANCH_EN_MAIN_RXDET                 |
| 0x39        | r/w     | [15:11]   | 0           | TX_BRANCH_EN_POST_RXDET                 |
| 0x3A        | r/w     | [2:0]     | 4           | TX_TAIL_CASCODE_RXDET                   |
| 0x3A        | r/w     | [9:3]     | 63          | TX_DC_ENABLE_RXDET                      |
| 0x 3A       | r/w     | [14:10]   | 0           | TX_DC_OFFSET_RXDET                      |
| 0x 3A       | r       | [15]      | 0           | Unused                                  |
| 0x 3B       | r/w     | [4:0]     | 0           | TX_CM_RAISE_RXDET                       |
| 0x 3B       | r/w     | [9:5]     | 14          | TX_CM_THRESHOLD_0_RXDET                 |
| 0x 3B       | r/w     | [14:10]   | 16          | TX_CM_THRESHOLD_1_RXDET                 |
| 0x 3B       | r       | [15]      | 0           | Unused                                  |
| 0x 3C       | w/c     | [0]       | 0           | TX_CALIB_EN                             |
| 0x 3C       | r       | [1]       | 1           | TX_CALIB_DONE                           |
| 0x 3C       | r/w     | [2]       | 0           | TX_CALIB_OVR                            |
| 0x 3C       | r/w     | [6:3]     | 0           | TX_CALIB_VAL                            |
| 0x 3C       | r       | [10:7]    | 0           | TX_CALIB_CAL                            |
| 0x 3C       | r       | [15:11]   | 0           | Unused                                  |
| 0x3D        | r/w     | [7:0]     | 0x 80       | TX_CM_REG_KI                            |
| 0x3D        | r/w     | [8]       | 0           | TX_CM_SAR_EN                            |
| 0x3D        | r/w     | [9]       | 1           | TX_CM_REG_EN                            |
| 0x3D        | r       | [15:10]   | 0           | Unused                                  |
| 0x3E        | r       | [4:0]     | 0           | TX_CM_SAR_RESULT_0                      |
| 0x3E        | r       | [9:5]     | 0           | TX_CM_SAR_RESULT_1                      |
| 0x3E        | r       | [15:10]   | 0           | Unused                                  |
| 0x3F        | r/w     | [4:0]     | 3           | TX_PMA_RESET_TIME                       |
| 0x3F        | r/w     | [9:5]     | 3           | TX_PCS_RESET_TIME                       |
| 0x3F        | r/w     | [10]      | 0           | TX_PCS_RESET_OVR                        |
| 0x3F        | w/c     | [11]      | 0           | TX_PCS_RESET                            |
| 0x3F        | r/w     | [12]      | 0           | TX_PMA_RESET_OVR                        |
| 0x3F        | w/c     | [13]      | 0           | TX_PMA_RESET                            |
| 0x3F        | r/w     | [14]      | 0           | TX_RESET_OVR                            |
| 0x3F        | w/c     | [15]      | 0           | TX_RESET                                |
| 0x40        | r/w     | [1:0]     | 0           | TX_PMA_LOOPBACK                         |
| 0x40        | r/w     | [2]       | 0           | TX_PCS_LOOPBACK                         |
| 0x40        | r/w     | [4:3]     | 3           | TX_DATAPATH_SEL                         |
| 0x40        | r/w     | [5]       | 0           | TX_PRBS_OVR                             |
| 0x40        | r/w     | [8:6]     | 0           | TX_PRBS_SEL                             |
| 0x40        | w/c     | [9]       | 0           | TX_PRBS_FORCE_ERR                       |
| 0x40        | r/w     | [10]      | 0           | TX_LOOPBACK_OVR                         |
| 0x40        | r/w     | [11]      | 0           | TX_POWER_DOWN_OVR                       |
| 0x40        | r/w     | [12]      | 0           | TX_POWER_DOWN_N                         |
| 0x40        | r       | [15:13]   | 0           | Unused                                  |
| 0x41        | r/w     | [0]       | 0           | TX_ELEC_IDLE_OVR                        |
| 0x41        | r/w     | [1]       | 0           | TX_ELEC_IDLE                            |
| 0x41        | r/w     | [2]       | 0           | TX_DETECT_RX_OVR                        |
| 0x41        | r/w     | [3]       | 0           | TX_DETECT_RX                            |
| 0x41        | r/w     | [4]       | 0           | TX_POLARITY_OVR                         |
| 0x41        | r/w     | [5]       | 0           | TX_POLARITY                             |
| 0x41        | r/w     | [6]       | 0           | TX_8B10B_EN_OVR                         |
| 0x41        | r/w     | [7]       | 0           | TX_8B10B_EN                             |
| 0x41        | r/w     | [8]       | 0           | TX_DATA_OVR                             |
| 0x41        | r/w     | [11:9]    | 0           | TX_DATA_CNT                             |
| 0x41        | w/c     | [12]      | 0           | TX_DATA_VALID                           |
| 0x41        | r       | [13]      | 0           | TX_BUF_ERR                              |
| 0x41        | r       | [14]      | 0           | TX_RESET_DONE                           |
| 0x41        | r       | [15]      | 0           | Unused                                  |
| 0x42        | r/w     | [15:0]    | 0           | TX_DATA                                 |
| 0x50        | r/w     | [0]       | 0           | PLL_EN_ADPLL_CTRL                       |
| 0x50        | r/w     | [1]       | 0           | PLL_CONFIG_SEL                          |
| 0x50        | r/w     | [2]       | 0           | PLL_SET_OP_LOCK                         |
| 0x50        | r/w     | [3]       | 0           | PLL_ENFOCRE_LOCK                        |
| 0x50        | r/w     | [4]       | 0           | PLL_DISABLE_LOCK                        |
| 0x50        | r/w     | [5]       | 1           | PLL_LOCK_WINDOW                         |
| 0x50        | r/w     | [6]       | 1           | PLL_LOCK_WINDOW                         |
| 0x50        | r/w     | [7]       | 0           | PLL_FAST_LOCK                           |
| 0x50        | r/w     | [8]       | 0           | PLL_SYNC_BYPASS                         |
| 0x50        | r/w     | [9]       | 0           | PLL_PFD_SELECT                          |
| 0x50        | r/w     | [10]      | 0           | PLL_REF_BYPASS                          |
| 0x50        | r/w     | [11]      | 1           | PLL_REF_SELPLL_REF_RTERM                |
| 0x50        | r       | [15:12]   | 0           | Unused                                  |
| 0x51        | r/w     | [5:0]     | 58          | PLL_FCNTRL                              |
| 0x51        | r/w     | [11:6]    | 27          | PLL_MAIN_DIVSEL                         |
| 0x51        | r/w     | [13:12]   | 0           | PLL_OUT_DIVSEL                          |
| 0x51        | r       | [15:14]   | 0           | Unused                                  |
| 0x52        | r/w     | [4:0]     | 3           | PLL_CI                                  |
| 0x52        | r/w     | [14:5]    | 80          | PLL_CP                                  |
| 0x52        | r       | [15]      | 0           | Unused                                  |
| 0x53        | r/w     | [3:0]     | 0           | PLL_AO                                  |
| 0x53        | r/w     | [6:4]     | 0           | PLL_SCAP                                |
| 0x53        | r/w     | [8:7]     | 2           | PLL_FILTER_SHIFT                        |
| 0x53        | r/w     | [11:9]    | 2           | PLL_SAR_LIMIT                           |
| 0x53        | r       | [15:12]   | 0           | Unused                                  |
| 0x54        | r/w     | [10:0]    | 512         | PLL_FT                                  |
| 0x54        | r/w     | [11]      | 0           | PLL_OPEN_LOOP                           |
| 0x54        | r/w     | [12]      | 1           | PLL_SCAP_AUTO_CAL                       |
| 0x54        | r       | [15:13]   | 0           | Unused                                  |
| 0x55        | r       | [0]       | 0           | PLL_LOCKED                              |
| 0x55        | r       | [1]       | 0           | PLL_CAP_FT_OF                           |
| 0x55        | r       | [2]       | 0           | PLL_CAP_FT_UF                           |
| 0x55        | r       | [12:3]    | 0           | PLL_CAP_FT                              |
| 0x55        | r       | [14:13]   | 0           | PLL_CAP_STATE                           |
| 0x55        | r       | [15]      | 0           | Unused                                  |
| 0x56        | r       | [7:0]     | 0           | PLL_SYNC_VALUE                          |
| 0x56`       | r       | [15:8]    | 0           | Unused                                  |
| 0x57        | r/w     | [2:0]     | 4           | PLL_BISC_MODE                           |
| 0x57        | r/w     | [6:3]     | 15          | PLL_BISC_TIMER_MAX                      |
| 0x57        | r/w     | [7]       | 0           | PLL_BISC_OPT_DET_IND                    |
| 0x57        | r/w     | [8]       | 0           | PLL_BISC_PFD_SEL                        |
| 0x57        | r/w     | [9]       | 0           | PLL_BISC_DLY_DIR                        |
| 0x57        | r/w     | [12:10]   | 1           | PLL_BISC_COR_DLY                        |
| 0x57        | r/w     | [13]      | 0           | PLL_BISC_CAL_SIGN                       |
| 0x57        | r/w     | [14]      | 1           | PLL_BISC_CAL_AUTO                       |
| 0x57        | r       | [15]      | 0           | Unused                                  |
| 0x58        | r/w     | [4:0]     | 4           | PLL_BISC_CP_MIN                         |
| 0x58        | r/w     | [9:5]     | 18          | PLL_BISC_CP_MAX                         |
| 0x58        | r/w     | [14:10]   | 12          | PLL_BISC_CP_START                       |
| 0x58        | r       | [15]      | 0           | Unused                                  |
| 0x59        | r/w     | [4:0]     | 0           | PLL_BISC_DLY_PFD_MON_REF                |
| 0x59        | r/w     | [9:5]     | 2           | PLL_BISC_DLY_PFD_MON_DIV                |
| 0x59        | r       | [15:10]   | 0           | Unused                                  |
| 0x5A        | r       | [0]       | 0           | PLL_BISC_TIMER_DONE                     |
| 0x5A        | r       | [7:1]     | 0           | PLL_BISC_CP                             |
| 0x5A        | r       | [15:8]    | 0           | Unused                                  |
| 0x5B        | r       | [15:0]    | 0           | PLL_BISC_CO                             |
| 0x5C        | r/w     | [0]       | 0           | SerDes Enable                           |
| 0x5C        | r/w     | [1]       | 0           | SerDes Auto Init                        |
| 0x5C        | r/w     | [2]       | 0           | SerDes Testmode                         |
| 0x5C        | r       | [15:3]    | 0           | Unused                                  |











