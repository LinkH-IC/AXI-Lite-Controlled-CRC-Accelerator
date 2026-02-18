# AXI4-Lite CRC Accelerator

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Verilog/SystemVerilog](https://img.shields.io/badge/Language-Verilog-blue.svg)](https://github.com/LinkH-IC/AXI-Lite-Controlled-CRC-Accelerator.git)

Phase 1 (RTL & Sim) Complete; Phase 2 (Synthesis) in progress

## 📌 Project Overview
This project features a high-performance hardware **CRC (Cyclic Redundancy Check) Accelerator** controlled via the **AXI4-Lite** bus protocol. It is specifically designed to offload data integrity verification tasks from the CPU in embedded systems or SoC environments.

By offloading the bit-wise CRC calculations to dedicated hardware, this IP core significantly reduces CPU cycles and power consumption for communication protocols and storage verification.

### Key Features:
* **Protocol**: Fully compliant with the AXI4-Lite Slave interface (32-bit data width).
* **Efficiency**: Parallel implementation capable of processing data in a single clock cycle.
* **Synchronous Design**: Robust reset and clocking strategy suitable for ASIC synthesis and FPGA implementation.

---

## 🏗 System Architecture
The accelerator architecture is divided into three functional layers to ensure modularity and ease of verification:



1.  **AXI-Lite Slave Interface**: Handles the standard 5-channel handshake (AW, W, B, AR, R).
2.  **Register Bank**: Maps the hardware logic to the CPU's memory space. (Integrated inside the slave module)
3.  **CRC Engine**: The core combinatorial logic implementing the polynomial division. (Copyright (C) Michael Büsch https://bues.ch/h/crcgen)

### Mathematical Foundation
The engine implements the CRC calculation based on the generator polynomial $G(x)$. For a standard CRC-32, the polynomial used is:
$$G(x) = x^{32} + x^{26} + x^{23} + x^{22} + x^{16} + x^{12} + x^{11} + x^{10} + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1$$

---

## 🔢 Register Map
| Offset | Name | Access | Description |
| :--- | :--- | :--- | :--- |
| `0x00` | `CRC_INITIAL` | W/R | CRC Initial: Writing to this register provides the CRC init value |
| `0x04` | `CRC_DATA_IN` | W/R | Input Data: Writing to this register triggers the engine |
| `0x08` | `CRC_RESULT` | R | Output: Holds the current 32-bit checksum |

---

## 🛠 Tools & Environment
* **HDL**: Verilog
* **Simulation**: Icarus Verilog / GTKWave
<!--* **Synthesis**: Xilinx Vivado / Synopsys Design Compiler (ASIC Flow)-->
<!--* **Verification**: Python (cocotb) or SystemVerilog Testbench-->

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone [https://github.com/LinkH-IC/AXI-Lite-Controlled-CRC-Accelerator.git](https://github.com/LinkH-IC/AXI-Lite-Controlled-CRC-Accelerator.git)
cd AXI-Lite-CRC-Accelerator