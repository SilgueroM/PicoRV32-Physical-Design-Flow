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
set_top_module picorv32
link
read_sdc design/constraints.sdc

# Load the TLU+ parasitic RC models to fix the Scenario Manager errors
read_parasitic_tech -tlup $TLU_MAX_FILE -layermap $MAP_FILE -name typical_tlup
set_parasitic_parameters -corner default -early_spec typical_tlup -late_spec typical_tlup

# --- 4. Logic Synthesis ---
# Map the generic RTL to actual NanGate45 physical standard cells
compile_fusion -to logic_opto

# --- 5. Reconnect Power & Ground ---
# The newly synthesized gates need their power pins hooked to the floorplan grid
connect_pg_net -net VDD [get_pins -hierarchical "*/VDD"]
connect_pg_net -net VSS [get_pins -hierarchical "*/VSS"]

# --- 6. Placement & Timing Optimization ---
place_opt

# --- 7. Save Database ---
save_block -as picorv32_placed
puts "\[INFO\] Placement and optimization complete! Database saved."