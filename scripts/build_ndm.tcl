cat << 'EOF' > scripts/build_ndm.tcl
# ==============================================================================
# FreePDK45 NDM Compilation Script (icc2_lm_shell)
# ==============================================================================
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

set tech_lef  "$proj_root/libraries/FreePDK45/FreePDK45/osu_soc/lib/files/tech.lef"
set macro_lef "$proj_root/libraries/FreePDK45/FreePDK45/osu_soc/lib/files/gscl45nm.lef"
set phys_ndm  "$proj_root/work/FreePDK45.ndm"

file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

puts "INFO: Creating workspace..."
create_workspace freepdk45_ws -technology $tech_lef
read_lef $macro_lef

puts "INFO: Committing NDM database..."
commit_workspace -output $phys_ndm
puts "INFO: NDM successfully built at $phys_ndm"
exit
EOF