# **Serial Adder Top**

**Task Description:** Adds two 8-bit numbers using the serial addition method. This project involves **bit-by-bit data shifting with shift registers, serial addition with a full adder, and FSM-controlled data flow.** Once addition is complete, the total is converted from binary to decimal using a **9-bit shift register.**

---

## 🎯 **Objectives**

- Understand the logic of serial addition by processing 8-bit numbers bit-by-bit.
    
- Experience parallel loading, shifting, and process control using a **Finite State Machine (FSM).**
    
- Observe the correct calculation of the sum using a D flip-flop for **carry bit** feedback.
    
- Obtain the serial addition result as a decimal value by accumulating it in a **9-bit shift register.**
    

---

## **Algorithm**

### 1️⃣ Initialization

1. The `start` signal is set to **1**.
    
2. The FSM transitions from the `IDLE` state to the `LOAD` state.
    
3. Shift registers A and B are **parallel loaded** with the input 8-bit numbers (`load_a = 1`, `load_b = 1`).
    

### 2️⃣ Serial Addition Loop

1. The FSM transitions to the `ADD` state, and `enable` is set to **1**.
    
2. Shift registers A and B **shift by 1 bit with every clock cycle**:
    
    - `a_bit` = LSB output of Shift Register A.
        
    - `b_bit` = LSB output of Shift Register B.
        
3. The Full Adder module generates a **1-bit sum and a new carry** using these 2 bits and the previous carry (`carry_q`):
    
    - $sum\_bit = a\_bit \oplus b\_bit \oplus carry\_q$
        
    - $carry\_bit = (a\_bit \cdot b\_bit) \lor (b\_bit \cdot carry\_q) \lor (a\_bit \cdot carry\_q)$
        
4. The `carry_q` is transferred to the next addition round via a D flip-flop.
    

### 3️⃣ Writing Results to the Shift Register

1. At every clock cycle, the `sum_bit` and `carry_bit` from the Full Adder are shifted into the **9-bit shift register**:
    
    - `shift_data[7:0]` → Bit-by-bit addition results.
        
    - `shift_data[8]` → The final carry bit.
        
2. This results in the **binary sum obtained as a 9-bit value.**
    

### 4️⃣ Completion of Addition

1. When the FSM bit counter (`bit_count`) reaches 8, it transitions to the `FIN` state.
    
2. The `done = 1` signal indicates that the addition is complete and the `shift_data` value is now reliable.
    
3. The user can read the `result` at this point (a decimal value between 0–511).
    

### 5️⃣ Summary Flow

|**State**|**Process**|
|---|---|
|**IDLE**|Wait for Start signal.|
|**LOAD**|Parallel load Shift Registers A and B.|
|**ADD**|Serial addition starts; carry feedback via DFF; 9-bit SR shifts.|
|**FIN**|Addition complete; `done = 1`; `result` is reliable.|

---

## **Block Diagram Description**

The block diagram illustrates the serial addition of two 8-bit numbers and the control flow. The main components and data paths of the module are as follows:

<p align="center">

<img src="Images/Pasted image 20250908165833.png" style="display: block; margin: auto;">

</p>

---

💡 **Note:**

- During addition, the shift register is continuously shifted (`enable = 1`).
    
- The `result` should not be read until `done = 1`; otherwise, incomplete or incorrect values will be retrieved.
    

---

## 📂 Project Structure

Plaintext

```
serial_adder_top/  
│── log/      # Log records
│── net/      # Netlist files
│── sim/      # Testbench files
│── src/      # Source code (.v)
│── Makefile  # Build settings
│── run.bat   # Execution script
```

---

## 💡 Code Structure

### Modules Used

1. **Full Adder (with Carry)**
    
    - Performs the serial addition operation.
        
    - `sum_o = a_i ^ b_i ^ c_i`
        
    - `c_o = (a_i & b_i) | (b_i & c_i) | (a_i & c_i)`
        

<p align="center">

<img src="Images/Pasted image 20250908163203.png" style="display: block; margin: auto;">

  

<a href="Led-Bounce-Up-Down-Counter/Led-Bounce-Up-Down-Counter/src/FullAdder.v">

<em style="display:flex;justify-content:center">Fulladder.v code view</em>

</a>

</p>

2. **Shift Register (8-bit)**
    
    - Converts the 8-bit input number into **serial binary** format.
        
    - One bit is shifted out every clock cycle and sent to the Full Adder.
        

<p align="center">

<img src="Images/Pasted image 20250908163408.png" style="display: block; margin: auto;">

  

<a href="/SerialAdderTop/src/shift_register_8bit.v">

<em style="display:flex;justify-content:center">Shift Register code view</em>

</a>

</p>

3. **Finite State Machine (FSM)**
    
    - Controls parallel loading, serial addition, and the completion processes.
        

<p align="center">

<img src="Images/Pasted image 20250908164046.png" style="display: block; margin: auto;">

  

<a href="/SerialAdderTop/src/Full_Adder_SR_FSM_tb.v">

<em style="display:flex;justify-content:center">Full Adder SR Testbench view</em>

</a>

</p>

4. **9-bit Shift Register (Result Storage)**
    
    - Records the 9-bit result along with every bit coming from the Full Adder and the final carry.
        
    - `result[7:0]` → sum bits, `result[8]` → carry bit.
        

<p align="center">

<img src="Images/Pasted image 20250908162928.png" style="display: block; margin: auto;">

  

<a href="/SerialAdderTop/src/shift_register_9bit.v">

<em style="display:flex;justify-content:center">Final Shift Register code view</em>

</a>

</p>

---

## 🔧 Usage

- Start addition with `start = 1`.
    
- When `done = 1`, the `result` shows the correct sum value.
    
- You can provide two numbers (`data_a`, `data_b`) via the testbench and read the outcome through `result`.
    

---

📌 This project is specifically designed to demonstrate **serial addition logic, FSM-controlled data flow, and binary-to-decimal conversion.**