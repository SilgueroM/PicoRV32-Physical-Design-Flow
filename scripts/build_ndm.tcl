# ==============================================================================
# NanGate45 NDM Library Compilation Script
# ==============================================================================
puts "INFO: Starting NanGate45 NDM Compilation..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set tech_lef  "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.tech.lef"
set macro_lef "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.macro.mod.lef"
set phys_ndm  "$proj_root/work/NangateOpenCellLibrary.ndm"

# 1. Clean workspace directory
puts "INFO: Cleaning previous workspace and work directory..."
file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

# 2. Pre-flight file check
foreach file [list $tech_tf $tech_db $tech_lef $macro_lef] {
    if {![file exists $file]} {
        puts "ERROR: Missing required library file -> $file"
        exit
    }
}

# 3. Create Workspace and set developer options
puts "INFO: Creating workspace using NanGate technology file..."
create_workspace nangate_ws -technology $tech_tf

set_app_options -name lib.workspace.allow_commit_workspace_overwrite -value true
set_app_options -name lib.workspace.library_developer_mode -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true

puts "INFO: Reading LEF and DB files..."
read_lef $tech_lef
read_lef $macro_lef
read_db $tech_db

# 4. Purge physical-less tie cells matching LOGIC* (LOGIC0_X1, LOGIC1_X1)
puts "INFO: Purging physical-less LOGIC* cells from memory..."
catch {remove_lib_cells [get_lib_cells nangate_ws/LOGIC*]}

# 5. Check and Commit
puts "INFO: Running workspace check..."
catch {check_workspace}

puts "INFO: Committing workspace to NDM database..."
if {[catch {commit_workspace -output $phys_ndm} err_commit]} {
    puts "ERROR: Failed to commit NDM workspace.\n$err_commit"
    exit
}

puts "INFO: NDM library successfully built at: $phys_ndm"
exit