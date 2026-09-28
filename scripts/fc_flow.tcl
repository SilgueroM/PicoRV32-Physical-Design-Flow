# ==============================================================================
# PicoRV32 Physical Design Flow - Fusion Compiler (FC) Feasibility Check
# Target Technology: SkyWater 130nm (sky130_fd_sc_hd)
# ==============================================================================

# 1. Environment & Path Resolution
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

# Local repository technology file (your committed .tf file)
set tech_file  "$proj_root/tech/sky130_fd_sc_hd.tf"

# Shared nanoHUB Sky130 PDK library assets
set sky130_base "/apps/share64/rocky8/openpdks/openpdk-20241202/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd"
set logic_lib   "$sky130_base/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set phys_lef    "$sky130_base/lef/sky130_fd_sc_hd.lef"

# Ensure output and report directories exist
file mkdir "$proj_root/outputs"
file mkdir "$proj_root/reports"

# 2. Database Initialization & Library Binding
catch { remove_lib workspace_rv32 }

# Create design library bound to the Sky130 technology file
create_lib workspace_rv32 -technology $tech_file

# Ingest standard cell logical timing and physical geometry on the fly
read_lib $logic_lib
read_lef $phys_lef

# 3. Design Read & Synthesis Map
read_verilog "$proj_root/rtl/picorv32.v"
current_design picorv32
link

# Clock Constraint (500 MHz / 2.0ns period to ensure feasible setup closure in Sky130 HD)
create_clock -name clk -period 2.0 [get_ports clk]

# Execute initial logic synthesis map
compile_fusion -to initial_map

# 4. Floorplanning & Power Mesh
initialize_floorplan -core_utilization 0.65 -shape R
create_power_plan -nets {VDD VSS} -strategy ring_and_stripe

# 5. Placement & Clock Tree Synthesis (CTS)
place_opt
clock_opt

# 6. Routing & Post-Route Optimization
route_auto
route_opt

# 7. Deliverable Exports & Sign-Off Generation
write_verilog -exclude {scalar_wire_declarations leaf_module_declarations} \
  "$proj_root/outputs/picorv32_routed.v"
write_parasitics -output "$proj_root/outputs/picorv32.spef"
write_def "$proj_root/outputs/picorv32.def"

# Save the compiled database and dump reports
save_block -as picorv32_routed_final
report_timing > "$proj_root/reports/timing_signoff.rpt"
report_area   > "$proj_root/reports/area_summary.rpt"
report_power  > "$proj_root/reports/power_summary.rpt"

puts "=== Fusion Compiler Flow Completed Successfully ==="
exit