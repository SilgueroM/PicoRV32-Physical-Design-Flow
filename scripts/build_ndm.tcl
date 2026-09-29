# ==============================================================================
# NanGate45 NDM Library Compilation
# ==============================================================================
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set tech_lef  "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.tech.lef"
set macro_lef "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.macro.mod.lef"
set phys_ndm  "$proj_root/work/NangateOpenCellLibrary.ndm"

file mkdir "$proj_root/work"

create_workspace nangate_ws -technology $tech_tf
read_lef $tech_lef
read_lef $macro_lef
read_db $tech_db
check_workspace
commit_workspace -output $phys_ndm

puts "INFO: NDM library successfully built at $phys_ndm"
exit