# ==============================================================================
# FreePDK45 NDM Compilation Script (icc2_lm_shell)
# ==============================================================================
puts "INFO: Starting FreePDK45 NDM compilation..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

# Paths: Use the .tf file for tech setup, and .lef for standard cell geometries
set tech_tf   "$proj_root/libraries/FreePDK45/FreePDK45/ncsu_basekit/techfile/FreePDK45.tf"
set macro_lef "$proj_root/libraries/FreePDK45/FreePDK45/osu_soc/lib/files/gscl45nm.lef"
set phys_ndm  "$proj_root/work/FreePDK45.ndm"

# 1. Clean and recreate work directory
file delete -force "$proj_root/work"
file mkdir "$proj_root/work"

# 2. Create Workspace using the Synopsys technology file (.tf)
puts "INFO: Creating NDM workspace with technology file..."
create_workspace freepdk45_ws -technology $tech_tf

# 3. Read the standard cell LEF file
puts "INFO: Reading standard cell LEF..."
read_lef $macro_lef

# 4. Commit Workspace to generate the NDM database
puts "INFO: Committing NDM database..."
if {[catch {commit_workspace -output $phys_ndm} err]} {
    puts "ERROR: Failed to commit NDM workspace:\n$err"
    exit 1
}

puts "INFO: SUCCESS! Compiled NDM generated at: $phys_ndm"
exit