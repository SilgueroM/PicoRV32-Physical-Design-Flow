cat << 'EOF' > scripts/fc_flow.tcl
# ==============================================================================
# PicoRV32 Physical Design Flow - FreePDK45 (Fusion Compiler)
# ==============================================================================
puts "INFO: Initializing Physical Design Flow..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

set phys_ndm   "$proj_root/work/FreePDK45.ndm"
set target_db  "$proj_root/libraries/FreePDK45/FreePDK45/osu_soc/lib/files/gscl45nm.db"
set synth_net  "$proj_root/outputs/picorv32_synth.v"

# 1. Setup Design Environment using the pre-compiled NDM
set target_library $target_db
set link_library   "* $target_library"

create_lib pico_design -technology $phys_ndm -ref_libs $phys_ndm

# 2. Read Synthesized Netlist & Link
read_verilog $synth_net
current_design picorv32
link

# 3. Constraints & Floorplanning
create_clock -name clk -period 1.0 [get_ports clk]
initialize_floorplan -core_utilization 0.7 -shape R
create_power_plan -nets {VDD VSS} -strategy ring_and_stripe

# 4. Place, CTS, and Route
puts "INFO: Starting Placement and Routing..."
place_opt
clock_opt
route_auto
route_opt

# 5. Export Final Deliverables
file mkdir "$proj_root/outputs"
file mkdir "$proj_root/reports"

write_verilog -output "$proj_root/outputs/picorv32_routed.v"
write_parasitics -output "$proj_root/outputs/picorv32.spef"
write_def -output "$proj_root/outputs/picorv32.def"
report_timing > "$proj_root/reports/signoff_timing.rpt"

puts "INFO: Full physical design flow finished successfully!"
exit
EOF