# **Button → LED Toggle (Debounced)**

## **Task Description**

This project demonstrates **LED control using a debounced push-button signal** on an FPGA.  
Each time the button is pressed, the LED state is **toggled (ON/OFF)**.  
Thanks to the Debounce IP Core, **no noise, glitches, or signal drifting** are observed during fast press/release actions.

---

## 🎯 **Objective**

- Demonstrate how button noise (bounce) is filtered on the FPGA side
    
- Generate a **single, clean pulse** using `debounce_ip_core`
    
- Implement toggle logic (LED state changes on each press)
    
- Learn **active-low LED control**
    

---

## 📂 Project Structure

button_led_toggle/  
│── log/ # Log kayıtları  
│── net/ # Sentez sonucu netlist dosyaları  
│── sim/ # Testbench dosyaları  
│── src/ # Kaynak kodlar (.v) + .ccf constraints  
│── Makefile # Build ayarları  
│── run.bat # Çalıştırma scripti

---

## 💡 Example Code

`timescale 1ns / 1ps
// DEMSAY ELEKTRONİK - ARGE
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module ButtonLedToggle (
    input  wire clk,          // 10 MHz sistem clock
    input  wire rst_n,        // reset (aktif düşük)
    input  wire push_button,  // ham buton girişi
    output reg  led_out       // LED çıkışı (aktif-low)
);

    // ======================
    // Debouncer
    // ======================
    wire debounced_button;
    wire out_valid; // butona geçerli basış geldiğinde 1 clock pulse

    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000),
        .SHIFT_LEN(3),
        .IS_PULLUP(0)             
    ) debounce_inst (
        .clk(clk),
        .rst_n(rst_n),
        .push_button(push_button),
        .out_valid(out_valid),
        .debounced_button(debounced_button)
    );

    // ======================
    // LED Toggle
    // ======================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_out <= 1'b1;  // Reset → LED kapalı (aktif-low)
        end 
        else if (out_valid && debounced_button) begin
            // sadece basıldığında toggle (bırakmada değil)
            led_out <= ~led_out;
        end
    end

endmodule  

<a href="Debounced_direck_Button_Led/src/ButtonLedToggle.v"><em> ButtonLedToggle.v</em> </a>


---

## ⚠️ Why Debounce?

- **Without debounce:**  
    During fast press/release actions, the LED **flickers unpredictably**.  
    FPGA counters or FSMs may be triggered incorrectly (single press → 2–3 toggles).
    
- **With debounce:**  
    Each button press generates **exactly one clean pulse**.  
    The LED toggles **reliably and stably**, with no glitches.
    

---

## 📌 Constraint File (`.ccf`)

 **Clock input (10 MHz)**
Net "clk"         Loc = "IO_SB_A8";    

 **Push-button input**
Net "push_button" Loc = "IO_EB_B0";    

 **LED output (aktif-low)**
Net "led_out"     Loc = "IO_EB_B1";    

<a href="Debounced_direck_Button_Led/src/ButtonLedToggle.ccf"><em> ButtonLedToggle.ccf</em> </a>

---

📌 This project is an **enhanced version of the previous _Direct_Button_Led_ example**.  
By introducing a debouncer, the signal becomes **clean and stable**, ensuring the LED never flickers or misbehaves.