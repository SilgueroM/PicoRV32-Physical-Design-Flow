# ==============================================================================
# PicoRV32 Logical Synthesis Script (FreePDK45 / OSU Cells)
# ==============================================================================
puts "INFO: Initializing Synthesis Flow..."

set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file normalize "$script_dir/.."]

# Paths to FreePDK45 standard cell libraries
set target_db  "$proj_root/libraries/FreePDK45/FreePDK45/osu_soc/lib/files/gscl45nm.db"
set rtl_file   "$proj_root/rtl/picorv32.v"

# Set target and link libraries
set target_library $target_db
set link_library   "* $target_library"

# Define design library work path
define_design_lib WORK -path "$proj_root/work"

# 1. Read RTL and Elaborate
puts "INFO: Reading RTL source files..."
read_verilog -rtl $rtl_file
current_design picorv32
link

# 2. Timing Constraints (1 GHz / 1.0ns period target)
create_clock -name clk -period 1.0 [get_ports clk]
set_driving_cell -lib_cell INVX1 [all_inputs]
set_input_delay  0.1 -clock clk [remove_from_collection [all_inputs] clk]
set_output_delay 0.1 -clock clk [all_outputs]

# 3. Compile & Optimize
puts "INFO: Running synthesis optimization..."
compile -map_effort medium -ungroup_all

# 4. Export Synthesis Outputs
file mkdir "$proj_root/outputs"
file mkdir "$proj_root/reports"

write -f verilog -hierarchy -output "$proj_root/outputs/picorv32_synth.v"
write_sdc "$proj_root/outputs/picorv32_synth.sdc"
write -f db -hierarchy -output "$proj_root/outputs/picorv32_synth.db"

redirect "$proj_root/reports/synth_timing.rpt" { report_timing }
redirect "$proj_root/reports/synth_area.rpt"   { report_area }

puts "INFO: Synthesis completed successfully!"
exit