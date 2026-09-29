# ==============================================================================
# PicoRV32 Physical Design Flow - NanGate45 "Bulletproof" Script
# ==============================================================================
puts "=== [DEBUG] Starting Bulletproof FC Run ==="

# 1. Environment Setup
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

file mkdir "$proj_root/outputs"
file mkdir "$proj_root/reports"
file mkdir "$proj_root/work"

# Open our custom debug log
set debug_log [open "$proj_root/reports/cracked_debug.log" w]
puts $debug_log "=== PICO RV32 CRACKED DEBUG LOG ==="

# 2. Exact Paths (Based flawlessly on your VS Code Screenshots)
set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set tech_lef  "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.tech.lef"
set macro_lef "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.macro.mod.lef"
set phys_ndm  "$proj_root/work/NangateOpenCellLibrary.ndm"
set rtl_file  "$proj_root/rtl/picorv32.v"

# 3. Pre-Flight File Checks (Zero Tolerance for Missing Files)
puts "=== [DEBUG] Verifying Library Files Exist ==="
foreach file [list $tech_tf $tech_db $tech_lef $macro_lef $rtl_file] {
    if {![file exists $file]} {
        set err_msg "CRITICAL ERROR: Cannot find file -> $file"
        puts $err_msg
        puts $debug_log $err_msg
        close $debug_log
        exit
    }
}
puts "=== [DEBUG] All files verified. ==="

# 4. Automated NDM Compilation (Builds physical library if it doesn't exist)
if {![file exists $phys_ndm]} {
    puts "=== [DEBUG] NDM missing. Packaging via icc2_lm_shell... ==="
    
    # Write a quick script for the library manager
    set lm_script [open "$proj_root/work/build_ndm.tcl" w]
    puts $lm_script "create_workspace nangate_ws -technology $tech_tf"
    puts $lm_script "read_lef $tech_lef"
    puts $lm_script "read_lef $macro_lef"
    puts $lm_script "read_db $tech_db"
    puts $lm_script "check_workspace"
    puts $lm_script "commit_workspace -output $phys_ndm"
    puts $lm_script "exit"
    close $lm_script
    
    # Execute the library manager in the background
    if {[catch {exec icc2_lm_shell -f "$proj_root/work/build_ndm.tcl"} lm_err]} {
        puts "CRITICAL ERROR: NDM generation failed. Check debug log."
        puts $debug_log "NDM GEN ERROR:\n$lm_err"
        close $debug_log
        exit
    }
    puts "=== [DEBUG] NDM physical database successfully generated! ==="
}

# 5. Tool Setup & Database Binding
set_app_var target_library $tech_db
set_app_var link_library "* $target_library"

catch { remove_lib workspace_rv32 }
if {[catch {create_lib workspace_rv32 -technology $tech_tf -ref_libs $phys_ndm} err_lib]} {
    puts "CRITICAL ERROR: Failed to create FC workspace. Check debug log."
    puts $debug_log "WORKSPACE ERROR:\n$err_lib"
    exit
}

# 6. Read RTL & Synthesize
puts "=== [DEBUG] Elaborating & Synthesizing RTL ==="
analyze -format sverilog $rtl_file
elaborate picorv32
link
current_design picorv32

create_clock -name clk -period 2.0 [get_ports clk]
compile_fusion -to initial_map

# 7. Floorplan & Placement Track Verification
puts "=== [DEBUG] Floorplanning ==="
if {[catch {initialize_floorplan -core_utilization 0.7 -shape R} err_fp]} {
    puts "FLOORPLAN CRASHED. Check debug log."
    puts $debug_log "FLOORPLAN ERROR:\n$err_fp"
    exit
}

# Trap the row report to ensure we have physical placement tracks!
redirect -variable row_rep {report_site_row}
puts "=== [DEBUG] Site Row Status: ==="
puts $row_rep
puts $debug_log "SITE ROW STATUS:\n$row_rep"

if {[string match "*No site rows*" $row_rep]} {
    puts "CRITICAL ERROR: Floorplan drew 0 rows. Place_opt will crash. Exiting safely."
    exit
}

# 8. Placement & Routing
puts "=== [DEBUG] Running Placement ==="
if {[catch {place_opt} err_place]} {
    global errorInfo
    puts "PLACEMENT CRASHED. Check debug log."
    puts $debug_log "PLACEMENT ERROR:\n$err_place\n$errorInfo"
    exit
}

puts "=== [DEBUG] Running CTS and Routing ==="
clock_opt
route_auto
route_opt

# 9. Deliverables Export
puts "=== [DEBUG] Exporting Sign-off Deliverables ==="
write_verilog -output "$proj_root/outputs/picorv32_routed.v"
write_parasitics -output "$proj_root/outputs/picorv32.spef"
write_def -output "$proj_root/outputs/picorv32.def"

report_timing > "$proj_root/reports/timing_signoff.rpt"
report_area   > "$proj_root/reports/area_summary.rpt"
report_power  > "$proj_root/reports/power_summary.rpt"

puts "=== [SUCCESS] CRACKED FLOW FINISHED FLAWLESSLY ==="
close $debug_log
exit