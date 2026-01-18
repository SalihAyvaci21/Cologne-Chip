## UART RX LED Control

### 🎯 Objectives

This project controls the status of LEDs based on serial data received via UART:

- **When '1' (0x31) is sent** → All LEDs are **OFF**.
    
- **When any other character is received** → All LEDs are **ON**.
    
- LEDs are connected in an **active-low** configuration (`0 = LED ON`, `1 = LED OFF`).
    

---

### ⚙️ Algorithm

1. One byte of data is received via UART (`rx_byte`).
    
2. When `rx_dv` (data valid) becomes active, the incoming byte is checked.
    
3. If the byte is `'1' (0x31)` → `led_out = 8'b1111_1111` (all LEDs OFF).
    
4. Otherwise → `led_out = 8'b0000_0000` (all LEDs ON).
    

---

### 📂 Project Structure

Plaintext

```
Uart_rx_Led/  
│── src/      # Source code (.v)  
│── sim/      # Testbench files  
│── log/      # Simulation logs  
│── Makefile  # Build settings
```

---

### 💡 Code Structure

#### Modules Used

1. **UART Receiver (`receiver.v`)**
    
    - Captures the serial input and converts it to a parallel byte.
        
    - Validates data using the `rx_dv` signal.
        


<a href="src/receiver.v"><em>receiver.v</em></a> 
2. **Top Module (`uart_rx_led.v`)**
    
    - Evaluates the received byte and updates the `led_out` register according to the project logic.
        

<a href="src/uart_rx_led.v"><em>uart_rx_led.v</em></a> 

---

### 🔧 Usage

1. Send data from a PC to the FPGA via UART.
    
2. When `'1'` is sent, the LEDs will turn off.
    
3. When any other character is sent, the LEDs will turn on.
    

---

### 🖥️ Expected Simulation Output

Plaintext

```
>>> UART TX: '1'
LED Out = 11111111   // All LEDs OFF
>>> UART TX: 'A'
LED Out = 00000000   // All LEDs ON
>>> UART TX: '0'
LED Out = 00000000   // All LEDs ON
```

In GTKWAVE, you can observe the start, data, and stop bits on the `rx_serial` line, as well as the transition of the `led_out` signal.