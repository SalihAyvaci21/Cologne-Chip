# **Debounce LED Counter – FPGA Application**

This project was developed on the **Gatemate CCGM1A1 V3.2A Eval Board**. The objective is to demonstrate the **"debounce" effect in button signals** and observe the difference between a **stable signal obtained using a debouncer** and a **noisy signal without one**.

---

## Project Objective

Mechanical buttons do not produce a single pulse when pressed or released; instead, they rapidly open and close, creating a **noisy (bouncing) signal**. With this project:

- **Without a Debouncer** → The LED counter performs erroneous increments.
    
- **With a Debouncer** → The LED counter increments stably only at the moment of an actual press.
    

---

## Code

The project consists of two fundamental modules:

1. **debounce_ip_core.v** → IP core that filters the button signal.
    
2. **debounce_led_counter_top.v** → Top module that controls the LEDs.
    

---

## Results

### **Button Signal Without Debouncing**

The unstable output of a mechanical button shows multiple triggers.

### **Filtered Signal With Debouncer**

The noise is cleaned, and only a single pulse is generated.

- **LED Counter Behavior:**
    
    - 8 LEDs light up in sequence.
        
    - On the 9th press, all LEDs turn off, and the counter resets.
        

---

## Flip-Flop (FF) Structure

The debouncer logic used in the project is based on a **Flip-Flop chain** and a counter:

- 32 Cells
    
- 10 I/O Ports
    
- 89 Nets
    

A stable button output is achieved using a shift-register and counter structure.

---

# **ReadMe (Setup and Configuration)**

There are two source files for this project:

1. **debounce_led_counter_top.v** → Top module (LED control logic).
    
2. **debounce_ip_core.v** → Debounce IP core (button filtering).
    

These files are processed by **Yosys** during the synthesis stage. Yosys reads the source files, identifies the `top` module, and executes the synthesis process accordingly.

### Makefile Settings

To ensure the correct top module is selected in the **Makefile**, the following command must be entered: `TOP = debounce_led_counter_top`

Additionally, all modules must be defined in the `run` file. To do this: `set SRC=src/debounce_led_counter_top.v src/debounce_ip_core.v`