# 🟢 JK Flip-Flop

## 📘 Nedir?

JK Flip-Flop, SR Flip-Flop’un geliştirilmiş bir versiyonudur ve iki girişe sahiptir:

- **J**: Set girişi
    
- **K**: Reset girişi
    

Saat darbesinde:

- **J=1, K=0** → Q=1 (Set)
    
- **J=0, K=1** → Q=0 (Reset)
    
- **J=1, K=1** → Q toggle eder.
    
- **J=0, K=0** → Q mevcut durumu korur.
    

---

## 🎯 Ne İşe Yarar?

✅ Durum makinelerinde **çok amaçlı veri saklama ve toggle** işlemleri.  
✅ Sayıcı ve kaydırma kayıtlarının (shift registers) temel yapı taşı.

---

## 🛠️ Kullanım Alanları

- **Senkron Sayıcılar (Synchronous Counters)**
    
- **FSM (Finite State Machines)**
    
- **Veri Yolu Kontrolü**
    

---

## ✅ Avantajlar

- SR Flip-Flop’taki **“geçersiz durum”** (S=1, R=1) problemi çözülmüştür.
    
- Toggle işlevi T Flip-Flop gibi kullanılabilir.
    
- Esnek giriş kombinasyonları ile farklı işlevler yapılabilir.
    

## ❌ Dezavantajlar

- Daha karmaşık giriş mantığı.
- T Flip-Flop’a göre daha fazla donanım kapısı kullanır.



![[Cologne Chip/Resimler/JK-Flip-Flop.png]]