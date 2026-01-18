# **Uart Tx Led**

**Task Description:** This project features a **counter that controls LEDs via a push button** and a **UART transmitter system that sends the LED status to a computer**. Each time the button is pressed, the LEDs light up in an active-low configuration, and the **number of illuminated LEDs is sent over UART in ASCII format**.

---

## 🎯 **Objectives**

- **LED control (active-low)** → The LED sequence changes as the button is pressed.
    
- Send the LED count to a computer using a **UART transmitter**.
    
- Control the **UART transmission process** using a Finite State Machine (FSM).
    
- Correctly count the number of illuminated LEDs within the **active-low LED logic**.
    

---

## **Algorithm**

### 1️⃣ Initialization

- The system resets when `rst_n = 0`.
    
- LEDs are set to their initial value (`8’hFF` = all off).
    

### 2️⃣ LED Control

- The `led_bounce_up_down_counter` module changes the LED pattern as the button is pressed.
    
- Since the LED output is active-low, a `0` bit indicates the LED is ON.
    

### 3️⃣ Finding the Number of Illuminated LEDs

- The `count_leds` function counts how many `0` bits are present in `led_out`.
    
- This count is converted to ASCII (`8’h30 + count`).
    

### 4️⃣ UART Transmission

- If `led_out` changes:
    
    - `tx_byte` is assigned the ASCII value.
        
    - The transmitter is started by setting `tx_dv = 1`.
        
- The process completes when the UART transmitter provides the `tx_done = 1` signal.
    

---

## 🔧 Usage

- Press the button on the FPGA → LEDs change.
    
- The number of illuminated LEDs (active-low) is sent to the computer as an ASCII character via UART.
    
- Example: If 3 LEDs are on → `'3'` (ASCII 0x33) is sent over UART.
    

---

## 📂 Project Structure

Plaintext

```
Uart_Tx_Led/  
│── src/      # Source code (.v)  
│── sim/      # Testbench files  
│── log/      # Simulation logs  
│── Makefile  # Build settings
```

---

## 💡 Code Structure

### Modules Used

1. **`led_bounce_up_down_counter`**
    
    - Changes the LED pattern based on push button input.
        

<a href="src/led_bounce_up_down_counter.v"><em>led_bounce_up_down_counter.v</em></a>

2. **`transmitter` (UART TX)**
    
    - Initiated by `tx_dv` and `tx_byte` inputs.
        
    - Signals completion via the `tx_done` output.
        
    - `CLKS_PER_BIT = 87` → 10 MHz / 115200 baud.
        

<a href="src/transmitter.v"><em>transmitter.v</em></a>

3. **`top_uart_led`**
    
    - Integration of the LED counter and UART transmitter.
        
    - Calculates the LED count and sends it via UART.
        

<a href="src/top_uart_led.v"><em>top_uart_led.v</em></a>


---

### ⚡ Summary Flow

|**Step**|**Process**|
|---|---|
|1|Initial LED position is assigned after reset|
|2|LED pattern changes via button press|
|3|Number of LEDs is calculated (`count_leds`)|
|4|Count is converted to ASCII and sent via UART|
|5|UART `tx_done` → FSM waits for the next LED change|

---

## 🔍 Expected Simulation

- **LED Output (led_out):** Changes with each button press.
    
- **UART TX (uart_tx):**
    
    - First press → `'1'` is sent.
        
    - Second press → `'2'` is sent.
        
    - Third press → `'3'` is sent.
        
- If you examine the `uart_tx` signal in GTKWAVE, you will see the bitstream at a baud rate of 115200.
    
