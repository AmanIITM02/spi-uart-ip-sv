# AMBA APB-Mapped Low-Power SPI Peripheral Controller IP

A high-performance, parameterized Serial Peripheral Interface (SPI) Master Controller IP integrated with an AMBA APB Slave Interface and Dynamic Clock Gating, written in SystemVerilog (IEEE 1800).

This design allows SoC host processors (e.g., RISC-V or ARM) to configure and trigger SPI serial transmissions over a memory-mapped bus while minimizing dynamic power dissipation during idle states.

---

## Architecture & System Integration

Modern System-on-Chip (SoC) architectures require modular, memory-mapped peripheral IP cores connected via standard bus fabrics:

* AMBA APB Slave Interface: Handles register read/write transactions (PSEL, PENABLE, PWRITE, PADDR, PWDATA, PRDATA, PREADY) for control and data payload access.
* Memory-Mapped Register File:
  * 0x0 — Control Register: Bit 0 = Enable Power Domain, Bit 1 = Start Transmission Trigger (self-clearing).
  * 0x4 — TX Data Register: Holds the 8-bit data payload to serialize.
  * 0x8 — Status Register (Read-Only): Bit 0 = SPI Busy Flag, Bit 1 = Transmission Done Flag.
* Dynamic Integrated Clock Gating (ICG): Generates serial clock SCLK strictly when a transfer is active (CS_N == 0) and the peripheral power domain is enabled.
* Finite State Machine (FSM): 4-state engine managing setup, shift, and deselect timing for MSB-first SPI frame serialization.
* Assertion-Based Verification (ABV): Embedded procedural assertions verify that active shifting only occurs while Chip Select (CS_N) is driven low.

---

## Toolchain & Specifications

* Language: SystemVerilog (IEEE 1800)
* Bus Protocol: AMBA APB (Advanced Peripheral Bus)
* Simulation Engine: Icarus Verilog (iverilog -g2012)
* Waveform Visualization: GTKWave / VCD (apb_spi_trace.vcd)

---

## Directory Structure

spi_uart_ip.sv      # Low-level SPI Controller RTL with Clock Gating
apb_spi_top.sv      # AMBA APB Memory-Mapped Slave Wrapper
tb_apb_spi.sv       # APB Bus Transaction Simulation Testbench
README.md           # Architecture and Verification Documentation
apb_spi_trace.vcd   # Simulation Waveform Output

---

## Build and Verification Guide

### 1. Compile SystemVerilog Modules
iverilog -g2012 -o apb_spi_sim apb_spi_top.sv spi_uart_ip.sv tb_apb_spi.sv

### 2. Run APB Bus Simulation
vvp apb_spi_sim

### 3. Waveform Visualization
gtkwave apb_spi_trace.vcd
