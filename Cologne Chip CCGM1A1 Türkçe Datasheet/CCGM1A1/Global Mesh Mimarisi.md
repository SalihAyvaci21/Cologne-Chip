Her FPGA yongasında bulunan **Global Mesh**, çip genelinde sinyallerin hızlı ve güvenilir bir şekilde dağıtılmasını sağlayan dört anahtarlı sinyal hattından oluşur. Bu yapı, özellikle saat sinyallerinin yayılması için tasarlanmış olsa da; yüksek fan-out gerektiren etkinleştirme (enable) ve kullanıcı reseti (user reset) gibi kontrol sinyalleri için de ideal bir çözümdür. Global Mesh’in saat üretim modülleriyle olan yakın entegrasyonu, aşağıdaki şekilde ayrıntılı olarak gösterilmiştir.

![[Pasted image 20250708142658.png]]

GateMate FPGA’lar (**CCGM1A1 / CCGM1A2**), her biri GPIO pinlerinin ikinci fonksiyonu olarak tanımlanmış **dört özel saat giriş pini (CLK0–CLK3)** ile donatılmıştır. Bunlara ek olarak, **SER_CLK** pini de FPGA’ya saat sinyali beslemek için kullanılabilir. Bu beş giriş saatinden, **CLKIN modülü** dört çıkış saati seçer ve bunları aşağıdaki şekilde gösterildiği gibi PLL’lere iletir. Her FPGA yongası kendi **CLKIN modülüne** sahip olmakla birlikte, giriş saatleri (**CLK0–CLK3 ve SER_CLK**) tüm yongalar arasında ortaktır. Ayrıca, her bir **CLK_REF[3:0]** çıkışı için saat tersleme (180° faz kaydırma) yapılandırılabilir.

![[Pasted image 20250708142820.png]]

GateMate FPGA’larda bulunan dört PLL’in her biri, tanımlanan PLL çekirdeğini barındırır. **CLKIN çoklayıcılarından (multiplexers)** gelen her bir saat çıkışı, herhangi bir PLL için referans saat kaynağı olarak seçilebilir. Gösterildiği gibi, **CLK_REF[3:0]** sinyallerine alternatif olarak **CPE çıkışlarındaki RAM_O1** üzerinden gelen kullanıcı saatleri (**USR_CLK_REF[3:0]**) de PLL girişinde kullanılabilir. Her PLL, seçilen giriş saatine bağlı olarak dört fazlı (0°, 90°, 180°, 270°) çıkış frekansı üretir. Aynı zamanda **Şekil 2.52**’de gösterilen mantık bloğu; saat çıkışını etkinleştirme, kilit durumu gereksinimi ve 180° ile 270° çıkış saatleri için frekans iki katına çıkarma gibi yapılandırma seçeneklerini barındırır. Ek olarak, her iki giriş saati de PLL içinde bypass edilebilir.


![[Pasted image 20250708143201.png]]

### USR_CLK_REF(n) Kaynakları

| **PLL** | **CPE Koordinatı** | **CPE Çıkışı** |
| ------- | ------------------ | -------------- |
| 0       | CPE(1,124)         | RAM_O1         |
| 1       | CPE(1,123)         | RAM_O1         |
| 2       | CPE(1,122)         | RAM_O1         |
| 3       | CPE(1,121)         | RAM_O1         |


## PLL Çıkış Saatlerinin Dağıtımı

Dört PLL çıkış saati, hem **GLBOUT modülüne** (bkz. sayfa 110) hem de **CPE girişleri RAM_I1**’e bağlıdır. Buradan, saat sinyalleri **CPE.OUT1** üzerinden **Switch Box**’lara yönlendirilir ve FPGA fabric genelinde dağıtılır. Aşağıdaki tablo ilgili CPE koordinatları hakkında ayrıntılı bilgileri sunmaktadır.


**CPE destinations of PLL clock output signals**

| PLL | PLL clock output | CPE coordinate | CPE input/output |
| --- | ---------------- | -------------- | ---------------- |
| 0   | CLK0_0           | CPE(39,128)    | RAM_I1 / OUT1    |
| 0   | CLK90_0          | CPE(40,128)    | RAM_I1 / OUT1    |
| 0   | CLK180_0         | CPE(41,128)    | RAM_I1 / OUT1    |
| 0   | CLK270_0         | CPE(42,128)    | RAM_I1 / OUT1    |
| 1   | CLK0_1           | CPE(43,128)    | RAM_I1 / OUT1    |
| 1   | CLK90_1          | CPE(44,128)    | RAM_I1 / OUT1    |
| 1   | CLK180_1         | CPE(45,128)    | RAM_I1 / OUT1    |
| 1   | CLK270_1         | CPE(46,128)    | RAM_I1 / OUT1    |
| 2   | CLK0_2           | CPE(47,128)    | RAM_I1 / OUT1    |
| 2   | CLK90_2          | CPE(48,128)    | RAM_I1 / OUT1    |
| 2   | CLK180_2         | CPE(49,128)    | RAM_I1 / OUT1    |
| 2   | CLK270_2         | CPE(50,128)    | RAM_I1 / OUT1    |
| 3   | CLK0_3           | CPE(51,128)    | RAM_I1 / OUT1    |
| 3   | CLK90_3          | CPE(52,128)    | RAM_I1 / OUT1    |
| 3   | CLK180_3         | CPE(53,128)    | RAM_I1 / OUT1    |
| 3   | CLK270_3         | CPE(54,128)    | RAM_I1 / OUT1    |
Kartezyen sistemdeki koordinatların her zaman kalıp yönünde verildiğini lütfen unutmayın.


**GLBOUT çoklayıcıları**, PLL’den gelen beş sinyali (**dört fazlı saat çıkışı ve bypass edilmiş saat**) ve dört ek kullanıcı sinyalini (**USR_GLB[3:0]**) işleyerek dört çıkış sinyali (**GLB[3:0]**) üretir. Bu çıkışlar, çip genelinde yüksek fan-out gerektiren sinyallerin ve saat sinyallerinin dağıtımında kullanılır. Giriş sinyallerinin nasıl seçilip yönlendirildiğini gösterirken, aşağıdaki tabloda ilgili sinyalleri detaylandırır. GLBOUT çıkışları, **Global Mesh** ağına bağlanır ve çip genelinde düşük gecikme sapması (**low skew**) ile erişilebilir.


USR_GLB[3:0] sources

| signal   | CPE coordinate | CPE output |
| -------- | -------------- | ---------- |
| USR_GLB0 | CPE(1,128)     | RAM_01     |
| USR_GLB1 | CPE(1,127)     | RAM_01     |
| USR_GLB2 | CPE(1,126)     | RAM_01     |
| USR_GLB3 | CPE(1,125)     | RAM_01     |

![[Pasted image 20250708143815.png]]




## CC_BUFG Elemanlarının Global Mesh’te Kullanımı

**CC_BUFG elemanları**, sinyallerin FPGA’nın **Global Mesh** ağına beslenmesi için kullanılır. Bu mesh dört ağdan (net) oluştuğu için, bir tasarımda maksimum **dört CC_BUFG elemanı** kullanılabilir. Daha fazla CC_BUFG instantiate edilirse, **Place & Route** aşaması hata mesajı ile durdurulur. Eğer tasarımda hiç CC_BUFG elemanı yoksa, Global Mesh ağı devreye alınmaz ve sinyaller standart routing üzerinden dağıtılır.

Sentez aracı (**synthesis tool**), bir CC_BUFG elemanının yerleştirilip yerleştirilmeyeceğine karar verirken saat sinyalleri ve diğer sinyaller arasında ayrım yapar. Bazı primitifler bu bağlamda **clock input portlarına** sahiptir ve doğrudan Global Mesh’e bağlanabilir.

![[Pasted image 20250708150218.png]]

## CC_BUFG Elemanlarının Kullanımı ve Sentez Davranışı

GateMate FPGA tasarımlarında **CC_BUFG** elemanları, sinyallerin Global Mesh ağı üzerinden dağıtılması için kullanılabilir. Kullanıcı bu elemanları doğrudan tasarımına ekleyebilir veya sentez aracının otomatik olarak yerleştirmesine izin verebilir. Ancak, Global Mesh’te en fazla **dört CC_BUFG elemanı** bulunabileceği için bu sınırlamaya dikkat edilmelidir. Aksi takdirde, **Place & Route** aşaması hata mesajıyla duracaktır.

---

###  CC_BUFG Kullanım Süreci

| **Adım**                       | **Açıklama**                                                                                                                                                                                                                                                                      |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1) Manual Instantiation**    | Kullanıcı herhangi bir sinyale manuel olarak **CC_BUFG** elemanı ekleyebilir. Bu sinyaller Global Mesh üzerinden yönlendirilir. En fazla 4 CC_BUFG izin verilir.                                                                                                                  |
| **2) Synthesis Option**        | Sentez sırasında:  <br>- Eğer `-noclkbuf` seçeneği kullanılırsa, sentez aracı **CC_BUFG** yerleştirmez.  <br>- Kullanılmazsa, clock girişlerine sahip tüm netlere otomatik olarak **CC_BUFG** eklenir.                                                                            |
| **3) User Intervention**       | Place & Route öncesinde, kullanıcı tasarımda kaç tane **CC_BUFG** olduğunu kontrol etmelidir. Eğer sayı > 4 ise, sentez yeniden çalıştırılmalı ve `-noclkbuf` opsiyonu kullanılmalıdır. Aksi takdirde, Yerleştirme ve Yönlendirme işlemi bir hata mesajı ile başarısız olacaktır. |
| **4) Place & Route Execution** | GLB[3:0] sinyallerinin **CC_BUFG** elemanlarına atanması, Place & Route yazılımı tarafından otomatik olarak gerçekleştirilir. Kullanıcının manuel atama yapmasına gerek yoktur.                                                                                                   |


