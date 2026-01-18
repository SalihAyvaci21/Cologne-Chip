Her bir GateMate™ blok RAM hücresinde, entegre senkron ve asenkron FIFO denetleyicisi bulunur. Bu sayede, bir blok RAM hücresi yalnızca **40K konfigürasyonlarında** FIFO belleği olarak kullanılabilir.
- **Port B**, FIFO’nun yazma / itme (write / push) portudur.
- **Port A**, FIFO’nun okuma / çekme (read / pop) portudur.

Senkronize edilmiş FIFO durumunda, hem yazma / itme hem de okuma / çekme işlemleri için **A_CLK** saat sinyali kullanılır.

FIFO modu, TDP / SDP **40K** modunun bir uzantısı olduğundan, gösterilen aynı bit genişliği konfigürasyonlarını destekler. Giriş ve çıkış veri yollarının bit genişlikleri eşit olmalıdır:


| Width | Depth  | Addres-in bus | Data-in bus                    | Data-out bus                  |
| ----- | ------ | ------------- | ------------------------------ | ----------------------------- |
| 1     | 32,768 | a0_addr[15:1] | a0_di[0]                       | a0_do[0]                      |
| 2     | 16,384 | a0_addr[15:2] | a0_di[1:0]                     | a0_do[1:0]                    |
| 5     | 8,192  | a0_addr[15:3] | a0_di[4:0]                     | a0_do[4:0]                    |
| 10    | 4,096  | a0_addr[15:4] | a0_di[9:0]                     | a0_do[9:0]                    |
| 20    | 2,048  | a0_addr[15:5] | a0_di[19:0]                    | a0_do[19:0]                   |
| 40    | 1,024  | a0_addr[15:6] | a1_di[19:0] , <br> a0_di[19:0] | a1_do[39:0] ,<br> a0_do[39:0] |

- **TDP 40K**: keyfi fakat eşit giriş ve çıkış bit genişliği
- **SDP 40K**: sabit 80 bit giriş ve çıkış bit genişliği

FIFO konfigürasyonunda, gelen adres sinyalleri göz ardı edilir. Bunun yerine, SRAM makrolarına bit genişliğine göre hizalanmış dahili okuma ve yazma göstergeleri (pointers) iletilir.

Ayrıca, yalnızca FIFO izleme amaçlı kullanılan ve ek çıkış sinyalleri de mevcuttur.

- **F_ALMOST_FULL_FLAG** ve **F_ALMOST_EMPTY_FLAG**, FIFO sınırlarına yaklaşırken erken uyarı sağlar.
- Bu bayrakların offset değerleri, konfigürasyon sırasında **15 bitlik kayıtlar** aracılığıyla ayarlanabilir veya **F_ALMOST_FULL_OFFSET** ve **F_ALMOST_EMPTY_OFFSET** girişleri kullanılarak dinamik olarak belirlenebilir.

| Flag            | Width | Description                                                                                            |
| --------------- | ----- | ------------------------------------------------------------------------------------------------------ |
| F_FULL          | 1     | All entries in the FIFO are filled, is set on the rising edge of the write clock (asynchronous)        |
| F_EMPTY         | 1     | The FIFO is empty, is set on the rising edge of the read clock (asynchronous)                          |
| F_ALMOST_FULL   | 1     | Almost all entries in the FIFO are filled, is set on the rising edge of the write clock (asynchronous) |
| F_ALMOST_EMPTY  | 1     | Almost all entries in FIFO have been read, is set on the rising edge of the read clock (asynchronous)  |
| F_READ_ADDRESS  | 16    | Current FIFO read pointer                                                                              |
| F_WRITE_ADDRESS | 16    | Current FIFO write pointer                                                                             |
| F_RD_ERR        | 1     | Is set if FIFO is empty and a read access takes place                                                  |
| F_WR_ERR        | 1     | Is set if FIFO is full and data is pushed, new data will be lost                                       |


**Not:** Dinamik offset girişlerinin kullanımı yalnızca **TDP konfigürasyonunda** mümkündür. SDP modunda yalnızca statik offset konfigürasyonu desteklenir.

Ek olarak, FIFO denetleyicisinin, dahili olarak saat alanına senkronize edilen özel bir **aktif düşük sıfırlama giriş sinyali (F_RST_N)** bulunmaktadır.


değişken bit genişlikli veri için **TDP modunda** geçerli olan FIFO veri birleştirme (concatenation) yapılarını göstermektedir.

- **B_EN**: Yazma / itme etkinleştirme (write / push enable) sinyali
- **B_WE**: Yazma / itme izin (write / push write enable) sinyali
- **A_EN**: Okuma / çekme etkinleştirme (read / pop enable) sinyali

FIFO, 40 bit genişliğindeki veri işlemlerini destekleyen **TDP modunda**  çalışacak şekilde yapılandırılmıştır.


**FIFO 40 bit data concatenations**

| Function     | Width | Concatenations |
| ------------ | ----- | -------------- |
| Push data    | 40    | B_DI[39:0]     |
| Push bitmask | 40    | B_BM[39:0]     |
| Pop data     | 40    | A_DO[39:0]     |

FIFO, 80 bit genişliğindeki veri işlemlerini destekleyen Tek Saat Çift Port (SDP) modunda  çalışacak şekilde yapılandırılmıştır.


**FIFO 40 bit data concatenations**

| Function     | Width | Concatenations            |
| ------------ | ----- | ------------------------- |
| Push data    | 80    | B_DI[39:0],<br>A_DI[39:0] |
| Push bitmask | 80    | B_BM[39:0],<br>A_BM[39:0] |
| Pop data     | 80    | B_DO[39:0],<br>A_DO[39:0] |
   
FIFO modunda DPSRAM'ın dahili veri akışı aşağıdaki görseldeki gibidir. İç pointer’lar adres yönetimini devralır. FIFO doluluk/boşluk durumlarını bayraklar bildirir. ECC yalnızca bazı genişliklerde aktif olur.

![[Pasted image 20250708085125.png]]

### **Senkron FIFO Erişimi**

**Yazma / itme (write / push)** ve **okuma / çekme (read / pop)** göstergeleri (**pointers**), **A_CLK** saat sinyalinin yükselen kenarında kayıtlanır.

Yazma / itme işlemi sırasında, **{A,B}_DI / {A,B}_BM** hattında bulunan veri kelimesi (data word), **B_EN** ve **B_WE** sinyalleri aktif olduğunda ve bu aktiflik **A_CLK**’in yükselen kenarından bir kurulum zamanı önce sağlandığında FIFO’ya yazılır.

Okuma / çekme işlemi, **A_EN** sinyali aktif olduğunda ve bu aktiflik **A_CLK**’in yükselen kenarından bir kurulum zamanı (setup time) önce sağlandığında, veri kelimesini **{A0,A1}_DO** çıkışına sunar.

- **empty, full, almost empty, almost full** ve **read/write error** sinyalleri, okuma ve yazma göstergelerinden kombinatoryal olarak hesaplanır.
- **Error bayrakları yapışkan (sticky) değildir**, yani hata durumu ortadan kalktığında bayraklar da sıfırlanır.

Bu zaman diyagramı, **boş bir senkron FIFO’ya yazma sürecini** göstermektedir:
## Zaman Çizgileri

| Sinyal           | Açıklama                                                                          |
| ---------------- | --------------------------------------------------------------------------------- |
| **A_CLK**        | Saat sinyali. Tüm pointer güncellemeleri bu sinyale göre yapılır.                 |
| **B_WE**         | Yazma etkinleştirme. Yüksekken, FIFO’ya veri yazılır.                             |
| **A_EN**         | Okuma etkinleştirme. Çıkış verisi aktifleşir.                                     |
| **FIFO memory*** | FIFO’daki veri kelimesi sayısı. `0 dw` → boş, `1 dw` → bir veri kelimesi yazıldı. |
| **empty**        | FIFO tamamen boş → ilk veri yazılınca düşer.                                      |
| **almost empty** | almost_empty_offset=2 → doluluk 2 kelimenin altında olduğunda aktif.              |
| **full**         | FIFO dolu olduğunda aktif.                                                        |
| **almost full**  | FIFO neredeyse dolu olduğunda aktif.                                              |

---

###  Önemli Notlar:

- İlk başta FIFO **boş (empty=1)** ve **almost_empty=1** durumundadır.  
- İlk yazma ile **empty=0** olur.  
- almost_empty, **2 veri kelimesi** yazılana kadar 1 kalır (çünkü offset=2).  
- Okuma işlemleri A_EN sinyali aktifken gerçekleşir.  
- Yazma ve okuma işlemleri A_CLK’in yükselen kenarına göre senkronize edilir.
- Yazma: `B_EN & B_WE & A_CLK ↑`
- Okuma: `A_EN & A_CLK ↑`
- Doluluk bayrakları anlık hesaplanır (kombinatoryal)
- Hata bayrakları **sticky değildir**, FIFO eski haline döndüğünde otomatik sıfırlanır.

Aşağıdaki görselde zamanlama diyagramı boş bir senkron FIFO'ya yazmayı göstermektedir.
![[Pasted image 20250708090457.png]]


Aşağıdaki görselde zamanlama diyagramı, neredeyse tam senkron FIFO'ya yazmayı göstermektedir.

![[Pasted image 20250708090609.png]]

Aşağıdaki görselde zamanlama diyagramı tam senkron bir FIFO'dan okumayı göstermektedir.

![[Pasted image 20250708090645.png]]

Aşağıdaki görselde zamanlama diyagramı, neredeyse boş bir senkron FIFO'dan okumayı göstermektedir.

![[Pasted image 20250708090716.png]]


### **Asenkron FIFO Erişimi**

**Yazma / itme (write / push)** ve **okuma / çekme (read / pop)** göstergeleri (**pointers**), kendi saat alanlarında (**B_CLK** ve **A_CLK**) kayıtlanır.

Yazma / itme işlemi sırasında, **{A,B}_DI / {A,B}_BM** hattında bulunan veri kelimesi, **B_EN** ve **B_WE** sinyalleri aktif olduğunda ve bu aktiflik **B_CLK**’in yükselen kenarından bir kurulum zamanı önce sağlandığında FIFO’ya yazılır.

Okuma / çekme işlemi, **A_EN** sinyali aktif olduğunda ve bu aktiflik **A_CLK**’in yükselen kenarından bir kurulum zamanı önce sağlandığında, veri kelimesini **{A0,A1}_DO** çıkışına sunar.

- **empty, full, almost empty, almost full** ve **read/write error** sinyalleri, okuma ve yazma göstergelerinden kombinatoryal olarak hesaplanır.
- Senkronizasyon mekanizması **Gray kodlaması + 2 aşamalı senkronizasyon** kullanır.
- Hata bayrakları **sticky değildir**.
    

---

## Zaman Çizgileri:

| Sinyal           | Açıklama                                                             |
| ---------------- | -------------------------------------------------------------------- |
| **A_CLK**        | Okuma saati. Read pointer bu saatle güncellenir.                     |
| **B_CLK**        | Yazma saati. Write pointer bu saatle güncellenir.                    |
| **B_WE**         | Yazma etkinleştirme. Yüksekken, FIFO’ya veri yazılır.                |
| **A_EN**         | Okuma etkinleştirme. Çıkış verisi aktifleşir.                        |
| **FIFO memory*** | FIFO’daki veri kelimesi sayısı.                                      |
| **empty**        | FIFO tamamen boş → ilk veri yazılınca düşer.                         |
| **almost empty** | almost_empty_offset=2 → doluluk 2 kelimenin altında olduğunda aktif. |
| **full**         | FIFO dolu olduğunda aktif.                                           |
| **almost full**  | FIFO neredeyse dolu olduğunda aktif.                                 |

---

### Önemli Notlar:

- Yazma işlemleri **B_CLK** ile, okuma işlemleri **A_CLK** ile senkronize edilir.
- Doluluk bayrakları (full, almost full) **write clock domain**’de hesaplanır.
- Boşluk bayrakları (empty, almost empty) **read clock domain**’de hesaplanır.
- Yazma: `B_EN & B_WE & B_CLK ↑`
- Okuma: `A_EN & A_CLK ↑`

---

Aşağıdaki görselde zamanlama diyagramı boş bir asenkron FIFO’ya yazmayı göstermektedir.  
![[Pasted image 20250708091552.png]]

Aşağıdaki görselde zamanlama diyagramı, neredeyse tam dolu asenkron FIFO’ya yazmayı göstermektedir.

![[Pasted image 20250708091607.png]]

Aşağıdaki görselde zamanlama diyagramı tam dolu bir asenkron FIFO’dan okumayı göstermektedir.

![[Pasted image 20250708091622.png]]

Aşağıdaki görselde zamanlama diyagramı, neredeyse dolu bir asenkron FIFO’dan okumayı göstermektedir.

![[Pasted image 20250708091541.png]]







