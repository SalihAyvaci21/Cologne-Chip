# ⚡ FPGA Sine Wave PWM - "Breathing" LED Effect

## 🎯 Project Description

This project utilizes the **PWM (Pulse Width Modulation)** technique on an FPGA to vary LED brightness according to a **sine wave**. As a result, the LEDs fade in and out smoothly, creating a **"breathing"** effect.

- `sine_gen.v`: Sine wave generation (LUT-based)
    
- `pwm_driver.v`: PWM signal generation
    
- `top_module.v`: Top-level module integrating the entire system
    

---

## 🧠 Core Objectives

- Design an 8-bit resolution digital **sine wave generator** using Verilog.
    
- Control **LED brightness via PWM duty cycle** using these generated values.
    
- Create a breathing effect at a frequency of approximately **10 Hz**.
    
- Synchronize all LEDs to ensure a fluid visual effect.
    

---

## ⚙️ System Architecture

### 🟦 1. Sine Wave Generation

<p><a href="sinuslü ledler/src/sine_gen.v"><em> sine_gen.v</em> </a></p>

- A **clock divider** is used to derive a 10 Hz sine output from the 100 MHz system clock.
    
- Sine values are read sequentially from a 256-step **Look-Up Table (LUT)**.
    
- In each step, the `lut_index` increments, and the `sine_out` output produces a value between 0–255.
    

**Basic Flow:** clk → clk_divider → lut_index++ → sine_lut[lut_index] → sine_out (8-bit)

---

### 🟨 2. PWM Generation

<p><a href="sinuslü ledler/src/pwm_driver.v"><em> pwm_driver.v</em> </a></p>

- The `sine_out` value serves as the **duty cycle** for the PWM signal.
    
- An 8-bit `pwm_counter` continuously counts from 0–255.
    
- A comparison is made:
    
    - If `pwm_counter < sine_val` → `led_pwm_out = 1`
        
    - Otherwise → `led_pwm_out = 0`
        

Consequently, the **LED is brighter at high sine values** and dimmer at lower values.

---

### 🟩 3. Top-Level Connection

<p><a href="sinuslü ledler/src/top_module.v"><em> top_module.v</em> </a></p>

- Connects the `sine_gen` and `pwm_driver` modules.
    
- The single-bit PWM output is replicated across 8 LEDs using the expression `{8{led_pwm_signal}}`.
    
- Since the LEDs on the FPGA board are **active-low**, the signal is inverted using the `~` operator.
    

**Output:** `led_out = ~{8{led_pwm_signal}};`

---

## 🔄 Operation Flow

1. When the FPGA starts, `reset = 0` → all counters are cleared.
    
2. When `reset = 1`, the `clk_divider` and `pwm_counter` begin operating.
    
3. The sine wave is continuously scanned via the LUT.
    
4. The PWM duty cycle changes according to the sine value.
    
5. 8 LEDs demonstrate a synchronized **breathing effect** (~10 Hz).
    

---

## 📂 Project Directory Structure

Plaintext

```
FPGA_Sine_PWM/
│
├── hdl/                # Verilog source codes
│   ├── top_module.v    # Main (Top) module
│   ├── sine_gen.v      # Sine wave generator module
│   ├── pwm_driver.v    # PWM driver module
│   └── pwm_gen.v       # Debugging module (includes ILA)
│
├── constraints/
│   └── top_module.ccf  # FPGA pin assignments
│
└── sim/
    └── tb_top_module.v # Testbench (simulation file)
```

---

## 🔧 Hardware Information

- **FPGA Development Board:** GateMate ccgm1a1 EvaBoard V3.2A
    
- **System Clock:** 10 MHz
    
- **PWM Resolution:** 8-bit
    
- **Sine LUT Size:** 256 points
    
- **Sine Frequency:** ~10 Hz
    
- **Number of LEDs:** 8 (active-low)
    

---

## 🚀 Observation

Once the program is loaded onto the FPGA:

- When the reset is released (`reset = 1`), the system starts.
    
- All LEDs **increase and decrease in brightness** simultaneously with smooth transitions.
    

The observed effect is created by converting a sine wave into **PWM brightness**.

---

## Test Images

<p align="center"> <img src="Images/sin_tb-photo1.png" style="display: block; margin: auto;"> </p> <p align="center"> <img src="Images/sin_tb-photo.png" style="display: block; margin: auto;"> </p>

---

## Demo Visuals

<p align="center"> <img src="Images/giriş_videom.gif" style="display: block; margin: auto;"> </p>

---

## 💬 Summary

This project combines the principles of **digital sine wave generation** and **PWM-based analog-like control** on an FPGA. The resulting breathing LED effect is an ideal FPGA starter project that demonstrates both **PWM fundamentals** and **digital wave synthesis**.

---

### 👤 Prepared By

**Salih Tekin Ayvacı**

Electrical & Electronics Engineer
