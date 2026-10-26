# Low-Power SPI Peripheral Controller IP with Clock Gating

A high-performance, parameterized Serial Peripheral Interface (SPI) Master Controller IP written in SystemVerilog (IEEE 1800). This design features integrated dynamic clock gating to eliminate dynamic power dissipation when peripheral buses sit idle in System-on-Chip (SoC) architectures.

---

## Architecture & Low-Power Design

Modern mobile processors require aggressive power management. This module implements hardware-level power optimizations:

* Dynamic Integrated Clock Gating (ICG): Generates SCLK only when transaction is active (cs_n == 0) and power domain is enabled, reducing clock tree switching activity.
* Finite State Machine (FSM) Control Engine: 4-state control pipeline (IDLE, SETUP, SHIFT, DONE) managing serialized frame timing.
* Programmable Data Width: Parameterized payload engine (default 8-bit, customizable to 16/32-bit frames).
* Assertion-Based Verification (ABV): Embedded assertions monitor frame control boundaries and flag protocol violations in real-time.

---

## Toolchain & Specifications

* Language: SystemVerilog (IEEE 1800)
* Simulation Engine: Icarus Verilog (iverilog -g2012)
* Waveform Dumping: GTKWave / VCD (spi_trace.vcd)

---

## How to Build and Run Simulation

iverilog -g2012 -o spi_sim spi_uart_ip.sv tb_spi_uart_ip.sv
vvp spi_sim
