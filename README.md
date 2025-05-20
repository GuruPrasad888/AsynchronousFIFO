# Asynchronous FIFO (First-In-First-Out) Buffer


This project implements a **8-bit wide and 65536 depth Asynchronous FIFO** using Verilog. The FIFO allows data to be safely transferred between two different clock domains, using dual-port SRAM and pointer synchronization via Gray code and double flip-flop synchronization.

---

## Module Descriptions

### `asynchronous_fifo.v`

This file contains the following modules:

- **`dp_sram`**: Dual-port RAM supporting asynchronous read/write.
- **`write_logic`**: Generates binary/Gray code write pointers and detects FIFO full.
- **`read_logic`**: Generates binary/Gray code read pointers and detects FIFO empty.
- **`sync_ff`**: 2-stage synchronizer for pointer crossing between clock domains.
- **`asynchronous_fifo`**: Top-level module connecting all logic components.

---

## Testbench (`tb_asynchronous_fifo.v`)

- Simulates the asynchronous FIFO with independent read and write clocks.
- Writes 20 values into the FIFO and reads them back.
- Uses `fork-join` to allow writing and reading simultaneously.

---

## Clocks

- **Write Clock**: 10 ns period (100 MHz)
- **Read Clock**: 8 ns period (125 MHz)

---

##  Features

- Asynchronous write and read operation
- Full and empty flag detection
- Dual-port memory-based design
- Synchronization of pointers across clock domains using Gray code and 2-stage flip-flops