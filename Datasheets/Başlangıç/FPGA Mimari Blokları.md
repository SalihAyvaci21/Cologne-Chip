### **LUT (Look-Up Table) – Bakım Tablosu**

#### Nedir?

LUT, dijital devrelerde **mantıksal işlemleri** gerçekleştiren temel birimdir. Bir nevi mini bir ROM gibi çalışır: giriş kombinasyonlarına karşılık gelen çıkışları saklar.

#### Nasıl Çalışır?

Örneğin 2 girişli bir LUT, 4 farklı giriş kombinasyonu için çıkış değerlerini saklar. Bu sayede `AND`, `OR`, `XOR` gibi işlemler LUT içinde tanımlanabilir.

#### Avantajları:

- Esnek yapı: Her türlü mantık fonksiyonu tanımlanabilir.
- Hızlı erişim: Girişe göre çıkış doğrudan alınır.

#### Dezavantajları:

- Karmaşık işlemler için çok sayıda LUT gerekebilir.
- LUT sayısı sınırlı olduğundan kaynak yönetimi önemlidir.

### **Flip-Flop (FF) – Sekansiyel Bellek Elemanı**

#### Nedir?

Flip-Flop, **zamanla değişen verileri** saklamak için kullanılır. Saat sinyaliyle senkron çalışır ve bir bitlik veri tutar.

#### Nasıl Çalışır?

Her saat darbesinde girişteki veri çıkışa aktarılır. Bu sayede sayıcılar, kaydediciler gibi sekansiyel devreler oluşturulabilir.

#### Avantajları:

- Zamanlama kontrolü sağlar.
- Sekansiyel devrelerin temelidir.

#### Dezavantajları:

- Fazla sayıda Flip-Flop, güç tüketimini artırabilir.
- Karmaşık zamanlama analizleri gerekebilir.

### **CLB (Configurable Logic Block) – Yapılandırılabilir Mantık Bloğu**

#### Nedir?

CLB, genellikle birkaç LUT ve Flip-Flop'un bir araya gelmesiyle oluşur. FPGA'nin programlanabilir mantık birimidir.

#### Nasıl Çalışır?

Bir CLB içinde:

- LUT'ler kombinasyonel mantığı sağlar.
- Flip-Flop'lar sekansiyel mantığı sağlar.
- MUX ve diğer kontrol devreleri yönlendirme yapar.

#### Avantajları:

- Modüler yapı: Karmaşık devreler kolayca inşa edilebilir.
- Yüksek paralellik: Aynı anda birçok işlem yapılabilir.

#### Dezavantajları:

- CLB'ler arası bağlantılar karmaşık olabilir.
- Yerleşim ve yönlendirme süreci zaman alabilir.
