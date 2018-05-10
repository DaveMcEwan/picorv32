
Digital Design Group Project Coursework
=======================================

This is the framework for the DDGP assignment in which you will design and
implement a simple CPU, demonstrating its functionallity by running real
software written in C.
The core is divided into 6 blocks of functionallity:

  1. `ifetch`
  2. `idecode`
  3. `alu`
  4. `lsu`
  5. `branch`
  6. `archstate`

Pre-synthesized blocks are provided for each of these to give you a starting
point and allow you to progress through the design by replacing these with your
own implementations.
The core will implement a RISC-V (pronounced "risk-five") instruction set
architecture, specifically the RV32I flavour and optionally the C and/or M
extensions.
This is a popular free ISA used by most major silicon companies with various
flavours begin used in everything from power-management co-processors to
powerful many-core servers.


Overview
--------

 1. Work through the "Getting Started" tasks to ensure you have a functional
    development environment and access to all the relevant documentation.
    This should take up to one lab session.
 2. Implement the `idecode`, `alu`, and `ifetch` blocks to run on both
    simulators and the FPGA board.
 3. Interim assessment - Short online quiz and demonstrations.
 4. Implement the `archstate`, `branch`, and `lsu` blocks.
 5. (Optional for additional credit) Implement either C or M ISA extensions. No
    reference model is given for these but tests are provided. It is expected
    that groups pursuing the highest marks  will attempt at least one ISA
    extension.
 6. Final assessment - Group presentation and demonstrations.


Getting Started
---------------

RISC-V is a free and open ISA and intimate knowledge of the (well written)
documentation is required.
The ISA specification can be downloaded from:
`https://content.riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf`
Chapters 1 and 2 are the most important for this module.

You will be writing in the SystemVerilog hardware description language.
The SystemVerilog language reference manual may be downloaded from:
`http://www.ece.uah.edu/~gaede/cpe526/2012%20System%20Verilog%20Language%20Reference%20Manual.pdf`

Verilator is a free and open source industry-standard software tool for
performing very fast 2-state simulations.
This should be installed on the lab machines but can also be installed easily
on personal machines. `TODO`
`https://www.veripool.org/projects/verilator/wiki/Manual-verilator`

Icarus (iverilog) is a free and open source 4-state (System)Verilog simulator
which can be installed on personal machines.
`http://iverilog.icarus.com/`
Alternatively, Cadence (ncsim), Xilinx (vivado), or Modelsim simulators may be
used and are installed on the lab machines.

Vivado (made by Xilinx) must be used to synthesize your design into a bitstream
which is used to program the Xilinx FPGA. This is installed on the lab machines.

GCC is a free and open source industry-standard C compiler with ports available
for the RISC-V ISA.

The testbench is based on the PicoRV32 core written by Clifford Wolf.

You should first ensure that you can complete the following steps in order to
get a working development environment:
  1. Download and install the RISC-V ports of GCC by cloning the git repository
     and compiling them with your system compiler: `TODO skip, lab machines?`
    - `make download-tools`
    - `make build-tools`
  2. Test your GCC installation by compiling a simple program: `make build_hello`

