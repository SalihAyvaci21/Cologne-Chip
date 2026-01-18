# **LED Brightness 3-Phase**

**Task Description:** This project is designed to **simulate 3-phase motor driving logic using LEDs**. By generating three separate PWM signals, the LEDs are operated at different duty cycles in a specific sequence:

1. **Phase 1:** 50%, **Phase 2:** 100%, **Phase 3:** 0%
    
2. **Phase 1:** 0%, **Phase 2:** 50%, **Phase 3:** 100%
    
3. **Phase 1:** 100%, **Phase 2:** 0%, **Phase 3:** 50%
    

Each phase combination is applied sequentially for 0.5 seconds by an **FSM (Finite State Machine)**.

---

## 🎯 **Objectives**

- Control three separate LED outputs using PWM.
    
- Sequentially generate 3 different duty cycle combinations using an FSM.
    
- **Test 3-phase motor driving logic via LEDs.**
    
- Observe the effects of PWM duty cycles on hardware.
    

---

## **Algorithm**

### 1️⃣ Initialization

- `rst_n = 0` → All counters and states are reset.
    
- Initially, `state = 0` and duty cycles are assigned.
    

### 2️⃣ FSM State Machine

- Each state remains active for 0.5 seconds.
    
- As the state increments, the duty cycle values change.
    
- State cycle: `0 → 1 → 2 → 0`.
    

### 3️⃣ PWM Generation

- A separate `pwm_generator` instance runs for each LED.
    
- The `duty_cycle` is assigned by the FSM.
    
- Consequently, the LED outputs illuminate as PWM signals.
    

---

## 🔧 Usage

- When the program is loaded onto the FPGA, the LEDs blink at different brightness levels in sequence.
    
- The FSM changes state every 0.5 seconds.
    
- The LEDs illuminate according to the following table:
    

|**State**|**LED1 Duty**|**LED2 Duty**|**LED3 Duty**|
|---|---|---|---|
|0|50%|100%|0%|
|1|0%|50%|100%|
|2|100%|0%|50%|

---

## 📂 Project Structure

Plaintext

```
led_brightness_3phase/  
│── src/      # Source code (.v)  
│── sim/      # Testbench files  
│── log/      # Simulation logs  
│── Makefile  # Build settings
```

---

## 💡 Code Structure

### Modules Used

1. **PWM Generator**
    
    - Generates 1 kHz PWM with a 10 MHz system clock.
        
    - Features 8-bit duty cycle control.
        

<a href="src/pwm_generator.v"><em>pwm_generator.v</em></a>

2. **FSM (State Machine)**
    
    - Changes LED duty cycles sequentially through a 3-state cycle.
        
    - Each state is valid for 0.5 seconds.
        
3. **Top Module (`led_brightness_3phase`)**
    
    - Combines the FSM and 3 PWM generators.
        
    - The LEDs illuminate based on 3-phase motor driving logic.
        

<a href="src/led_brightness_3phase.v"><em>led_brightness_3phase.v</em></a>

---

### ⚡ Summary Flow

|**Step**|**Process**|
|---|---|
|1|Reset → FSM state = 0|
|2|PWM duty values are assigned|
|3|LEDs illuminate with the duty cycle|
|4|When the 0.5s counter elapses, the FSM transitions to the next state|
|5|The cycle continues indefinitely|

---

## 🔍 Expected Simulation Waveform

- **LED1, LED2, and LED3 PWM signals** produce pulses of different widths according to the duty cycles.
    
- As the FSM state changes, the duty cycle combinations update in order:
    

|**Time (sec)**|**State**|**LED1 Duty**|**LED2 Duty**|**LED3 Duty**|
|---|---|---|---|---|
|0.0 – 0.5|0|50%|100%|0%|
|0.5 – 1.0|1|0%|50%|100%|
|1.0 – 1.5|2|100%|0%|50%|
|1.5 – 2.0|0|50%|100%|0%|
