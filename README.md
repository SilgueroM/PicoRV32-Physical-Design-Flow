# PicoRV32 Physical Design Flow: RTL-to-GDSII

## 📌 Project Overview
This repository demonstrates a complete, automated Application-Specific Integrated Circuit (ASIC) physical design pipeline. It focuses entirely on backend implementation, taking the industry-standard PicoRV32 RISC-V core from raw Verilog RTL all the way to a fully routed physical layout. 

The primary purpose of this project is to apply advanced VLSI methodologies—including power grid formulation, timing-aware placement, and rigorous static timing analysis—while evaluating Power, Performance, and Area (PPA) metrics using the **NanGate 45nm open-source PDK**.

## 🔬 The Core: PicoRV32
The PicoRV32 is a popular, size-optimized 32-bit RISC-V CPU core that implements the RV32IMC instruction set. Because it is written in standard, generic Verilog and has a highly configurable architecture, it serves as an excellent benchmark design for driving complex EDA toolchains, testing high-frequency clock constraints, and analyzing standard cell density and routing congestion.

## ⚙️ Technology & Enablement
* **Target Node:** 45nm (NanGate Open Cell Library)
* **Libraries Integrated:** 
  * `Liberty (.db)` for logical timing/power
  * `LEF` for physical standard cell/macro definitions
  * `TLU+` for RC parasitic extraction
  * `SDC` for clock and I/O timing constraints (Targeting 500 MHz)

---

## 🛠️ Synopsys Toolchain & Automation Scripts
This flow is heavily automated using custom Tcl scripts designed specifically for the Synopsys digital implementation suite.

### 1. Synopsys Fusion Compiler (`fc_shell`)
Acts as the unified engine for logic synthesis and physical implementation. 
* **Synthesis:** Translates generic RTL logic into mapped NanGate45 standard cells.
* **Floorplanning:** Defines core dimensions, places I/O pins, and builds the macro VDD/VSS power mesh.
* **Placement & Optimization:** Executes timing-driven standard cell placement to resolve design rule violations and layout congestion.
* **Associated Scripts:** 
  * `scripts/setup.tcl` - Initializes the tool environment, links `.db` logical libraries, `.lef` physical libraries, and loads `TLU+` parasitic models.
  * `scripts/place.tcl` - The main execution script that drives `compile_fusion`, applies the `constraints.sdc`, and runs `place_opt`.

### 2. Synopsys StarRC
Used for sign-off physical extraction.
* Extracts highly accurate Resistance and Capacitance (RC) network data from the fully routed Fusion Compiler database.
* Generates the SPEF (Standard Parasitic Exchange Format) file required for final timing analysis.

### 3. Synopsys PrimeTime (`pt_shell`)
The industry-standard sign-off Static Timing Analysis (STA) tool.
* Reads the synthesized netlist and the StarRC-extracted SPEF.
* Rigorously evaluates all critical timing paths to ensure zero setup or hold violations across the design.
* **Associated Scripts:** 
  * `scripts/pt_signoff.tcl` (or equivalent) - Loads the netlist and parasitics, generates critical path reports, and performs timing closure verification.

---

## 🚀 Quick Start
To run the automated Fusion Compiler flow:

1. Ensure your environment has access to the Synopsys toolchain (`fc_shell`).
2. Clone this repository and verify your local PDK paths inside `scripts/setup.tcl`.
3. Launch the placement and optimization flow in batch mode:
   ```bash
   fc_shell -f scripts/place.tcl
   ```
4. Review the generated terminal output and log files for Synthesis mapping and `place_opt` QOR (Quality of Results).