# 1. Setup Libraries & Technology LEF
set tech_db "/apps/share64/rocky8/freepdk/freepdk45-1.4/FreePDK45/osu_soc/lib/files/gscl45nm.db"
set phys_lef "/apps/share64/rocky8/freepdk/freepdk45-1.4/FreePDK45/osu_soc/lib/files/gscl45nm.lef"

set target_library $tech_db
set link_library "* $tech_db"

# Safely close current block and remove existing library if it's open/cached
current_block -q
close_block -q
if {[file exists workspace_rv32] || [get_libs -quiet workspace_rv32] ne ""} {
    remove_lib -force workspace_rv32
}

# Create design library and read physical LEF
create_lib workspace_rv32
read_lef $phys_lef