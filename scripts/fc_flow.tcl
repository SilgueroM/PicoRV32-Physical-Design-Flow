# 1. Setup Libraries & Exact Verified Paths
set sky130_base "/apps/share64/rocky8/openpdks/openpdk-20241202/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd"

set logic_lib "$sky130_base/lib/sky130_fd_sc_hd__tt_025C_1v80.lib" 
set phys_lef "$sky130_base/lef/sky130_fd_sc_hd.lef"

# Safely clear out any cached library session state
catch { remove_lib workspace_rv32 }

# Create design library and bind the physical tech LEF natively
create_lib workspace_rv32 -technology $phys_lef

# Ingest the logical timing models directly into the library since we don't have a .db file
read_lib $logic_lib

# 2. Read RTL & Synthesize
read_verilog ../rtl/picorv32.v
current_design picorv32
link

# 1 GHz Clock Constraint (May need to lower to 500MHz / 2.0ns if Sky130 struggles to close timing)
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