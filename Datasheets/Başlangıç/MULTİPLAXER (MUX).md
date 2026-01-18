## Multiplexer (MUX) – Derinlemesine Teknik İnceleme

### Nedir?

Multiplexer (MUX), birden fazla girişten **yalnızca birini seçip çıkışa yönlendiren** dijital bir devre elemanıdır. Seçim işlemi, **kontrol (seçim) sinyalleri** ile yapılır. MUX’lar, veri yollarında yönlendirme, kaynak seçimi ve kontrol mantığı gibi birçok alanda kullanılır.

### FPGA İçindeki Kullanımı

- FPGA’lerde MUX’lar genellikle **LUT’ler içinde sentezlenir**.
- HDL’de `case`, `if-else`, `?:` gibi yapılar sentez sırasında MUX’a dönüşür.
- **Veri yolu seçimi**, **durum geçişleri**, **giriş/çıkış yönlendirme** gibi işlemlerde kullanılır.

### Ne Zaman Kullanılır?

- **Veri yönlendirme**: Birden fazla kaynaktan gelen veriyi tek çıkışa yönlendirmek için.
- **FSM (Finite State Machine)**: Durum geçişlerinde hangi durumun aktif olacağını seçmek için.
- **ALU tasarımı**: Hangi işlemin yapılacağını seçmek için.
- **Giriş/Çıkış kontrolü**: Hangi pinin aktif olacağını belirlemek için.

