	
Bu proje **Gatemate CCGM1A1 V3.2A Eval Board** üzerinde geliştirilmiştir. Amaç, **buton sinyalindeki “debounce” etkisini** göstermek ve **debouncer kullanıldığında elde edilen kararlı sinyal** ile **kullanılmadığında oluşan bozuk sinyal** arasındaki farkı gözlemlemektir.  

---

## Proje Amacı
Mekanik butonlar basıldığında veya bırakıldığında tek bir darbe üretmez, hızlı bir şekilde açılıp kapanarak **gürültülü (bouncing) sinyal** oluşturur.  
Bu proje ile:  
- **Debouncer olmadan** → LED sayacı hatalı artışlar yapar.  
- **Debouncer ile** → LED sayacı yalnızca gerçek basma anında kararlı artar.  

---

## Kodlar
Projede iki temel modül bulunmaktadır:  
1. debounce_ip_core.v → Buton sinyalini filtreleyen IP core.  

 <p align="center">

<img src="Images/Pasted image 20250825092256.png" style="display: block; margin: auto;">

<br>

<a href="Led-Bounce-Up-Down-Counter/Led-Bounce-Up-Down-Counter/src/debounce_ip_core.v">
<em style="display:flex;justify-content:center">debounce_ip_core.v kod görüntüsü</em>
</a>	
</p>
2.   debounce_led_counter_top.v  → LED’leri kontrol eden top modül.  
<p align="center">
  <img src="Images/Pasted image 20250825092312.png" style="display: block; margin: auto;">
  <br>
  
<a href="Led-Bounce-Up-Down-Counter/Led-Bounce-Up-Down-Counter/src/led_bounce_up_down_counter.v">
  <em style="display:flex;justify:content:center">debounce_led_counter_top.v kod görüntüsü</em>
</a>
</p>

---

## Sonuçlar

### **Debouncersız buton sinyali**  
<p align="center">

<img src="Images/scope-view-2.jpg" style="display: block; margin: auto;">

<br>
<em style="Images/display:flex;justify-content:center">Debouncersız buton sinyali</em>
</p>
Mekanik butonun kararsız çıkışı. Birden fazla tetikleme görülüyor.

### **Debouncer ile filtrelenmiş sinyal**  
<p align="center">

<img src="Images/max-0020-image-for-home-page-2.png" style="display: block; margin: auto;">

<br>
<em style="display:flex;justify-content:center">Debouncer ile filtrelenmiş sinyal</em>
</p>
    
  Gürültü temizlenmiş, yalnızca tek bir darbe oluşmuş.

- **LED sayacı davranışı:**  
  - 8 LED sırayla yanar.  
	- 9.basışta tüm LED’ler söner ve sayaç sıfırlanır.

---

## FF Yapısı
Projede kullanılan debouncer mantığı **Flip-Flop zinciri** ve sayaç tabanlıdır:  
<p align="center">

<img src="Images/Schema.png" style="display: block; margin: auto;">

<br>
<em style="display:flex;justify-content:center">FF Yapısı</em>
</p>

- 32 Cell
- 10 I/O Port
- 89 Nets

  Shift-register + sayaç yapısı ile kararlı buton çıkışı elde edilir.

---


## Çalışma Görseli

<p align="center">

<img src="Images/Gif.gif" style="display: block; margin: auto;">

<br>
<em style="display:flex;justify-content:center">Debouncer ile LED sayacının çalışması</em>
</p>

