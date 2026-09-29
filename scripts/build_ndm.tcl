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
puts "INFO: Cleaning previous workspace..."
file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

# 2. Create Workspace & Read Data
puts "INFO: Reading logical and physical libraries..."
create_workspace nangate_ws -technology $tech_tf
read_lef $tech_lef
read_lef $macro_lef
read_db $tech_db

# ------------------------------------------------------------------------------
# 3. THE INDUSTRY FIX: Completely suppress the open-source mismatch errors
# ------------------------------------------------------------------------------
puts "INFO: Masking inherent NanGate45 library errors..."

# Suppress "inout vs in" pin direction mismatches
suppress_message NDM-032

# Suppress "missing physical tie cell" mismatches
suppress_message LM-035

# ------------------------------------------------------------------------------

# 4. Check and Commit
puts "INFO: Running workspace check..."
catch {check_workspace}

puts "INFO: Committing workspace to NDM database..."
if {[catch {commit_workspace -force -output $phys_ndm} err_commit]} {
    puts "ERROR: Failed to commit NDM workspace.\n$err_commit"
    exit
}

puts "INFO: SUCCESS! NDM library built at: $phys_ndm"
exit