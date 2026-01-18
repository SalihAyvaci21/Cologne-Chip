# **Direct Button → LED**

## **Task Description**

The purpose of this project is to observe the behavior of a **mechanical push button** by directly connecting the button signal to an LED output.  
Since **no debouncing** is applied in this circuit, **flickering, glitches, and signal instability** can be observed on the LED during fast press/release actions.

---

## 🎯 **Objective**

- Observe the real-world behavior of mechanical push buttons
    
- See how the LED reacts directly to a button press
    
- Experience the **bounce (mechanical noise)** problem firsthand
    
- Understand why a signal is unreliable without a debounce circuit
    

---

## 📂 Project Structure

direct_button_led/  
│── log/ # Log kayıtları  
│── net/ # Netlist dosyaları  
│── sim/ # Testbench dosyaları  
│── src/ # Kaynak kod (.v) + .ccf constraints  
│── Makefile # Build ayarları  
│── run.bat # Çalıştırma scripti

---

## 💡 Example Code

`timescale 1ns / 1ps

module Direct_Button_Led(
    input  wire clk,          // sistem clock (kullanılmıyor)
    input  wire push_button,  // buton girişi
    output wire led           // LED çıkışı
);

    // Buton doğrudan LED’e bağlandı
    assign led = push_button;

endmodule

<a href="Direct_Button_Led/src/Direct_Button_Led.v"><em> Direct_Button_Led.v</em> </a>


---

## ⚠️ Observed Issues

- **Button bounce:**  
    Even during a single press, the internal metal contacts of the button **bounce for several milliseconds**.
    
- **LED flicker / glitching:**  
    When the button is pressed and released quickly, the LED appears to flicker or toggle multiple times.
    
- **Signal instability:**  
    If this button were used as an input for a counter or toggle logic, a single press could be detected as **multiple presses**.
    

---

## 🔧 Solution

To solve this issue, a **debounce circuit** must be used:

- **Hardware debouncing:** RC filter, Schmitt trigger
    
- **FPGA / MCU debouncing:** shift-register-based filtering + single-pulse generation
    

---

📌 This project is a **basic but important example** designed to demonstrate **why a debounce circuit is necessary** in digital systems.