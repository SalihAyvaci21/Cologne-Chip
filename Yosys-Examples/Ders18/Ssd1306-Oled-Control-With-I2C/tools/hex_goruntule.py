import sys
from PIL import Image

# --- Ayarlar ---
HEX_FILE_NAME = "kod_cikti.hex"  # Sizin 1024 satırlık 8-bit hex dosyanız
IMAGE_WIDTH = 128
IMAGE_HEIGHT = 64
# ----------------

# 128x64 boyutunda, siyah-beyaz (1-bit) yeni bir resim oluştur
try:
    img = Image.new('1', (IMAGE_WIDTH, IMAGE_HEIGHT))
    pixels = img.load()
except ImportError:
    print("Hata: Pillow kütüphanesi kurulu değil.")
    print("Lütfen 'pip install pillow' veya 'py -m pip install pillow' komutu ile kurun.")
    sys.exit(1)

try:
    with open(HEX_FILE_NAME, 'r') as f:
        hex_lines = f.readlines()
except FileNotFoundError:
    print(f"Hata: '{HEX_FILE_NAME}' dosyası bulunamadı.")
    print("Script'in hex dosyasıyla aynı klasörde olduğundan emin olun.")
    sys.exit(1)

ram_address = 0

# Hex dosyasındaki satırları oku
for line in hex_lines:
    line = line.strip()
    if not line:
        continue # Boş satırları atla
    
    # 1024 satırlık RAM'in sonuna geldiysek dur
    if ram_address >= 1024:
        break

    # 2 haneli hex veriyi (örn: "ff") 8-bit integer'a çevir
    try:
        byte_val = int(line, 16)
    except ValueError:
        print(f"Hata: Satır '{line}' geçerli bir 8-bit hex değeri değil.")
        continue

    # Adreslemeyi hesapla (OLED.v 'step 30' mantığı - 8 sayfa, 128 sütun)
    # ram_address 0'dan 1023'e gider
    page = ram_address // 128  # 0-7 arası sayfa
    col = ram_address % 128   # 0-127 arası sütun
    
    # Pikselin ekrandaki X ve Y başlangıç koordinatları
    x = col
    y_base = page * 8      # Her sayfa 8 piksel yüksekliktedir

    # Bu 8-bit'lik byte'ı dikey olarak piksellere işle
    for i in range(8): # 8 bit'in her biri için (i = 0'dan 7'ye)
        # Bit '1' ise pikseli BEYAZ (1) yap, '0' ise SİYAH (0) kalır
        # (byte_val >> i) & 1 : i=0 en alttaki (LSB), i=7 en üstteki (MSB) pikseldir
        if (byte_val >> i) & 1:
            pixels[x, y_base + i] = 1

    ram_address += 1

if ram_address != 1024:
    print(f"Uyarı: Hex dosyasında 1024'ten az ({ram_address}) satır okundu.")

# Resmi kaydet
output_file = "goruntu_cikti1.png"
img.save(output_file)

print(f"Başarılı! '{HEX_FILE_NAME}' dosyası '{output_file}' olarak kaydedildi.")