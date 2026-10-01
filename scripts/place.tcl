# ==============================================================================
# 3. Placement (fc_shell)
# ==============================================================================
puts "\[INFO\] Running place.tcl..."

# --- 1. Pre-Placement Checks ---
# Ensure the floorplan is legal and ready for standard cell placement
check_design -checks pre_placement_stage

# --- 2. Core Placement & Optimization ---
# This single command performs global placement, high-fanout net synthesis, 
# legalization, and physical timing optimization.
place_opt

# --- 3. Tie-Cell Insertion ---
# Logic '1' and '0' cannot be wired directly to VDD/VSS in advanced nodes without causing DRCs.
# We connect them using NanGate45's specific Tie-High (LOGIC1_X1) and Tie-Low (LOGIC0_X1) cells.
# (Note: Some libraries use TIEH/TIEL instead, adjust if Fusion Compiler warns about missing cells).
connect_tie_cells -objects [get_lib_cells "*/LOGIC1_X1 */LOGIC0_X1"]

# --- 4. Generate Quality of Results (QoR) Reports ---
file mkdir reports
report_qor > reports/01_place_qor.rpt
report_congestion -routing_stage global > reports/01_place_congestion.rpt
report_timing -delay_type max > reports/01_place_timing_setup.rpt

# --- 5. Save the Database ---
# Saving here allows you to close the tool and resume from CTS tomorrow without re-running placement
save_block -as ${DESIGN_NAME}_placed

puts "\[INFO\] Placement complete. Database saved to ${DESIGN_NAME}_placed."