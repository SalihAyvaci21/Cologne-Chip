## FPGA PLL Saat Üreteçleri – Teknik Özellikler

Her FPGA yongasında (**die**) dört bağımsız PLL saat üreteci (clock generator) bulunur:

- **CCGM1A1** yapılandırmasında **4 PLL** bulunur.
- **CCGM1A2** yapılandırmasında **8 PLL** bulunur.

###  Genel Özellikler:

- **ADPLL saat üreteci**: FPGA’da çok yönlü saat üretimi için.
- **Dijital Kontrollü Osilatör (DCO) tabanlı saat üretimi**: Tipik frekans ayar aralığı: **1 GHz ila 2 GHz**
- **Programlanabilir frekans bölücüler**:
	- Referans saat girişi için
	- PLL döngü bölücüsü için
	- Saat çıkışı bölücüsü için
	- Böylece geniş çıkış ve referans frekans aralıkları sağlanır.
	- Saat çıkışları, **90° faz farkı ile 4 adet** olarak sağlanır.
	- **Hızlı kilitlenme (fast lock-in)**: İkili frekans arama (binary frequency search) yöntemi ile.
	- Güç verildikten sonra FPGA konfigürasyon saati için **otonom serbest çalışma osilatör modu (autonomous free-running oscillator)**.


![[Pasted image 20250708104054.png]]
Genel PLL yapısını resimde göründüğü şekildedir. Her bir PLL için referans saat (**f_in**) bağımsız olarak seçilebilir:

| Clock Numarası | Pin | 1.Fonksiyon     |
| -------------- | --- | --------------- |
| CLK0           | N14 | GPIO (IO_SB_A8) |
| CLK1           | P12 | GPIO (IO_SB_A7) |
| CLK2           | P14 | GPIO (IO_SB_A6) |
| CLK3           | R13 | GPIO (IO_SB_A5) |


SER_CLK, hem **tek uçlu modda (single-ended mode)** hem de **SER_CLK_N (pin T12)** ile birlikte **LVDS modunda kullanılabilir**
Referans saatler aynı anda birden fazla PLL tarafından kullanılabilir.

İzin verilen osilatör frekansı (fdco), FPGA'nin besleme voltajına bağlı olarak aşağıdaki şekilde değişir:

Low power mode: (VDDPLL = 0.9 V ± 50 mV) : 500 MHz ⩽ fdco ⩽ 1,000 MHz 
Economy mode: (VDDPLL = 1.0 V ± 50 mV) : 1,000 MHz ⩽ fdco ⩽ 2,000 MHz 
Speed mode: (VDDPLL = 1.1 V ± 50 mV) : 1,250 MHz ⩽ fdco ⩽ 2,500 MHz

### **CCGM1A2 çipinin saat sinyalleri**

 **CCGM1A2**’deki **BGA pinleri T12 (SER_CLK)** ve **T13 (SER_CLK_N)**, her iki FPGA kalıbının (**die**) **SerDes saat girişlerini** bağlar.
- Benzer şekilde, dört özel saat giriş pini:

| Clock Numarası | Pin |
| -------------- | --- |
| CLK0           | N14 |
| CLK1           | P12 |
| CLK2           | P14 |
| CLK3           | R13 |


Bu yapı sayesinde hem SerDes saat kaynağı hem de genel amaçlı saat girişleri **her iki FPGA die’ına aynı anda erişebilir**.


## **PLL Çekirdek (Core)**


### Portlar ve Yapılandırma

**PLL core** modülü:
- Bir adet referans saat girişi (**PLL_CLK_IN**)
- Dört adet saat çıkışı (**PLL_CLK_OUT0, PLL_CLK_OUT90, PLL_CLK_OUT180, PLL_CLK_OUT270**) 
- Çıkış saatleri, her biri **90° faz farkı** ile sağlanır (aşağıdaki görselden referans alabilirsiniz). 
- Ek olarak, harici geri besleme yolu için bir saat girişi (**PLL_FB**) bulunur.

PLL çekirdek portlarının genel bir özetini sunar. 
![[Pasted image 20250708110332.png]]

### Programlanabilir Bölücüler ve Sinyal Yolu Ayarları

Basitleştirilmiş blok diyagramı:

- **PLL_SETUP** vektörünün bazı bitlerinin, **beş programlanabilir bölücüyü** (dividers) yapılandırmak için kullanıldığını gösterir.
- Diğer bitler:
  - Sinyal yoluna ek bir **bölücü (divider by 2)** eklemek (****$p_{osc}$**)
  - Sinyal yolunu değiştirmek (**$p_{loop}$**, ****$p_{out}$**) için kullanılır.
![[Pasted image 20250708110629.png]]

| Name           | Width | Direction | Description                        |
| -------------- | ----- | --------- | ---------------------------------- |
| PLL_CLK_IN     | 1     | input     | Referance clock                    |
| PLL_CLK_OUT0   | 1     | output    | PLL output, 0° phase               |
| PLL_CLK_OUT90  | 1     | output    | PLL output, 90° phase              |
| PLL_CLK_OUT180 | 1     | output    | PLL output, 180° phase             |
| PLL_CLK_OUT270 | 1     | output    | PLL output, 270° phase             |
| PLL_FB         | 1     | input     | PLL feedack for external loop path |

| Name            | Width | Direction | Description              |
| --------------- | ----- | --------- | ------------------------ |
| PLL_SETUP       | 1     | input     | Setup selection vector   |
| PLL_EN          | 1     | input     | PLL enable signal        |
| PLL_LO          | 1     | output    | PLL locked signal        |
| PLL_LO_STDY     | 1     | output    | Steady PLL locked signal |
| PLL_LO_STDY_RST | 1     | input     | Reset for PLL_LO_STEADY  |

Bu yapılandırmalar, döngü (loop) ve çıkış yolunda farklı bölücü oranlarıyla sonuçlanır.

### Maksimum Giriş Frekansları

**Not:** Bir istenen bölücü değeri (divider value), seri bağlı iki bölücü arasında bölüştürüldüğünde bu maksimum giriş frekanslarının dikkate alınması gereklidir.
![[Pasted image 20250708110936.png]]
Parametre: **ploop = PLL_SETUP[54] = 0** 
Bu ayarda geri besleme yolu, PLL modülü içinde tamamen kapalı döngü (**feedback loop inside PLL**) olarak seçilir. 
Bu durumda, osilatör frekansı doğrudan PLL modülünde belirlenir.

Desteklediği maximum hızlar aşağıdaki tabloda verilmiştir.
![[Pasted image 20250708111206.png]]

| Divider | Low power | Economy    | High speed | Description                              |
| ------- | --------- | ---------- | ---------- | ---------------------------------------- |
| N1      | 1 GHz     | 1.25 GHz   | 1.6666 GHz | High-speed part of the loop path divider |
| N2      | 0.5 GHz   | 0.6125 GHz | 0.833 GHz  | Low-speed part of the loop path divider  |
| M1      | 1 GHz     | 1.25 GHz   | 1.6666 GHz | High-speed part of the loop path divider |
| M2      | 0.5 GHz   | 0.6125 GHz | 0.8333 GHz | Low-speed part of the loop path divider  |


$p_{osc}$ = PLL_SETUP[86]** parametresi, iki değer alabilir: {0,1}

#### Durum 1: **$p_{loop}$ = 0**

- Geri besleme döngüsü (**feedback loop**), tamamen PLL modülü içinde kapalıdır.
- Osilatör frekansı, PLL içindeki yapılandırmaya göre belirlenir.

####  Durum 2: **$p_{loop}$ = 1**

 Geri besleme yolu, PLL çıkışından kullanıcı devresi (**user circuit**) üzerinden geçirilerek PLL’e geri döner.
 Bu durumda, osilatör frekansı dış döngüye bağlıdır ve kullanıcı devresinin gecikme süresi dikkate alınır.
![[Pasted image 20250708111446.png]]
PLL çıkış saati $p_{out}$ ve $p_{osc}$ parametrelerine bağlıdır.
![[Pasted image 20250708111718.png]]

ve $f_{dco}$'yu ekledikten sonra

![[Pasted image 20250708110553.png]]
$p_{loop}$ = 0 olan dahili geri bildirim yolu için ve
![[Pasted image 20250708112054.png]]
$p_{loop}$ = 1 olan harici geri bildirim yolu için.

![[Pasted image 20250708112119.png]]


#### 90° Faz Kaydırmalı Saat Üretimi – Koşullar

Tüm çıkış sinyalleri için **90° faz kaydırma (phase shifting)** yalnızca aşağıdaki iki koşuldan biri sağlandığında:
1. **$M_{1}$ = $M_{2}$ = 1**
2. **$M_{2}$ çift sayı ve $M_{2}$ > 0**

**Eğer bu koşullar karşılanmazsa
- **Faz kaydırmalar tam 90° olmayabilir.**
- Bunun nedeni, faz üreticiye giren giriş sinyali **f0**’ın %50 görev döngüsüne sahip olmamasıdır.
###  Tanımlar

| Parametre           | Açıklama                               |
| ------------------- | -------------------------------------- |
| **a**               | f0 için darbe genişliği (pulse width)  |
| **b**               | f0 için boşluk genişliği (space width) |
| **$T_{0}$ = a + b** | f0 periyodu                            |
| $D_{0}$ = a / T0**  | f0 için görev döngüsü (duty cycle)     |
###  Görev Döngüsü Koşulları ($D_{0}$)

- **DCO çıkış saati (fdco):** Her zaman %50 görev döngüsüne sahiptir.
- Çıkış bölücülerden sonra **$D_{0}$ = D(f0)** aşağıdaki durumlara göre belirlenir:
####  Durum 1) M1 = M2 = 1
- Bölücü yok → **$f_{0}$ = $f_{dco}$**
- Görev döngüsü: **$D_{0}$ = 50%**

####  Durum 2) $M_{1}$ > 1 ve $M_{2}$ = 1

- **$f_{0}$ darbe genişliği, fdco ile aynıdır.
- Görev döngüsü:
   **$D_{0}$=1/(2$M_{1}$)
- **Sonuç:** D0 çok küçük değerler alır (**0 < **$D_{0}$ ⩽ 25%**) → zayıf görev döngüsü.

---

####  Durum 3) $M_{2}$ çift ve $M_{2}$ > 0

- Görev döngüsü:
   $D_{0}$=50%
- **Sonuç:** Tam görev döngüsü, tüm faz kaydırmalar doğru.    

---

####  Durum 4) $M_{2}$ tek ve $M_{2}$ ≥ 3

- Görev döngüsü:
  - $D_{0}$ =(1/2)−(1/2$M_{2}$ ) 
- **Sonuç:** Büyük $M_{2}$  için $D_{0}$  yaklaşık %50’ye yaklaşır (**1/3 ≤ **$D_{0}$ < 50%**).


## **Önemli Not** Tam 90° faz kaydırma için **$D_{0}$ = 50%** olmalıdır.


	
![[Pasted image 20250708114448.png]]



### Temel Tanımlar

| Parametre             | Anlamı                                            |
| --------------------- | ------------------------------------------------- |
| **T_PLL**             | PLL periyodu, **T_PLL = 2·T₀**                    |
| **D₀**                | f₀’ın görev döngüsü (Duty Cycle), **≤ 50%**       |
| **ϕ₀**                | f₀’ın referans fazı (0°)                          |
| **ϕ($f_{out}$,90°)**  | PLL_CLK_OUT90’ın fazı, **D₀’ye bağlı**            |
| **Δ₉₀**               | 90° çıkış fazının sapması (**Δ₉₀ = ϕ₉₀–90°**)     |
| **ϕ($f_{out}$,180°)** | PLL_CLK_OUT180’ın fazı (her zaman 180°)           |
| **ϕ($f_{out}$,270°)** | PLL_CLK_OUT270’ın fazı, **D₀’ye bağlı**           |
| **Δ₂₇₀**              | 270° çıkış fazının sapması (**Δ₂₇₀ = ϕ₂₇₀–270°**) |

**Faz üreticinin (phase generator):**
- **Giriş saati (f₀)** ve
- **Dört çıkış saati ($f_{out}$)** arasındaki ilişkiyi gösterir.

###  Görev Döngüsü (Duty Cycle) İle İlgili Kritik Detaylar:

- **f₀** için görev döngüsü (D₀):

D₀ = (a/**$T_{0}$) ≤ 50%

Burada **a = f₀ darbe süresi**, ****$T_{0}$ = **$f_{0}$ periyodu**.

- Bu durum **faz kaydırmalarında sapma (Δ)** yaratır:
   0Δ≤0
- **Yani çıkış fazları ($f_{out}$,90°, $f_{out}$,270°) tam 90° veya 270° olmayabilir → biraz geri kalırlar. Ancak arasında 90° olur.**

###  Faz Üreticinin Çıkışı

- Çıkış saatleri **fₒᵤₜ** her zaman %50 görev döngüsüne sahiptir.
- Bu düzeltme, f₀’daki dengesizlikten bağımsızdır.


- Bu tablo, fₒᵤₜ çıkışlarının:
- Fazları (ϕ)
- Faz sapmaları (Δ) 

###  Referans Faz

- **f₀** sinyali, çıkış fazları için referans noktasıdır:
  ϕ₀ = 0°
  ∆0 = 0°
- Bu, tüm faz kaydırmaların başlangıç fazı olarak alınır.

|Çıkış|Beklenen Faz|Gerçek Faz (D₀ ⩽ 50%)|
|---|---|---|
|fₒᵤₜ,90°|90°|85° (örnek)|
|fₒᵤₜ,270°|270°|265° (örnek)|

![[Pasted image 20250708115915.png]]

PLL’in kilitlenme mekanizması (locking mechanism).

### Sinyaller

| Sinyal              | Anlamı                                                          |
| ------------------- | --------------------------------------------------------------- |
| **PLL_LO**          | PLL’in o an kilitlenmiş durumda olduğunu gösterir (lock flag).  |
| **PLL_LO_STDY**     | PLL kilitlenme durumunun **sürekli kararlı** olduğunu gösterir. |
| **PLL_LO_STDY_RST** | Stabilite göstergesini sıfırlayan reset sinyali.                |

#### (A) İlk Kilitlenme

- PLL kilitlenme durumuna ulaştığında **PLL_LO** sinyali **yükselen kenar (rising edge)** verir.
- Eğer bu **ilk yükselen kenarsa**, **PLL_LO_STDY** de **high** olur.  

#### (B) Kilidin Kaybolması

- PLL kilit durumunu kaybederse:
- **PLL_LO** düşük seviyeye (low) iner.
- **PLL_LO_STDY** de düşük seviyeye iner.

#### (C) Yeniden Kilitlenme

- PLL tekrar kilitlenirse (**PLL_LO↑**):- **PLL_LO** tekrar **high** olur.   
- Ama **PLL_LO_STDY** **low kalır.**   
-  Bu, PLL’in **kararsız bir kilitlenme yaşadığını** gösterir.

#### (D) Resetleme

- **PLL_LO_STDY_RST** sinyali **en az 2 PLL_CLK_IN döngüsü** boyunca bir pulse alırsa…

#### (E) Stabilite Yeniden Başlar
- ... Sonraki **PLL_LO↑** kenarında
- **PLL_LO_STDY** tekrar **high** olur.  
  Artık kilit durumu yeniden **stabil** sayılır.

### Özet:

| Durum                    | PLL_LO | PLL_LO_STDY    |
| ------------------------ | ------ | -------------- |
| İlk kilitlenme           | High   | High           |
| Kilidin kaybolması       | Low    | Low            |
| Yeniden kilitlenme       | High   | Low (unstable) |
| Reset sonrası kilitlenme | High   | High           |

- **PLL_LO = 1** → PLL o anda kilitli
- **PLL_LO_STDY = 1** → PLL kilitli ve bu durum hep stabil 
- **PLL_LO_STDY = 0** → PLL en az bir kez kilidini kaybetmiş


![[Pasted image 20250708130954.png]]

## **ADPLL (Otonom Mod)**

**ADPLL**, **CCGM1A1** ve **CCGM1A2** için bir **otonom konfigürasyon modu** sağlar.  
Bu modda **ADPLL**, **referans saat (reference clock)** olmadan da çıkış saat sinyali üretebilir.

### Özellikler

- **Çalışma Modu:** Açık döngü (**open loop**)
- **Çıkış Frekansı:** Her zaman **50 MHz’den düşük**
- **Bunun nedeni:** Çoğu flash belleğin güvenli bir şekilde çalışabilmesi için saat frekansının sınırlanması.
- **Frekans Aralığı:** Besleme voltajı ve sıcaklığa bağlıdır.

###  Yapılandırma Gereksinimleri

- Otonom modda:
- **Divider ayarları** gerekmez
- **Lock-in konfigürasyonu** gerekmez
- **PLL_SETUP** vektörü **yok sayılır (ignored)**

 **Not:** Bu mod, FPGA konfigürasyonu sırasında bir başlangıç saati sağlamak için idealdir.




**ADPLL output frequencies in autonomous mode table**

| VDD_PLL | Power Mode | min (-40°) | max (+125°) |
| ------- | ---------- | ---------- | ----------- |
| 0.85 V  | Low Power  | 8.3 MHz    | 23.1 MHz    |
| 0.95 V  | Low Power  | 15 MHz     | 31.4 MHz    |
| 0.95 V  | Economy    | 15 MHz     | 31.4 MHz    |
| 1.05 V  | Economy    | 22.9 MHz   | 39.9 MHz    |
| 1.05 V  | High Speed | 22.9 MHz   | 39.9 MHz    |
| 1.15 V  | High Speed | 31.8 MHz   | 49 MHz      |



## Flash Bellekten Otomatik Konfigürasyon için Gereksinimler

GateMate FPGA’nın **resetten sonra konfigürasyonu otomatik olarak bir flash bellekten yüklemesi** isteniyorsa:

###  Ön Koşullar

 **SPI Master Modu** etkinleştirilmelidir.  
 Kullanılacak flash bellek aşağıdaki gereksinimleri karşılamalıdır:

###  Flash Bellek Gereksinimleri

-  **Saat Frekansı Uyumu**
- Flash bellek, verilen saat frekanslarında çalışabilmelidir.
-  **READ ID (0x9F) Komut Desteği**
- Flash bellek, **READ ID** komutuna (0x9F) yanıt vermeli.    
- Gelen yanıt **0x00** veya **0xFF** olmamalıdır.
-  **FAST READ (0x0B) Komut Desteği**
- Flash bellek, **FAST READ** komutunu (0x0B) tanımalı ve işlemelidir.

 ### **Not: Bu gereksinimler karşılanmazsa FPGA, flash’tan konfigürasyon yükleyemez.**

## PLL temel öğeleri




**PLL çekirdeği (PLL Core)** ve bazı harici devreleri içeren basitleştirilmiş bir PLL blok diyagramını göstermektedir.

![[Pasted image 20250708134551.png]]

###  PLL Giriş Saat Seçimi

- **PLL giriş saati**, **Kontrol Kaydı A (Control Register A)** üzerinden seçilebilir.
- Veya kullanıcı devresinden gelen bir saat sinyali (**USR_CLK_REF**), yani FPGA fabic'te sağlanan bir saat.
###  PLL Çıkış Saatlerinin Yönetimi

- **PLL çekirdeğinin saat çıkışları**, **Kontrol Kaydı A bitleri** aracılığıyla etkinleştirilebilir.
- PLL’in kilitlenme durumu (locking state), aşağıda gösterilen yöntemle izlenebilir.
![[Pasted image 20250708134847.png]]
 **Not:** Bu yapı, kullanıcı devrelerinden gelen saatleri PLL’e yönlendirme ve PLL’den çıkan saatlerin seçimini kolaylaştırır.
 ![[Pasted image 20250708134835.png]]
###  Dört Fazlı Saat Çıkışları

**Şekil 2.48**, PLL’in ürettiği dört fazlı saat çıkışlarını gösterir; **CLK0** (0°), **CLK90** (90°), **CLK180** (180°),  **CLK270** (270°)


###  Çift Saat Hızı Modu

- **Kontrol Kaydı B (Control Register B)** bitleri:
- **CLK180_DOU**, **CLK270_DOU**
-  Bu bitler etkinleştirildiğinde; **CLK180** ve **CLK270** çıkışları **çift saat hızına (double clock rate)** geçer.



![[Pasted image 20250708135746.png]]

###  İleri Seviye PLL Primitifi

**PLL’in advanced primitifini (CC_PLL_ADV)** göstermektedir.

- **CC_PLL** ve **CC_PLL_ADV**
- Aynı PLL’dir.
- Fark: **Sentez (synthesis)** işlemi sırasında, her PLL için ayrı ayrı **CC_PLL** veya **CC_PLL_ADV** kullanılabilir.

### **CC_PLL ile CC_PLL_ADV Arasındaki Farklar**

- Yapılandırma değiştirildiğinde:
- **PLL otomatik olarak kapatılır (disable)**

- Geçiş tamamlandıktan sonra **PLL yeniden etkinleştirilir (re-enable)**    
- Bu işlem **kontrolör tarafından yönetilir** ve kullanıcı müdahalesi gerekmez.


### PLL Kontrol Kaydı A (Control Register A)

| **Bit** | **Adı (Name)**  | **Varsayılan (Default)** | **Fonksiyon (Function)**                                                                                      |
| ------- | --------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------- |
| 1       | **PLL_EN**      | 0                        | PLL etkinleştirme:  <br>0: PLL kapalı  <br>1: PLL çalışır                                                     |
| 3       | **SET_SEL**     | 0                        | PLL yapılandırma seçimi:  <br>0: İlk yapılandırma  <br>1: İkinci yapılandırma                                 |
| 4       | **USR_SET**     | 0                        | Kullanıcı PLL yapılandırma seçimi:  <br>0: SET_SEL biti ile seçilir  <br>1: Kullanıcı sinyali ile seçilir     |
| 5       | **USR_CLK_REF** | 0                        | Kullanıcı saat seçimi:  <br>0: Harici referans saat  <br>1: Kullanıcı sinyalinden referans saat               |
| 6       | **CLK_OUT_EN**  | 0                        | Saat çıkışlarını etkinleştirme:  <br>0: Saat çıkışları devre dışı  <br>1: Saat çıkışları aktif                |
| 7       | **LOCK_REQ**    | 0                        | Kilit durumu gerekliliği:  <br>0: Kilit durumu olmadan çıkış aktif  <br>1: Çıkışlar için kilit durumu gerekli |

### PLL Kontrol Kaydı B (Control Register B)

| **Bit** | **Adı (Name)**  | **Varsayılan (Default)** | **Fonksiyon (Function)**                                                                                                                                       |
| ------- | --------------- | ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 3       | **CLK180_DOUB** | 0                        | PLL çıkışı CLOCK_180 için frekans iki katına çıkarma:  <br>0: Normal sinyal CLOCK_180  <br>1: Çift frekanslı CLOCK_180                                         |
| 4       | **CLK270_DOUB** | 0                        | PLL çıkışı CLOCK_270 için frekans iki katına çıkarma:  <br>0: Normal sinyal CLOCK_270  <br>1: Çift frekanslı ve ters CLOCK_270                                 |
| 7       | **USR_CLK_OUT** | 0                        | Bypass çıkışı için kullanıcı saat seçimi:  <br>0: Bypass çıkışı SER_CLK pininden gelen harici saat ile beslenir  <br>1: Bypass çıkışı kullanıcı saatini besler |













