# **Counter_LED**

**Task Description:** To control an LED array on an FPGA with a **forward-backward chase (sliding)** effect. In default mode, the LEDs flash at **1-second intervals**. Speed modes are toggled using a push-button integrated with a debounce IP core:

- **Default:** 1 second
    
- **1st Press:** 0.5 seconds
    
- **2nd Press:** 0.25 seconds
    
- **3rd Press:** Returns to 1 second
    

---

## 🎯 **Objectives**

- Understand the logic of a **clock divider**.
    
- Implement a forward-backward chase effect on an LED array.
    
- Enable **multi-speed control** via a button.
    
- Clean button noise using a Debounce IP core.
    
- Generate a single pulse for control functionality.
    

---

## Algorithm Steps

1. **Debounce IP Core**
    
    - A debounce module is used to prevent mechanical bouncing of the button.
        
    - The `out_valid` signal generates a single pulse for every button press.
        
2. **Speed Mode**
    
    - Mode 0 → 1 second
        
    - Mode 1 → 0.5 seconds
        
    - Mode 2 → 0.25 seconds
        
    - The system cycles through modes 0 → 1 → 2 → 0 with each button press.
        
3. **Clock Divider**
    
    - A clock pulse is generated according to the selected mode using a counter.
        
    - The LED shift operation occurs whenever a pulse is received.
        
4. **LED Chase Forward-Backward**
    
    - `led_index` determines the position of the active LED.
        
    - `dir` stores the direction information (0=forward, 1=backward).
        
    - When the LED reaches the far right, it reverses direction; when it reaches the far left, it moves forward again.
        

---

## 📂 Project Structure

Plaintext

```
counter_led/  
│── log/      # Log records
│── net/      # Netlist files resulting from synthesis
│── sim/      # Testbench files (for Icarus Verilog / iverilog)
│── src/      # Source codes (.v / .vhd) + .ccf constraints files
│── Makefile  # Build settings
│── run.bat   # Execution script
```

**Note:**

- The `TOP` variable in the `Makefile` must match the **top module** name.
    
- The `.ccf` file name must be identical to the top module name.
    

---

## ⚙️ Makefile Content

Makefile

```
include ../config.mk

TOP = Counter_led

PRFLAGS += -ccf src/$(TOP).ccf -cCP
```

---

## ⚡ Run.bat Content

Kod snippet'i

```
:: toolchain
set YOSYS=../../bin/yosys/yosys.exe
set PR=../../bin/p_r/p_r.exe
set OFL=../../bin/openFPGALoader/openFPGALoader.exe

:: project name and sources
set TOP=Counter_led
set SRC=src/Counter_led.v src/debounce_ip_core.v
set VHDL_SRC=
set LOG=0
```

---

## 💡 Example Code: Counter_led

Verilog

```
`timescale 1ns / 1ps
// DEMSAY ELECTRONICS - R&D
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module Counter_led (
    input  wire clk,           // 10 MHz system clock input
    input  wire rst,           // reset (active low) signal
    input  wire push_button,   // button input to change speed
    output reg  [7:0] led_out  // 8-bit LED output (active-low LEDs)
);
    // ...
endmodule
```

---

## 📌 Constraints File (`.ccf`)

Plaintext

```
# Clock input (e.g., 10 MHz from onboard oscillator)
Net "clk"         Loc = "IO_SB_A8";      # Clock pin

# Push-button input (SW3)
Net "push_button" Loc = "IO_EB_B0";      # Active-low mechanical button

# 8-bit active-low LED outputs
Net "led_out[0]"  Loc = "IO_EB_B1";      # D1
Net "led_out[1]"  Loc = "IO_EB_B2";      # D2
Net "led_out[2]"  Loc = "IO_EB_B3";      # D3
Net "led_out[3]"  Loc = "IO_EB_B4";      # D4
Net "led_out[4]"  Loc = "IO_EB_B5";      # D5
Net "led_out[5]"  Loc = "IO_EB_B6";      # D6
Net "led_out[6]"  Loc = "IO_EB_B7";      # D7
Net "led_out[7]"  Loc = "IO_EB_B8";      # D8
```
