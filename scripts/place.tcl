################################################################################
# 3. Placement Script (fc_shell)
################################################################################
puts "\[INFO\] Running place.tcl..."

# --- 0. Setup and Load Database ---
# Source the setup variables
source scripts/setup.tcl

# If running this script standalone, we must open the library and the saved floorplan block
set NDM_LIB "work/${DESIGN_NAME}_lib.ndm"
if {![current_block -quiet]} {
    puts "\[INFO\] Opening NDM library and floorplan block..."
    open_lib $NDM_LIB
    open_block ${DESIGN_NAME}_floorplan
}

# --- 1. Pre-Placement Checks ---
# Ensure the floorplan is legal and ready for standard cell placement
check_design -checks pre_placement_stage

# --- 2. Core Placement & Optimization ---
# Performs global placement, high-fanout net synthesis, legalization, and physical timing optimization.
place_opt

# --- 3. Tie-Cell Insertion ---
# Connect logic '1' and '0' to specific Tie-High and Tie-Low cells to prevent DRC errors
connect_tie_cells -objects [get_lib_cells "*/LOGIC1_X1 */LOGIC0_X1"]

# --- 4. Generate Quality of Results (QoR) Reports ---
file mkdir reports
report_qor > reports/01_place_qor.rpt
report_congestion -routing_stage global > reports/01_place_congestion.rpt
report_timing -delay_type max > reports/01_place_timing_setup.rpt

# --- 5. Save the Database ---
# Save as a new block so we don't overwrite the floorplan
save_block -as ${DESIGN_NAME}_placed

puts "\[INFO\] Placement complete. Database saved to ${DESIGN_NAME}_placed."