
## **General Features**

**CCGM1A1**, **CCGM1A2**, and **CCGM1A4** chips operate as **multi-die** (pin-to-pin). This increases the system's **flexibility** and **extensibility**. **Initially, the CCGM1A1** distribution can be upgraded to more powerful models such as **CCGM1A2** or **CCGM1A4**, enabling the system to handle CPE or flip-flop capacity. During this upgrade, the system's processing capacity can be easily increased by **2x** or **4x** without any pcb replacement.


<p align="center">

<img src="Pasted image 20250717110521.png" >

<br>

</p>
<p align="center">

<img src="Pasted image 20250717110535.png" >

<br>

</p>
f A1 is insufficient and A2 is inserted into the same area, the codes entered remain stored in A1A. For A1B, the codes can be continued from where they left off without any integration.


## **Operating Modes**

**CCGM1A1/2/4** has three different operating modes:

- **LVDS (Low Power Mode)**: Provides low power consumption.
- **Eco Mode**: Energy-saving mode.
- **Speed Mode**: Provides high-speed data transmission.

Each mode balances **power consumption** and **performance** according to different application requirements.

## **CPE (Configurable Processing Element)**


**CPEs** are not limited to data processing; they also allow you to design versatile and flexible circuits** with high parallel processing capabilities. These features allow systems with high parallel processing capabilities. They can be configured to perform logic operations (AND, OR, XOR, etc.), arithmetic operations (addition, subtraction, multiplication), embedded RAM, and DSP operations.

**CPEs** include the following building blocks:

- **Dual 4-input LUT-2 tree**
- **8-input LUT-2 tree**
- **6-input MUX-4**
- Each CPE includes:
	- **1-bit or 2-bit full adder** – expandable horizontally/vertically.
	- **2 × 2-bit multiplier** – expandable to desired size.
	- **2 Flip-Flops or 2 Latches**.


CPE vs DSP:

| **GateMate CPE**                                          | **Klasik DSP Blokları** (Vivado/Quartus)                            |
| --------------------------------------------------------- | ------------------------------------------------------------------- |
| General processing (logic, arithmetic, bit manipulation)  | Dedicated for high-speed arithmetic (multiplication, addition, MAC) |
| Very high (LUT + FF + Carry Chain + Config bits)          | Limited (fixed functions: multiplier, accumulator, filtering)       |
| Small logic blocks (similar to LUT4/5)                    | Wide data buses, fixed multipliers and accumulators                 |
| More compact (flexible use due to general-purpose design) | Occupies larger area (includes dedicated circuits)                  |
| Tightly coupled with BRAM and interconnect                | High-bandwidth fixed data paths                                     |
| General logic, small arithmetic, flexible designs         | FIR/IIR filters, FFT, intensive mathematical operations             |

 <p align="center">

<img src="Pasted image 20250714023114.png" style="display: block; margin: auto;" width="400">

<br>
<em style="display:flex;justify-content:center">CPE Blok architecture</em>
</p>

Arbitrarily Scalable Multipliers 
- No fixed placement in CPE array 
- Optional input and output pipeline stages

**Performance**
- B(+A)-path is critica
<p align="center">

<img src="Pasted image 20250714023207.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center">18x8 output pipeline </em>

</p>



<p align="center">

<img src="Pasted image 20250717112853.png">

<br>

<em style="display:flex;justify-content:center">Verimliliği</em>

</p>

## **GPIO Features**

Each Block RAM cell can be configured as a single 40 KB memory or two independent 20 KB dual-port SRAM (DPSRAM) blocks. Both configurations support True Dual Port (TDP) and Simple Dual Port (SDP) modes.

- 162 GPIO pins.
- All GPIO pins support DDR and can be configured as single-ended or LVDS diff pairs.
- MIPI D-PHY compatible GPIOs allow for manual sampling and parameterization.
- I/O features include delay, pin assignment, driver powers, slew rate control, pull-up/pull-down configuration, and register mapping.

### **GPIO Cell**
Each bank contains **9 GPIO**.
- All GPIOs can be configured as single-ended or LVD pair.
- MIPI D-PHY compatible.
- Allows manual sampling and parameterization.
- I/O delay.
- Pin assignment.
- Driver powers.
- Slew rate control.
- Pull up/Pull down configuration.
- Register mapping inside the IO Cell.
- All GPIOs support DDR (double data rate).

<p align="center">

<img src="Pasted image 20250717130551.png" style="display: block; margin: auto;" width="400">

<br>

<em></em>

</p>
<p align="center">

<img src="capture.gif">

<br>

<em style="display:flex;justify-content:center">Also tested at 3.6V with GPIO acceleration. Aging is increased but depends on temperature.</em>

</p>

## **RAM Structure**

- **32x40Kbit RAM cells** are available (1,280Kbits in total).
- These RAM cells can be configured as **two-lane high-data-rate (True Dual Port - TDP mode)** or **single-lane high-capacity (Simple Dual Port - SDP mode)**.
- Because the RAM cells are **vertically connected**, signal latency is **reduced** and data processing is significantly faster.

### **Ram Block**

- Available with a single 40K cell or two independent 20K cells.
- Supports FIFO (synchronous or asynchronous).
- Provides debugging and correction features.
- Additionally, since all cells are vertically connected, signal latency is minimized.

<p align="center">

<img src="Pasted image 20250714023514.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center">Block RAM (BRAM) cell architecture on the GateMate A1/A2 FPGA.</em>

</p>

## **Data Processing Speed and Low Latency**

**The CCGM1A1** can process data very quickly thanks to its closely spaced memory cells. This architecture ensures data processing with very low latency. This translates to high-speed signal processing and fast throughput. A structure specifically designed for data flow and parallel processing increases system efficiency.

<p align="center">

<img src="Pasted image 20250717113045.png">

<br>

<em style="display:flex;justify-content:center">A1 CPE and RAM Placement</em>

</p>

## **Multiple Clock Sources and Parallel Processing Capability**

The CCGM1A1 features four different clock sources. This allows it to simultaneously process different operations in parallel, providing more synchronized operation. Parallel processing capabilities allow the system to operate at high speed and efficiency. This is particularly advantageous for applications working with large datasets.

<p align="center">

<img src="Pasted image 20250717120244.png">

<br>

<em style="display:flex;justify-content:center">There are 4 different clocks and each clock has 4 different phases.</em>

</p>


## **Operating Temperature Range**

**CCGM1A1/2/4** has a **extreme-resistant** structure that can operate between **-40°C and +125°C**.

## **Voltage Ranges**

- **Core voltage**: **0.9V to 1.1V** is a healthy operating range.
- **I/O voltage**: **1.2V to 2.5V** is a healthy operating range, but can withstand up to **3.3V**.
<p align="center">

<img src="Pasted image 20250714024254.png" style="display: block; margin: auto;" width="400">

<br>

<em style="display:flex;justify-content:center">Operating speed at different voltages</em>

</p>

## **Ser-Des**

Thanks to this protocol, **SerDes** can process data at **5 Gbit/s** and is compatible with **wireless communication protocols** such as **Wi-Fi**. This is a significant advantage for applications requiring **high-speed data transmission**.
<p align="center">
  <img src="Pasted image 20250714024549.png">
  <br>
  <em style="display:flex;justify-content:center">block diagram</em>
</p>

- To use LVDS SerDes, you must install a Serdes clock on the X3 Crystal (100MHz LVDS Clock: 511FCA100M000BAG).
- You must also fill the resistors.
- **Configurable Bus Width: 16/20-bit, 32/40-bit, or 64/80-bit bus configuration (for TX and RX)
- **8B/10B Encoding and Decoding: Used to maintain data integrity in the serial data stream.
- **Comma Detection and Byte Alignment: Provides synchronization in the data stream.
- **Clock and Data Recovery (CDR): Automatically corrects clock synchronization with data on the receiving end.
- **Pseudo-Random Bit Stream (PRBS) Generators and Controllers:** Supports PRBS generation and verification for error testing.
- **Phase-Adjusted FIFO (Elastic Buffer):** Compensates for phase shifts for clock correction.
- **Polarity Control:** Automatically manages polarity on TX and RX signals.

<p align="center">
  <img src="Pasted image 20250717125806.png">
  <br>
  <em style="display:flex;justify-content:center"x>Serdes: Its placement in the development kit</em>
</p>
## **Flow Diagram**

You can write code in one of the **HDL** languages and then synthesize it using **Yosys**. This allows for manual integration, preventing unnecessary data delays and power consumption. Because different intermediate applications are not used, this increases system stability.

<p align="center">

<img src="Pasted image 20250717105321.png" style="display: block; margin: auto;" width="400">

<br>

<em></em>

</p>

## **Input Sources**

- **Verilog Source / VHDL Source / **GHDL Source**

## **RTL Synthesis**

- This is where **Yosys** comes into play.
- Verilog code is converted to a **Verilog Netlist**.

## **GateMate Place & Route Software**

- **Netlist Conversion**
- The Verilog netlist is converted to a format suitable for GateMate.
- **Mapping**
- **Placement**
- **Routing**- Connections are created between these components.
- **Static Timing Analysis (STA) & SDF Generation**
- Timing analysis is performed.
- An SDF file is created (for timing data simulation).
- **Configuration File Generation**
- A **CFG File** that can be loaded onto the FPGA is created.

### **Outputs:**

- **SDF File:** Contains timing information.
- **Verilog Netlist:** After final layout/routing.
- **CFG File:** Configuration file required for loading into the FPGA.
## **Simulation Flow (Bottom Left Boxes)**

- **Customer Testbench**
- You create synthetic test vectors by writing your own testbench.
- **Simulator (Icarus, ModelSim, GateWave, etc.)**
- Simulate your code and catch errors early.
- **Simulation Results**
- A realistic simulation is created by including timing information (SDF).



## **Programming**

- **openFPGALoader or GateMate™ Programmer Scripts**
- CFG file is loaded into the FPGA.
- There is also support for **External Flash Programming**.

### **Summary**

The Yosys → Place&Route (GateMate) → STA → Simulation → CFG loading chain is **fully open source**.

For GateMate, loading is possible with **Synthesis** with Yosys, vendor-provided **P&R software**, and openFPGALoader.

<p align="center">
<img src="Pasted image 20250717130929.png">
</p>

|                    | Debug                                                        | Source            | System Load                              | License                        | Flexibility                        | Supported<br>FPGAs                                  |
| ------------------ | ------------------------------------------------------------ | ----------------- | ---------------------------------------- | ------------------------------ | ---------------------------------- | --------------------------------------------------- |
| Yosys +<br>nextpnr | Provides inspection at every stage of the flow.              | Fully open source | Lightweight, does not strain the system. | No license required, free use. | Every step can be customized.      | Lattice,<br>Cologne<br>Chip,<br>partially<br>Xilinx |
| Vivado             | Has its own debugging protocol, but hidden errors may exist. | Closed source.    | Requires 10–20GB download.               | License system applies.        | Fixed flow, limited customization. | Only<br>Xilinx<br>devices                           |
| Quartus            | Provides inspection at every stage of the flow.              | Fully open source | Requires 10–20GB download.               | No license required, free use. | Every step can be customized.      | Only<br>Lattice<br>devices                          |


Compared to FPGAs of similar capabilities:

<p align="center">
  <img src="Pasted image 20250714032907.png">
</p>





LINKLER 
- https://colognechip.com/programmable-logic/gatemate/#tab-313423
- https://colognechip.com/docs/ds1001-gatemate1-datasheet-latest.pdf
- https://github.com/enjoy-digital/litex
- https://github.com/YosysHQ/yosys
- https://github.com/YosysHQ/nextpnr
- https://github.com/ghdl/ghdl
- https://github.com/trabucayre/openFPGALoader
- https://github.com/YosysHQ/prjpeppercorn
