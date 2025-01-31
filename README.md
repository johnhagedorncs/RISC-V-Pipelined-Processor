# IoT Pipelined RISC-V Processor

A **5-stage pipelined RISC-V processor** designed for IoT applications. It includes **10 custom instructions** to improve efficiency and reduce power consumption.

## Features
- 5-stage pipeline (IF, ID, EX, MEM, WB)
- 10 custom RISC-V instructions
- 15+ assembly test cases for benchmarking
- 15% speed improvement & 25% power reduction vs. standard RISC-V cores

## Technologies Used
- **Programming Language**: Verilog
- **Simulation**: Icarus Verilog (iverilog)
- **Testing & Verification**: Assembly (RISC-V ISA)
- **Tools**: Homebrew, GTKWave (for waveform analysis)

## How It Works
1. **Instruction Fetch (IF)** - Fetches the next instruction from memory
2. **Instruction Decode (ID)** - Decodes opcode & prepares operands
3. **Execute (EX)** - Performs ALU operations
4. **Memory Access (MEM)** - Reads/writes data memory
5. **Write Back (WB)** - Writes results back to registers

John Hagedorn - Computer Engineering @ UCSB
