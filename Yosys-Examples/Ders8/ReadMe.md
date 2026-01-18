# Gatemate Cologne Chip Toolchain: Simulation Guide on Windows

This guide explains step-by-step how to simulate a Verilog project on Windows using the **Icarus Verilog** and **MSYS2** toolchains for those who want to step into the world of open-source hardware development. The guide covers installation, testing, and **waveform** analysis processes starting from scratch.

## Step 1: Icarus Verilog Installation

Icarus Verilog is a tool used to compile and simulate Verilog code.

1. Download the latest stable version of Icarus Verilog from the following address: [https://bleyer.org/icarus/](https://bleyer.org/icarus/)
    
    - Click the **iverilog-0.9.7_setup.exe (latest stable release)** link.
        
2. During installation, proceed by checking the options shown in these screenshots.
    

<p align="center"> <div style='display: flex; justify-content: center; align-items: center;'> <img src="Images/Pasted image 20250903125054.png" style="max-width: 32%;"> <img src="Images/Pasted image 20250903125112.png" style="max-width: 32%;"> <img src="Images/Pasted image 20250903125207.png" style="max-width: 32%;">

  

<em style="display:flex;justify-content:center"> </em> </div> 

1. Once the installation is complete, type **"edit the system environment variables"** in the **Start** menu and click **Environment Variables** in the window that opens.
    
2. Double-click the **Path** variable and ensure the `C:\iverilog\bin` path is in the list. If not, add this path.
    

<p align="center"> <div style='display: flex; justify-content: center; align-items: center;'> <img src="Images/Pasted image 20250903125451.png" style="max-width: 32%;"> <img src="Images/Pasted image 20250903125523.png" style="max-width: 32%;"> <img src="Images/Pasted image 20250903125556.png" style="max-width: 32%;">

  

<em style="display:flex;justify-content:center"> </em> </div> 

3. To verify the installation, open the **Command Prompt (CMD)** and enter the following commands:
    

Bash

```
iverilog -V    
```

This command should display the version information for Icarus Verilog.

## Step 2: MSYS2 Installation

MSYS2 provides a Linux-like command-line environment on Windows and hosts additional tools required for Verilog.

1. Download MSYS2 from the official site: [https://www.msys2.org/](https://www.msys2.org/)
    
    - Or use the direct download link: [https://github.com/msys2/msys2-installer/releases/download/2025-08-30/msys2-x86_64-20250830.exe](https://github.com/msys2/msys2-installer/releases/download/2025-08-30/msys2-x86_64-20250830.exe)
        
2. Do not change the default file location during installation. Proceed by checking the ticks in this screenshot.
    

<p align="center"> <img src="Images/Pasted image 20250903130022.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>

1. After installation, MSYS2 will run automatically. If it doesn't, launch the program.
    

<p align="center"> <img src="Images/Pasted image 20250903131715.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>

Install the necessary packages by entering the following commands in the terminal sequentially:

Bash

```
$ pacman -Syu
```

(Continue by typing `y` after this command.)

Bash

```
$ pacman -S mingw-w64-x86_64-gtkwave
$ pacman -S mingw-w64-x86_64-iverilog
$ pacman -S mingw-w64-ucrt-x86_64-gcc
$ pacman -S mingw-w64-ucrt-x86_64-gdb
```

Confirm the download for each command by typing `y`.

2. Check the environment variables in the **Command Prompt (CMD)** and ensure the `C:\msys64\mingw64\bin` path is added to the **Path**.
    

<p align="center"> <img src="Images/Pasted image 20250903125256.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>

<p align="center"> <div style='display: flex; justify-content: center; align-items: center;'> <img src="Images/Pasted image 20250903125451.png" style="max-width: 32%;"> <img src="Images/Pasted image 20250903125523.png" style="max-width: 32%;"> <img src="Images/Pasted image 20250903130555.png" style="max-width: 32%;">

  

<em style="display:flex;justify-content:center"> </em> </div> 

3. To verify the installation is complete, enter the following commands in CMD:
    

Bash

```
iverilog -V
gcc --version
gdb --version
gtkwave
```

## Step 3: Basic Simulation Test

You can now compile and run a Verilog code.

1. Create a folder for your Verilog codes on your computer (e.g., `C:\VerilogCodes`).
    
2. Create a file named `test.v` inside it and add the following code:
    

<p align="center"> <img src="Images/Pasted image 20250903131516.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>

Verilog

```
module hello;
 
initial begin
$display("Hello, World");
$finish;
end

endmodule
```

3. Open the MSYS2 terminal and navigate to the folder you created:
    

Bash

```
$ cd /c/VerilogCodes
```

4. Compile the code and create a `.vvp` file:
    

Bash

```
$ iverilog -o test.vvp test.v
```

<p align="center"> <img src="Images/Pasted image 20250903132123.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>

5. Run the simulation:
    

Bash

```
$ vvp test.vvp
```

You should see the **"Hello, World"** output in the terminal.

<p align="center"> <img src="Images/Pasted image 20250903132215.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>

## Step 4: Advanced Testing and Waveform Visualization

To test more complex circuits and see signal changes in waveform format, let's use the **full adder** example.

1. Create the following two files in the same folder: `fullAdderTB.v` and `fullAdder.v`.
    

**fullAdder.v** (Full Adder Module)

Verilog

```
module full_adder(
    input a,
    input b,
    input c_in,
    output sum,
    output carry_out
);
    assign sum = a ^ b ^ c_in;
    assign carry_out = (a & b) | (b & c_in) | (a & c_in);
endmodule
```

**fullAdderTB.v** (Testbench and Waveform commands)

Verilog

```
`timescale 1ns / 1ps

module tb_full_adder;

// Declare testbench signals
reg a, b, c_in;
wire sum, carry_out;

// Instantiate the full adder module
full_adder dut (
    .a(a),
    .b(b),
    .c_in(c_in),
    .sum(sum),
    .carry_out(carry_out)
);

// Create waveform files
initial begin
    $dumpfile("fullAdderTB.vcd");
    $dumpvars(0, tb_full_adder);
end

// Apply test scenario
initial begin
    $display("Testing Full Adder");
    $display("a   b   c_in | sum carry_out");
    $display("--------------------------");

    $monitor("%b   %b   %b    | %b   %b", a, b, c_in, sum, carry_out);

    a = 0; b = 0; c_in = 0; #10;
    a = 0; b = 0; c_in = 1; #10;
    a = 0; b = 1; c_in = 0; #10;
    a = 0; b = 1; c_in = 1; #10;
    a = 1; b = 0; c_in = 0; #10;
    a = 1; b = 0; c_in = 1; #10;
    a = 1; b = 1; c_in = 0; #10;
    a = 1; b = 1; c_in = 1; #10;

    #20;
    $finish;
end

endmodule
```

2. Compile the files using the MSYS2 terminal and create the `.vvp` file:
    

Bash

```
$ iverilog -o fullAdderTB.vvp fullAdderTB.v fullAdder.v
```

3. Run the simulation:
    

Bash

```
$ vvp fullAdderTB.vvp
```

<p align="center"> <img src="Images/Pasted image 20250903133156.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>

You should see the results of all test scenarios in the terminal.

4. View the Waveform with GTKWave:
    

Bash

```
$ gtkwave fullAdderTB.vcd
```

<p align="center"> <img src="Images/Pasted image 20250903140944.png" style="display: block; margin: auto;" width="400">

  

<em style="display:flex;justify-content:center"> </em> </p>