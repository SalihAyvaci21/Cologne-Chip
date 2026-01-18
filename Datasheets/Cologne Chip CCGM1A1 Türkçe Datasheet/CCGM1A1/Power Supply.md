**GateMate™ FPGA modelleri CCGM1A1 / CCGM1A2**, yonga çekirdeği için tek bir güç kaynağına ve her bir GPIO bankası için ayrı GPIO güç pinlerine sahiptir. Ayrıca FPGA’nin belirli bölümleri için ayrılmış bazı özel güç pinleri de bulunmaktadır:

- **VDD**: Çekirdek (core) besleme voltajı.
- **VDD_CLK**: Aşağıdaki giriş pinleri için besleme voltajı: `SER_CLK`, `SER_CLK_N`, `RST_N` ve `POR_ADJ`.
- **VDD_PLL**: PLL (Phase-Locked Loop) devreleri için besleme pini.
- **VDD_SER**: SerDes (Serializer/Deserializer) modülü için besleme pini.
- **VDD_SER_PLL**: SerDes PLL devresi için besleme pini.
- **VDD_EA, VDD_EB, VDD_NA, VDD_NB, VDD_SA, VDD_SB, VDD_WA, VDD_WB, VDD_WC**: GPIO bankaları için besleme pinleri.

---

## Performans Modları ve Voltaj Seviyeleri

Çekirdek voltajı (VDD), FPGA’nin çalışma modunu belirlemek için seçilebilir:

|Mod|VDD Voltajı|
|---|---|
|Düşük Güç Modu|0.9 V ± 50 mV|
|Ekonomi Modu|1.0 V ± 50 mV|
|Hız Modu|1.1 V ± 50 mV|

- **VDD_PLL**, çekirdek voltajı (VDD) ile aynı voltaj aralığını kullanır.
- **VDD_SER** ve **VDD_SER_PLL**, **1.0 V ± 50 mV ile 1.1 V ± 50 mV** arasında bir voltaj aralığında çalışır.
- Tüm bu voltaj hatları, **gürültü filtrelerine** bağlanmalıdır.

---

## GPIO ve Saat Giriş Voltajları

- **GPIO bankaları** ve **VDD_CLK** için voltaj aralığı: **1.1 V – 2.7 V** arasında ayarlanabilir.