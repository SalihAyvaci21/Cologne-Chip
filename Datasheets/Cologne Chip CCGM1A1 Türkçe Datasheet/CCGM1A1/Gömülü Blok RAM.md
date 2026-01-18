
**GateMate™ FPGA’lar**, yonga içine gömülü bir dizi **uçucu bellek hücresi** içerir. Bu hücreler, yapılandırılabilir **40 kbit çift portlu SRAM (DPSRAM)** blokları olarak organize edilmiştir.

###  **Mimari Yerleşim:**

- Bu RAM hücreleri, **CPE dizisi ile yönlendirme yapısı (routing structure)** arasında **dikey sütunlar** halinde yerleştirilmiştir.
- Her blok RAM, bir **adres koordinatı (x, y)** ile tanımlanır:
    - **x = 0 . . 3** (4 sütun)
    - **y = 0 . . 7** (8 satır)
- Bu yapı, toplamda **32 adet blok RAM kaynağı** sağlar.
 ![[Pasted image 20250707111730.png]]


##  **Avantajlar**

| Özellik                         | Avantaj                                                   |
| ------------------------------- | --------------------------------------------------------- |
| **Çift portlu erişim (DPSRAM)** | Aynı anda iki farklı işlem birimi tarafından erişilebilir |
| **Yüksek bant genişliği**       | Paralel veri erişimi sayesinde hızlı işlem yapılabilir    |
| **CPE ile yakın yerleşim**      | Veri yolları kısa tutulur, gecikme azalır                 |

| Cihaz       | Toplam block                                              | Kolon RAM Sayısı | Kolon Başı Block Sayısı | Toplam Memory biti |
| ----------- | --------------------------------------------------------- | ---------------- | ----------------------- | ------------------ |
| **CCGM1A1** | Aynı anda iki farklı işlem birimi tarafından erişilebilir | 4                | 8                       | 1,310,720          |
| **CCGM1A2** | Paralel veri erişimi sayesinde hızlı işlem yapılabilir    | 8                | 8                       | 2,621,440          |

### Block RAM Özellikleri

Her Block RAM hücresi, **tek bir 40 Kbit bellek** veya **iki bağımsız 20 Kbit çift portlu SRAM (DPSRAM)** bloğu olarak yapılandırılabilir. Her iki yapılandırma da **True Dual Port (TDP)** ve **Simple Dual Port (SDP)** modlarını destekler.

#### Temel Özellikler:

1. **Esnek Veri Genişliği**:
- TDP modunda: 1 ila 40 bit
- SDP modunda: 1 ila 80 bit
2. **Bit Bazlı Yazma İzni**:  
Gelen verinin bit seviyesinde yazılmasına olanak tanır. Örneğin: mikrodenetleyici arayüzlerinde kullanışlıdır.

3. **İsteğe Bağlı Çıkış Kayıtları**:  
Her port, çıkış verisini bir tick-rate geciktiren opsiyonel bir çıkış kaydına sahiptir. Bu özellik, kritik yol optimizasyonlarında faydalıdır.

4. **Entegre Hata Kontrolü (ECC)**:  
Her portta yerleşik ECC modülü bulunur. Bu modül, **tek bit hatalarını düzeltebilir**, **çift bit hatalarını tespit edebilir**.

5. **Bellek Zincirleme (Cascading)**:  
Komşu RAM blokları birbirine bağlanarak daha büyük bellek dizileri oluşturulabilir. Saat, adres, kontrol, veri ve bitmask sinyalleri bu yapı üzerinden iletilebilir.  Örneğin: İki blok birleştirilerek **64K × 1** yapı elde edilebilir.


6. **ROM Başlatma Desteği**:  
Block RAM içerikleri, konfigürasyon sırasında önceden yüklenebilir. Bu sayede **salt okunur bellek (ROM)** olarak kullanılabilir.

7. **Sinyal Polarite Kontrolü**:  
Tüm saat, etkinleştirme ve yazma izni sinyalleri ayrı ayrı terslenebilir.

8. **FIFO Desteği**:  
Her Block RAM, **senkron veya asenkron FIFO** olarak çalışabilir. FIFO durumu ve sıfırlama için özel durum sinyalleri mevcuttur.


Tablo 2.2 ve 2.3, hem 20K hem de 40K yapılandırmaları için SDP ve TDP modlarında mevcut adres ve veri yolu genişliği yapılandırmalarının yanı sıra ECC kullanılabilirliğini göstermektedir.

![[Pasted image 20250707124443.png]]

![[Pasted image 20250707125737.png]]

Bellek girişleri, CPE çıkışlarından **RAM_O1** veya **RAM_O2** üzerinden beslenebilir.  
Kontrol ve adres sinyalleri (**CLK, EN, WE, ADDR**) için iki farklı giriş bağlantısı seçilebilir, bu da yönlendirme ve zamanlama açısından esneklik sağlar.

![[Pasted image 20250707131020.png]]

## Block RAM Hücre Yapısı ve İşlevsel Özellikleri

###  Bellek Giriş ve Kontrol Sinyalleri

- Bellek girişleri, CPE çıkışlarından **RAM_O1** veya **RAM_O2** üzerinden beslenebilir.
- Kontrol ve adres sinyalleri (**CLK, EN, WE, ADDR**) için iki farklı giriş bağlantısı seçilebilir.
- Çıkış verisi ve durum sinyalleri (örneğin ECC ve FIFO bayrakları), **RAM_I1** ve **RAM_I2** girişleri üzerinden yönlendirme yapısındaki **Switch Box (SB)** birimlerine bağlanır.

###  Katmanlı Donanım Mimarisi

Block RAM işlevselliği, RAM çekirdeği etrafında çok katmanlı bir yapıda uygulanır. Bu mimaride yer alan **ileri yönlendirme (forward selection)** katmanı, gelen sinyaller arasında esnek bir seçim yapılmasına olanak tanır. Bu sinyaller; saat (CLK), etkinleştirme (EN), yazma izni (WE), adres (ADDR), veri ve bitmask sinyalleridir.

- Komşu RAM hücresinden (örneğin daha geniş veya derin bellek oluşturmak için) veya
   CPE dizisinden (A0, A1, B0, B1 grupları) gelebilir.
- **Sinyal Tersleme (Signal Inversion)** katmanı, clock, enable ve write enable sinyallerinin konfigürasyon parametrelerine bağlı olarak ayrı ayrı ters çevrilmesine olanak tanır.


###  ECC (Error Correction Code) Özelliği

Block RAM, veri bütünlüğünü korumak amacıyla dahili bir **ECC kodlama ve çözme** katmanına sahiptir:

- ECC, **Hamming (39,32)** kodlaması kullanır.
- **1 bit hatayı düzeltebilir**, **2 bit hatayı tespit edebilir**.
- ECC yalnızca **40 bit (TDP)** veya **80 bit (SDP)** veri genişliklerinde kullanılabilir.
- ECC için 8 veya 16 bitlik **parite bitleri** ayrılır; bu nedenle net veri genişliği sırasıyla **32 bit** veya **64 bit** olur.
- Hata durumu, ilgili çıkış sinyalleri üzerinden izlenebilir.

###  FIFO (First-In, First-Out) Modu

Block RAM, **FIFO modu** ile yapılandırılabilir:

- FIFO etkinleştirildiğinde, dahili **yazma ve okuma işaretçileri** bellek makrolarına yönlendirilir; bu durumda adres sinyalleri devre dışı kalır.
- **Port B → veri yazma (push)**  
    **Port A → veri okuma (pop)** işlemleri için kullanılır.
- FIFO, **senkron** veya **asenkron** modda çalışabilir.
- Durum bayrakları: boş (empty), dolu (full), neredeyse boş/dolu, okuma/yazma hatası, okuma/yazma işaretçileri.
- FIFO kontrolü için **aktif düşük sıfırlama sinyali (FIFO_RST_N)** mevcuttur.


## **TDP Modu**
### Block RAM Hücre Yapısı ve Port Konfigürasyonu

Her Block RAM hücresi, dört giriş sinyal grubu olan **A0, B0, A1 ve B1** üzerinden yapılandırılır.

- **İki bağımsız 20 Kbit hücre** olarak yapılandırıldığında:
   - A0 ve B0 → birinci RAM hücresinin portları
   - A1 ve B1 → ikinci RAM hücresinin portları olarak görev yapar.
   
- **Tek bir 40 Kbit hücre** olarak yapılandırıldığında:
   - A0 ile A1 birleştirilerek port A ,
   - B0 ile B1 birleştirilerek port B oluşturulur.

Her Block RAM hücresi, **CPE (Configurable Processing Element)** dizisinden gelen yatay giriş/çıkış bağlantılarına ve yönlendirme yapısına sahiptir. Ayrıca, dikey bağlantılar aracılığıyla **komşu Block RAM hücreleriyle** zincirleme (cascading) yapılabilir.

 Avantajlar

- **İki bağımsız port:** Aynı anda okuma ve yazma işlemleri yapılabilir.
- **Senkron/asenkron destek:** Portlar bağımsız saat sinyalleriyle çalışabilir.
- **Genişletilebilir mimari:** Cascading ile daha büyük bellek blokları elde edilebilir.
- **Esnek veri genişliği:** 20K modunda port başına 20 bit, 40K modunda port başına 40 bit veri genişliği.

###  Dezavantajlar

- **Adres çatışma riski:** Aynı adrese eşzamanlı erişimlerde veri tutarsızlığı olabilir; kontrol mantığı gerektirir.
- **Donanım karmaşıklığı:** Konfigürasyon ve sinyal eşleştirmeleri dikkatle tasarlanmalıdır.
- **Kaynak sınırlaması:** Bellek derinliği BRAM boyutuyla sınırlıdır; daha derin yapılar için birden fazla BRAM kullanılmalıdır.
![[Pasted image 20250707135041.png]]

**Pin wiring in TDP 20k mode**

| Width | Depth  | Address-in bus                   | Data-in-bus | Data-out-bus |
| ----- | ------ | -------------------------------- | ----------- | ------------ |
| 1     | 16,384 | a0_addr[15:7], <br> a0_addr[5:1] | a0_di[0]    | a0_d0[0]     |
| 2     | 8,192  | a0_addr[15:7], <br> a0_addr[5:2] | a0_d0i[1:0] | a0_d0[1:0]   |
| 5     | 4,096  | a0_addr[15:7], <br> a0_addr[5:3] | a0_di[4:0]  | a0_d0[4:0]   |
| 10    | 2,048  | a0_addr[15:7], <br> a0_addr[5:4] | a0_di[9:0]  | a0_d0[9:0]   |
| 20    | 1,024  | a0_addr[15:7], <br> a0_addr[5]   | a0_di[19:0] | a0_d0[19:0]  |

**Pin wiring in TDP 40k mode**

| Width | Depth  | Address-in bus | Data-in-bus                  | Data-out-bus                 |
| ----- | ------ | -------------- | ---------------------------- | ---------------------------- |
| 1     | 32,768 | a0_addr[15:1]  | a0_di[0]                     | a0_d0[0]                     |
| 2     | 16,384 | a0_addr[15:2]  | a0_d0i[1:0]                  | a0_d0[1:0]                   |
| 5     | 8,192  | a0_addr[15:3]  | a0_di[4:0]                   | a0_d0[4:0]                   |
| 10    | 4,096  | a0_addr[15:4]  | a0_di[9:0]                   | a0_d0[9:0]                   |
| 20    | 2,048  | a0_addr[15:5]  | a0_di[19:0]                  | a0_d0[19:0]                  |
| 40    | 1,024  | a0_addr[15:6]  | a1_di[39:0],<br> a0_di[39:0] | a1_d0[39:0],<br> a0_d0[39:0] |


## **SDP Modu**

Her Block RAM hücresi, dört giriş sinyal grubu olan **A0, B0, A1 ve B1** üzerinden yapılandırılır.

- **İki bağımsız 20 Kbit hücre** olarak yapılandırıldığında:
- - **Port A → Yazma Portu**: Yazma işlemleri için kullanılır.
- **Port B → Okuma Portu**: Okuma işlemleri için kullanılır.

  **20K Modu:** A0 ve B0 veri yolları birleştirilerek maksimum veri genişliği iki katına çıkarılır.
  **40K Modu:** A0, B0, A1 ve B1 veri yollarının tamamı birleştirilerek veri genişliği tekrar iki katına çıkarılır.
   
![[Pasted image 20250707135258.png]]

**Pin wiring in SDP 20k mode**

| Width | Depth | Address-in bus         | Data-in-bus                   | Data-out-bus                 |
| ----- | ----- | ---------------------- | ----------------------------- | ---------------------------- |
| 40    | 512   | {b0,b0}**_addr**[15:7] | b0_di[19:0], <br> a0_di[19:0] | b0_do[19:0],<br> a0_d0[19:0] |

**Pin wiring in SDP 40k mode**

| Width | Depth | Address-in bus         | Data-in-bus                                                     | Data-out-bus                                                   |
| ----- | ----- | ---------------------- | --------------------------------------------------------------- | -------------------------------------------------------------- |
| 40    | 512   | {b0,b0}**_addr**[15:7] | b1_di[19:0], <br> b0_di[19:0], <br> a0_di[19:0]<br> a1_di[19:0] | b1_do[19:0],<br> b0_do[19:0],<br> a0_do[19:0],<br> a1_do[19:0] |
###  Avantajlar

- **Artırılmış Veri Genişliği:** Veri yollarının birleştirilmesi sayesinde TDP moduna göre iki kat daha geniş veri işleme kapasitesi.
- **Basitleştirilmiş Port Yapısı:** Yazma ve okuma portlarının sabitlenmesi, kontrol mantığını sadeleştirir.    
- **Bağımsız Saat Desteği:** Yazma ve okuma portları farklı saat domainlerinde çalışabilir.
- **Veri Akışı Optimizasyonu:** Büyük veri blokları için hızlı transfer imkanı sağlar.

### Dezavantajlar

- **Tek Çıkış Portu:** Okuma verisi yalnızca Port B’den alınabilir; bu, bazı uygulamalarda esneklik kaybına yol açabilir.
- **Adres Çatışması Riski:** Yazma ve okuma işlemleri aynı adres üzerinde gerçekleşirse kontrol mantığı gereklidir.
- **Veri Gecikmesi:** Tek çıkış portu nedeniyle, veri yollarında fazladan gecikme oluşabilir.
- **Yapılandırma Karmaşıklığı:** 40K modunda tüm portların birleştirilmesi sinyal yönlendirme için dikkat gerektirir.


## **Block RAM – Cascade (Zincirleme) Modu Açıklaması**

Block RAM, **komşu RAM hücrelerinin clock, enable, write enable** ve **adres sinyallerini ileterek** daha büyük veya daha derin bellek yapıları oluşturulmasına olanak tanır. Bu özellik, **CPE (Compute Processing Element)** dizisinde sinyal yönlendirmesini kolaylaştırır.

###  **Cascade (Zincirleme) Modu:**

- **Cascade modu**, yukarıdaki sinyallere ek olarak **veri (data)** ve **bitmask** sinyallerinin de iletilmesini sağlar.
- Bu modda **yalnızca 1 bit veri genişliği** desteklenir.
- **Yalnızca aşağı yönde** zincirleme yapılabilir 
- Örneğin: İki adet **32K × 1 bit** Block RAM hücresi birleştirilerek **64K × 1 bit** bellek oluşturulabilir.
- **Veri ve bitmask giriş/çıkışları**, üstteki RAM hücresine aittir.
- Her iki RAM hücresi de **32K × 1 bit TDP modunda** yapılandırılmış olmalıdır.
- **Adres veri yolunun 0. biti**, okuma/yazma işlemi için **üst veya alt RAM hücresini** seçer.

![[Pasted image 20250707142039.png]]


##  **Avantajlar:**

| Avantaj                          | Açıklama                                                                              |
| -------------------------------- | ------------------------------------------------------------------------------------- |
| **Bellek Derinliği Artışı**      | Zincirleme ile daha derin bellek yapıları oluşturulabilir (örneğin 64K × 1 bit).      |
| **Sinyal Yönlendirme Kolaylığı** | Saat, enable, write enable, adres, veri ve bitmask sinyalleri otomatik yönlendirilir. |
|  **Modüler Tasarım**             | Küçük RAM hücreleri birleştirilerek büyük yapılar oluşturulabilir.                    |

##  **Kısıtlamalar:**

| Dezavantaj                          | Açıklama                                                  |
| ----------------------------------- | --------------------------------------------------------- |
| **Sadece 1 Bit Veri Genişliği**     | Cascade modu yalnızca 1 bit veri genişliğini destekler.   |
| **Yalnızca Aşağı Yönlü Zincirleme** | RAM hücreleri sadece aşağı yönde bağlanabilir.            |
| **Ön Koşul**                        | Her iki RAM hücresi de 32K × 1 bit TDP modunda olmalıdır. |


**Bellek Eşleme ve İçerik Başlatma**
## **Teknik Açıklama:**

###  **Bellek Dağılımı:**

- Geniş veri kelimeleri (örneğin 20 bit) belleğe düzgün şekilde dağılır: her SRAM bloğu bu kelimenin bir kısmını barındırır.
- Ancak **1 veya 2 bitlik veri kelimeleri** kullanıldığında, donanım mimarisi nedeniyle **her 5. bitlik konum boşta kalır** veya erişilemez olur. Bu, **verimsiz bellek kullanımı** anlamına gelir.

###  **Mantıksal Haritalama**

Bu durum, fiziksel belleğin nasıl organize edildiğini değil, **veri erişiminin yazılım/donanım tarafından nasıl yorumlandığını** ifade eder. Yani:

- 1-bitlik veri yazarken, bazı adresler atlanır.
- 5-bitlik veya daha büyük veri yazarken, tüm SRAM blokları aktif olarak kullanılır.

---

##  **Avantajlar:**

| Avantaj                          | Açıklama                                                              |
| -------------------------------- | --------------------------------------------------------------------- |
| **Verimli Dağılım (Geniş Veri)** | 5 bit ve üzeri veri genişliklerinde SRAM blokları dengeli kullanılır. |
| **Modlar Arası Uyum**            | Aynı adresleme şeması hem SDP hem TDP modlarında geçerlidir.          |

---

## **Dezavantajlar:**

| Dezavantaj                            | Açıklama                                                                           |
| ------------------------------------- | ---------------------------------------------------------------------------------- |
| **1-2 Bitlik Verilerde Erişim Kaybı** | Her 5. bit erişilemez, bu da bellek kapasitesinin tam kullanılmamasına neden olur. |
| **Karmaşık Haritalama**               | Yazılım/donanım tasarımında özel adresleme mantığı gerekebilir.                    |

![[Pasted image 20250707142900.png]],



## **ECC Kodlama / Kod Çözme**

### **Block RAM – ECC (Error Correction Code) Özelliği**

###  **Genel Tanım:**

Block RAM hücreleri, **veri bozulmalarına karşı koruma sağlamak amacıyla** dahili bir **ECC (Hata Düzeltme Kodu)** katmanına sahiptir. Bu özellik etkinleştirildiğinde, **parite bitleri otomatik olarak üretilir ve kontrol edilir**.

##  **ECC Özelliğinin Temel Özellikleri:**

- **ECC aktifken**, kullanıcı tüm 40 veya 80 veri bitini kullanamaz.
- Kullanıcıya ayrılan veri genişliği:
    - **TDP 40K**: 40 bit yapılandırmada **32 bit** kullanılabilir.
    - **SDP 40K**: 80 bit yapılandırmada **64 bit** kullanılabilir.
    - **SDP 20K**: 40 bit yapılandırmada **32 bit** kullanılabilir.
- Kalan 8 veya 16 bit, **parite bitleri** için ayrılmıştır.
- **Bitmask sinyali bu modda dikkate alınmaz**. Belleğe yazılan tüm 32 veya 64 bit veri + parite bitleri birlikte yazılır.

##  **Kullanılan Kodlama:**

- **Hamming Kodu (39,32)** kullanılır:
    - **7 parite biti**
    - **1 bitlik hataları düzeltebilir**
    - **2 bitlik hataları tespit edebilir**

##  **Hata Durumu Sinyalleri:**

| Konfigürasyon | Veri Genişliği | Hata Sinyalleri                          | Açıklama                                                  |
| ------------- | -------------- | ---------------------------------------- | --------------------------------------------------------- |
| **TDP 40K**   | 40 bit         | `A_ECC_{1B,2B}_ERR`, `B_ECC_{1B,2B}_ERR` | Port A ve B için ayrı hata sinyalleri                     |
| **SDP 40K**   | 80 bit         | `A_ECC_{1B,2B}_ERR`                      | Sadece Port A için geçerli, Port B sinyalleri kullanılmaz |
| **SDP 20K**   | 40 bit         | `A_ECC_{1B,2B}_ERR`, `B_ECC_{1B,2B}_ERR` | A: Block RAM #0, B: Block RAM #1 için hata sinyalleri     |

**1B_ERR**: Tek bitlik hata tespit edildi 
**2B_ERR**: Çift bitlik hata tespit edildi (düzeltilemez)

---

##  **Avantajlar:**

| Avantaj                       | Açıklama                                                              |
| ----------------------------- | --------------------------------------------------------------------- |
| **Veri Güvenliği**            | Bellek içeriği bozulmalara karşı korunur.                             |
| **Hata Tespiti ve Düzeltme**  | 1 bitlik hatalar otomatik düzeltilir, 2 bitlik hatalar tespit edilir. |
|  **Otomatik Parite Yönetimi** | Kullanıcı müdahalesi olmadan parite üretimi ve kontrolü yapılır.      |

---

##  **Sınırlamalar:**

| Sınırlama                               | Açıklama                                                                                                  |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------- |
|  **Kullanılabilir Veri Azalır**         | ECC için ayrılan parite bitleri nedeniyle 40/80 bitlik yapılandırmalarda sadece 32/64 bit kullanılabilir. |
| **Bitmask Kullanılamaz**                | Yazma işlemlerinde byte seçimi yapılamaz, tüm veri yazılır.                                               |
| **Sadece Belirli Modlarda Desteklenir** | Sadece TDP 40K, SDP 40K ve SDP 20K modlarında kullanılabilir.                                             |


## **RAM Erişim Modları ve Etkinleştirme**

### **Block RAM – Erişim Kontrol Sinyalleri ve Adresleme Modları**

Bir Block RAM hücresi, **okuma ve yazma işlemlerini kontrol etmek için üç ana sinyal** kullanır:

| `{EN}` | `{WE}` | `{BM}` | Mod           | Sonuç                                 |
| ------ | ------ | ------ | ------------- | ------------------------------------- |
| 0      | X      | X      | Her ikisi     | **Hiçbir işlem yapılmaz**             |
| 1      | 0      | X      | NO CHANGE     | **Okuma yapılır, veri korunur**       |
| 1      | 1      | 0      | Her ikisi     | **Yazma yapılmaz (bitmask kapalı)**   |
| 1      | 1      | 1      | WRITE THROUGH | **Veri yazılır ve çıkışa yansıtılır** |
| 1      | 1      | 1      | NO CHANGE     | **Veri yazılır, çıkış değişmez**      |


**Access combinations in NO CHANGE mode with {A|B}_EN = 1 (SDP and TDP)**
|**{A\|B}_WE¹**|**{A\|B}_BM[i]**|**Bellek ve {A\|B}_DO Üzerindeki Etki**|

| **{A\|B}_WE¹** | **{A\|B}_BM[i]**<br> | **Bellek ve {A\|B}_DO Üzerindeki Etki**                  |
| -------------- | -------------------- | -------------------------------------------------------- |
| 0              | 0                    | Tekil okuma, `mem[addr][i]` üzerinde güncelleme yapılmaz |
| 1              | 0                    | Son okuma, `mem[addr][i]` üzerinde güncelleme yapılmaz   |
| 0              | 1                    | Tekil okuma, `mem[addr][i]` üzerinde güncelleme yapılmaz |
| 1              | 1                    | Son okuma, `mem[addr][i]` güncellenir                    |
**Not:** SDP (Single Dual Port) modunda yalnızca **A_WE** sinyali kullanılır.



 Bellek Erişim Kombinasyonları – WRITE THROUGH Modu {A|B}_EN = 1 (yalnızca TDP)

| **{A\|B}_WE** | **{A\|B}_BM[i]** | **Bellek ve {A\|B}_DO Üzerindeki Etki**                  |
| ------------- | ---------------- | -------------------------------------------------------- |
| 0             | 0                | Tekil okuma, `mem[addr][i]` üzerinde güncelleme yapılmaz |
| 1             | 0                | Tekil okuma, `mem[addr][i]` üzerinde güncelleme yapılmaz |
| 0             | 1                | Tekil okuma, `mem[addr][i]` üzerinde güncelleme yapılmaz |
| 1             | 1                | **Write-through**: `mem[addr][i]` güncellenir            |

**Not:** Bu erişim kombinasyonları yalnızca **TDP (True Dual Port)** modunda ve **{A|B}_EN = 1** durumunda geçerlidir.

- **Tekil bir okuma işlemi**, yalnızca **etkinleştirme sinyali aktif** olduğunda (`{A|B}_EN = 1`) ve **tüm yazma sinyalleri pasif** olduğunda (`{A|B}_WE = 0`, `{A|B}_BM = 0`) gerçekleşir.
  **SDP (Simple Dual Port)** hem de **TDP**

![[Pasted image 20250707145211.png]]
-------
sonuç raporu bu kartı tercih etme sebebi gömülü blok ram olyadı bu hangi özellikleri olurdu muadil kartlarda var mı özel tasarım mı neyi etkiler 


