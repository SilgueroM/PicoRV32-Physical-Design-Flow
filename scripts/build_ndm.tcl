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

# 1. Clean previous build
puts "INFO: Cleaning previous workspace and work directory..."
file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

# 2. Pre-flight check
foreach file [list $tech_tf $tech_db $tech_lef $macro_lef] {
    if {![file exists $file]} {
        puts "ERROR: Missing required library file -> $file"
        exit
    }
}

# 3. Create Workspace
puts "INFO: Creating workspace using NanGate technology file..."
create_workspace nangate_ws -technology $tech_tf

# 4. Set Exact App Options Found in Diagnostic Dump
set_app_options -name lib.workspace.allow_commit_workspace_overwrite -value true
set_app_options -name lib.workspace.library_developer_mode -value true
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true

puts "INFO: Reading physical (LEF) and logical (.db) libraries..."
read_lef $tech_lef
read_lef $macro_lef
read_db $tech_db

puts "INFO: Checking workspace..."
catch {check_workspace}

puts "INFO: Committing workspace to NDM database..."
if {[catch {commit_workspace -output $phys_ndm} err_commit]} {
    puts "ERROR: Failed to commit NDM workspace.\n$err_commit"
    exit
}

puts "INFO: NDM library successfully built at: $phys_ndm"
exit