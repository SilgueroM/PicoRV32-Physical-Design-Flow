################################################################################
# PicoRV32 Floorplan Script 
# Target Tool: Synopsys Fusion Compiler
################################################################################

# --- 1. Load Environment & Setup ---
source scripts/setup.tcl

# Ensure the working directory exists
file mkdir work

# --- 2. Create the Design Library (NDM) ---
set NDM_LIB "work/${DESIGN_NAME}_lib.ndm"
if {[file exists $NDM_LIB]} {
    file delete -force $NDM_LIB
}

# Create and open the Fusion Compiler working library
create_lib $NDM_LIB -technology $TECH_FILE -ref_libs $LEF_FILES
open_lib $NDM_LIB

# --- 2.5 Load TLU+ Parasitic RC Models (Now that a library is open) ---
puts "\[INFO\] Loading TLU+ Parasitic RC models..."
read_parasitic_tech -tlup $TLUP_FILE -layermap $MAP_FILE -name typical_tlup
set_parasitic_parameters -early_spec typical_tlup -late_spec typical_tlup

# --- 3. Read RTL & Constraints ---
analyze -format verilog design/picorv32.v
elaborate picorv32
set_top_module picorv32
link
read_sdc design/constraints.sdc

# --- 4. Initialize Floorplan ---
initialize_floorplan -control_type aspect_ratio \
                     -core_aspect_ratio 1.0 \
                     -core_utilization 0.6 \
                     -boundary_offset {10 10 10 10}

# --- 5. Power Grid Synthesis (PDN) ---
create_net -power VDD
create_net -ground VSS
connect_pg_net -net VDD [get_pins -hierarchical "*/VDD"]
connect_pg_net -net VSS [get_pins -hierarchical "*/VSS"]

create_pg_std_cell_conn_pattern std_pattern -layers metal1
set_pg_strategy std_strat -pattern {{name: std_pattern} {nets: {VDD VSS}}} -core
compile_pg -strategies std_strat

# --- 6. I/O Pin Placement & Verifications ---
set_app_options -name plan.pins.incremental -value false
place_pins -self

puts "\[INFO\] Verifying NanGate45 Site Definitions:"
get_site_defs

puts "\[INFO\] Verifying NanGate45 Site Rows:"
get_site_rows

# --- 7. Save Database ---
save_block -as ${DESIGN_NAME}_floorplan
puts "\[INFO\] Floorplan complete! Database saved to ${NDM_LIB}:${DESIGN_NAME}_floorplan"