# **Chase&Toggle**

**Task Description:** To control an LED array on an FPGA. In the default mode, LEDs flash with a back-and-forth effect (**Chase Mode**). When switched to **Toggle Mode** via a push-button, all LEDs are turned on or off simultaneously.

---

## 🎯 **Objectives**

- Use counters and learn clock division logic.
    
- Implement visual effects (chase) on an LED array.
    
- Learn to manage multiple control states using a single button (toggle).
    
- Clean button noise using a Debounce IP core.
    
- Generate a single pulse to provide control functionality.
    

---

## Algorithm Steps

1. **Debounce IP Core**
    
    - A debounce IP core was written to ensure stable button operation.
        
2. **Definitions**
    
    - `Toggle_mode`: A parameter that detects whether the button has been pressed to switch between modes.
        
    - `Toggle`: A parameter used to assign a state different from the previous one upon a button press.
        
    - `Counter`: A counter definition that determines the timing between the first 4 LEDs and the last 4 LEDs.
        
3. **Button Tracking**
    
    - Using a `case` structure, the system operates based on the last saved toggle value; this allows LEDs to turn on with one press and off with another.
        
    - The LED pattern changes when the counter reaches a specific value.
        
    - This creates a sequential flashing effect → a light effect sliding from right to left or left to right.
        

---

## 📂 Project Structure

Plaintext

```
chase_toggle/  
│── log/      # Log records
│── net/      # Netlist files resulting from synthesis
│── sim/      # Testbench files (for Icarus Verilog / iverilog)
│── src/      # Source codes (.v / .vhd) + .ccf constraints files
│── Makefile  # Build settings
│── run.bat   # Execution script
```

**Note:**

- The `TOP` variable in the `Makefile` must match the **top module** name.
    
- The `.ccf` file name must be exactly the same as the top module name.
    

---

## ⚙️ Makefile Content

Makefile

```
include ../config.mk

TOP = Chase&Toggle

PRFLAGS += -ccf src/$(TOP).ccf -cCP
```

---

## ⚡ Run.bat Content

Kod snippet'i

```
:: toolchain
set YOSYS=../../bin/yosys/yosys.exe
set PR=../../bin/p_r/p_r.exe
set OFL=../../bin/openFPGALoader/openFPGALoader.exe

:: project name and sources
set TOP=Chase&Toggle
set SRC=src/Chase&Toggle.v src/debounce_ip_core.v
set VHDL_SRC=
set LOG=0
```

_If the project consists of multiple files:_ `set SRC=src/Chase&Toggle.v src/debounce_ip_core.v`

---

## 💡 Example Code: Chase&Toggle

Verilog

```
`timescale 1ns / 1ps
// DEMSAY ELECTRONICS - R&D
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module Chase&Toggle(
    input  wire clk,           // 10 MHz system clock input
    input  wire rst,           // reset (active low) signal
    input  wire push_button,   // button input (LED on/off control)
    output reg  [7:0] led_out  // 8-bit LED output (active-low LEDs)
);

    // =======================
    // Debounce Module Connection
    // =======================
    wire debounced_button;     // cleaned version of the button (bouncing removed)
    wire out_valid;            // 1-clock wide pulse generated from a single press

    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000), // System clock frequency = 10 MHz
        .SHIFT_LEN(3),            // Shift register length used for debouncing
        .IS_PULLUP(0)             // Indicates the button is connected as pull-down
    ) debounce_inst (
        .clk(clk),                // clock input
        .push_button(push_button),// raw button input
        .out_valid(out_valid),    // valid button pulse output
        .debounced_button(debounced_button) // stable button output
    );

    reg [26:0] counter;        // long counter (can be used to generate 0.5s timing, etc.)
    reg toggle;                // bit used to change the LED pattern
    reg toggle_mode;           // 0=normal mode, 1=toggle mode (toggled by button)

    // ======================
    // Counter
    // ======================
    always @(posedge clk or negedge rst) begin
        if (!rst)               // counter resets when reset is active
            counter <= 0;
        else
            counter <= counter + 1'b1; // counter increments every clock cycle
    end

    // =======================
    // Toggle Mode (via Button)
    // =======================
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            toggle_mode <= 0;          // reset → normal mode
        end else if (out_valid) begin
            toggle_mode <= ~toggle_mode; // change mode when button is pressed
        end
    end

    // =======================
    // LED Output Control
    // =======================
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            led_out <= 8'b1111_1111; // reset → all LEDs off
        end else if (toggle_mode) begin
            // When Toggle mode is active: LEDs change according to toggle state
            case (toggle)
                1'b0: begin 
                    if (toggle == 1'b0) begin
                        led_out <= 8'b0000_0000; // all LEDs on
                    end 
                    if (out_valid == 1'b1) begin
                        toggle  <= 1'b1;        // if button is pressed again, set toggle to 1
                    end
                end
                1'b1: begin 
                    if (toggle == 1'b1) begin
                        led_out <= 8'b1111_1111; // all LEDs off
                    end 
                    if (out_valid == 1'b1) begin
                        toggle  <= 1'b0;        // if button is pressed again, set toggle to 0
                    end
                end
            endcase
        end else begin
            // In Normal mode: Flashing between LED0..3 and LED4..7
            if (counter[26] == 1'b1)
                led_out <= 8'b1111_0000; // LED0..3 OFF, LED4..7 ON
            else
                led_out <= 8'b0000_1111; // LED0..3 ON, LED4..7 OFF
        end
    end

endmodule
```


<a href="Chase_Toggle/src/Chase_Toggle.v"><em> Chase_Toggle.v</em> </a>

---

## 📌 Constraints File (`.ccf`)

Plaintext

```
# Clock input (e.g., 10 MHz from onboard oscillator)
Net "clk"         Loc = "IO_SB_A8";      # Clock pin

# Push-button input (SW3)
Net "push_button" Loc = "IO_EB_B0";      # Active-low mechanical button

# 8-bit active-low LED outputs
Net "led_out[0]"  Loc = "IO_EB_B1";      # D1
Net "led_out[1]"  Loc = "IO_EB_B2";      # D2
Net "led_out[2]"  Loc = "IO_EB_B3";      # D3
Net "led_out[3]"  Loc = "IO_EB_B4";      # D4
Net "led_out[4]"  Loc = "IO_EB_B5";      # D5
Net "led_out[5]"  Loc = "IO_EB_B6";      # D6
Net "led_out[6]"  Loc = "IO_EB_B7";      # D7
Net "led_out[7]"  Loc = "IO_EB_B8";      # D8
```


<a href="src/Chase_Toggle.ccf"><em> Chase_Toggle.ccf</em> </a>
