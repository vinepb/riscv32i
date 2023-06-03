# 32-bit RISC-V core
The project contains a five stage pipeline implementation of a 32-bit RISC-V ISA, with the datapath, control, fowarding unit, and hazard detection unit.
This project is based on [David Patterson's and John Hennessy's Computer Organization and Design RISC-V Edition](https://www.amazon.com/dp/0128122757) and [Maestro](https://github.com/Artoriuz/maestro).

## Current Design
- Entirely written in VHDL.
- 5-stage pipeline.
- Top entity: core_rv32i.vhd
- There ir a preliminar testbench (core_rv32i_tb.vhd) to generate 20Mhz clock.
- The privileged ISA is **not** implemented.
- FENCE, FENCE.I and CSR instructions are not implemented.

## User Guide
- It is possible to synthesize the project and use the RTL viewer in Quartus version 19.1 (not guaranteed in newer versions).
- It is possible to simulate the project using the testbench present in ModelSim.
- There is a progmem.mif file that contains the binary code to be executed, which can be changed following the pre-existing pattern.

## Inconveniences
- The processor does not have any output. Use the debug output or load to memory to move data out of it.

## Block diagram:
![Alt text](/RISCV32i.png "RISCV32i")
