## FPGA PLL Parametreleri: **fin, fout, ploop, pout, posc**

###  **$f_{in}$ (Input Frequency)**

- **$f_{in}$, PLL’e giren **referans saat sinyalinin frekansıdır**.
- FPGA üzerindeki **CLK0–CLK3** girişler; **SER_CLK/SER_CLK_N** girişleri (tek uçlu veya LVDS)
- Tipik kullanım: Sistemin temel saat kaynağı (ör. 50 MHz kristal osilatör).

---

###  ****$f_{out}$ (Output Frequency)**

- ****$f_{out}$, PLL’den çıkan **üretilecek saat sinyalinin frekansıdır**.
- Bu, DCO frekansı (****$f_{dco}$) ve programlanabilir bölücüler tarafından belirlenir.
- PLL’in çıkışları:
    - **PLL_CLK_OUT0**
    - **PLL_CLK_OUT90**
    - **PLL_CLK_OUT180**
    - **PLL_CLK_OUT270**  
        Her biri 90° faz kaydırmalı.
- **Kullanım:** FPGA iç saat ağına veya dış devrelere gönderilir.
    

---

###  **Ploop (Feedback Path Selection)**

- **ploop = PLL_SETUP[54]** parametresi, geri besleme yolunu seçer.
- **İki mod:**
    - **ploop = 0** → **Dahili geri besleme**
    - Geri besleme döngüsü PLL’in içinde kapalıdır.
    - Daha hızlı kilitlenme (lock-in) ve stabilite sağlar.

	- **ploop = 1** → **Harici geri besleme**
	- PLL çıkış saat sinyali dış devreye gönderilir ve oradan geri döner.
	- Kullanıcının devre gecikmesi hesaba katılır.

---

###  $p_{out}$ (Output Path Selection)**

- $p_{out}$, çıkış yolunda kullanılacak ek bölücüyü seçer.
- Bu parametre, PLL çıkış frekansını doğrudan etkiler.
- Genellikle yüksek DCO frekanslarından düşük çıkış frekanslarına ulaşmak için kullanılır.
---

### **$p_{osc}$ (Post Divider Enable)**

- **$p_{osc}$ = PLL_SETUP[86]** ile kontrol edilir.
- **$p_{osc}$ = 1:** Sinyal yoluna ek bir **2’ye bölücü** yerleştirilir.
- ****$p_{osc}$ = 0:** Ek bölücü devre dışıdır.
- Kullanım amacı; Çıkış saat frekansını istenen aralığa ince ayarlamak ve Çıkışta tam frekans bölmesi yerine yarı frekansta çalışma.

---

##  Görsel Destekli Özet

| Parametre  | Ne Yapar?                                    | Tipik Kullanım                     |
| ---------- | -------------------------------------------- | ---------------------------------- |
| $f_{out}$  | PLL giriş saat frekansı                      | 50 MHz kristal veya harici saat    |
| $f_{out}$  | PLL çıkış saat frekansı                      | FPGA logic saat ağı                |
| $p_{loop}$ | Geri besleme yolunu seçer (dahili/harici)    | Harici döngü ile gecikme ölçümü    |
| $p_{out}$  | Çıkış yolunu ve bölücüyü yapılandırır        | Yüksek DCO → Düşük fout dönüştürme |
| $p_{osc}$  | Sinyal yoluna ek bir 2’ye bölücü yerleştirir | İnce frekans ayarı                 |

---

##  Neden Bu Kadar Kritikler?

✅ Bu parametreler, PLL’in **çıkış frekansı**, **faza bağlı jitter**, **lock time** ve **stabilite** üzerinde doğrudan etkilidir.  
✅ **ploop=1** modunda, kullanıcı devresinin gecikme süresi **PLL bandwidth’ini etkileyecek kadar büyükse**, kilitlenme zorlaşabilir.