################################################################################
# PicoRV32 Placement Script 
# Target Tool: Synopsys Fusion Compiler
################################################################################

# --- 1. Load Environment ---
source scripts/setup.tcl

# --- 2. Open Existing Database & Floorplan Block ---
open_lib work/picorv32_lib.ndm
open_block picorv32_floorplan

# --- 3. Ensure Design Context & Constraints Are Active ---
# Re-analyze/elaborate or link the loaded block to ensure top module and SDC are bound
set_top_module picorv32
link
read_sdc design/constraints.sdc

# --- 4. Placement & Timing Optimization ---
place_opt

# --- 5. Save Database ---
save_block -as picorv32_placed
puts "\[INFO\] Placement and optimization complete! Database saved to picorv32_lib.ndm:picorv32_placed"