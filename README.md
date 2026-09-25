# PicoRV32 RISC-V: RTL-to-GDSII Physical Design Flow

This repository houses a complete backend ASIC physical design pipeline for the PicoRV32, a popular open-source 32-bit RISC-V CPU core. Instead of focusing on frontend logic design, this project dives straight into physical implementation. It uses custom Tcl automation to drive the RISC-V architecture through synthesis, floorplanning, placement, routing, and timing sign-off using the Synopsys EDA toolchain.

## The Toolchain
*   **Synopsys Fusion Compiler:** Unified logic synthesis, floorplanning, power mesh planning, standard cell placement, Clock Tree Synthesis (CTS), and routing.
*   **Synopsys StarRC:** Sign-off RC parasitic extraction from the routed database.
*   **Synopsys PrimeTime:** Static Timing Analysis (STA) to evaluate critical paths and verify setup/hold timing closure.
*   **Synopsys Formality:** Logic Equivalence Checking (LEC) to prove the routed netlist matches the golden RTL.

## Directory Structure
*   `/rtl` - The golden `picorv32.v` Verilog source file.
*   `/scripts` - The Tcl automation scripts for `fc_shell`, `pt_shell`, and `fm_shell`.
*   `/docs` - The compiled PDF lab manual and LaTeX source detailing the environment setup, execution commands, and PD methodology.
*   `/outputs` - Generated netlists, SPEF, SDC, and DEF files (ignored via `.gitignore`).
*   `/reports` - Timing, power, and area reports (ignored via `.gitignore`).

## Quick Start
Check out the `docs/main.pdf` manual for detailed environment setup and standard cell library routing. To run the main implementation flow:

1. Update your `$tech_lib` and `$phys_lib` paths in `scripts/fc_flow.tcl` to match your local SAED32 PDK installation.
2. Run Fusion Compiler in batch mode:
   ```bash
   fc_shell -f scripts/fc_flow.tcl
