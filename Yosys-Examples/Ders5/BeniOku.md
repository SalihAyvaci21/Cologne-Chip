Bu proje için iki adet kaynak dosya bulunmaktadır:  
1. **debounce_led_counter_top.v** → Top modül (LED kontrol mantığı)  
2. **debounce_ip_core.v** → Debounce IP core (buton filtreleme)  

Bu dosyalar sentez aşamasında **Yosys** tarafından işlenir. Yosys, kaynak dosyaları okuyarak `top` modülünü belirler ve sentezleme sürecini buna göre yürütür. 

### Makefile Ayarı  

**Makefile** dosyasında top modülün doğru seçilmesi için şu komutun girilmesi gerekmektedir:  

<p align="center">

<img src="Images/Pasted image 20250825092313.png" style="display: block; margin: auto;">

<br>
<a href="Led-Bounce-Up-Down-Counter/Led-Bounce-Up-Down-Counter/src/led_bounce_up_down_counter.v">
<em style="display:flex;justify-content:center">TOP = debounce_led_counter_top</em>
</a>
  
</p>

Ayrıca, `run` dosyasında tüm modüllerin tanımlanması gerekmektedir. Bunun için:

<p align="center">

<img src="Images/Pasted image 20250825092314.png" style="display: block; margin: auto;">

<br>
<em style="display:flex;justify-content:center"></em>
</p>

`set SRC=src/debounce_led_counter_top.v src/debounce_ip_core.v` kodunun yazılması gerekmektedir.
