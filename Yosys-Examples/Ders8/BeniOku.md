# Gatemate Cologne Chip Toolchain: Windows'da Simülasyon Kılavuzu

Bu kılavuz, açık kaynak donanım geliştirme dünyasına adım atmak isteyenler için **Icarus Verilog** ve **MSYS2** araç zincirini kullanarak bir Verilog projesinin Windows üzerinde nasıl simüle edileceğini adım adım açıklamaktadır. Kılavuz, sıfırdan başlayarak kurulum, test ve **waveform** analizi süreçlerini kapsamaktadır.
## Adım 1: Icarus Verilog Kurulumu

Icarus Verilog, Verilog kodlarını derlemek ve simüle etmek için kullanılan bir araçtır.

1. Aşağıdaki adresten Icarus Verilog'un en son kararlı sürümünü indirin:
		[https://bleyer.org/icarus/](https://bleyer.org/icarus/ "null")
    
    - **iverilog-0.9.7_setup.exe (latest stable release)** linkine tıklayın.
        
2. Kurulum sırasında, bu ekran görüntüsündeki seçenekleri işaretleyerek ilerleyin.

<p align="center">

<div sytle='display: flex; justify-content: center; align-items: center;"'>

<img src="Pasted image 20250903125054.png" style="max-width: 32%;"  >
<img src="Pasted image 20250903125112.png" style="max-width: 32%;" >
<img src="Pasted image 20250903125207.png" style="max-width: 32%;" >
<br>

<em style="display:flex;justify-content:center"> </em>
</div>

1. Kurulum tamamlandıktan sonra, **Başlat** menüsüne **"sistem ortam değişkenlerini düzenleyin"** yazın ve açılan pencereden **Ortam Değişkenleri (Environment Variables)**'ne tıklayın.
    
2. **Path** değişkenine çift tıklayın ve listede `C:\iverilog\bin` yolunun bulunduğundan emin olun. Yoksa bu yolu ekleyin.

<p align="center">

<div sytle='display: flex; justify-content: center; align-items: center;"'>

<img src="Pasted image 20250903125451.png" style="max-width: 32%;"  >
<img src="Pasted image 20250903125523.png" style="max-width: 32%;" >
<img src="Pasted image 20250903125556.png" style="max-width: 32%;" >
<br>

<em style="display:flex;justify-content:center"> </em>
</div>
    
3. Kurulumu doğrulamak için **Komut İstemi (CMD)**'ni açın ve şu komutları girin
  ```
  iverilog -V    
  ```
Bu komut, Icarus Verilog'un sürüm bilgisini görüntülemelidir.

## Adım 2: MSYS2 Kurulumu

MSYS2, Windows üzerinde Linux benzeri bir komut satırı ortamı sağlar ve Verilog için gerekli ek araçları barındırır.

1. MSYS2'yi aşağıdaki resmi sitesinden indirin: [https://www.msys2.org/](https://www.msys2.org/ "null")
    
    - Veya direkt indirmek için şu adrese gidin: [https://github.com/msys2/msys2-installer/releases/download/2025-08-30/msys2-x86_64-20250830.exe](https://github.com/msys2/msys2-installer/releases/download/2025-08-30/msys2-x86_64-20250830.exe "null")
        
2. Kurulum sırasında varsayılan dosya konumunu değiştirmeyin. Bu ekran görüntüsündeki tikleri işaretleyerek devam edin.

<p align="center">

<img src="Pasted image 20250903130022.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>
1. Kurulumdan sonra MSYS2 otomatik olarak çalışacaktır. Çalışmazsa bu programı çalıştırın.
 <p align="center">

<img src="Pasted image 20250903131715.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>
Açılan terminale sırasıyla aşağıdaki komutları girerek gerekli paketleri yükleyin:


   ```
   $ pacman -Syu
   ```

(Bu komuttan sonra `y` yazarak devam edin.)

```
$ pacman -S mingw-w64-x86_64-gtkwave
$ pacman -S mingw-w64-x86_64-iverilog
$ pacman -S mingw-w64-ucrt-x86_64-gcc
$ pacman -S mingw-w64-ucrt-x86_64-gdb
```

Her komutta `y` yazarak indirme işlemini onaylayın.



2. **Komut İstemi (CMD)**'nde ortam değişkenlerini kontrol edin ve **Path**'e `C:\msys64\mingw64\bin` yolunun eklendiğinden emin olun.

<p align="center">

<img src="Pasted image 20250903125256.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>

<p align="center">

<div sytle='display: flex; justify-content: center; align-items: center;"'>

<img src="Pasted image 20250903125451.png" style="max-width: 32%;"  >
<img src="Pasted image 20250903125523.png" style="max-width: 32%;" >
<img src="Pasted image 20250903130555.png" style="max-width: 32%;" >
<br>

<em style="display:flex;justify-content:center"> </em>
</div>
1. Kurulumun tamamlandığını doğrulamak için CMD'ye aşağıdaki komutları girin:


```
iverilog -V
gcc --version
gdb --version
gtkwave
```
    

## Adım 3: Temel Simülasyon Testi

Artık bir Verilog kodunu derleyip çalıştırabilirsiniz.

1. Bilgisayarınızda Verilog kodları için bir klasör oluşturun (örneğin: `C:\VerilogCodes`).
    
2. İçine `test.v` adında bir dosya oluşturun ve şu kodu ekleyin:
<p align="center">

<img src="Pasted image 20250903131516.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>

```
module hello;
 
initial begin
$display("Hello, World");
$finish;
end

endmodule

```

![[test.v]]
3. MSYS2 terminalini açın ve oluşturduğunuz klasöre gidin:

```
$ cd /c/VerilogCodes
```

4. Kodu derleyin ve bir `.vvp` dosyası oluşturun:



$ iverilog -o test.vvp test.v

![[test.vvp]]



<p align="center">

<img src="Pasted image 20250903132123.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>

![[test.vvp]]
3. Simülasyonu çalıştırın:

$ vvp test.vvp

Terminalde **"Hello, World"** çıktısını görmelisiniz.

<p align="center">

<img src="Pasted image 20250903132215.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>

## Adım 4: Gelişmiş Test ve Waveform Görüntüleme

Daha karmaşık devreleri test etmek ve sinyal değişimlerini dalga formunda görmek için **full adder** örneğini kullanalım.

1. Aşağıdaki iki dosyayı aynı klasörde oluşturun: `fullAdderTB.v` ve `fullAdder.v`.

**fullAdder.v** (Full Adder modülü)



```
   module full_adder(
     input a,
     input b,
    input c_in,
    output sum,
     output carry_out
    );
    assign sum = a ^ b ^ c_in;
    assign carry_out = (a & b) | (b & c_in) | (a & c_in);
endmodule
```
![[fullAdder.v]]


    **fullAdderTB.v** (Testbench ve Waveform komutları)
    
    ```
    `timescale 1ns / 1ps
    
    module tb_full_adder;
    
    // Declare testbench signals
    reg a, b, c_in;
    wire sum, carry_out;
    
    // Instantiate the full adder module
    full_adder dut (
        .a(a),
        .b(b),
        .c_in(c_in),
        .sum(sum),
        .carry_out(carry_out)
    );
    
    // Waveform dosyalarını oluştur
    initial begin
        $dumpfile("fullAdderTB.vcd");
        $dumpvars(0, tb_full_adder);
    end
    
    // Test senaryosunu uygula
    initial begin
        $display("Testing Full Adder");
        $display("a   b   c_in | sum carry_out");
        $display("--------------------------");
    
        $monitor("%b   %b   %b    | %b   %b", a, b, c_in, sum, carry_out);
    
        a = 0; b = 0; c_in = 0; #10;
        a = 0; b = 0; c_in = 1; #10;
        a = 0; b = 1; c_in = 0; #10;
        a = 0; b = 1; c_in = 1; #10;
        a = 1; b = 0; c_in = 0; #10;
        a = 1; b = 0; c_in = 1; #10;
        a = 1; b = 1; c_in = 0; #10;
        a = 1; b = 1; c_in = 1; #10;
    
        #20;
        $finish;
    end
    
    endmodule
    
    

![[fullAdderTB.v]]

2. MSYS2 terminalini kullanarak dosyaları derleyin ve `.vvp` dosyasını oluşturun:




```
$ iverilog -o fullAdderTB.vcd fullAdderTB.v fullAdder.v
```


![[fullAdderTB.vcd]]
3. Simülasyonu çalıştırın:

```
$ vvp fullAdderTB.vcd
```
<p align="center">

<img src="Pasted image 20250903133156.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>
Terminalde tüm test senaryolarının sonuçlarını görmelisiniz.

4. Waveform'u GTKWave ile görüntüleyin:

```
$ gtkwave fullAdderTB.vcd
```

<p align="center">

<img src="Pasted image 20250903140944.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center"> </em>

</p>





