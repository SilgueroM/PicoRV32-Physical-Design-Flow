# ==============================================================================
# PicoRV32 Physical Design Flow - Direct Library Mode (Bypassing NDM Workspace)
# ==============================================================================
puts "INFO: Initializing physical design flow..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

file mkdir "$proj_root/outputs"
file mkdir "$proj_root/reports"
file mkdir "$proj_root/work"

# Define raw library paths directly
set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set tech_lef  "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.tech.lef"
set macro_lef "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.macro.mod.lef"
set rtl_file  "$proj_root/rtl/picorv32.v"

# Set target libraries for synthesis
set target_library $tech_db
set link_library   "* $target_library"

# Initialize design library directly using the technology file and raw LEFs
create_lib pico_design -technology $tech_tf
read_lef $tech_lef
read_lef $macro_lef

# Read RTL & Link
puts "INFO: Elaborating and synthesizing RTL..."
analyze -format sverilog $rtl_file
elaborate picorv32
link
current_design picorv32

# Apply constraints and run compilation
create_clock -name clk -period 2.0 [get_ports clk]
compile_fusion -to initial_map

# Floorplanning
puts "INFO: Initializing floorplan..."
initialize_floorplan -core_utilization 0.7 -shape R

# Placement, CTS, and Routing
puts "INFO: Running placement and routing..."
place_opt
clock_opt
route_auto
route_opt

# Export Deliverables
puts "INFO: Exporting sign-off deliverables..."
write_verilog -output "$proj_root/outputs/picorv32_routed.v"
write_parasitics -output "$proj_root/outputs/picorv32.spef"
write_def -output "$proj_root/outputs/picorv32.def"

report_timing > "$proj_root/reports/timing_signoff.rpt"
report_area   > "$proj_root/reports/area_summary.rpt"

puts "INFO: Physical design flow completed successfully."
exit