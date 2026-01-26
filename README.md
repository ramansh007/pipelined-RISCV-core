# 32-bit Pipelined RISC-V Processor (RV32I)

This repository contains the RTL design, verification, and synthesis results of a **32-bit 5-stage pipelined RISC-V processor** implementing a subset of the **RV32I ISA**.  
The processor is designed in **Verilog**, verified using **behavioral and post-synthesis simulation**, and synthesized using **Xilinx Vivado**.

---

## 🔹 Key Features

- 32-bit RISC-V (RV32I subset)
- Classic **5-stage pipeline**
  - Instruction Fetch (IF)
  - Instruction Decode (ID)
  - Execute (EX)
  - Memory Access (MEM)
  - Write Back (WB)
- **Data forwarding**
  - EX–EX forwarding
  - MEM–EX forwarding
- **Load-use hazard detection**
  - Single-cycle pipeline stall
  - PC and IF/ID freeze with ID/EX bubble insertion
- Separate Instruction and Data Memories
- Synthesizable on FPGA
- Verified using **behavioral and post-synthesis simulation**

---

## 🔹 Pipeline Architecture

The processor follows the standard 5-stage RISC-V pipeline with forwarding and hazard detection.

<p align="center">
  <img src="Docs/Architecture.png" width="800">
</p>

### Pipeline Registers

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

---

## 🔹 Hazard Handling

### Data Forwarding

To resolve data hazards without stalling:

- Forwarding from **EX/MEM → EX**
- Forwarding from **MEM/WB → EX**

The forwarding unit compares source registers (`rs1`, `rs2`) with destination registers (`rd`) in later stages and selects the correct operand through multiplexers.

### Load-Use Hazard

When an instruction immediately depends on a previous `lw`:

- PC write is disabled
- IF/ID register is frozen
- A bubble (NOP) is inserted into ID/EX

This introduces a **single-cycle stall**, ensuring correctness.

---

## 🔹 Verification Strategy

### Behavioral (RTL) Simulation

A simple, readable RTL testbench is used to validate:

- Individual instruction correctness
- EX-EX and MEM-EX forwarding
- Load-use hazard stall behavior

Verification is done by observing **architectural write-back values**.

Example instruction sequence:

```assembly
addi x1, x0, 5
addi x2, x0, 10
add  x3, x1, x2      # forwarding
sw   x3, 0(x0)
lw   x4, 0(x0)
add  x5, x4, x4      # load-use stall
addi x5, x5, 1
```

## Expected Final Register Values

| Register | Value |
| -------- | ----- |
| x1       | 5     |
| x2       | 10    |
| x3       | 15    |
| x4       | 15    |
| x5       | 31    |

---

## Post-Synthesis Simulation

- The same testbench used for RTL (behavioral) simulation is reused
- Behavioral and post-synthesis simulation results match at the architectural level

<p align="center">
  <img src="Docs/RTL_Simulation.png" width="800">
</p>

This confirms that **synthesis preserves functional correctness**.

---

## Synthesis Results (Artix-7)

**Target Device:** `xc7a35t`

### Resource Utilization

<p align="center">
  <img src="Docs/Utilization.png" width="800">
</p>

---

### Timing Summary

<p align="center">
  <img src="Docs/Timing_Summary.png" width="800">
</p>

All user-specified timing constraints are met.

---

## Critical Path Analysis

The critical path lies within the **EX stage**, from the EX/MEM register through:

- Forwarding compare logic
- Operand multiplexers
- ALU computation
- Back into the EX/MEM register

Even with a **carry-save based ALU**, the forwarding control and high fan-out multiplexing dominate the delay, which is expected in a pipelined CPU design.

---

## Tools Used

- **Language:** Verilog
- **Simulation:** XSim (Vivado)
- **Synthesis & Timing:** Xilinx Vivado
- **Target FPGA:** Artix-7

---

## Future Work

- Branch and jump instructions
- Pipeline flush support
- True BRAM-based instruction and data memory
- FPGA board bring-up

---
