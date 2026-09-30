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
create_lib $NDM_LIB -technology $TECH_FILE -ref_libs "$LEF_FILES"
open_lib $NDM_LIB

# --- 3. Read RTL & Constraints ---
# Analyze and elaborate the RTL source
analyze -format verilog design/picorv32.v
elaborate picorv32

# Explicitly set the top module for Fusion Compiler
set_top_module picorv32

# Link logical instances to physical libraries
link

# Apply timing constraints
read_sdc design/constraints.sdc

# --- 4. Initialize Floorplan ---
# Target: Square shape (1:1 ratio), 60% core utilization, and a 10um margin 
# on all 4 sides between the core standard cells and the die boundary.
initialize_floorplan -control_type core \
                     -shape R \
                     -side_ratio {1.0 1.0} \
                     -core_utilization 0.6 \
                     -core_offset {10 10 10 10}

# --- 5. Power Grid Synthesis (PDN) ---
# Define global logical power and ground nets
create_net -power VDD
create_net -ground VSS

# Connect logical standard cell power pins to the global nets
connect_pg_net -net VDD [get_pins -hierarchical "*/VDD"]
connect_pg_net -net VSS [get_pins -hierarchical "*/VSS"]

# Build Standard Cell Rails on Metal 1
create_pg_std_cell_conn_pattern std_pattern -layers metal1
set_pg_strategy std_strat -pattern {{name: std_pattern} {nets: {VDD VSS}}} -core

# Compile the power network
compile_pg -strategies std_strat

# --- 6. I/O Pin Placement ---
# Let the tool automatically distribute the input/output ports around the boundary
set_app_options -name plan.pins.incremental -value false
place_pins -self

# --- 7. Save Database ---
# Save the current state as a block inside the NDM library
save_block -as ${DESIGN_NAME}_floorplan
puts "\[INFO\] Floorplan complete! Database saved to ${NDM_LIB}:${DESIGN_NAME}_floorplan"