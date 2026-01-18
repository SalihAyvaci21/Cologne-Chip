### **Genel Yapı**

- **GateMate CCGM1A1 / CCGM1A2 FPGA’ları**, toplamda **162 adet GPIO pini** sunar.
- Bu pinler, **pad hücreleri (pad cells)** olarak adlandırılan çiftler halinde düzenlenmiştir.
- Her pad hücresi:
- **İki bağımsız, çift yönlü (bidirectional) tek uçlu (single-ended)** sinyal olarak çalışabilir.
- Alternatif olarak, **çift yönlü düşük voltajlı diferansiyel sinyal (LVDS)** olarak yapılandırılabilir.
- **PAD A / PAD B:** Her biri bağımsız olarak giriş veya çıkış olarak yapılandırılabilir.
- **Gecikme Elemanları (Delay - Dly):** Sinyal zamanlamasını ayarlamak için kullanılır.
- **Buffer’lar:** Sinyal gücünü artırarak yönlendirme sağlar.
- **Switch Box Bağlantısı:** GPIO sinyalleri, FPGA içindeki yönlendirme ağına bağlanır.
- **CPE Bağlantısı:** GPIO sinyalleri doğrudan işlem birimlerine (CPE) iletilebilir.
- **Saat Hatları (CLOCK[3:0]):** Zamanlama kontrolü için dört farklı saat sinyali desteği.
- **Güç Hatları (VDDcore, VDDIO):** Çekirdek ve I/O voltajları için ayrı besleme hatları.

Bu yapı, hem **yüksek hızlı haberleşme** hem de **genel amaçlı dijital kontrol** için optimize edilmiştir.



## **1. Single-Ended GPIO Açıklaması**

**Single-ended GPIO pinleri**, dijital sinyalleri tek bir hat üzerinden ileten ve alan, genel amaçlı giriş/çıkış pinleridir. GateMate FPGA’larda bu pinler, **LVCMOS standardına** uygun olarak çalışır.

###  Teknik Özellikler:

- **Desteklenen voltajlar:**
    - 1.8 V ±0.15 V (normal aralık)
    - 1.2 V – 1.95 V (geniş aralık)
    - Maksimum 2.5 V nominal

###  Çıkış Özellikleri:

- 0 / 1 / high-Z (üç durumlu çıkış)
- Slew-rate kontrolü (geçiş hızı ayarı)
- Sürücü gücü: 3 mA, 6 mA, 9 mA, 12 mA
- 2 Flip-Flop (SDR ve DDR desteği)
- Programlanabilir gecikme hattı

###  Giriş Özellikleri:

- Schmitt-trigger giriş (gürültüye dayanıklı)
- Pull-up / pull-down dirençleri veya keeper fonksiyonu
- Alıcı devreyi devre dışı bırakma (güç tasarrufu)
- 2 Flip-Flop (SDR ve DDR desteği)
- Programlanabilir gecikme hattı



![[Pasted image 20250707102132.png]]

## **2. LVDS GPIO Açıklaması**

**LVDS (Low-Voltage Differential Signaling)**, yüksek hızlı ve düşük gürültülü veri iletimi için kullanılan diferansiyel sinyal yöntemidir. GateMate FPGA’larda GPIO pin çiftleri, LVDS modunda çalışacak şekilde yapılandırılabilir.

###  Teknik Özellikler:

- **Diferansiyel sinyal iletimi:** Gürültü bağışıklığı yüksek, hızlı veri aktarımı sağlar.
- **Çift yönlü çalışma:** Aynı pad çifti hem giriş hem çıkış olarak kullanılabilir.

###  Çıkış Özellikleri:

- Sürücü gücü: 3.2 mA ve 6.4 mA
- 2 Flip-Flop (SDR ve DDR desteği)
- Programlanabilir gecikme hattı

###  Giriş Özellikleri:

- 2 Flip-Flop (SDR ve DDR desteği)
- Programlanabilir gecikme hattı


![[Pasted image 20250707102946.png]]

## **3. GPIO Bank Yapısı**

GateMate FPGA’larda GPIO pinleri, **pad hücreleri (pad cells)** olarak adlandırılan çiftler halinde düzenlenmiştir. Bu pad hücreleri, **GPIO bankaları** adı verilen gruplar oluşturur.

###  Yapı:

- **1 GPIO bankası = 9 pad hücresi**
- **Toplam 8 ana GPIO bankası + 1 opsiyonel banka**
- Her pad hücresi:
    - 2 pad içerir (PAD A ve PAD B)
    - Switch box ve CPE’lere doğrudan bağlıdır
    - CLOCK[3:0], VDDcore ve VDDIO hatlarıyla entegredir

###  Avantajlar:

- LVDS ve single-ended modlar arasında esnek geçiş yapılabilir
- Her bank bağımsız olarak yapılandırılabilir



**NOT: Kullanılmayan GPIO bankaları, parazitlenmeyi önlemek için yine de güçle beslenmelidir. Bu amaçla, baskılı devre kartı (PCB) üzerinde mevcut olan herhangi bir GPIO voltajı kullanılabilir.**


## **GPIO Bankalarının Konumlandırılması**

**CCGM1A1 / CCGM1A2 FPGA** cihazlarında, her kenarda (edge) **iki adet GPIO bankası** bulunur. Bu bankalar, **ana yönlere göre adlandırılmıştır:

###  **Özel Durum: Konfigürasyon Bankası**

- Batı kenarında, standart iki GPIO bankasına ek olarak, **üçüncü bir GPIO bankası** daha yer alır.
- Bu özel bankada, **konfigürasyon sinyalleri** (örneğin JTAG, SPI, vb.) yer alır.
![[Pasted image 20250707105831.png]]
###  **Avantajlar**

| Özellik                                | Avantaj                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------ |
| **Yön bazlı yerleşim**                 | PCB tasarımında sinyal yönlendirmeyi kolaylaştırır                       |
| **Simetrik dağılım**                   | Giriş/çıkış yükünü dengeler, sinyal bütünlüğünü artırır                  |
| **Konfigürasyon bankasının ayrılması** | Sistem başlatma ve programlama işlemlerini izole eder, güvenliği artırır |

###  **Dezavantajlar**

| Sınırlama                                 | Açıklama                                                           |
| ----------------------------------------- | ------------------------------------------------------------------ |
| **Konfigürasyon bankasının sabit konumu** | Alternatif yerleşim senaryolarında yeniden yönlendirme gerekebilir |

---

Bu yapı, FPGA’nın hem **giriş/çıkış performansını optimize etmek** hem de **konfigürasyon işlemlerini güvenli ve kararlı şekilde yönetmek** amacıyla tasarlanmıştır.

WB => WA (Pad A)  
WC => WB (Pad B)  
WA => configuration bank olarak kullanılmıstır.

**WA (konfigürasyon bankası)** ile **SerDes** arayüzünün yonga üzerinde **karşılıklı hizalanmış** olması, bilinçli bir mimari tercihtir ve bunun birkaç teknik nedeni ve avantajı vardır,

1. ### **Yönlendirme Basitliği ve Kısalık**

- SerDes de yüksek hızlı seri veri iletiminde kullanıldığından, bu iki birimin karşılıklı yerleştirilmesi, **daha kısa ve doğrudan bağlantı yolları** sağlar.

1. ### **Başlangıçta Hızlı Erişim**   
   - FPGA ilk açıldığında, konfigürasyon pinlerinin hızlıca erişilebilir olması gerekir.
   - SerDes üzerinden gelen yapılandırma verileri doğrudan WC bankasındaki pinlere yönlendirilebilir.

1. ### **PCB Tasarımı Kolaylığı**
   - Yüksek hızlı sinyallerin yönlendirilmesi PCB üzerinde zordur.
   - Bu hizalama, **dış dünyadan gelen konfigürasyon sinyallerinin** doğrudan SerDes’e hızlıca ulaşmasını sağlamaktadır.


## **CCGM1A2 GPIO Bankası Yapısı ve BGA Bağlantısı**

###  **Temel Bilgi:**

- Ancak, **tüm GPIO bankaları doğrudan BGA pinlerine bağlanmamıştır**.
- Bunun nedeni, **CCGM1A1 ile pin uyumluluğunu (pin compatibility)** korumaktır.

![[Pasted image 20250707110548.png]]

---

##  **GPIO Bankalarının Eşleştirilmesi (Bank Pairing)**

- **Bazı GPIO bankaları çiftler halinde bağlanmıştır** (örneğin: NA ↔ NA’, SA ↔ NA’).
- Bu eşleştirme, **iki yongadaki aynı konumda bulunan bankaların** tek bir BGA pin grubuna bağlanması anlamına gelir. **Giriş olarak** her iki bankadan veri alınabilir.
- **Yedeklilik** sağlar: bir bankada sorun olursa diğer kullanılabilir.
-  **1A üzerindeki EA bankası** ile **1B üzerindeki WB bankası** fiziksel olarak **aynı BGA pinlerine bağlanmıştır**, bu iki bankanın birleşik hali artık **WB** olarak adlandırılır.


---

##  **Avantajlar**

| Özellik                                | Avantaj                                                                         |
| -------------------------------------- | ------------------------------------------------------------------------------- |
| **Pin uyumluluğu (pin compatibility)** | CCGM1A2, CCGM1A1 ile aynı PCB üzerinde çalışabilir.                             |
| **Kaynak paylaşımı**                   | Aynı BGA pinleri üzerinden iki yonganın GPIO kaynakları kullanılabilir.         |
| **GPIO sayısında artış**               | Eşleştirme sayesinde toplamda daha fazla GPIO erişilebilir olur.                |
| **Alan tasarrufu**                     | BGA pin sayısı sınırlı olduğundan, bu yöntemle daha fazla işlevsellik sağlanır. |
|                                        |                                                                                 |

---

##  **Sınırlamalar**

|Sınırlama|Açıklama|
|---|---|
|**Çift yönlü sürücü kısıtı**|Eşleştirilmiş bankalardan **yalnızca biri çıkış (output) olarak etkinleştirilebilir**. Aksi takdirde sinyal çakışması olur.|
|**Tasarım karmaşıklığı**|Hangi bankanın aktif olacağı dikkatle kontrol edilmelidir.|
|**Yazılım yapılandırması**|FPGA konfigürasyonunda bank eşleştirmeleri göz önünde bulundurulmalıdır.|

---






Bu yapı, **çoklu yonga mimarisinde** hem **donanım uyumluluğunu korumak** hem de **maksimum GPIO verimliliği sağlamak** için oldukça akıllıca bir çözümdür.

