################################################################################
# PicoRV32 Placement Script 
# Target Tool: Synopsys Fusion Compiler
################################################################################

# --- 1. Load Environment ---
source scripts/setup.tcl

# --- 2. Open Existing Database & Floorplan Block ---
# Open the NDM library created during floorplanning
open_lib work/picorv32_lib.ndm

# Open the floorplan block we saved previously
open_block picorv32_floorplan

# --- 3. Placement & Timing Optimization ---
# place_opt drives the placement engine:
# - Performs global and detailed placement
# - Fixes setup/hold timing violations using standard cell sizing and buffering
# - Mitigates routing congestion and legalizes cell locations into rows
place_opt

# --- 4. Save Database ---
# Save the resulting placed design as a new block in the NDM
save_block -as picorv32_placed
puts "\[INFO\] Placement and optimization complete! Database saved to picorv32_lib.ndm:picorv32_placed"