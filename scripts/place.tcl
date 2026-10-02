################################################################################
# 3. Placement Script (fc_shell)
################################################################################
puts "\[INFO\] Running place.tcl..."

# --- 0. Setup and Load Database ---
source scripts/setup.tcl

set NDM_LIB "work/${DESIGN_NAME}_lib.ndm"
if {[current_block -quiet] eq ""} {
    puts "\[INFO\] Opening NDM library and floorplan block..."
    open_lib $NDM_LIB
    open_block ${DESIGN_NAME}_floorplan
}

# --- 1. Pre-Placement Checks ---
check_design -checks pre_placement_stage

# --- 2. Core Placement & Optimization ---
place_opt

# --- 3. Generate Quality of Results (QoR) Reports ---
file mkdir reports
redirect reports/01_place_qor.rpt { report_qor }
redirect reports/01_place_congestion.rpt { report_congestion -routing_stage global }
redirect reports/01_place_timing_setup.rpt { report_timing -delay_type max }

# --- 4. Save the Database ---
save_block -as ${DESIGN_NAME}_placed

puts "\[INFO\] Placement complete. Database saved to ${DESIGN_NAME}_placed."