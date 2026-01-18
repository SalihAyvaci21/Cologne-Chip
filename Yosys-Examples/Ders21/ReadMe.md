# **FPGA SSD1306 OLED Driver (I2C)**

This project is a Verilog implementation developed to drive **SSD1306 OLED displays** with a 128x64 pixel resolution over the **I2C protocol**. The project utilizes a **"frame buffer"** architecture.

---

## **Key Features**

- **Display Support:** 128x64 SSD1306 OLED.
    
- **Interface:** I2C (Approximately 833kHz @ 10MHz system clock).
    
- **Architecture:** Frame buffer-based. The `OLED` module continuously reads from the image buffer while the main FSM writes to it.
    
- **Font Support:** Supports 8x8 bitmap fonts loaded from the `font8x8.hex` file.
    
- **Auto-Initialization:** Automatically starts after reset, clears the screen, and writes the text.
    
- **Text Rotation:** Texts are written into the frame buffer rotated 180 degrees.
    

---

## **Project Files**

- <a href="SSD1306/src/Top_OLED.v.v"><em>Top_OLED.v.v</em></a>: Main top-level module. Connects all sub-modules together.
    
- <a href="SSD1306/src/OLED.v"><em>OLED.v</em></a>: SSD1306 controller. Initializes the screen and continuously sends data read from the frame buffer to the display over I2C.
    
- <a href="SSD1306/src/I2C.v"><em>I2C.v</em></a>: Low-level I2C Master module. Transmits commands and data from the `OLED.v` module to the physical SDA/SCL lines.
    
- <a href="SSD1306/src/Frame_Buffer.v"><em>Frame_Buffer.v</em></a> (Module name `Simple_RAM`): 1024x8 (1KB) dual-port RAM. One port is read by `OLED.v`, and the other port is written by the `Top_OLED.v` FSM.
    
- <a href="SSD1306/src/Font_ROM.v"><em>Font_ROM.v</em></a>: 1024x8 ROM. Loads the `font8x8.hex` file into memory at synthesis time.
    
- <a href="SSD1306/font8x8.v"><em>font8x8.v</em></a>: Memory file containing bitmap data for 8x8 characters.
    
- <a href="SSD1306/src/debounce_ip_core.v"><em>debounce_ip_core.v</em></a>: A debounce module for buttons. (Note: This module is not actively used in the project).
    
- <a href="SSD1306/src/Top_OLED.ccf"><em>Top_OLED.ccf</em></a>: Constraint file containing FPGA pin assignments.
    

---

## **How It Works**

The project consists of two main parallel processes:

### **1. Text Writing FSM (`Top_OLED.v`)**

This process runs only once after a reset:

1. **Initialization:** When the system resets, the FSM automatically transitions to the `S_CLEAR_FB_LOOP` state.
    
2. **Clearing:** The FSM writes `8'h00` (black) to all 1024 addresses in the `Simple_RAM` (frame buffer).
    
3. **Character Selection:** After clearing, it enters the `S_SET_CHAR_PARAMS` state. Based on the `char_index` counter, it sequentially selects characters from the texts "nem: 25" and "sicaklik: 36".
    
4. **Font Reading:** It reads 8 horizontal row data segments (`reg_row0` ... `reg_row7`) from the `Font_ROM` using the selected character's ASCII code.
    
5. **Rotation and Writing:** It converts the 8 read 8-bit horizontal data segments into 8 8-bit vertical column data segments by rotating them 180 degrees. These vertical data segments are then written into the `Simple_RAM` (frame buffer).
    
6. **Loop:** Steps 3-5 are repeated until all characters are written.
    
7. **Completion:** Once all text is written, it moves to `S_DONE` and then `S_IDLE` states to remain on standby.
    

### **2. Screen Refresh (`OLED.v`)**

This process starts after reset and runs **continuously**:

1. **Initialization (Init):** The `OLED` module uses the `I2C` module to send a sequence of initialization commands to the SSD1306 (e.g., turn on display, adjust contrast, set addressing mode, etc.).
    
2. **Refresh Loop:** After initialization (from step 25 onwards), the module enters an infinite loop.
    
3. **Reading:** It sequentially reads all data in the `Simple_RAM` (frame buffer) by incrementing the `addr` counter from 0 to 1023.
    
4. **Transmission:** Every byte read (`ram_dout`) is sent to the OLED screen via the `I2C` module. This ensures the screen continuously reflects the image in the frame buffer.
    
5. **FPS Signal:** When all 1024 bytes are sent (one full frame), it toggles the state of the `FPS` output signal.
    

---

## **Requirements**

For the synthesis process, the `font8x8.hex` file must be in a location accessible by the `Font_ROM.v` module (usually in the main project directory).