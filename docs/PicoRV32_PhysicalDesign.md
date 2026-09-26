# PicoRV32 RISC-V: RTL-to-GDSII Physical Design Flow

This repository contains a complete backend ASIC physical design pipeline for the PicoRV32, a 32-bit RISC-V CPU core. Bypassing frontend logic design, this project focuses strictly on physical implementation methodologies. Custom Tcl scripts drive the RISC-V architecture through synthesis, floorplanning, placement, routing, and timing sign-off using the Synopsys digital EDA toolchain via nanoHUB.

## Toolchain
* **Synopsys Fusion Compiler**: Unified logic synthesis, floorplanning, power mesh planning, standard cell placement, Clock Tree Synthesis (CTS), and routing.
* **Synopsys StarRC**: Sign-off RC parasitic extraction from the routed database.
* **Synopsys PrimeTime**: Static Timing Analysis (STA) to evaluate critical paths and verify setup and hold timing closure.
* **Synopsys Formality**: Logic Equivalence Checking (LEC) to prove the routed netlist matches the golden RTL.

## Directory Structure
* `/rtl` - The golden `picorv32.v` Verilog source file.
* `/scripts` - The Tcl automation scripts for `fc_shell`, `pt_shell`, and `fm_shell`.
* `/media` - Visual assets including routed layouts, congestion maps, and timing reports.
* `/outputs` - Generated netlists, SPEF, SDC, and DEF files (ignored via `.gitignore`).
* `/reports` - Timing, power, and area reports (ignored via `.gitignore`).

---

## Phase 1: Environment Setup on nanoHUB

This flow targets the FreePDK educational process node (typically 45nm) available on nanoHUB.

### 1. Build the Workspace
Launch the XTerm terminal from the nanoHUB Synopsys menu, initialize the directory structure, and download the single-file PicoRV32 RTL:

```bash
mkdir -p asic_flow_project/{rtl,scripts,work,reports,outputs,media}
cd asic_flow_project/rtl
wget [https://raw.githubusercontent.com/YosysHQ/picorv32/master/picorv32.v](https://raw.githubusercontent.com/YosysHQ/picorv32/master/picorv32.v)
cd ..
```

### 2. Locate Standard Cell Libraries
You need the absolute paths to the FreePDK technology files on the nanoHUB server. Run this targeted command to instantly find them without freezing the server:

```bash
find /apps/share64/rocky8/freepdk -name "*.db" -o -name "*.ndm" -o -name "*.lef" 2>/dev/null
```

Note the paths to the logical library (`.db`) and physical library (`.ndm` or `.lef`). You will need to insert these into the Tcl scripts below.

---

## Phase 2: Synthesis & Physical Implementation

We use Fusion Compiler to manage logical synthesis and physical routing within a single run.

### 1. Create the Flow Script (`scripts/fc_flow.tcl`)
Open VS Code via nanoHUB, create this file, and update the `tech_lib` and `phys_lib` paths based on the output of your search.

```tcl
# 1. Setup Libraries (REPLACE PATHS WITH YOUR NANOHUB PATHS)
set tech_lib "/path/to/freepdk/logic/freepdk45_typical.db"
set phys_lib "/path/to/freepdk/phys/freepdk45_tech.ndm"
set target_library $tech_lib
set link_library "* $tech_lib"

create_lib workspace_rv32 -technology $phys_lib -ref_libs $phys_lib

# 2. Read RTL & Synthesize
read_verilog ../rtl/picorv32.v
current_design picorv32
link

# 1 GHz Clock Constraint
create_clock -name clk -period 1.0 [get_ports clk]
compile_fusion -to initial_map

# 3. Floorplanning & Power Mesh
initialize_floorplan -core_utilization 0.7 -shape R
create_power_plan -nets {VDD VSS} -strategy ring_and_stripe

# 4. Placement & Clock Tree Synthesis (CTS)
place_opt
clock_opt

# 5. Routing
route_auto
route_opt

# 6. Export Files for Sign-off
write_verilog ../outputs/picorv32_routed.v
write_parasitics -output ../outputs/picorv32.spef
write_def -output ../outputs/picorv32.def

save_block -as picorv32_final
exit
```

### 2. Execute Fusion Compiler
Run this from the XTerm terminal in the root project folder:

```bash
# To run silently in the background:
fc_shell -f scripts/fc_flow.tcl

# To run with the GUI to watch the layout generate (Recommended):
fc_shell -gui
# Once open, type this in the GUI's command console:
# source scripts/fc_flow.tcl
```

---

## Phase 3: Extraction & Timing Sign-Off

Physical wire delays introduced during routing must be extracted and analyzed to verify the 1 GHz timing constraint.

### 1. Parasitic Extraction (StarRC)
Launch StarRC from the nanoHUB menu.

Create a command file (`scripts/starrc.cmd`) pointing to your routed `../outputs/picorv32.def` and the FreePDK technology mapping file.

Run StarRC to output a sign-off quality SPEF file: `../outputs/picorv32_signoff.spef`.

### 2. Static Timing Analysis (PrimeTime)
Create `scripts/pt_sta.tcl`:

```tcl
set target_library "/path/to/freepdk/logic/freepdk45_typical.db"
set link_library "* $target_library"

read_verilog ../outputs/picorv32_routed.v
current_design picorv32
link

read_sdc ../outputs/picorv32.sdc
read_parasitics ../outputs/picorv32_signoff.spef

report_timing -delay_type max -nworst 10 > ../reports/pt_setup.rpt
report_timing -delay_type min -nworst 10 > ../reports/pt_hold.rpt
exit
```

Execute STA:

```bash
pt_shell -f scripts/pt_sta.tcl
```

A successful sign-off requires all critical paths in the generated reports to display positive slack (MET).

---

## Phase 4: Logic Equivalence Checking

Use Formality to mathematically prove the routed netlist maintains strict functional equivalence to the golden PicoRV32 RTL.

### 1. Create the LEC Script (`scripts/fm_lec.tcl`)

```tcl
set target_library "/path/to/freepdk/logic/freepdk45_typical.db"
read_db $target_library

# Golden RTL
read_verilog -r ../rtl/picorv32.v
set_top r:/WORK/picorv32

# Routed Netlist
read_verilog -i ../outputs/picorv32_routed.v
set_top i:/WORK/picorv32

match
verify
exit
```

### 2. Execute Formality

```bash
fm_shell -f scripts/fm_lec.tcl
```

Look for `Verification SUCCEEDED` in the terminal output.

---

## Phase 5: Media Generation & Portfolio Integration

To solidify this project for recruiters, generate visual proof of your physical implementation and save these assets to the `/media` folder. Add these images to your notebook or repository README.

### Final Routed Layout
**Action:** Launch the Fusion Compiler GUI (`fc_shell -gui`). Zoom in to capture a high-resolution screenshot displaying the metal routing tracks, the standard cell placement density, and the VDD/VSS power rings.  
**Save as:** `media/picorv32_routed_layout.png`

### Routing Congestion Heatmap
**Action:** Use the Fusion Compiler GUI to enable the routing congestion overlay and capture a screenshot.  
**Save as:** `media/congestion_heatmap.png`

### Clock Tree Synthesis (CTS) Visualization
**Action:** Use the CTS visualizer in Fusion Compiler to highlight the clock distribution network and capture a screenshot.  
**Save as:** `media/cts_distribution.png`

### Timing Sign-Off Verification
**Action:** Open the generated `pt_setup.rpt` and `pt_hold.rpt` files from PrimeTime. Extract the text snippet or capture a screenshot of the critical path analysis explicitly showing the positive slack margin (MET).  
**Save as:** `media/primetime_slack.png`

---

## Notes and Tips
* Replace all placeholder paths (e.g., `/path/to/freepdk/...`) with the actual absolute paths on the nanoHUB environment.
* Keep generated large files (DEF, SPEF, routed netlists) out of Git by listing them in `.gitignore`.
* When running GUI flows, capture high-resolution screenshots for portfolio presentation.
* Verify library versions and timing corners used for synthesis and STA match the educational process node documentation on nanoHUB.

---

## License
Include an appropriate license for your repository (e.g., MIT, Apache 2.0) depending on how you want to share your scripts and assets.