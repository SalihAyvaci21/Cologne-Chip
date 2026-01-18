# Verilog Nota Sıralayıcı (Note Sequencer)

Bu proje, 10MHz'lik bir sistem saati kullanarak bir buzzer üzerinden 8 nota (Do, Re, Mi, Fa, Sol, La, Si, Do) ve bir duraklamadan oluşan bir melodiyi sırayla çalan bir Verilog tasarımıdır.

Her nota ve duraklama **1 saniye** sürer ve ardından bir sonrakine geçer. Toplam döngü 9 saniyedir.

##  Özellikler

- **Dinamik Frekans Üretimi:** `note_player.v` modülü, girişine gelen sayısal bir değere (yarım periyot süresi) göre anlık olarak kare dalga frekansı üretir.
    
- **Sıralayıcı FSM:** `top.v` modülü, 9 durumlu bir Sonlu Durum Makinesi (FSM) içerir.
    
- **Ayarlanabilir Nota Süresi:** `top.v` içindeki `DURATION_LIMIT` parametresi, her notanın ne kadar süreceğini belirler (şu anda 1 saniyeye ayarlı).
    
- **Sessizlik Desteği:** `note_player` modülüne `0` değeri gönderildiğinde, `buzzer_out` çıkışını '0' yaparak sessizlik sağlar.
    
##  Modül Hiyerarşisi

- <a href="Buzzer_Test/src/Top.v"><em> Top.v</em> </a> (Ana Modül):**
    
    - Sistemin 10MHz'lik `CLK_IN` sinyalini alır.
        
    - Her 1 saniyede bir (10,000,000 saat döngüsü) `note_state_reg` durumunu günceller.
        
    - O anki duruma (`note_state_reg`) göre çalınacak notanın yarım periyot değerini (`HP_C4`, `HP_D4`, vb.) seçer.
        
    - Bu değeri `current_note_half_period` sinyali üzerinden `note_player` modülüne iletir.
        
- <a href="Buzzer_Test/src/note_player.v"><em> note_player.v</em> </a> (Frekans Üreteci):**
    
    - `top.v`'den `half_period_in` girişini alır.
        
    - Eğer `half_period_in == 0` (Duraklama) ise, `buzzer_out`'u '0' yapar.
        
    - Eğer `half_period_in > 0` ise, 0'dan o değere kadar sayar, `buzzer_out`'u tersler (toggle) ve sayacı sıfırlar. Bu işlem, `buzzer_out` üzerinde istenen frekansta bir kare dalga oluşturur.
        

##  Vivado'da Simülasyon

Bu projeyi Vivado'da simüle etmek çok basittir:

1. **Vivado Projesi Oluşturun:** Vivado'yu açın ve yeni bir proje oluşturun.
    
2. **Tasarım Kaynaklarını Ekleyin (Add Sources):**
    
    - top.v
        
    - note_player.v
        
3. **Simülasyon Kaynaklarını Ekleyin (Add Simulation Sources):**
    
    - top_tb.v
        
4. **Simülasyonu Çalıştırın:** Sol taraftaki "Flow Navigator" panelinden **"Run Simulation" -> "Run Behavioral Simulation"** seçeneğine tıklayın.
    
5. **Simülasyon Penceresi:** Vivado simülatörü açılacaktır.
    
    - Simülasyon otomatik olarak 10 saniye (testbench'te belirtildiği gibi) çalışacak ve duracaktır. Eğer daha uzun çalışmasını isterseniz, `top_tb.v` dosyasındaki `#(10_000_000_000);` satırını değiştirmeniz veya `$stop;` komutunu kaldırmanız gerekir.
        
6. **Sinyalleri İnceleyin:**
    
    - "Scope" panelinden `top_tb` -> `DUT` (Design Under Test) seçeneğini genişletin.
        
    - `note_state_reg` sinyalini dalga formu penceresine sürükleyin. (Değerleri ondalık görmek için sinyal adına sağ tıklayıp "Radix -> Unsigned Decimal" seçin).
        
    - `buzzer_out` sinyalini dalga formu penceresine sürükleyin.
        
    - "Zoom Fit" (Tümünü Göster) butonuna basın.
        
    - `note_state_reg` sinyalinin her 1 saniyede bir (1,000,000,000 ns) 0, 1, 2... 8, 0 şeklinde değiştiğini göreceksiniz.
        
    - Her durum değiştiğinde, `buzzer_out` sinyalinin frekansının (sıklığının) değiştiğini görmek için dalga formuna yakınlaşın (zoom yapın). Durum '8' (PAUSE) olduğunda `buzzer_out` sinyalinin '0'da sabit kaldığını göreceksiniz.
        
##  Görseller

### Simülasyon Formu (icarus)

Vivado simülatöründe 10 saniyelik tam döngünün dalga formu görüntüsü. `note_state_reg`'in her 1 saniyede bir değiştiği ve `buzzer_out` frekansının buna göre uyarlandığı görülmektedir.

![[Images/icarus.png]]
### Simülasyon Dalga Görseli (Vivado)

Projenin FPGA kartı üzerinde çalışırken çekilmiş fotoğrafı.

![[Images/vivado.png]]

##  Pin Kısıtlamaları (Constraints)

Projeyi FPGA'e yüklemek için `top.ccf` dosyasında belirtilen pinler kullanılabilir:

```
# Clock input (10 MHz)
Net "CLK_IN"         Loc = "IO_SB_A8";

# Reset input (Button)
Net "RESET_N_IN"     Loc = "IO_EB_B0";

# Buzzer Output
Net "buzzer_out"     Loc = "IO_NB_A7";
```

## 👤 Hazırlayan

Salih Tekin Ayvacı Electrical & Electronics Engineer