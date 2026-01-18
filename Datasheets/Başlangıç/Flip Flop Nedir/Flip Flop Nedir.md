## Flip-Flop (FF) – Derinlemesine Teknik İnceleme

###  Nedir?

Flip-Flop, dijital devrelerde **bir bitlik veri saklamak** ve işlemek için kullanılan temel yapı taşıdır. Saat (clock) sinyaliyle senkron çalışır ve girişteki veriyi çıkışta tutar. FPGA'lerde her CLB (Configurable Logic Block) içinde genellikle bir veya daha fazla Flip-Flop bulunur.

---

###  Flip-Flop Türleri ve Kullanım Alanları

| Tür                 | Açıklama                                         | Kullanım Alanı               |
| ------------------- | ------------------------------------------------ | ---------------------------- |
| **D Flip-Flop**     | Girişteki veri saat darbesiyle çıkışa aktarılır. | Kayıtlar, veri tutma         |
| **T Flip-Flop**     | Tetiklendiğinde çıkışı değiştirir (toggle).      | Sayaçlar                     |
| **JK Flip-Flop**    | J ve K girişlerine göre çıkışı değiştirir.       | Durum makineleri             |
| **SR Flip-Flop**    | Set ve Reset girişleriyle çalışır.               | Basit kontrol devreleri      |
| **Edge-Triggered**  | Saat sinyalinin kenarında çalışır.               | Zamanlama hassas uygulamalar |
| **Level-Triggered** | Saat sinyali aktifken çalışır.                   | Daha az yaygın               |


---

###  Avantajları

- **Veri tutma**: Geçici veri saklama için idealdir.
- **Zaman kontrolü sağlar**: Saat sinyaliyle senkron çalışır.
- **Sekansiyel devrelerin temelidir**: Sayaçlar, FSM'ler, kaydediciler.

---

###  Dezavantajları

- **Fazla sayıda Flip-Flop**, FPGA kaynaklarını tüketebilir.
- **Güç tüketimi** artabilir (özellikle yüksek frekansta).

---

### Ne Zaman Kullanılır?

- **Veri senkronizasyonu**: Giriş/çıkış verilerini saatle hizalamak için.
- **Durum makineleri**: FSM'lerde durum bilgisini tutmak için.
- **Sayaçlar ve zamanlayıcılar**: Artan/azalan sayılar için.
- **Kayıtlar (registers)**: Paralel veri saklama ve taşıma için.