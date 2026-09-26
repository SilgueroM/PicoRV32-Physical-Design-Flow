# 1. Setup Libraries (REPLACE PATHS WITH YOUR NANOHUB PATHS)
set tech_lib "/path/to/freepdk/logic/freepdk45_typical.db"
set phys_lib "/path/to/freepdk/phys/freepdk45_tech.ndm"
set target_library $tech_lib
set link_library "* $tech_lib"

create_lib workspace_rv32 -technology $phys_lib -ref_libs $phys_lib

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