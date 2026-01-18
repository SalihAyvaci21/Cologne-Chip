![[Cologne Chip/Resimler/Pasted image 20250707100241.png]]

### **Ne Anlatıyor?**

1. **CCGM1A1** yongasında yer alan **ek işlevsel bloklar** şunlardır:
    
    - **Çift portlu SRAM’ler (DPSRAMs):** Aynı anda iki farklı işlem birimi tarafından erişilebilen bellek blokları.
    - **PLL’ler (Phase-Locked Loops):** Saat sinyallerini senkronize eder.
    - **GPIO hücreleri:** Harici cihazlarla giriş/çıkış bağlantısı sağlar.
    - **SPI konfigürasyon ve veri flash arayüzü:** FPGA’nın yapılandırılması ve veri saklaması için kullanılır.
    - **JTAG arayüzü:** Test ve hata ayıklama işlemleri için kullanılır.
    - **SerDes arayüzü:** Yüksek hızlı seri veri iletimi sağlar.
2. **Şekil 2.1**, bu bileşenlerin CCGM1A1 içindeki mimari yerleşimini gösterir.
    
3. **CCGM1A2**, iki adet CCGM1A1 yongasını tek bir pakette birleştiren **multi-die (çoklu yonga)** mimarisine sahiptir. Bu yapı yukarıdaki görselde gösterilmektedir.
    

---

### ✅ **Avantajlı Yönleri**

#### 🔹 **Çift Portlu SRAM (DPSRAM):**

- Aynı anda iki farklı işlem birimi tarafından erişilebilir.
- **Avantaj:** Paralel veri işleme kapasitesini artırır.

#### 🔹 **PLL’ler:**

- Farklı frekanslarda çalışan bileşenleri senkronize eder.
- **Avantaj:** Zamanlama hatalarını azaltır, sistem kararlılığını artırır.

#### 🔹 **GPIO Hücreleri:**

- Harici sensörler, motorlar veya diğer cihazlarla bağlantı sağlar.
- **Avantaj:** Geniş uygulama alanı ve esneklik sunar.

#### 🔹 **SPI ve Flash Arayüzü:**

- FPGA’nın hızlı ve güvenilir şekilde yapılandırılmasını sağlar.
- **Avantaj:** Kalıcı veri saklama ve hızlı başlatma imkânı sunar.

#### 🔹 **JTAG Arayüzü:**

- Donanım testleri ve hata ayıklama için kullanılır.
- **Avantaj:** Geliştirme sürecini kolaylaştırır.

#### 🔹 **SerDes Arayüzü:**

- Yüksek hızlı veri iletimi sağlar.
- **Avantaj:** Daha az pinle daha fazla veri aktarımı yapılabilir.

#### 🔹 **Multi-Die Mimari (CCGM1A2):**

- İki yonganın doğrudan silikon üzerinde bağlanması sayesinde daha yüksek işlem gücü ve bant genişliği elde edilir.
- **Avantaj:** Daha fazla kaynak, daha yüksek performans ve daha kompakt sistem tasarımı.