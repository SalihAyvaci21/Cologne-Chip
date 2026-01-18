# **Led Blink8_1**

**Task Description:** To practice basic LED blinking on an FPGA. First, a single LED will be controlled, followed by an 8-bit LED array.

## 🎯 **Objectives**

- Learn how to use the ToolChain.
    
- Learn bit-level LED control.
    
- Define LED pins using a Constraints file.
    
- Familiarize yourself with the basic Verilog module structure.
    
- Clean button noise using a debouncer.
    
- Control LEDs by generating a single pulse with edge detection.
    

---

## 📂 Project Structure

Plaintext

```
Blink8_1/
│── log/      # Log records
│── net/      # Netlist files resulting from synthesis
│── sim/      # Testbench files (for Icarus Verilog / iverilog)
│── src/      # Source codes (.v / .vhd) + .ccf constraints files
│── Makefile  # Build settings
│── run.bat   # Execution script
```

**Note:**

- The `TOP` variable inside the `Makefile` must match the **top module** name.
    
- The `.ccf` file name must be identical to the top module name.
    

---

## ⚙️ Makefile Content

Makefile

```
include ../config.mk

PRFLAGS += -ccf src/$(TOP).ccf -cCP
TOP = Blink8_1
```

---

## ⚡ Run.bat Content

Kod snippet'i

```
@echo off

:: toolchain
set YOSYS=../../bin/yosys/yosys.exe
set PR=../../bin/p_r/p_r.exe
set OFL=../../bin/openFPGALoader/openFPGALoader.exe

:: project name and sources
set TOP=Blink8_1
set VLOG_SRC=src/Blink8_1.v
set LOG=0

:: Place&Route arguments
set PRFLAGS=--ccf src/%TOP%.ccf -cCP
```

If the project consists of multiple files:

Kod snippet'i

```
set VLOG_SRC=src/top.v src/ip_core.v src/ip_corex.v
set VHDL_SRC=src/top.vhd src/ip_core.vhd src/ip_corex.vhd
```

---

## ▶️ Usage

### Synthesis

`run.bat synth`

- FPGA source files are synthesized.
    
- Synthesis **netlist** files are generated in the `net/` folder.
    
- Resource usage information, such as LUTs and flip-flops, can be viewed here.
    

### Implementation

`run.bat impl`

- The implementation process begins.
    
- The `top_00.cfg` file is generated.
    
- If you encounter errors, check the `log/` folder.
    

### Uploading to FPGA

- **Via JTAG:**
    
    `run.bat jtag` SW1 → `11XX`
    
- **Via SPI:**
    
    `run.bat spi` SW1 → `01XX`
    
- **Writing to Flash (Persistent):**
    
    `run.bat jtag-flash` or `run.bat spi-flash` After the Flash writing is complete, reset the FPGA; the code will start automatically.
    

---

## Example Code: Blink8_1

Verilog

```
`timescale 1ns / 1ps
// DEMSAY ELECTRONICS - R&D
// Salih Tekin Ayvaci - FIELD APPLICATION ENGINEER
// 12.06.2025

module Blink8_1(
    input  wire clk,          // 10 MHz system clock
    input  wire rst,          // reset (active low)
    input  wire push_button,  // button input
    output reg  [7:0] led     // active-low LED outputs
);

    // ======================
    // Debounce Module
    // ======================
    wire debounced_button;
    wire out_valid;

    debounce_ip_core #(
        .CLK_FREQ_HZ(10_000_000), // 10 MHz system clock
        .SHIFT_LEN(3),            // 3-bit filter
        .IS_PULLUP(0)             // pull-down button
    ) debounce_inst (
        .clk(clk),
        .push_button(push_button),
        .out_valid(out_valid),          // pulse when button is pressed
        .debounced_button(debounced_button) // stable button value
    );

    // ======================
    // PLL (10 MHz → 100 MHz)
    // ======================
    reg [26:0] counter;

    wire clk270, clk180, clk90, clk0, usr_ref_out;
    wire usr_pll_lock_stdy, usr_pll_lock;

    CC_PLL #(
        .REF_CLK("10.0"),
        .OUT_CLK("100.0"),
        .PERF_MD("ECONOMY"),
        .LOW_JITTER(1),
        .CI_FILTER_CONST(2),
        .CP_FILTER_CONST(4)
    ) pll_inst (
        .CLK_REF(clk), .CLK_FEEDBACK(1'b0), .USR_CLK_REF(1'b0),
        .USR_LOCKED_STDY_RST(1'b0), .USR_PLL_LOCKED_STDY(usr_pll_lock_stdy), .USR_PLL_LOCKED(usr_pll_lock),
        .CLK270(clk270), .CLK180(clk180), .CLK90(clk90), .CLK0(clk0), .CLK_REF_OUT(usr_ref_out)
    );

    // ======================
    // Counter
    // ======================
    always @(posedge clk0) begin
        if (!rst)
            counter <= 0;
        else
            counter <= counter + 1'b1;
    end

    // ======================
    // LED Control
    // ======================
    always @(*) begin
        if (!rst) begin
            led = 8'b1111_1111;  // reset → all OFF
        end else if (counter[26] == 1'b1) begin
            led = 8'b0000_0000;  // normal state → all LEDs ON
        end else begin
            led = 8'b1111_1110;  // normal state → only LED0 ON
        end
    end

endmodule
```

**Description:**

- In this design, the 10 MHz input clock is increased to 100 MHz using a PLL.
    
- The LEDs blink at specific intervals thanks to the counter.
    
- When the reset button is pressed, the counter resets, and the LED sequence restarts.
    

---

## Constraints File (`.ccf`)

In FPGA design, if the **signals in your Verilog/VHDL code** are not mapped to actual physical pins on the hardware, peripherals like LEDs, buttons, or UART will not function.

A **Constraint Configuration File (.ccf)** is used to perform this mapping.

### Example: `Blink8_1.ccf`

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

**Explanations:**

- `Net "clk"` → Defines the **system clock pin** on the FPGA (e.g., 10 MHz external crystal).
    
- `Net "rst"` → Connects to the **SW3 button** on the board. Used as a reset signal.
    
- `Net "led"` → Connects to the **D1 LED output** on the FPGA.
    

Note: The names (`clk`, `rst`, `led`) must be **identical to the port names in the Verilog top module**.