# **FPGA I2C OLED Image Toggler**

## **Task Description**

This project aims to drive a 128x64 resolution I2C OLED display using an FPGA. The project stores two different images in the FPGA's internal RAM blocks. An external button is used to perform a **"toggle" (switch)** operation between these two images.

Images are converted into 1024-byte `.hex` files using the `png_to_hex.py` script and are loaded into memory by the `Simple_RAM` modules during synthesis.

---

## 🎯 **Objectives**

- Design an **I2C Master controller** using Verilog.
    
    - <a href="Ssd1306-Oled-Control-With-I2C/src/I2C.v"><em>I2C.v</em></a>
        
- Develop a **driver** for SSD1306 or similar 128x64 I2C OLED screens.
    
    - <a href="Ssd1306-Oled-Control-With-I2C/src/OLED.v"><em>OLED.v</em></a>
        
- Store image data on the FPGA using **Simple_RAM** modules.
    
    - <a href="Ssd1306-Oled-Control-With-I2C/src/Simple_RAM.v"><em>Simple_RAM.v</em></a>
        
- Filter physical button noise using **debounce_ip_core**.
    
    - <a href="Ssd1306-Oled-Control-With-I2C/src/debounce_ip_core.v"><em>debounce_ip_core.v</em></a>
        
- Instantly switch the displayed image by selecting between two different RAM blocks via button input.
    
    - <a href="Ssd1306-Oled-Control-With-I2C/src/Top_OLED.v"><em>Top_OLED.v</em></a>
        
- Provide Python tools to convert images (PNG, JPG) into the `.hex` format that Verilog can understand.
    
    - <a href="Ssd1306-Oled-Control-With-I2C/tools/png_to_hex.py"><em>png_to_hex.py</em></a>, <a href="Ssd1306-Oled-Control-With-I2C/tools/hex_goruntule.py"><em>hex_goruntule.py</em></a>
        

---

## ⚙️ **Algorithm**

### 1️⃣ Initialization

1. The FPGA is reset (`reset_n = 0`).
    
2. `Simple_RAM` modules (`ram1` and `ram2`) load the `image_data.hex` and `image2.hex` files into their memory blocks during synthesis.
    
3. The `image_select` register in the `Top_OLED` module starts at `0`, selecting `ram1` (the first image).
    
4. The `OLED.v` controller sends initialization commands to the screen via I2C from `step = 0` to `step = 24` (e.g., Display OFF, Set MUX Ratio, Set Charge Pump, Display ON).
    

### 2️⃣ Image Writing Loop

1. Once initialization is complete (`step = 25`), `OLED.v` enters the main image writing loop.
    
2. The OLED controller sets the cursor position based on `page` (0–7) and `col` (0–127) counters.
    
3. The controller generates an `addr` (RAM address) between 0–1023.
    
4. This `addr` is sent to both RAMs (`ram1`, `ram2`) in the `Top_OLED.v` module simultaneously.
    
5. A **MUX** inside `Top_OLED.v` selects either `ram1_dout` or `ram2_dout` based on the `image_select` bit.
    
6. The selected data (`ram_mux_out`) enters the `OLED.v` controller as `ram_dout`.
    
7. `OLED.v` sends this data to the screen using the `I2C.v` module (`DCn = 1`).
    
8. This process repeats many times per second to continuously refresh the image on the screen.
    

### 3️⃣ Button Detection and Image Toggle

1. When the user presses the physical `button`, the `debounce_ip_core` module cleans the noise from the signal.
    
2. The moment the button is pressed (falling edge) is detected as `btn_valid = 1` and `btn_stable = 0`.
    
3. This triggers the `always` block in `Top_OLED.v`, and the value of the `image_select` register is toggled (`image_select <= ~image_select`).
    
4. The change in the `image_select` bit immediately switches the source of the RAM MUX (e.g., `ram1_dout` → `ram2_dout`).
    
5. As the `OLED.v` controller continues its loop, it begins pulling data from the other RAM during the next frame refresh, and the displayed image changes.
    

---

## 🔧 **Usage (Image Preparation)**

The `image_data.hex` and `image2.hex` files are required for the project to function.

1. **Image Preparation:** Prepare two black-and-white images with a resolution of 128x64 pixels (e.g., `logo.png`, `test.png`).
    
2. **Convert to Hex:** Use the `png_to_hex.py` script to convert these images.
    
    Bash
    
    ```
    # 1. Image 1
    INPUT_IMAGE_NAME = "logo.png"
    OUTPUT_HEX_FILE = "image_data.hex"
    
    # 2. Image 2
    INPUT_IMAGE_NAME = "test.png"
    OUTPUT_HEX_FILE = "image2.hex"
    ```
    
    > 💡 _The script automatically resizes images that are not 128x64_.
    
3. **Verification (Optional):** You can check if the `.hex` files appear correctly using the `hex_goruntule.py` script.
    
4. **Synthesis:** Add the `image_data.hex` and `image2.hex` files to your FPGA project and synthesize.
    
5. **Execution:**
    
    - When the FPGA starts, `image_data.hex` (Image 1) is displayed.
        
    - Pressing the button switches the screen to `image2.hex`.
        
    - Each press toggles between the two images.
        

---

## 📂 **Project Structure**

Plaintext

```
FPGA_OLED_Image_Toggle/
├── src/                  # Verilog source codes
│   ├── Top_OLED.v        # Main (Top) module
│   ├── OLED.v            # OLED 128x64 Driver
│   ├── I2C.v             # I2C Master Controller
│   ├── Simple_RAM.v      # Synchronous RAM Block
│   ├── debounce_ip_core.v # Button Noise Filter
│   └── Top_OLED.ccf      # FPGA Pin assignments
├── image_data.hex        # RAM Memory files
├── image2.hex
├── tools/                # Helper Python scripts
│   ├── png_to_hex.py
│   └── hex_goruntule.py
└── README.md
```

---

## 💡 **Code Structure**

### 1. <a href="Ssd1306-Oled-Control-With-I2C/src/Top_OLED.v"><em>Top_OLED.v</em></a>

- The main module of the project.
    
- Connects `debounce_ip_core`, two `Simple_RAM` modules, and the `OLED` controller.
    
- Contains the **toggle logic** that updates the `image_select` register when the button is pressed.
    
- Houses the **MUX** structure that selects between the two RAM outputs.
    

### 2. <a href="Ssd1306-Oled-Control-With-I2C/src/OLED.v"><em>OLED.v</em></a>

- The core controller for the display.
    
- Executes the OLED initialization sequence at start-up (`step 0–24`).
    
- Writes to the screen row by row using `page` and `col` counters.
    
- Generates the `addr` to be read from RAM.
    
- Sends data to the screen using the `I2C.v` module.
    

### 3. <a href="Ssd1306-Oled-Control-With-I2C/src/I2C.v"><em>I2C.v</em></a>

- An FSM (Finite State Machine) based **I2C Master** driver.
    
- Triggered by the `start` signal.
    
- Operates in **Command/Data** mode based on the `DCn` bit.
    
- Sends data serially via `SCL` and `SDA` pins.
    

### 4. <a href="Ssd1306-Oled-Control-With-I2C/src/Simple_RAM.v"><em>Simple_RAM.v</em></a>

- A parametric **synchronous RAM** module.
    
- Configured as 1024x8 (1KB) with a 10-bit address and 8-bit data.
    
- Loads `.hex` files during synthesis using `$readmemh`.
    

### 5. <a href="Ssd1306-Oled-Control-With-I2C/src/debounce_ip_core.v"><em>debounce_ip_core.v</em></a>

- A filter module that prevents **bouncing** in mechanical buttons.
    
- Produces an `out_valid` signal one clock pulse wide when the button is pressed.
    

---

## 📸 **Hardware Visuals**

### FPGA - OLED connection and first image:

<p align="center"> <img src="Images/ssd1306-2.jpg" style="display: block; margin: auto;"> </p>

### Switching to the second image via button:

<p align="center"> <img src="Images/ssd1306-1.jpg" style="display: block; margin: auto;"> </p>

---

## ⚡ **Summary Flow**

|Step|Operation|Source|
|---|---|---|
|1|FPGA resets. RAMs load `.hex` files. `image_select = 0`.|`Simple_RAM.v`, `Top_OLED.v`|
|2|`OLED.v` module initializes the screen over I2C (Commands sent).|`OLED.v`|
|3|`OLED.v` enters the image loop, generates `addr` (0–1023).|`OLED.v`|
|4|`Top_OLED.v` MUX selects `ram1_dout` data.|`Top_OLED.v`|
|5|Image 1 is drawn on the screen.|`OLED.v`, `I2C.v`|
|6|User presses the button.|`Top_OLED.ccf`|
|7|`debounce_ip_core` produces a clean `btn_valid` signal.|`debounce_ip_core.v`|
|8|`Top_OLED.v` sets `image_select` register to `1`.|`Top_OLED.v`|
|9|`Top_OLED.v` MUX now selects `ram2_dout` data.|`Top_OLED.v`|
|10|Image 2 is drawn on the screen.|`OLED.v`|

---

📘 **Prepared By:** **Salih Tekin Ayvacı**