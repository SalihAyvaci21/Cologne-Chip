## Global Mesh ile Saat Dağıtımı ve Pick-Up Yöntemleri

**Global Mesh**, tüm FPGA çip alanında en fazla dört sinyali düşük saat kayması (**clock skew**) ile dağıtabilen bir sinyal ağıdır. Bu ağ çoğunlukla saat sinyallerinin dağıtımı için kullanılsa da, yüksek fan-out gerektiren kontrol sinyalleri (ör. enable, user reset) de Global Mesh üzerinden yönlendirilebilir. Çipin kenar çerçevesinde yer alan bir ring yapısı, Global Mesh sinyallerinin dağıtımını sağlar. Ayrıca dört ek dikey iz yapısı (vertical trace structures) sinyalleri FPGA fabric’in iç kısımlarına taşır. Saatleme şeması seçimi, **CC_BUFG kullanımı** ve sentez seçeneği **‘-noclkbuf’** ile yapılır. 
Bu bölüm, FPGA fabric içinde saat sinyallerinin dağıtımı için üç temel yöntemi açıklamaktadır.

---

### Saat Dağıtım Yöntemleri

1) **Global Mesh Kullanılmadan Routing**
- Tüm sinyaller, özel saat kaynakları kullanılmadan routing yapısıyla dağıtılır.

1) **Global Mesh Üzerinden Dağıtım**
- Saat sinyalleri, Global Mesh ağı üzerinden dağıtılır.

1) **CP-Lines Kullanarak Dağıtım**
- CP-line yapısı, saat ve ilgili enable sinyallerini çip genelinde dağıtarak clock skew’ü azaltır.

---

###  Global Mesh Pick-Up Seçenekleri

 Global Mesh sinyallerinin dört farklı yöntemle alınabileceğini gösterir:

| **Pick-Up Seçeneği**            | **Tanım**                                                                                                                                                                                                                   |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1) **Left Edge Select (LES)**   | Çipin sol kenarında, her y konumunda **LES(–2, y)** iki sinyali besler:  <br>• `CPE_CINX → CPE(1, y).CINX`  <br>• `CPE_PINX → CPE(1, y).PINX`  <br>1 ≤ y ≤ 128                                                              |
| 2) **Bottom Edge Select (BES)** | Çipin alt kenarında, her x konumunda **BES(x, –2)** iki sinyali besler:  <br>• `CPE_CINY2 → CPE(x, 1).CINY2`  <br>• `CPE_PINY2 → CPE(x, 1).PINY2`  <br>1 ≤ x ≤ 160                                                          |
| 3) **SB_BIG (Big Switch Box)**  | Tüm kenarlarda her koordinat, dört Global Mesh sinyalini **SB_BIG(x, y, p)** stack’ine besler. Aynı koordinatta üç plane paralel sinyal beslemesi yapılır.                                                                  |
| 4) **CPE Array Feed**           | Global Mesh sinyalleri dört sütunda CPE array’e beslenir (**bkz. Tablo 2.71**).  <br>Sinyaller doğrudan Switch Box girişlerine yönlendirilir:  <br>• `CPE.RAM_I1 → CPE.OUT1 → SB.D0`  <br>• `CPE.RAM_I2 → CPE.OUT2 → SB.D0` |
![[Pasted image 20250708154354.png]]
![[Pasted image 20250708154321.png]]
![[Pasted image 20250708154334.png]]

---

###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                              | **Dezavantajlar**                                                                                                      |
| ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Düşük Clock Skew:** Global Mesh sayesinde saat sinyalleri çip genelinde dengeli şekilde yayılır.          |  **Sınırlı Kaynak:** En fazla 4 Global Mesh sinyali desteklenir.                                                       |
| **Yüksek Fan-Out Uygulamaları:** Enable ve reset sinyalleri gibi kontrol sinyallerinde idealdir.            | **Konfigürasyon Karmaşıklığı:** Farklı pick-up yöntemlerinin dikkatle yapılandırılması gerekir.                        |
| **Esnek Pick-Up Seçenekleri:** LES, BES, SB_BIG ve CPE array ile dört farklı sinyal alma yolu vardır.       | **CP-Lines Sadece Belirli Durumlarda Etkili:** CP-line yöntemi karmaşık topolojilerde kısıtlı performans sağlayabilir. |
| **Saat ve Kontrol Sinyalleri için Optimize:** Global Mesh hem saat hem de kontrol sinyallerini taşıyabilir. | **Yerleşim Kısıtlamaları:** Sinyal yönlendirme bazı durumlarda kaynak çakışmalarına yol açabilir.                      |
![[Pasted image 20250708154407.png]]


## Genel Saatleme Şeması: Routing Yapısı Üzerinden Saat Dağıtımı

En genel saatleme şeması, saat sinyallerinin FPGA’nın **routing yapısı** üzerinden yönlendirilmesidir. Bu yöntemde **Global Mesh kullanılmaz** ve **Place & Route** işlemi **‘--clk_CP’** seçeneği ile başlatılmalıdır. Bu sayede, herhangi bir tasarımda **sınırsız sayıda saat domain’i** gerçekleştirilebilir.

Global Mesh izleri, saat sinyalleri yerine diğer sinyallerin dağıtımı için kullanılabilir. Bu sinyallere erişim, **Pick-Up Seçenekleri 3 (SB_BIG)** ve **4 (CPE)** aracılığıyla sağlanır. Ancak, kenar elemanları olan **LES** ve **BES** bu durumda kullanılamaz.

 **Not:** Elektromanyetik girişim (**EMI**) açısından bu saatleme şeması tercih edilmelidir. Bununla birlikte, özel saatleme kaynakları kullanılmadığı için saat sinyallerinin CPE ve routing mimarisi üzerinden yönlendirilmesi yüksek clock skew’e yol açabilir. Bu problem, Place & Route yazılımı tarafından ele alınır ve optimize edilir.

---

###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                                | **Dezavantajlar**                                                                                                |
| ------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Sınırsız Saat Domain’i:** Routing yapısı ile herhangi bir sayıda saat domain’i tasarlanabilir.              | **Yüksek Clock Skew Riski:** Saat sinyalleri özel kaynaklar yerine routing ile taşındığından sapmalar artabilir. |
| **Düşük EMI:** Elektromanyetik girişimi azaltır çünkü Global Mesh’te saat sinyali yoktur.                     | **Düşük Maksimum Frekans:** Routing yolu üzerinden saat sinyali taşımak frekans sınırlarını düşürebilir.         |
| **Esnek Sinyal Kullanımı:** Global Mesh izleri yüksek fan-out gerektiren diğer sinyaller için kullanılabilir. | **LES ve BES Kullanılamaz:** Kenar pick-up elemanları devre dışıdır.                                             |
| **Kolay Konfigürasyon:** Routing, doğrudan Place & Route yazılımı tarafından optimize edilir.                 | **Performans Sınırlaması:** Kritik yollar için Global Mesh kadar verimli değildir.                               |

---

**Not:** Bu saatleme şeması, EMI hassasiyeti yüksek sistemler ve esnek saat domain tasarımları için uygundur. Ancak yüksek frekanslı veya düşük sapma gerektiren uygulamalarda dikkatle değerlendirilmelidir.


## CP-Lines ile Saat Dağıtımı

**CP-Lines**, FPGA’nın tüm çip alanında hızlı saat yönlendirmesi (**fast clock routing**) sağlamak için kullanılabilir. Bu yöntem, saat dağıtımının Global Mesh üzerinden yapılmasıyla birleştirilebilir veya saat sinyalleri yalnızca routing yapısıyla sağlanabilir.

Kullanıcı devresine saat sinyalleri **CP-Lines** aracılığıyla beslenirken çeşitli yollar mevcuttur. Bu senaryolarda, kullanıcı devresinin **CPE array** içinde dikdörtgen bir alanı kapladığı varsayılır.

Saat sinyali ve buna eşlik eden enable sinyali, bir **intake element** tarafından alınır ve CP-Lines üzerinden dağıtılır. Her iki sinyalin de Global Mesh’ten gelmesi veya routing yapısıyla intake elementine ulaşması mümkündür. FPGA içinde yalnızca **bir saat / enable sinyali çifti** CP-Lines üzerinden yönlendirilebilir. Enable sinyali isteğe bağlıdır.

**Önkoşul:** Place & Route işlemi **‘++clk_CP’** seçeneği ile başlatılmalıdır.

---

###  CP-Line Dağıtım Türleri

Saat dağıtım prensibi, dört temel CP-Line türüne ayrılır:
1) **Intake CPE + Chained CPE Row**
2) **Intake BES + Chained BES Row**
3) **Unchained BES Row + Global Mesh Pick-up**
4) **Intake LES + Chained CPE Row**

###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                               | **Dezavantajlar**                                                                             |
| ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| **Hızlı Saat Dağıtımı:** CP-Lines saat sinyalini tüm çipte düşük gecikme ile dağıtır.                        |  **Sinyal Çifti Sınırlaması:** Sadece bir saat / enable çifti CP-Lines üzerinden taşınabilir. |
| **Esnek Kaynak Seçimi:** Saat ve enable sinyalleri Global Mesh veya routing ile intake elementine gelebilir. | **Yüksek Fan-Out Limitasyonu:** Çok sayıda yüksek fan-out sinyali bu yöntemle taşınamaz.      |
| **Optimize Edilmiş Zamanlama:** Düşük clock skew için ideal çözüm sunar.                                     | **Place & Route Bağımlılığı:** ‘++clk_CP’ seçeneği kullanılmazsa CP-Line ağı devreye girmez.  |
| **Kritik Devre Alanlarında Kullanışlı:** Dikdörtgen CPE bölgeleri için optimize edilmiştir.                  | **Konfigürasyon Karmaşıklığı:** Farklı intake element türlerinin doğru seçilmesi gerekir.     |
## 1) **CP-Lines Saatleme Şeması: Intake CPE ile Zincirlenmiş CPE Satırı**

Bu saatleme şeması, kullanıcı devresinin dikdörtgen alanı (**Şaşağıdaki şekilde, çizgili alan) altında, (x₀−1, y₀−1) konumundan (x₁, y₀−1) konumuna kadar yatay bir CPE zinciri (horizontal CPE chain)** yerleştirir. Saat sinyalleri bu zincir üzerinden **CP-Lines** aracılığıyla y ekseninde yukarı doğru iletilir. Bu yaklaşım, hem x hem de y yönünde minimum saat kayması (**minimal clock skew**) sağlar.

---

###  Intake CPE

- **Intake CPE (x₀−1, y₀−1):**
	- Kaynağı Global Mesh veya routing yapısındaki herhangi bir sinyal olabilir.
	- Saat sinyalini CPE zincirine besler.

---

###  Önkoşul

Bu saatleme şeması için kullanıcı devresinin altında en az bir **boş yatay CPE satırı** bulunmalıdır. Bu satır, CP-Line zincirinin yerleştirilmesi için gereklidir.

---

###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                | **Dezavantajlar**                                                                                  |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **Düşük Saat Kayması:** Saat sinyali hem yatay hem dikey olarak minimum gecikmeyle dağıtılır. |  **Yerleşim Kısıtlaması:** Kullanıcı devresinin altında en az bir boş yatay CPE satırı gerektirir. |
| **Esnek Sinyal Kaynağı:** Intake CPE hem Global Mesh hem de routing sinyallerini alabilir.    | **Kısıtlı Kullanım Alanı:** Devre alanı çok sıkışık olan tasarımlar için uygun olmayabilir.        |
| **Yüksek Performans:** Kritik zamanlama yollarında saat sapmasını azaltır.                    | **Tek Saat / Enable Çifti:** FPGA içinde sadece bir saat / enable çifti CP-Lines ile taşınabilir.  |


![[Pasted image 20250708160621.png]]
## 2) CP-Lines Saatleme Şeması: Intake BES ile Zincirlenmiş BES Satırı

Eğer kullanıcı devresinin altında ek bir **CPE zinciri** yerleştirmek için boş alan yoksa (**çizgili alan**), saat ve isteğe bağlı enable sinyalleri **Intake Bottom Edge Select (BES)** elemanı aracılığıyla alınabilir. Intake BES, **(x₀, −2)** koordinatında konumlanır ve sinyalleri **(x₁, −2)** koordinatına kadar zincirlenmiş BES satırı üzerinden iletir.

**Intake BES**, Global Mesh sinyallerini veya routing yapısından gelen herhangi bir sinyali alıp CPE array’e yönlendirebilir. Böylece saat sinyali, kullanıcı devresinin altındaki boşluk eksikliğine rağmen CP-Line ağına beslenebilir.

---

###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                                       | **Dezavantajlar**                                                                                   |
| -------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| **Yerleşim Esnekliği:** CPE zinciri için alt satır boşluğu gerektirmez, bu nedenle sıkışık tasarımlar için uygundur. |  **Edge Bağımlılığı:** Saat sinyali sadece alt kenardaki BES elemanları üzerinden alınabilir.       |
| **Global Mesh veya Routing Kaynağı:** BES, hem Global Mesh hem de routing sinyallerini kabul eder.                   | **Tek Saat / Enable Çifti:** FPGA’da yalnızca bir saat/enable çifti CP-Lines üzerinden taşınabilir. |
| **Hızlı Yönlendirme:** Zincirlenmiş BES satırı, saat sinyalini yatay olarak hızlıca iletir.                          | **Kısıtlı Fan-Out:** Yüksek fan-out gerektiren sinyaller için sınırlı kaynak olabilir.              |

---

 **Not:** Bu şema, alt satırda alan kısıtlı olsa bile saat dağıtımının CP-Line ağı üzerinden devam ettirilmesini sağlar.

![[Pasted image 20250708160959.png]]
## 3) CP-Lines Saatleme Şeması: Zincirlenmemiş BES Satırı ve Global Mesh Pick-Up

Bu saatleme şeması, önceki anlatılan yöntemin bir varyantıdır. Burada, **(x₀, −2)** ile **(x₁, −2)** koordinatları arasındaki her **Bottom Edge Select (BES)** elemanı, doğrudan **Global Mesh’ten iki sinyal** alır. Bu dağıtım biçiminde saat sinyalleri, yatay zincirleme olmadan her BES üzerinden bağımsız olarak alınır.

Bu yöntemde, **clock skew** sadece **y ekseni** boyunca oluşur çünkü x ekseninde sinyal iletimi zincirleme yapılmaz.

 **Alternatif Konfigürasyon:** Önceki örnekten farklı olarak, iki sinyalden biri Global Mesh’ten doğrudan alınabilirken, diğer sinyal **BES elemanları üzerinden zincirlenerek** iletilebilir.

---

###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                                 | **Dezavantajlar**                                                                                    |
| -------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Doğrudan Global Mesh Pick-Up:** Saat sinyalleri BES üzerinden zincirleme olmadan Global Mesh’ten alınır.     | **Y-Direction Skew:** Saat sinyalleri yalnızca y yönünde sapma (skew) gösterir.                      |
| **Hızlı Konfigürasyon:** Sinyaller doğrudan Global Mesh’ten BES elemanlarına gelir.                            | **Esnekliğin Azalması:** Zincirleme yapılmadığı için fan-out sınırlamaları daha belirgin hale gelir. |
| **Düşük Yönlendirme Gecikmesi:** Sinyaller yatay zincirleme yapmadan iletildiğinden minimum routing gecikmesi. |  **Sinyal Kaynak Sınırlaması:** Her BES yalnızca iki Global Mesh sinyaline erişebilir.               |

---

 **Sonuç:** Zincirleme olmadan Global Mesh erişimi, hızlı saat dağıtımı sağlar. Ancak, y yönünde oluşabilecek sapmaların kritik tasarımlar için değerlendirilmesi gerekir.








![[Pasted image 20250708161311.png]]
## 4) CP-Lines Saatleme Şeması: Intake LES ile Zincirlenmiş CPE Satırı

Bu saatleme şeması, kullanıcı devresinin **CPE array** içinde **sol kenara dayalı** olarak yerleştiği senaryolar için uygundur (**çizgili alan**). Kullanıcı devresi, alt sol köşesi **(1, y₀)** ve üst sağ köşesi **(x₁, y₁)** olan bir dikdörtgen alan kaplar.

Saat ve isteğe bağlı enable sinyalleri, sol kenarda bulunan **Intake Left Edge Select (LES)** elemanı **(−2, y₀−1)** üzerinden alınır ve bu sinyaller kullanıcı devresinin altındaki yatay **CPE zinciri** boyunca x yönünde iletilir (**(1, y₀−1)**’den **(x₁, y₀−1)**’e). Intake LES, sinyalleri **Global Mesh** veya routing yapısından alabilir.

 **Önkoşul:** Kullanıcı devresinin altındaki yatay CPE satırında en az bir boş satır olmalıdır.

---

###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                              | **Dezavantajlar**                                                                                    |
| ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Sol Kenara Dayalı Tasarımlar İçin İdeal:** Intake LES, CPE array’in sol kenarından saat sinyali alabilir. | **Yerleşim Kısıtlaması:** Yalnızca kullanıcı devresi sol kenara dayalıysa uygulanabilir.             |
|  **Global Mesh veya Routing Kaynağı:** Intake LES her iki kaynaktan da sinyal alabilir.                     | **Boş Satır Gereksinimi:** Alt yatay CPE satırında boşluk bulunması şarttır.                         |
| **Düşük Saat Sapması:** Zincirlenmiş yatay CPE satırı, x yönünde minimum clock skew sağlar.                 | **Sinyal Çifti Sınırlaması:** FPGA’da yalnızca bir saat/enable çifti CP-Lines üzerinden taşınabilir. |

---

 **Sonuç:** Sol kenara dayalı devreler için optimize edilmiş bu yöntem, saat sinyallerinin hızlı ve dengeli bir şekilde dağıtılmasını sağlar.## CP-Lines Saatleme Şeması: Intake LES ile Zincirlenmiş CPE Satırı

Bu saatleme şeması, kullanıcı devresinin **CPE array** içinde **sol kenara dayalı** olarak yerleştiği senaryolar için uygundur (**bkz. Şekil 2.58, çizgili alan**). Kullanıcı devresi, alt sol köşesi **(1, y₀)** ve üst sağ köşesi **(x₁, y₁)** olan bir dikdörtgen alan kaplar.

Saat ve isteğe bağlı enable sinyalleri, sol kenarda bulunan **Intake Left Edge Select (LES)** elemanı **(−2, y₀−1)** üzerinden alınır ve bu sinyaller kullanıcı devresinin altındaki yatay **CPE zinciri** boyunca x yönünde iletilir (**(1, y₀−1)**’den **(x₁, y₀−1)**’e). Intake LES, sinyalleri **Global Mesh** veya routing yapısından alabilir.

 **Önkoşul:** Kullanıcı devresinin altındaki yatay CPE satırında en az bir boş satır olmalıdır.

 **Sonuç:** Sol kenara dayalı devreler için optimize edilmiş bu yöntem, saat sinyallerinin hızlı ve dengeli bir şekilde dağıtılmasını sağlar.
![[Pasted image 20250708161831.png]]