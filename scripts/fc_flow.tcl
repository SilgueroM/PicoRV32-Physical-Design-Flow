# ==============================================================================
# PicoRV32 Physical Design Flow - Fusion Compiler (FC) Feasibility Check
# Target Technology: SkyWater 130nm (sky130_fd_sc_hd)
# ==============================================================================

# 1. Environment & Path Resolution
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

# Shared nanoHUB Sky130 PDK library assets (Raw Text Files)
set sky130_base    "/apps/share64/rocky8/openpdks/openpdk-20241202/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd"
set logic_lib_raw  "$sky130_base/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set phys_lef       "$sky130_base/lef/sky130_fd_sc_hd.lef"

# Local repository technology files (Compiled Binaries & TF)
set tech_file  "$proj_root/tech/sky130_fd_sc_hd.tf"
set tech_db    "$proj_root/tech/sky130_fd_sc_hd.db"
set phys_ndm   "$proj_root/tech/sky130_fd_sc_hd.ndm"

# Ensure output and report directories exist
file mkdir "$proj_root/outputs"
file mkdir "$proj_root/reports"

# ==============================================================================
# 2. Automated Library Compilation (Runs system shells via Tcl 'exec')
# ==============================================================================

# Compile the ASCII .lib into a Synopsys .db if it doesn't exist yet
if {![file exists $tech_db]} {
    puts "=== Compiling .lib to .db using lc_shell ==="
    exec lc_shell -x "read_lib $logic_lib_raw; write_lib sky130_fd_sc_hd__tt_025C_1v80 -format db -output $tech_db; exit"
}

# Package the .db, .lef, and .tf into a Fusion Compiler .ndm if it doesn't exist yet
if {![file exists $phys_ndm]} {
    puts "=== Packaging .ndm using icc2_lm_shell ==="
    exec icc2_lm_shell -x "create_workspace sky130_ws -technology $tech_file; read_lef $phys_lef; read_db $tech_db; check_workspace; commit_workspace -output $phys_ndm; exit"
}

# ==============================================================================
# 3. Database Initialization & Library Binding
# ==============================================================================
set_app_var target_library $tech_db
set_app_var link_library "* $target_library"

catch { remove_lib workspace_rv32 }

# Create design library bound to the tech file AND the physical NDM reference library
create_lib workspace_rv32 -technology $tech_file -ref_libs $phys_ndm

# ==============================================================================
# 4. Design Read, Elaborate & Map
# ==============================================================================
analyze -format sverilog "$proj_root/rtl/picorv32.v"
elaborate picorv32
link

current_design picorv32
set_top_module picorv32

# 2.0ns Clock Constraint (500 MHz)
create_clock -name clk -period 2.0 [get_ports clk]

# Map RTL to technology logic gates before placement
compile_fusion -to initial_map

# ==============================================================================
# 5. Floorplanning & Site Row Definition
# ==============================================================================
initialize_floorplan -core_utilization 0.65 -shape R

# Explicitly build and snap core placement site rows so the placer finds them
create_core_area_rows

# ==============================================================================
# 6. Placement, CTS, and Routing
# ==============================================================================
compile_fusion -to initial_map

place_opt
clock_opt
route_auto
route_opt

# ==============================================================================
# 7. Deliverable Exports & Sign-Off Generation
# ==============================================================================
write_verilog -exclude {scalar_wire_declarations leaf_module_declarations} \
  "$proj_root/outputs/picorv32_routed.v"
write_parasitics -output "$proj_root/outputs/picorv32.spef"
write_def "$proj_root/outputs/picorv32.def"

save_block -as picorv32_routed_final
report_timing > "$proj_root/reports/timing_signoff.rpt"
report_area   > "$proj_root/reports/area_summary.rpt"
report_power  > "$proj_root/reports/power_summary.rpt"

puts "=== Fusion Compiler Flow Completed Successfully ==="
exit