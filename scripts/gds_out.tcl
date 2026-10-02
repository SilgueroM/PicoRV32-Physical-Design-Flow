################################################################################
# 6. Final Finishing & GDSII Export Script (fc_shell)
################################################################################
puts "\[INFO\] Running final finishing and GDSII export..."

# --- 0. Load STA/PEX Database ---
source scripts/setup.tcl

set NDM_LIB "work/${DESIGN_NAME}_lib.ndm"
if {[current_block -quiet] eq ""} {
    open_lib $NDM_LIB
    open_block ${DESIGN_NAME}_routed
}

# --- 1. Insert Standard Cell Fillers ---
create_stdcell_fillers -lib_cells {FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1}

# --- 2. Save Final Block & Export GDSII ---
save_block -as ${DESIGN_NAME}_final
file mkdir outputs
write_gds outputs/picorv32.gds

puts "\[INFO\] GDSII export complete. Final layout saved to outputs/picorv32.gds."