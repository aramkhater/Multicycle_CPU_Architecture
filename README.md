# Multi-Cycle CPU VHDL Project

## Overview

This project is a VHDL implementation of a **16-bit Multi-Cycle CPU** design. It aims to create a CPU with a micro-instruction cycle that performs operations across multiple cycles for optimized instruction throughput. The system is designed for educational purposes to illustrate the principles of CPU design, such as finite state machine control and resource-sharing datapaths.

---

## Table of Contents

* [System Design](#system-design)
* [Control Unit](#control-unit)
* [Data Path](#data-path)
* [Verification](#verification)
* [Additional Components](#additional-components)

---

## System Design

The design encapsulates all the necessary modules required for the CPU operations, which include the following components:

### File Descriptions

**`aux_package.vhd`**
* Defines all component declarations, enabling interconnections between the various modules such as the ALU, Register File, and Control Unit.

**`Top.vhd`**
* Serves as the main module, integrating control and datapath modules.
* It interfaces with memory and other components, orchestrating the flow of instructions and data.
* **Inputs/Outputs:**
    * Reset, clock, and enable signals.
    * Data inputs for memory (ITCM and DTCM).
    * Control signals for operation stages and testbench signals.

**`Control.vhd`**
* Implements the finite state machine (FSM) of the control unit with signals to coordinate the actions of the datapath according to the current operation and state.

**`Datapath.vhd`**
* Responsible for the actual implementation of the system, including interactions with modules like the ALU, PC, and memory components.

**`RF.vhd`**
* A register file that facilitates data storage and retrieval needed for CPU operations.
* Features 16-bit registers with a hardwired zero value at `sysRF(0)`.

**`ProgMem.vhd` and `dataMem.vhd`**
* Represent program and data memory respectively, storing instructions for the CPU and the data it processes.
* Supports external loading via testbench addresses and data inputs.

**`ALU.vhd` (Logic.vhd / Shifter.vhd)**
* The arithmetic logic unit performs mathematical and logical operations.
* **`Logic.vhd`**: Handles AND, OR, XOR, and a specialized **Merge** operation.
* **`Shifter.vhd`**: Executes logical shift operations based on direction and shift amount.

**`IR.vhd`**
* The Instruction Register module that captures data from program memory.
* It extracts the opcode (OPC), register addresses (ra, rb, rc), and immediate/offset values.

**`PC_Update.vhd`**
* Manages the Program Counter (PC) transitions.
* Supports resetting the PC, sequential increments, and relative branching using a sign-extended offset.

---

## Control Unit

The control unit is implemented as a state machine, managing control signals sent to the datapath and dealing with signals for simulation purposes. It generates control signals—such as `ALUFN`, `PCsel`, and register write enables—based on the current state and the 4-bit opcode of the instruction being executed.



---

## Data Path

The datapath module includes all interactions between system modules, executing instructions as dictated by the control unit. It manages:
* **Bus Steering:** Uses an internal bus system (BusA and BusB) to move data between the Register File, ALU, and memory.
* **Sign Extension:** Resizes immediate values from the instruction to match the internal 16-bit word size.
* **Flag Management:** Maintains status registers for Carry (C), Zero (Z), and Negative (N) flags updated via the ALU.



---

## Verification

A series of processes are defined for system simulation:
* **Memory Loading:** Data is loaded from external testbench inputs into `ProgMem` and `dataMem` using `TBactive` and write-enable signals.
* **Clock & Reset:** Generation of synchronized clock and reset signals to drive the state machine and registers.
* **Functional Testing:** The system simulates a sequence of instructions to test functionality and state transitions, outputting final results via `TBdataout`.

---

## Additional Components

* **`OPCdecoder.vhd`**: Decodes the 4-bit opcode into specific instruction triggers such as `add`, `sub`, `jmp`, and `ld`.
* **`FA.vhd`**: A full adder module used as a building block for arithmetic operations within the ALU.
