# ==============================================================================
# FreePDK3 NDM Compilation Script (icc2_lm_shell)
# ==============================================================================
puts "INFO: Starting FreePDK3 NDM compilation..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

# Exact path to the FreePDK3 tech file from your repository tree
set tech_tf   "$proj_root/libraries/FreePDK3/syncust/techfiles/NCSU_TechLib_FreePDK3_CC.tf"
set work_dir  "$proj_root/work"
set phys_ndm  "$proj_root/work/FreePDK3.ndm"

# 1. Clean and recreate the working directory
file delete -force $work_dir
file mkdir $work_dir

# 2. Create the NDM workspace using the tech file
puts "INFO: Creating workspace with technology file..."
create_workspace freepdk3_ws -technology $tech_tf

# 3. Commit the workspace to output the compiled .ndm database
puts "INFO: Committing workspace to generate NDM..."
if {[catch {commit_workspace -output $phys_ndm} err]} {
    puts "ERROR: Failed to commit NDM workspace:\n$err"
    exit 1
}

puts "INFO: SUCCESS! Compiled NDM generated at: $phys_ndm"
exit