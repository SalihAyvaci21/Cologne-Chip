# **Clock Divider (Led_per_sec + Clockworks)**

**Task Description:** To observe the sequential lighting/extinguishing pattern of LEDs by dividing and slowing down the system clock on the FPGA using the **Clockworks** module.

In this circuit, **8 LEDs** light up in sequence and restart at a certain point, making the operation of clock division visible to the eye.

---

## 🎯 **Objectives**

- Learn the logic of **clock division (gearbox)** using the Clockworks module.
    
- Understand how the reset mechanism functions in FPGA designs.
    
- Observe the sequential lighting pattern of LEDs according to a binary counter.
    
- Comprehend how to adjust clock speeds in FPGA simulations.
    

---

## 📂 Project Structure

Plaintext

```
clock_divider/  
│── log/      # Log records
│── net/      # Netlist files
│── sim/      # Testbench files (Led_per_sec_tb.v)
│── src/      # Source code (Led_per_sec.v, clockworks.v, pll_gatemate.v)
│── Makefile  # Build settings (yosys, nextpnr, openFPGALoader, icarus)
```

---

## 💡 Example Code

**Led_per_sec.v (Top-level):** <a href="Led_per_sec/src/Led_per_sec.v"><em> Led_per_sec.v</em> </a>

---

**Led_per_sec_tb.v (Testbench):** <a href="Led_per_sec/src/Led_per_sec.tb"><em> Led_per_sec.tb</em> </a>

---

## ⚡ Expected Behavior

- The LEDs light up in sequence: `1 → 1,2 → 1,2,3 → 1,2 → 1 → 1,2,3,4` and then restart from the beginning.
    
- Since it is a binary counter, the LED pattern flows in a regular manner.
    
- Thanks to clock division, the LED transitions can be easily tracked by eye.
    

---

## 🔧 Simulation and Execution

### Generating the Bitstream

`run.bat synth_vlog`

### Simulation

`run.bat sim_vlog`

**Sample output:** `LEDS = 11111111 LEDS = 11111110 LEDS = 11111101 ...`

### Uploading to FPGA

`run.bat jtag`

You should observe the counter pattern on the LEDs ✅

---

## 📝 Notes

- UART RX/TX ports are currently unused (placeholders for future steps).
    
- The LED blinking speed can be adjusted by changing the `SLOW` parameter of the Clockworks module.
    
- Since the reset button (SW3) on the FPGA is active-low, it is connected as `~RESET`.
    

---

📌 This project serves as a fundamental example for learning **clock division and reset control** on an FPGA.