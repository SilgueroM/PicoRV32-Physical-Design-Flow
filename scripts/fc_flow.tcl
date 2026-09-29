# ==============================================================================
# PicoRV32 Physical Design Flow - NanGate45
# ==============================================================================
puts "INFO: Initializing physical design flow..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

file mkdir "$proj_root/outputs"
file mkdir "$proj_root/reports"
file mkdir "$proj_root/work"

# Define library and RTL paths
set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set phys_ndm  "$proj_root/work/NangateOpenCellLibrary.ndm"
set rtl_file  "$proj_root/rtl/picorv32.v"

# Pre-flight check
foreach file [list $tech_tf $tech_db $phys_ndm $rtl_file] {
    if {![file exists $file]} {
        puts "ERROR: Required file not found: $file"
        puts "Ensure the NDM library has been built before running this script."
        exit
    }
}

# Tool Setup & Database Binding
set_app_var target_library $tech_db
set_app_var link_library "* $target_library"

catch { remove_lib workspace_rv32 }
if {[catch {create_lib workspace_rv32 -technology $tech_tf -ref_libs $phys_ndm} err_lib]} {
    puts "ERROR: Failed to create library workspace.\n$err_lib"
    exit
}

# RTL Elaboration & Synthesis
puts "INFO: Elaborating and synthesizing RTL..."
analyze -format sverilog $rtl_file
elaborate picorv32
link
current_design picorv32

create_clock -name clk -period 2.0 [get_ports clk]
compile_fusion -to initial_map

# Floorplanning
puts "INFO: Initializing floorplan..."
if {[catch {initialize_floorplan -core_utilization 0.7 -shape R} err_fp]} {
    puts "ERROR: Floorplan initialization failed.\n$err_fp"
    exit
}

# Verify site rows exist to prevent placement crashes
redirect -variable row_rep {report_site_row}
if {[string match "*No site rows*" $row_rep]} {
    puts "ERROR: Floorplan generated 0 site rows. Missing physical data in NDM."
    exit
}

# Placement, CTS, and Routing
puts "INFO: Running placement and routing..."
if {[catch {place_opt} err_place]} {
    puts "ERROR: Placement failed.\n$err_place"
    exit
}
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
report_power  > "$proj_root/reports/power_summary.rpt"

puts "INFO: Physical design flow completed successfully."
exit