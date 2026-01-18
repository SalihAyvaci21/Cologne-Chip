# **LED Brightness Toggle**

Task Description:

This project performs a brightness toggle operation by controlling 8-bit LED outputs using PWM. LEDs initially light up at 50% brightness. When the button is pressed, brightness increases to 100%, and pressing it again returns it to 50%.

---

## 🎯 **Objectives**

- Control LED brightness using PWM.
    
- Toggle brightness via button inputs.
    
- Prevent button noise using **Debounce IP**.
    
- Understand the effect of duty cycle by observing the PWM signal on the FPGA.
    

---

## **Algorithm**

### 1️⃣ Initialization

1. The FPGA is reset (`rst_n = 0`).
    
2. LEDs initially light up at **50% brightness** (`toggle = 0`).
    
3. The PWM generator duty cycle is calculated: `duty = toggle ? 230 : 25`.
    

---

### 2️⃣ Button Detection and Toggle

1. The `debounce_ip_core` module cleans the button signal and **notifies the moment of change** via `db_valid`.
    
2. If `db_valid = 1`, the `toggle` register inverts:
    
    - toggle = 0 → 50% brightness
        
    - toggle = 1 → 100% brightness
        

---

### 3️⃣ PWM Calculation

- The `duty_reg` register is updated based on the toggle state:
    
    - `50%` → 25/255 (approximately 50% at 8-bit resolution)
        
    - `100%` → 230/255 (approximately 90–100% at 8-bit resolution)
        
- The `pwm_generator` module produces a PWM signal according to the duty cycle value.
    
- The PWM output `pwm_signal` is applied to all LEDs: `led_out = {8{pwm_signal}}`.
    

---

### 4️⃣ LED Output

- All LEDs are controlled by the same PWM signal.
    
- As the duty cycle changes, LED brightness increases or decreases.
    
- Every time the button is pressed, the LEDs **change brightness using toggle logic**.
    

---

## 🔧 Usage

- After programming the FPGA:
    
    1. Initially, LEDs light up at 50% brightness.
        
    2. When the button is pressed, LED brightness becomes 100%.
        
    3. When pressed again, it returns to 50% brightness.
        

---

## 📂 Project Structure

Plaintext

```
led_brightness_toggle/  
│── src/      # Source codes (.v)
│── sim/      # Testbench files
│── log/      # Simulation logs
│── Makefile  # Build settings
```

---

## 💡 Code Structure

### Modules Used

1. **Debounce IP Core**
    
    - Cleans button inputs and provides the change moment via `db_valid`.
        

<a href="src/debounce_ip_core.v"><em>debounce_ip_core.v</em></a>


2. **PWM Generator**
    
    - Controls the LED with a 10 MHz system clock and 1 kHz PWM frequency.
        
    - Generates an output signal based on the duty cycle register.
        


<a href="src/pwm_generator.v"><em>pwm_generator.v</em></a>


3. **Top Module (`led_brightness_toggle`)**
    
    - Combines the Debounce and PWM modules.
        
    - Changes LED brightness using toggle logic.
        


<a href="src/led_brightness_toggle.v"><em>led_brightness_toggle.v</em></a>


---

### ⚡ Summary Flow

|**Step**|**Process**|
|---|---|
|1|FPGA is reset, LED lights up at 50% brightness|
|2|Check if button is pressed (`db_valid`)|
|3|Toggle register is updated|
|4|PWM duty cycle is adjusted|
|5|PWM output is applied to all LEDs|
