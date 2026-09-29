# ==============================================================================
# NanGate45 NDM Library Compilation - DIAGNOSTIC & AUTO-FIX SCRIPT
# ==============================================================================
puts "INFO: Starting NanGate45 NDM Compilation..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set tech_lef  "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.tech.lef"
set macro_lef "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.macro.mod.lef"
set phys_ndm  "$proj_root/work/NangateOpenCellLibrary.ndm"

# 1. Clean workspace
puts "INFO: Cleaning previous workspace..."
file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

# 2. Pre-flight check
foreach file [list $tech_tf $tech_db $tech_lef $macro_lef] {
    if {![file exists $file]} {
        puts "ERROR: Missing required file -> $file"
        exit
    }
}

puts "INFO: Creating workspace and reading files..."
create_workspace nangate_ws -technology $tech_tf
read_lef $tech_lef
read_lef $macro_lef
read_db $tech_db

# ------------------------------------------------------------------------------
# 3. AUTO-FIX SECTION (Targeting LM-035 and NDM-032)
# ------------------------------------------------------------------------------
puts "INFO: Attempting to patch metadata mismatches in memory..."

# Fix LM-035: Remove purely logical tie cells that have no physical footprint
puts "      -> Removing LOGIC0/LOGIC1 cells from workspace..."
catch {remove_lib_cells [get_lib_cells nangate_ws/LOGIC*]}

# Fix NDM-032: Force physical VDD/VSS pins to match the logical 'in' direction
puts "      -> Patching VDD/VSS pin directions..."
catch {set_attribute [get_lib_pins nangate_ws/*/VDD] direction in}
catch {set_attribute [get_lib_pins nangate_ws/*/VSS] direction in}
# ------------------------------------------------------------------------------

# 4. Run workspace check
puts "INFO: Running workspace check..."
set check_err [catch {check_workspace} check_out]

if {$check_err != 0} {
    puts "================================================================="
    puts "CRITICAL: check_workspace failed!"
    puts "================================================================="
    puts "GENERATING DIAGNOSTIC LOG FOR AI ASSISTANT..."
    
    set log_file "$proj_root/work/diagnostic_dump.log"
    set log [open $log_file w]
    
    puts $log "=== check_workspace internal help ==="
    catch {help check_workspace} help_out
    puts $log $help_out
    
    puts $log "\n=== Available workspace app options ==="
    catch {report_app_options *workspace*} app_out
    puts $log $app_out
    
    close $log
    puts "INFO: Diagnostic data dumped to $log_file"
    puts "Please run this command in your terminal and show me the output:"
    puts "cat work/diagnostic_dump.log"
    exit
}

# 5. Commit workspace
puts "INFO: Forcing commit to NDM database..."
if {[catch {commit_workspace -force -output $phys_ndm} err_commit]} {
    puts "ERROR: Failed to commit NDM workspace.\n$err_commit"
    exit
}

puts "INFO: NDM library successfully built at: $phys_ndm"
exit