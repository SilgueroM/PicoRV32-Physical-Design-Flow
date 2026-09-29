# ==============================================================================
# FreePDK45 NDM Compilation Script (icc2_lm_shell)
# ==============================================================================
puts "INFO: Starting FreePDK45 NDM compilation..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

# Paths to FreePDK45 files in the submodule
set tech_lef  "$proj_root/libraries/FreePDK45/FreePDK45/osu_soc/lib/files/tech.lef"
set macro_lef "$proj_root/libraries/FreePDK45/FreePDK45/osu_soc/lib/files/gscl45nm.lef"
set phys_ndm  "$proj_root/work/FreePDK45.ndm"

# 1. Clean and recreate work directory
file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

# 2. Create Workspace and read LEF
puts "INFO: Creating NDM workspace..."
create_workspace freepdk45_ws -technology $tech_lef

puts "INFO: Reading macro LEF..."
read_lef $macro_lef

# 3. Commit Workspace to generate NDM
puts "INFO: Committing NDM database..."
if {[catch {commit_workspace -output $phys_ndm} err]} {
    puts "ERROR: Failed to commit NDM workspace:\n$err"
    exit 1
}

puts "INFO: SUCCESS! Compiled NDM generated at: $phys_ndm"
exit