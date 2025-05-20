# Asynchronous FIFO (First-In-First-Out) Buffer

## 🧠 Overview

This project implements a **16-bit pointer, 8-bit wide Asynchronous FIFO** using Verilog. The FIFO allows data to be safely transferred between two different clock domains (write and read clocks), using dual-port SRAM and pointer synchronization via Gray code and double flip-flop synchronization.

---

## 🛠️ Module Descriptions

### 🔹 `asynchronous_fifo.v`

This file contains the following modules:

- **`dp_sram`**: Dual-port RAM supporting asynchronous read/write.
- **`write_logic`**: Generates binary/Gray code write pointers and detects FIFO full.
- **`read_logic`**: Generates binary/Gray code read pointers and detects FIFO empty.
- **`sync_ff`**: 2-stage synchronizer for pointer crossing between clock domains.
- **`asynchronous_fifo`**: Top-level module connecting all logic components.

---

## 🧪 Testbench (`tb_asynchronous_fifo.v`)

- Simulates the asynchronous FIFO with independent read and write clocks.
- Writes 20 values into the FIFO and reads them back.
- Uses `fork-join` to allow writing and reading simultaneously.
- Checks and prints read data when available.

---

## ⏱ Clocks

- **Write Clock**: 10 ns period (100 MHz)
- **Read Clock**: 8 ns period (125 MHz)

---

## 🧰 Parameters

| Parameter     | Description                        | Default     |
|---------------|------------------------------------|-------------|
| `word_size`   | Width of each data word            | 8           |
| `ptr_size`    | Number of bits in read/write ptr   | 16          |
| `depth`       | Depth of the FIFO (2^ptr_size)     | 65536       |

---

## 🚀 How to Run the Simulation

1. Open the project in any Verilog simulator (ModelSim, VCS, XSIM, etc.).
2. Compile the `asynchronous_fifo.v` and `tb_asynchronous_fifo.v` files.
3. Run the simulation.
4. Observe the waveform or terminal output to verify correct data transfer.

---

## ✅ Features

- Asynchronous write and read operation
- Full and empty flag detection
- Dual-port memory-based design
- Synchronization of pointers across clock domains using Gray code and 2-stage flip-flops

---

## 🔍 Example Output (Console)

