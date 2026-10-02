################################################################################
# 6. Final Finishing & GDSII Export Script (fc_shell)
################################################################################
puts "\[INFO\] Running final finishing and GDSII export..."

# --- 0. Load Routed Database ---
source scripts/setup.tcl

set NDM_LIB "work/${DESIGN_NAME}_lib.ndm"
if {[current_block -quiet] eq ""} {
    open_lib $NDM_LIB
    open_block ${DESIGN_NAME}_routed
}

# --- 1. Insert Filler Cells & Metal Fill ---
# Inserts decap/tap filler cells to satisfy DRC rules and metal density fill
insert_stdcell_fillers -lib_cell_name {TAPCELL_X1 FILL1 FILL2 FILL4 FILL8 FILL16}
route_metal_fill

# --- 2. Save Final Block & Export GDSII ---
save_block -as ${DESIGN_NAME}_final
file mkdir outputs
write_gds -compress outputs/picorv32.gds

puts "\[INFO\] GDSII export complete. Final layout saved to outputs/picorv32.gds."