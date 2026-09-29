# ==============================================================================
# NanGate45 NDM Library Compilation Script
# ==============================================================================
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set tech_lef  "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.tech.lef"
set macro_lef "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.macro.mod.lef"
set phys_ndm  "$proj_root/work/NangateOpenCellLibrary.ndm"

file mkdir "$proj_root/work"

puts "INFO: Creating workspace using NanGate technology file..."
create_workspace nangate_ws -technology $tech_tf

puts "INFO: Reading technology and macro LEF files..."
read_lef $tech_lef
read_lef $macro_lef

puts "INFO: Reading standard cell database (.db)..."
read_db $tech_db

puts "INFO: Checking and committing workspace to NDM..."
check_workspace
commit_workspace -output $phys_ndm

puts "INFO: NDM library successfully built at $phys_ndm"
exit