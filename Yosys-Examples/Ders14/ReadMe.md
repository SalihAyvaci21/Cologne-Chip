# **UART Echo Project (FPGA)**

---

## 📖 Project Description

This project implements a **UART-based Echo application** on an FPGA.

The goal is for every byte received by the FPGA via UART to be sent back to the PC exactly as it was received. This ensures that every character sent through a terminal program (Putty, TeraTerm, etc.) is reflected back.

This application serves as a fundamental example of **UART communication on FPGA** and acts as a building block for more advanced UART-based protocols, such as calculators, sensor interfaces, or data logging systems.

---

## 🎯 Learning Objectives

- Understand the UART communication protocol (start/stop bits, baud rate).
    
- Utilize **receiver (RX)** and **transmitter (TX)** modules on an FPGA.
    
- Design a simple **Finite State Machine (FSM)** using Hardware Description Language (Verilog).
    
- Experience the processes of simulation, synthesis, and testing on hardware.
    
- Verify FPGA ↔ PC communication via UART.
    

---

## ⚙️ Algorithm

The operation of the UART Echo application consists of the following steps:

1. The **Receiver (RX)** module converts serial data coming from UART into a byte (`rx_byte`).
    
2. When the RX process is complete (`rx_dv=1`), the received byte is passed to the FSM.
    
3. The FSM loads this byte into the transmitter side (`tx_byte`).
    
4. The **Transmitter** (`tx_dv=1`) serializes the data again and sends it through the UART TX pin.
    
5. When the transmission is complete (`tx_done=1`), the FSM returns to the idle state.
    
6. The cycle continues indefinitely → every received byte is sent back (**echo**).
    

---

## 📂 Project Structure

Plaintext

```
UART-Echo/  
│── src/          # Source codes (.v)  
│   ├── uart.v         # Top module (echo FSM)  
│   ├── uart.ccf       # Pin assignment files (echo FSM) 
│   ├── receiver.v     # UART Receiver (RX)  
│   ├── transmitter.v  # UART Transmitter (TX)  
│── sim/          # Simulation files  
│   ├── uart_tb.v      # Testbench  
│── log/          # Simulation output files  
│── Makefile      # Build settings (optional)
```

---

## 📐 System Block Diagram

<p align="center"> <img src="Images/UART_Schema.drawio.png" style="display: block; margin: auto;"> </p>

---

## 🔌 Hardware Connection

The FPGA ↔ FT2232 ↔ PC connection is established as follows:

**PC (Putty) <--> FT2232 (USB-UART) <--> FPGA (RX/TX)**

- **Baudrate**: 115200 baud, 8N1
    
- **FPGA Clock**: 10 MHz
    
- **TX/RX Levels**: Must be 2.5V–3.3V compatible
    

---

## 📐 Pin Assignments (.ccf)

<a href="src/uart.ccf"><em>uart.ccf</em></a> 

---

## 💡 Code Structure: Echo FSM


<a href="src/uart.v"><em>uart.v</em></a> 

Through this FSM, **every received byte is sent back a single time**.

---

## 🧪 Simulation

**Testbench:** <a href="Uart/sim/iverilog/uart_tb.v"> <em>uart_tb code view</em> </a>



- A 10 MHz clock (100 ns period) is generated.
    
- Characters `"A"` and `"1"` are sent to the UART RX line.
    
- The FPGA echoes each character back.
    

### Expected Output:

- `"A"` received at RX → `"A"` sent from TX
    
- `"1"` received at RX → `"1"` sent from TX
    

📷 **GTKWAVE View** <p align="center"> <img src="Images/GTKWAVE.PNG" style="display: block; margin: auto;">

</p>

---

## 🖥️ Hardware Test (Putty)

- **Baudrate**: 115200
    
- **Connection**: FT2232 USB-UART → FPGA RX/TX
    

<p align="center"> <img src="Images/2025-10-03 16-09-03.gif" style="display: block; margin: auto;"> </p>

### Example Test:

- Type `"FPGA"` in the terminal → the same `"FPGA"` is returned.
    
- Any character or string sent is **echoed**.
    

📷 **Putty Screenshot** 
<p align="center">

<img src="Images/2025-10-03 16-09-03.gif" style="display: block; margin: auto;">	
</p>

---

📷 **FPGA Board Photo** <p align="center"> <img src="Images/WhatsApp Image 2025-10-03 at 16.15.01.jpeg" style="display: block; margin: auto;">

</p>

---

## ✅ Results and Evaluation

With this project:

- **UART communication** was successfully implemented on the FPGA.
    
- The **UART Echo** function was provided by sending back every received byte.
    
- Hardware tests (Putty terminal) were successfully verified.
    
- The project provides an **infrastructure** for more complex UART-based applications such as calculators, data protocols, and sensor communication.