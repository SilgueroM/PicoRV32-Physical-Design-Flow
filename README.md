# PicoRV32 RISC-V Physical Design Flow (RTL-to-GDSII)

A comprehensive, automated RTL-to-GDSII physical design repository for the PicoRV32 RISC-V processor core. This repository bridges open-source hardware design with enterprise-grade Synopsys EDA tools with full compatibility for the FreePDK45 / NanGate45 open-source library ecosystem.

---

## Background & Technology Stack

### 1. The Design: PicoRV32
PicoRV32 is a CPU core that implements the RISC-V RV32IMC instruction set. It is widely used in SoC designs, academic tape-outs, and hardware research due to its compact footprint, clean Verilog architecture, and high performance-per-watt efficiency.

### 2. The PDK: FreePDK45 & NanGate45
* FreePDK45: Developed by North Carolina State University (NCSU), FreePDK45 is an open-source generic 45nm Process Design Kit (PDK) created for educational and research purposes. Because it is non-proprietary, it provides realistic design rules without NDA restrictions.
* NanGate Open Cell Library: The 45nm Open Cell Library (designed using FreePDK45 and distributed via Silicon Integration Initiative - Si2) provides a full suite of standard logic cells (inverters, flip-flops, complex gates) characterized for robust digital implementation.

### 3. Synopsys Toolchain & Open-Source Compatibility
Commercial electronic design automation (EDA) software suite from Synopsys is traditionally built for proprietary commercial PDKs (like TSMC or GlobalFoundries). This repository configures standard Synopsys tools (Fusion Compiler, StarRC, and PrimeTime) to successfully ingest, process, and compile open-source LEF/DEF, Liberty (.lib), and Milkyway/NDM formats for the FreePDK45/NanGate45 environment.

---

## Repository Structure & Startup Menu

The flow is modularized into sequential Tcl scripts housed within the scripts/ directory, managed either individually or executed collectively via a master runner (run_flow.tcl).

PicoRV32-Physical-Design-Flow/
├── rtl/                  # PicoRV32 Verilog source files
├── constraints/          # SDC (Synopsys Design Constraints) files
├── scripts/              # Individual physical design step scripts
│   ├── setup.tcl         # Environment variables, libraries, and design setup
│   ├── floorplan.tcl     # Core sizing, pin placement, and power grid
│   ├── place.tcl         # Standard cell placement and optimization
│   ├── cts.tcl           # Clock Tree Synthesis and skew balancing
│   ├── route.tcl         # Global and detailed signal routing
│   ├── pex.tcl           # Parasitic Extraction (StarRC engine integration)
│   ├── sta.tcl           # Static Timing Analysis (PrimeTime engine integration)
│   └── gds_out.tcl       # Filler insertion, metal fill, and final GDSII export
├── work/                 # Working NDM databases and compiled libraries
├── outputs/              # Final exported GDSII, DEF, and Verilog netlists
└── run_flow.tcl          # Master execution script linking the entire pipeline

---

## Detailed Step-by-Step Flow & Tool Mapping

| Stage | Script Name | Synopsys Tool / Engine | Description & Function |
| :--- | :--- | :--- | :--- |
| 1. Setup | setup.tcl | fc_shell | Initializes global variables, sets up search paths, maps target and link libraries (.db, .lef), and creates the working NDM database library (work/). |
| 2. Floorplan | floorplan.tcl | fc_shell | Defines the core bounding box dimensions, aspect ratio, core-to-boundary margins, power rings/stripes, and physical pin locations for the core. |
| 3. Placement | place.tcl | fc_shell | Places standard cells across legal site rows while optimizing for timing, congestion, and wirelength reduction (place_opt). |
| 4. Clock Tree Synthesis | cts.tcl | fc_shell | Builds a balanced clock distribution network to minimize clock skew and insertion delay across all sequential registers (clock_opt). |
| 5. Routing | route.tcl | fc_shell | Performs global routing, track assignment, and detailed routing (route_opt) to connect all nets cleanly with zero DRC violations. |
| 6. Parasitic Extraction | pex.tcl | Integrated StarRC | Extracts accurate resistance and capacitance (RC) parasitics from physical metal geometries, generating database-ready routing parasitics. |
| 7. Static Timing Analysis | sta.tcl | Integrated PrimeTime | Executes signoff-grade timing verification using extracted parasitics, confirming setup/hold margin closure across design corners. |
| 8. GDSII Export | gds_out.tcl | fc_shell | Inserts standard cell fillers (create_stdcell_fillers), performs metal fill, saves the final block database, and streams out the layout (write_gds). |

---

## Design Choices & Hardcoded Parameters

To ensure a smooth, single-pass automated execution, several physical design parameters have been hardcoded into the Tcl scripts. Here is the rationale behind these specific values:

### 1. Floorplan Utilization (70%) & Aspect Ratio (1.0)
* Script: floorplan.tcl
* Rationale: A 0.7 (70%) core utilization provides a healthy balance. It is dense enough to minimize wirelength and total chip area, but leaves 30% white space for clock tree buffers, sizing optimizations, and routing detours. This prevents routing congestion in a highly interconnected RISC-V core. An aspect ratio of 1.0 makes the die perfectly square, simplifying power grid uniformity.

### 2. Core-to-Boundary Margins (10um - 15um)
* Script: floorplan.tcl
* Rationale: A 10um to 15um offset from the core standard cell area to the die boundary ensures enough peripheral space for inserting robust VDD/VSS power rings and placing top-level I/O pins without creating DRC spacing violations.

### 3. Power Planning Metal Layers
* Script: floorplan.tcl
* Rationale: Higher metal layers are chosen for global power stripes and rings because they are thicker, offering lower sheet resistance to minimize IR drop across the chip. Intermediate layers drop vias down to the core logic, while M1 is strictly used for standard cell internal power rails.

### 4. Standard Cell Fillers (FILLCELL_X*)
* Script: gds_out.tcl
* Rationale: Filler cells (like FILLCELL_X8 down to FILLCELL_X1) are hardcoded for insertion at the final stage. While they contain no logic, they are strictly required to ensure N-well and implant layer continuity across all site rows, satisfying fundamental base-layer DRC rules for the NanGate45 process node before tape-out.

---

## Quick Start & Execution

### Running the Complete Automated Flow
To run the full RTL-to-GDSII pipeline from scratch using the master orchestration script:

fc_shell -f run_flow.tcl

### Running Steps Manually
If you prefer executing the scripts interactively step-by-step inside the Synopsys shell:

fc_shell
# Inside fc_shell prompt:
source scripts/setup.tcl
source scripts/floorplan.tcl
source scripts/place.tcl
source scripts/cts.tcl
source scripts/route.tcl
source scripts/pex.tcl
source scripts/sta.tcl
source scripts/gds_out.tcl

### Launching Graphical User Interfaces (GUIs)
To inspect your block visually at any stage using the tool interfaces:

# Fusion Compiler Layout Viewer:
fc_shell -gui

# PrimeTime Timing Browser:
pt_shell -gui

---

## Outputs

Upon successful completion of the flow, the following deliverables are generated in the outputs/ directory:
* picorv32.gds: The final GDSII stream file containing complete layout geometries for fabrication handoff or layout viewing (e.g., KLayout).
* picorv32.def: Design Exchange Format file containing exact placement coordinates and routing topologies.
* picorv32_routed.v: Gate-level Verilog netlist including inserted filler cells and buffered clock trees.