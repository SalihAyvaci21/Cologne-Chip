## 2.9.1 Switch Boxes (SB) – Yönlendirme Yapısı

GateMate™ FPGA’nın tüm işlevsel elemanları, **routing yapısı** aracılığıyla birbirine bağlanır. Bu yapı, esas olarak **Switch Box’lar (SB)** ile oluşturulmuştur ve ek olarak **Input Multiplexers (IM)** ve **Output Multiplexers (OM)** ile desteklenir.

Tüm Switch Box’lar **(x, y)** matrisinde düzenlenmiştir:

(x,y)=(−1,−1)…(162,130)(x, y) = (-1, -1) \ldots (162, 130)(x,y)=(−1,−1)…(162,130)

![[Pasted image 20250708163654.png]]
Switch Box'lar temel olarak yatay ve dikey yönde diğer Switch Box'lara çift yönlü olarak bağlanır. Her ikinci koordinat Switch Box ile doldurulmuştur.

---

###  Switch Box Türleri

| **Tür**              | **Bağlantı Kapasitesi**                 | **Açıklama**                                                     |
| -------------------- | --------------------------------------- | ---------------------------------------------------------------- |
| **Big Switch Box**   | Her yönde 6 diğer Switch Box’a bağlanır | Geniş kapsama alanı ile uzun mesafeli sinyal yönlendirme sağlar. |
| **Small Switch Box** | Her yönde 2 diğer Switch Box’a bağlanır | Daha kompakt ve lokal yönlendirme için optimize edilmiştir.      |

![[Pasted image 20250708163728.png]]
Small ve Big Switch Box’ların yönlendirme bağlantılarını göstermektedir.

---

###  Yönlendirme Yetkinlikleri

-  **Yatay ve Dikey Yönlendirme:** SB’ler, yatay ve dikey eksende iki yönlü bağlantı sağlar.
-  **Yön Değiştirme:** Dikeyden yataya veya yataydan dikeye sinyal yönlendirme mümkündür.
-  **Çapraz Bağlantılar:** Üst sağ (xn+1,ym+1)(x_{n+1}, y_{m+1})(xn+1​,ym+1​) ve alt sol (xn−1,ym−1)(x_{n-1}, y_{m-1})(xn−1​,ym−1​) köşelerdeki diyagonal komşulara bağlantı yapılabilir.

Bu yapı, herhangi bir (xn,ym)(x_n, y_m)(xn​,ym​) noktasından tüm satır veya sütun koordinatlarına erişim sağlar.

---

###  Sinyal Besleme ve Çıkış

- 🟦 **CPE Çıkışları:** Sinyaller doğrudan CPE’lerden routing yapısına beslenebilir veya esneklik için OM’ler kullanılabilir.
- 🟩 **GPIO Girişleri:** Doğrudan Switch Box ağına bağlanır. 
-  **PLL, SerDes, RAM:** Belirli CPE’ler üzerinden routing yapısına bağlıdır.

![[Pasted image 20250708163745.png]]
###  Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                   | **Dezavantajlar**                                                                                 |
| ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| **Yüksek Esneklik:** Her noktadan satır veya sütun boyunca tüm koordinatlara erişim sağlar.      | **Routing Gecikmesi:** Çoklu Switch Box geçişlerinde sinyal gecikmesi artabilir.                  |
| **Çapraz Bağlantılar (Diagonal):** Alternatif yol seçenekleri ile routing optimizasyonu.         | **Yerleşim Karmaşıklığı:** Büyük matris, yoğun tasarımlarda yönlendirme optimizasyonu gerektirir. |
| **Büyük ve Küçük SB Seçenekleri:** Uzak ve lokal bağlantılar için uygun kaynak kullanımı sağlar. | **Kısıtlı Bant Genişliği:** Küçük SB’ler yalnızca 2 bağlantı yönüne izin verir.                   |
| **İntegrasyon:** PLL, SerDes ve RAM gibi bloklar doğrudan routing ağına bağlanabilir.            | **Yüksek Fan-Out Riski:** Yüksek yükte küçük SB’lerde tıkanmalar yaşanabilir.                     |

---

 **Sonuç:** Switch Box matrisi, GateMate FPGA’da esnek ve çok yönlü bir yönlendirme altyapısı sunar. Big ve Small Switch Box kombinasyonu, performans ve kaynak verimliliği arasında denge sağlar.


## **Die-to-Die Bağlantıları**

**CCGM1A2** cihazında, iki die arasındaki bağlantılar doğrudan yarı iletken üzerinde elektriksel olarak gerçekleştirilmiştir. Bu bağlantılar bir interposer üzerinden yapılmamış olup, iki die’ın yönlendirme yapıları (**routing structures**) doğrudan birbirine entegre edilmiştir.

Toplamda **1088 die-to-die bağlantısı** bulunur ve bu bağlantılar her iki sinyal yönü için de geçerlidir.

![[Pasted image 20250708164429.png]]
### Avantajlar ve Dezavantajlar

| **Avantajlar**                                                                                                 | **Dezavantajlar**                                                                                           |
| -------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Düşük Gecikme:** Doğrudan yarı iletken bağlantısı, interposer kullanımına kıyasla daha düşük gecikme sağlar. |  **Sabit Donanım Yapısı:** Die-to-die bağlantıları sabittir, esnek yeniden yönlendirme mümkün değildir.     |
| **Yüksek Bant Genişliği:** 1088 bağlantı her iki yönde yüksek veri aktarım kapasitesi sunar.                   | **Tasarım Karmaşıklığı:** İki die’ın routing yapıları arasındaki doğrudan entegrasyon ek dikkat gerektirir. |
| **Interposer İhtiyacı Yok:** Maliyet ve üretim karmaşıklığı azaltılır.                                         | **Hata İzolasyonu Zor:** Bir die’daki arıza, doğrudan bağlantı nedeniyle diğer die’ı etkileyebilir.         |
| **Düşük EMI:** Doğrudan yarı iletken bağlantılar, ek katmanlar gerektirmediği için EMI’yi azaltır.             |                                                                                                             |