# 1. Setup Libraries
set tech_lib "/apps/share64/rocky8/freepdk/freepdk45-1.4/FreePDK45/osu_soc/lib/files/gscl45nm.db"
set phys_ndm "freepdk45.ndm"

set target_library $tech_lib
set link_library "* $tech_lib"

# Create the Fusion Compiler workspace using the compiled NDM
create_lib workspace_rv32 -ref_libs $phys_ndm

# 2. Read RTL & Synthesize
read_verilog ../rtl/picorv32.v
current_design picorv32
link

# 1 GHz Clock Constraint
create_clock -name clk -period 1.0 [get_ports clk]
compile_fusion -to initial_map

# 3. Floorplanning & Power Mesh
initialize_floorplan -core_utilization 0.7 -shape R
create_power_plan -nets {VDD VSS} -strategy ring_and_stripe

# 4. Placement & Clock Tree Synthesis (CTS)
place_opt
clock_opt

# 5. Routing
route_auto
route_opt

# 6. Export Files for Sign-off
write_verilog ../outputs/picorv32_routed.v
write_parasitics -output ../outputs/picorv32.spef
write_def -output ../outputs/picorv32.def

save_block -as picorv32_final
exit