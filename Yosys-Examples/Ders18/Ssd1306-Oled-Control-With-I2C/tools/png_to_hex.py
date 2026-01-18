import sys
from PIL import Image

# --- Ayarlar ---
INPUT_IMAGE_NAME = "goruntu_cikti.png"  # Buraya dönüştürmek istediğiniz resminizin adını yazın
#INPUT_IMAGE_NAME = "goruntu_cikti.jpeg"  # Buraya .jpg, .jpeg veya .png dosyanızı yazın
OUTPUT_HEX_FILE = "kod_cikti1.hex"    # Çıktı olarak oluşturulacak hex dosyasının adı
IMAGE_WIDTH = 128
IMAGE_HEIGHT = 64
# ----------------

# 1. Resmi aç ve kontrol et
try:
    img = Image.open(INPUT_IMAGE_NAME)
except FileNotFoundError:
    print(f"Hata: '{INPUT_IMAGE_NAME}' dosyası bulunamadı.")
    print("Script'in ve resim dosyasının aynı klasörde olduğundan emin olun.")
    sys.exit(1)
except ImportError:
    print("Hata: Pillow kütüphanesi kurulu değil.")
    print("Lütfen 'pip install pillow' veya 'py -m pip install pillow' komutu ile kurun.")
    sys.exit(1)
except Exception as e:
    print(f"Hata: Resim dosyası açılamadı. {e}")
    sys.exit(1)

# 2. Resim boyutunu kontrol et VE GEREKİRSE YENİDEN BOYUTLANDIR (GÜNCELLENDİ)
if img.width != IMAGE_WIDTH or img.height != IMAGE_HEIGHT:
    print(f"Orijinal resim boyutu: {img.width}x{img.height}")
    print(f"Resim {IMAGE_WIDTH}x{IMAGE_HEIGHT} boyutuna yeniden boyutlandırılıyor...")
    
    # Yeniden boyutlandırma filtresi seçimi (kalite için)
    # Pillow 10.0.0+ için Image.Resampling.LANCZOS
    # Eski sürümler için Image.LANCZOS veya Image.ANTIALIAS
    try:
        # Modern Pillow (10.0.0+)
        if hasattr(Image, "Resampling"):
            resample_filter = Image.Resampling.LANCZOS
        else:
            # Eski Pillow (9.x ve altı)
            resample_filter = Image.LANCZOS
    except AttributeError:
        # Çok eski sürümler için güvenli bir fallback
        resample_filter = Image.ANTIALIAS

    img = img.resize((IMAGE_WIDTH, IMAGE_HEIGHT), resample_filter)
    print("Yeniden boyutlandırma tamamlandı.")
else:
    print(f"Resim zaten {IMAGE_WIDTH}x{IMAGE_HEIGHT} boyutunda. Yeniden boyutlandırmaya gerek yok.")


# 3. Resmi 1-bit (siyah-beyaz) moda dönüştür
# Bu, renkli veya gri tonlamalı resimleri otomatik olarak
# saf siyah (0) ve saf beyaza (1) dönüştürür.
print("Resim 1-bit (siyah-beyaz) moda dönüştürülüyor...")
img_bw = img.convert('1')
pixels = img_bw.load()

hex_lines = [] # Oluşturulacak 1024 hex satırını tutacak liste

# 4. Adres sırasına göre pikselleri işle (Verilog/OLED mantığı)
# (Bu kısım değiştirilmedi, orijinal mantık korunuyor)
# 1024 RAM adresini (0'dan 1023'e) tek tek geziyoruz
for ram_address in range(1024):
    
    # Bu RAM adresinin ekranda hangi X/Y pozisyonuna denk geldiğini hesapla
    page = ram_address // 128  # 0-7 arası sayfa
    col = ram_address % 128   # 0-127 arası sütun
    
    # Pikselin ekrandaki X ve Y başlangıç koordinatları
    x = col
    y_base = page * 8
    
    byte_val = 0 # Bu adrese yazılacak 8-bit'lik (1 byte) değer
    
    # Ekrondaki bu (x, y_base) konumundaki 8 dikey pikseli oku
    # ve bunları 1 byte'a dönüştür
    for i in range(8): # i = 0'dan 7'ye (Pikselin dikey konumu)
        y = y_base + i
        
        # Pikseli oku (1-bit modda 0=siyah, 255=beyaz döner)
        pixel_color = pixels[x, y]
        
        if pixel_color > 0: # Piksel beyazsa (yani '1' ise)
            # 'byte_val'in 'i' numaralı bitini '1' yap
            # (1 << i) -> i=0 için 00000001, i=1 için 00000010, ...
            byte_val = byte_val | (1 << i)
            
    # byte_val'i 2 haneli hex string'e çevir (örn: 5 -> "05", 255 -> "ff")
    hex_str = format(byte_val, '02x')
    hex_lines.append(hex_str)

# 5. Hex dosyasını yaz
try:
    with open(OUTPUT_HEX_FILE, 'w') as f:
        f.write("\n".join(hex_lines))
        f.write("\n") # Dosya sonuna bir yeni satır karakteri ekle (bazı $readmemh için gerekir)
except Exception as e:
    print(f"Hata: '{OUTPUT_HEX_FILE}' dosyası yazılamadı. {e}")
    sys.exit(1)

print(f"Başarılı! '{INPUT_IMAGE_NAME}' dosyası '{OUTPUT_HEX_FILE}' olarak kaydedildi.")
print(f"Toplam {len(hex_lines)} satır (1024 byte) yazıldı.")