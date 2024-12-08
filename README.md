# Computer Systems for VLSI Project / Projekat iz Računarskih VLSI sistema

This project implements a simple system using Verilog and SystemVerilog, designed for simulation, synthesis, and testing of digital components.
The system integrates key components such as a CPU, memory, clock divider, and display modules, allowing for hardware implementation and functional verification.

System is intended to work on Cyclone V FPGA

The architecture is inspired by Pico Computer: http://messylab.com/pico/
It is a project on the course Computer Systems for VLSI (Računarski VLSI sistemi) 
on University of Belgrade, Faculty of Electrical Engineering, Module for Computer Engineering and Informatics

![image](https://github.com/user-attachments/assets/30d6dc95-210a-44ad-89a4-87e316adfdfe)

## System Description

### Top-Level Design
The `top.v` module represents the **Top-Level Entity** that connects all major components of the system. 
Its purpose is to coordinate the interactions between the processor, memory, and peripherals. The system operates with the following key functionalities:

1. **Clock Divider (CLK_DIV)**:
   - Converts a high-frequency clock (50 MHz) into a slower 1 Hz clock signal for synchronized system operations.
   - Inputs: `clk` (50 MHz clock), `rst_n` (asynchronous reset).
   - Output: `out` (1 Hz clock).

2. **Memory Module**:
   - A 64-word memory, divided into:
     - **General-Purpose Registers**: First 8 memory locations for temporary data storage.
     - **Free Zone**: Remaining memory for instructions, data, and stack.
   - Supports read and write operations controlled by the processor.
   - Inputs: Address (`addr`), data input (`data`), write enable (`we`).
   - Outputs: Data output (`out`).

3. **CPU (Central Processing Unit)**:
   - Implements the PicoComputer's processor with:
     - **Registers**:
       - Program Counter (`PC`): Tracks the current instruction.
       - Stack Pointer (`SP`): Points to the top of the stack.
     - **Operations**: Arithmetic, data transfer, input/output, and control instructions.
   - Inputs: Clock (`clk`), reset (`rst_n`), memory input (`mem_in`), and standard input (`sw[3:0]`).
   - Outputs: Memory control signals (`mem_we`, `mem_addr`, `mem_data`), standard output (`led[4:0]`), and values for `PC` and `SP`.

4. **Binary Coded Decimal (BCD) Converter**:
   - Converts binary values from the `PC` and `SP` registers into two-digit BCD outputs.
   - Outputs: `tens` and `ones`.

5. **Seven-Segment Display (SSD)**:
   - Displays BCD values from `PC` and `SP` on seven-segment displays.
   - Inputs: 4-bit BCD values.
   - Outputs: Encoded data for display segments (`hex[27:21]`, `hex[20:14]`, `hex[13:7]`, `hex[6:0]`).

### System Functionality
- **Input**: User inputs data through switches (`sw[3:0]`), and the system is reset asynchronously using `sw[9]`.
- **Output**:
  - **LEDs**: Indicate standard output values (`led[4:0]`).
  - **Seven-Segment Displays**: Show the values of `PC` and `SP`.
- The system processes data, executes instructions, and manages memory access through the coordinated operation of its components.



