
## **Genel Özellikler**

**CCGM1A1**, **CCGM1A2** ve **CCGM1A4** çipleri **multi-die** (Pin-to-Pin) olarak çalışabilir. Bu, sistemin **esnekliğini** ve **gelişebilirliğini** artırır. **Başlangıç olarak CCGM1A1** kullanıldığında, CPE veya flip-flop'ların kapasitesi dolduğunda, **CCGM1A2** veya **CCGM1A4** gibi daha güçlü modeller ile geçiş yapılabilir. Bu değişim sırasında, sistemde **hiçbir ek yapılandırma** yapılmaksızın işlem kapasitesi kolayca **2 kat** veya **4 kat** artırılabilir. 


<p align="center">

<img src="Pasted image 20250717110521.png" >

<br>

</p>
<p align="center">

<img src="Pasted image 20250717110535.png" >

<br>

</p>
A1’in yetersiz kaldığı durumlarda aynı alana A2 takıldığında, yazılan kodlar A1A’da kayıtlı kalır. A1B için ise hiçbir entegrasyon yapmadan, kaldığı yerden kodlara devam edilebilmektedir.


## **Çalışma Modları**

**CCGM1A1/2/4**'ün üç farklı çalışma modu vardır:

- **LVDS (Low Power Mode)**: Düşük güç tüketimi sağlar.
- **Eco Mode**: Enerji tasarrufu modudur.
- **Speed Mode**: Yüksek hızda veri iletimi sağlar.

Her mod, farklı uygulama gereksinimlerine göre **güç tüketimi** ve **performans** arasında denge kurar.



## **CPE (Configurable Processing Element) Kullanımı**

**CPE**, yalnızca veri işlemeyle sınırlı kalmaz, aynı zamanda **yüksek paralel işlem kapasitesine** sahip **çok yönlü ve esnek devreler** tasarlamanıza olanak sağlar. Bu özellikler sayesinde, **çoklu veri işleme** ve **yüksek paralel işlem** kapasitesine sahip sistemler oluşturulabilir. Mantık (AND, OR, XOR, vb.) işlemleri, Aritmetik işlemler (toplama, çıkarma, çarpma), Gömülü RAM ve DSP işlemleri  
yapmak için yapılandırılabilir.

**CPE**, aşağıdaki yapı taşlarını içerir:

- **Çift 4 girişli LUT-2 ağacı**
- **8 girişli LUT-2 ağacı**
- **6 girişli MUX-4**
- Her bir CPE şunları barındırır:
    - **1-bit veya 2-bit tam toplayıcı (full adder)** – yatay/dikey genişletilebilir.
    - **2 × 2-bit çarpan (multiplier)** – istenilen boyuta genişletilebilir.
    - **2 Flip-Flop veya 2 Latches**.


CPE vs DSP Blokları Karşılaştırma Tablosu:

| **GateMate CPE**                                          | **Klasik DSP Blokları** (Vivado/Quartus)                |
| --------------------------------------------------------- | ------------------------------------------------------- |
| Genel amaçlı işlem (mantık, aritmetik, bit manipülasyonu) | Yüksek hızlı aritmetik (çarpma, toplama, MAC) için özel |
| Çok yüksek (LUT + FF + Carry Chain + Config bits)         | Sınırlı (sabit işlev: çarpıcı, akümülatör, filtreleme)  |
| Küçük mantık blokları (LUT4/5 benzeri)                    | Geniş veri yolu, sabit çarpan ve akümülatör             |
| Daha kompakt (genel amaçlı olduğu için esnek kullanım)    | Daha büyük alan kaplar (özel devreler içerir)           |
| BRAM ve Interconnect ile sıkı bağlı                       | Yüksek bant genişlikli sabit veri yollarına sahip       |
| Genel mantık, küçük aritmetik, esnek tasarımlar           | FIR/IIR filtreler, FFT, yoğun matematiksel işlemler     |

 <p align="center">

<img src="Pasted image 20250714023114.png" style="display: block; margin: auto;" width="400">

<br>
<em style="display:flex;justify-content:center">CPE Blok mimarisi</em>
</p>

Fonksiyonel Ölçeklenebilir Çarpanlar
- CPE dizisinde sabit yerleşim yok
- İsteğe bağlı giriş ve çıkış pipeline aşamaları

**Performans**
- B(+A) yolu kritiktir.
<p align="center">

<img src="Pasted image 20250714023207.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center">18x8 output pipeline </em>

</p>



<p align="center">

<img src="Pasted image 20250717112853.png">

<br>

<em style="display:flex;justify-content:center">Verimliliği</em>

</p>

## **GPIO Özellikleri**

Her Block RAM hücresi, **tek bir 40 Kbit bellek** veya **iki bağımsız 20 Kbit çift portlu SRAM (DPSRAM)** bloğu olarak yapılandırılabilir. Her iki yapılandırma da **True Dual Port (TDP)** ve **Simple Dual Port (SDP)** modlarını destekler. 

- **162 adet GPIO** pinine sahiptir.
- Tüm GPIO pinleri **DDR destekli** olup, **single-ended** veya **LVDS diff pair** olarak konfigüre edilebilir.
- **MIPI D-PHY uyumlu** olan GPIO'lar, manuel örnekleme ve parametrelendirmeye olanak tanır.
- I/O **delay**, **pin yerleşimi**, **sürücü güçleri**, **slew rate control**, **pull-up/pull-down konfigürasyonu** ve **register mapping** gibi özelliklere sahiptir.

### **GPIO Cell**
Her bankada **9 adet GPIO** bulunur.
- Bütün gpıo lar single-ended veya lvds pair olarak konfigre edilebilir
- MIPI D-PHY uyumlu
- Manuel örnekleme ve parametrelendirmeye olanak tanır
- I/O delay
- Pin yerleşimi
- Sürücü güçleri
- Slew rate Control
- Pull up/Pull down konfigrasyonu
- Register mapping IO Cellerin içinde 
- **Bütün GPIO'lar DDR (double data rate) destekler

<p align="center">

<img src="Pasted image 20250717130551.png" style="display: block; margin: auto;" width="400">

<br>

<em></em>

</p>
<p align="center">

<img src="capture.gif">

<br>

<em style="display:flex;justify-content:center">Ayrıca GPIO lar hızlandırılmıs 3.6Vda test edilmiştir Yaşlanma artmıştır ancak sıcaklığa bağlıdır.</em>

</p>

## **RAM Yapısı**

- **32x40Kbit RAM hücreleri** bulunur (toplamda 1.280 Kbit).
- Bu RAM hücreleri, **2’li yüksek veri hızlarında (True Dual Port - TDP modu)** ya da **tek hat halinde yüksek kapasiteli (Simple Dual Port - SDP modu)** olarak yapılandırılabilir.
- RAM hücreleri **dikey olarak bağlanmış**  olduğundan, sinyal gecikmesi **azalmış** ve veri işleme çok daha hızlı hale getirilmiştir.

### **Ram Bloğu**

- **Tek 40K hücre** veya **İki bağımsız 20K hücre** bulunur.
- **FIFO (senkronize veya asenkron)** desteği sunar.
- Debug  ve düzeltme özelliklerine sahiptir. 
- Ayrıca, tüm hücreler **dikey olarak bağlandığı** için **sinyal gecikmesi** minimize edilmiştir.

<p align="center">

<img src="Pasted image 20250714023514.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center">GateMate A1/A2 FPGA üzerindeki Block RAM (BRAM) hücre mimarisini.</em>

</p>

## **Veri İşleme Hızı ve Düşük Gecikme**

**CCGM1A1**, **yakın mesafede bulunan bellek hücreleri** sayesinde verileri çok **hızlı bir şekilde işleyebilir**. Bu yapı, veri işlemenin **çok düşük gecikme** ile yapılmasını sağlar. Bu da, **yüksek hızda sinyal işleme** ve hızlı çıkış **verimi** anlamına gelir. Özellikle veri akışı ve paralel işlemler için tasarlanmış bir yapı, sistemin verimliliğini artırır.

<p align="center">

<img src="Pasted image 20250717113045.png">

<br>

<em style="display:flex;justify-content:center">A1 CPE ve RAM Yerleşimi</em>

</p>

## **Çoklu Saat Kaynakları ve Paralel İşlem Kapasitesi**

**CCGM1A1**, **4 farklı saat kaynağına** sahiptir. Bu sayede aynı anda **farklı işlemleri paralel bir şekilde** gerçekleştirebilir ve **daha senkronize** çalışmasını sağlar. **Paralel işlem** yetenekleri, sistemin **yüksek hızda ve yüksek verimlilikle** çalışmasına olanak tanır. Bu, özellikle **büyük veri setleriyle çalışan** uygulamalar için **çok avantajlıdır**. 

<p align="center">

<img src="Pasted image 20250717120244.png">

<br>

<em style="display:flex;justify-content:center">4 farklı clock ve her bir clock 4 farklı faz bulunur</em>

</p>


## **Çalışma Sıcaklık Aralığı**

**CCGM1A1/2/4**, **-40°C ile +125°C** arasında çalışabilen **ekstrem koşullara dayanıklı** bir yapıya sahiptir.

## **Voltaj Aralıkları:**

- **Core voltajı**: **0.9V - 1.1V** arası sağlıklı çalışma aralığıdır.
- **I/O voltajı**: **1.2V - 2.5V** arası sağlıklı çalışma aralığıdır, ancak **3.3V**'a kadar dayanabilir.
<p align="center">

<img src="Pasted image 20250714024254.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center">Farklı voltajlardaki çalışma hızı</em>

</p>

## **Ser-Des**

**SerDes**, bu protokol sayesinde **5 Gbit/s** hızında veri işleyebilir ve **Wi-Fi** gibi **kablosuz haberleşme protokollerine** uyumlu çalışabilir. Bu, **yüksek hızlı veri iletimi** gerektiren uygulamalar için büyük bir avantajdır.

<p align="center">
  <img src="Pasted image 20250714024549.png">
  <br>
  <em style="display:flex;justify-content:center">Blok diyagramı</em>
</p>

- **LVDS SerDes** kullanabilmek için **X3 Kristaline serdes clock** takmanız gerekmektedir (100MHz LVDS Clock: 511FCA100M000BAG). 
- Ayrıca dirençleri de doldurmanız gereklidir.
- **Yapılandırılabilir Veri Yolu Genişliği:**  16/20-bit, 32/40-bit veya 64/80-bit veriyolu konfigürasyonu (TX ve RX için)
- **8B/10B Kodlama ve Dekodlama:** Seri veri akışında veri bütünlüğünü korumak için kullanılır.
- **Virgül Tespiti ve Bayt Hizalama:** Veri akışında senkronizasyonu sağlar.
- **Saat ve Veri Kurtarma (CDR):** Alıcı tarafta veri ile saat senkronizasyonunu otomatik olarak düzeltir.
- **Pseudo-Random Bit Stream (PRBS) Jeneratör ve Kontrolörler:** Hata testleri için PRBS oluşturma ve doğrulama desteği
- **Faz Ayarlı FIFO (Elastic Buffer):** Saat düzeltme için faz kaymalarını dengeler.
- **Polarite Kontrolü:** TX ve RX sinyallerinde polariteyi otomatik olarak yönetir.

<p align="center">
  <img src="Pasted image 20250717125806.png">
  <br>
  <em style="display:flex;justify-content:center"x>Serdes: Geliştirme kitindeki yerleşimi</em>
</p>
## **Akış Diyagramı**

Kodu, **HDL** dillerinden biriyle yazabilir ve ardından **Yosys** üzerinden sentez yapabilirsiniz. Bu sayede entegrasyon **manuel** olarak yapılır ve **gereksiz veri gecikmesi** ve **güç kaybı** engellenmiş olur. Farklı ara uygulamalar kullanılmadığı için **sistem stabilitesini** artırır. 

<p align="center">

<img src="Pasted image 20250717105321.png" style="display: block; margin: auto;" width="400">

<br>

<em></em>

</p>

## **Giriş Kaynakları** 

- **Verilog Source / VHDL Source /**GHDL Source**

##  **RTL Sentezi (RTL Synthesis)**

-  **Yosys** burada devreye girer.
-  Verilog kodu **Verilog Netlist**’ine dönüştürülür.  

##  **GateMate Place & Route Software**

 - **Netlist Conversion**
- Verilog netlist GateMate için uygun bir formata dönüştürülür.
-  **Mapping**
-  **Placement**
-  **Routing**- Bu bileşenler arasındaki bağlantılar oluşturulur.
- **Static Timing Analysis (STA) & SDF Generation**
- Zamanlama analizleri yapılır.
- SDF dosyası oluşturulur (zamanlama verileri simülasyon için).
- **Configuration File Generation**
- FPGA’ya yüklenebilir **CFG File** oluşturulur.

### **Çıktılar:**

- **SDF File:** Zamanlama bilgilerini içerir.
- **Verilog Netlist:** Son yerleşim/routing sonrası hali.
- **CFG File:** FPGA’ya yüklemek için gereken yapılandırma dosyası.
##  **Simülasyon Akışı (Sol Alt Kutular)**

- **Customer Testbench**
    - Kendi testbench’inizi yazarak sentetik test vektörleri oluşturursunuz.
- **Simulator (Icarus, ModelSim , GateWave vb.)**
    - Kodunuzu simüle eder ve hataları erkenden yakalarsınız.
- **Simulation Results**
    - Zamanlama bilgilerinin de dahil edilmesiyle (SDF) gerçekçi bir simülasyon yapılır.



## **Programlama**

- **openFPGALoader veya GateMate™ Programmer Scripts**
    - CFG file ile FPGA yüklenir.
    - Ayrıca **External Flash Programming** için de destek vardır.

### **Özetle**

Yosys → Place&Route (GateMate) → STA → Simülasyon → CFG yükleme zinciri **tamamen açık kaynaklı** çalışabilir.  
GateMate için **Yosys ile sentez**, vendor’ın sağladığı **P&R yazılımı** ve openFPGALoader ile yükleme mümkün.  

<p align="center">
<img src="Pasted image 20250717130929.png">
</p>

|                    | Debug                                                                  | Source                      | Sistem Yükü                                  | Lisans                       | Esneklik                          | Desteklenen<br>FPGA'ler                              |
| ------------------ | ---------------------------------------------------------------------- | --------------------------- | -------------------------------------------- | ---------------------------- | --------------------------------- | ---------------------------------------------------- |
| Yosys +<br>nextpnr | Akışın her aşamasında inceleme sağlar.                                 | Tamamıyla açık kaynaklıdır. | Küçük yükleme ister ve bilgisayarı zorlamaz. | Lisanssız, özgür kullanım.   | Her adımı özelleştirmek mümkün.   | Lattice, <br>Cologne <br>Chip, <br>kısmen <br>Xilinx |
| Vivado             | Kendi hata ayıklama protokolü bulunur ancak gizli hatalar bulunabilir. | Kapalı kaynak.              | 10-20GB indirme yapılması gereklidir.        | Lisans sistemi bulunmaktadır | Sabit akış, özelleştirme kısıtlı. | Yalnızca <br>Xilinx <br>cihazları                    |
| Quartus            | Akışın her aşamasında inceleme sağlar.                                 | Tamamıyla açık kaynaklıdır. | 10-20GB indirme yapılması gereklidir.        | Lisanssız, özgür kullanım.   | Her adımı özelleştirmek mümkün.   | Yalnızca <br>Lattice <br>cihazları                   |




Piyasadaki benzer yeteneklerdeki FPGA lerle karşılaştırıldığında:

<p align="center">
  <img src="Pasted image 20250714032907.png">
</p>





LINKLER 
- https://colognechip.com/programmable-logic/gatemate/#tab-313423
- https://colognechip.com/docs/ds1001-gatemate1-datasheet-latest.pdf
- https://github.com/enjoy-digital/litex
- https://github.com/YosysHQ/yosys
- https://github.com/YosysHQ/nextpnr
- https://github.com/ghdl/ghdl
- https://github.com/trabucayre/openFPGALoader
- https://github.com/YosysHQ/prjpeppercorn
