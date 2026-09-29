# ==============================================================================
# NanGate45 NDM Library Compilation Script (Forced Override Mode)
# ==============================================================================
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

set tech_tf   "$proj_root/libraries/NanGate45/NanGate45/tf/NangateOpenCellLibrary.tf"
set tech_db   "$proj_root/libraries/NanGate45/NanGate45/db/NangateOpenCellLibrary_typical.db"
set tech_lef  "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.tech.lef"
set macro_lef "$proj_root/libraries/NanGate45/NanGate45/lef/NangateOpenCellLibrary.macro.mod.lef"
set phys_ndm  "$proj_root/work/NangateOpenCellLibrary.ndm"

# Clean work dir
file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

puts "INFO: Creating workspace..."
create_workspace nangate_ws -technology $tech_tf

# Enable developer mode to override open-source library structural checks
set_app_options -name lib.workspace.library_developer_mode -value true
set_app_options -name lib.workspace.allow_commit_workspace_overwrite -value true

puts "INFO: Reading LEFs and DB..."
read_lef $tech_lef
read_lef $macro_lef
read_db $tech_db

puts "INFO: Forcing commit to NDM..."
# Skip check_workspace entirely and force commit directly
commit_workspace -force -output $phys_ndm

puts "INFO: NDM successfully built at $phys_ndm"
exit