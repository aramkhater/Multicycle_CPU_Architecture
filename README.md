# Multicycle_CPU_Architecture
## Overview
This project is a VHDL implementation of a 16-bit Multi-Cycle CPU design. It implements a modular architecture where instructions are executed across multiple clock cycles, allowing for resource sharing of the ALU and memory interfaces. The system is designed to demonstrate fundamental CPU principles, including finite state machine (FSM) control, sign-extended branching, and status flag management.

## Table of Contents
 - System Design
 - Control Unit
 - Data Path
 - Verification
 - Additional Components

## System Design
The design encapsulates all necessary modules for CPU operations, integrating them through a top-level hierarchy that separates control logic from data processing.
File Descriptions:
### File Descriptions

#### `aux_package.vhd`
- Defines all component declarations, including the ALU, Register File, and Control Unit, enabling clean interconnections between various modules.

#### `Top.vhd`
- Serves as the main structural module, integrating the Control Unit and Datapath.
- It interfaces with external signals for memory loading and system operation.
 ##### Inputs/Outputs:
- Reset, clock, and enable signals.
- Data inputs for Program Memory (ITCM) and Data Memory (DTCM).
- Testbench signals and system "Done" indicator.

#### `Control.vhd`
- Implements the Finite State Machine (FSM) that coordinates the timing of the datapath.
- It generates critical signals such as IRin (Instruction Register enable), Pcin (PC enable), and ALUFN (ALU function select).

#### `Datapath.vhd`
- Manages the actual data flow and structural mapping between internal modules.
- Orchestrates communication between the Register File, ALU, and both memory units via internal buses.

#### `RF.vhd`
- A Register File consisting of 16-bit registers.
- Includes a hardwired R[0] register that maintains a constant zero value for simplified logic operations.

#### `ProgMem.vhd` and `dataMem.vhd`
- Represent specialized memory blocks for instructions and data respectively.
- Includes logic to allow a Testbench to write directly to memory for simulation initialization.

#### `ALU.vhd`
- The Arithmetic Logic Unit performs operations based on the ALUFN signal.
- Logic module: Handles AND, OR, XOR, and a specialized Merge operation.
- Shifter module: Executes logical shifts based on input direction and amount.

#### `IR.vhd`
- The Instruction Register module that captures the raw memory output.
- It breaks down the 16-bit instruction into opcodes, register addresses (RFaddr_rdR, RFaddr_wrR), and immediate values.

#### `PC_Update.vhd`
- Manages the Program Counter with support for sequential increments and relative branching.
- Uses an 8-bit sign-extended IRoffset to calculate branch targets.
