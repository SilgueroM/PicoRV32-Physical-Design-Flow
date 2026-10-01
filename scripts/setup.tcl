################################################################################
# Design & Library Setup Script for PicoRV32 Physical Design Flow
# Target Tool: Synopsys Fusion Compiler / Design Compiler
# Technology: NanGate 45nm Open Cell Library
################################################################################

# --- 1. Top Design Name & Paths ---
set DESIGN_NAME           "picorv32"
set DESIGN_REF_PATH       "libraries/NanGate45-Synopsys-Enablement/NanGate45"

# --- 2. Search Paths ---
set_app_var search_path ". \
  ${DESIGN_REF_PATH}/db \
  ${DESIGN_REF_PATH}/lib \
  ${DESIGN_REF_PATH}/lef \
  ${DESIGN_REF_PATH}/tf \
  ${DESIGN_REF_PATH}/tlup \
  design"

# --- 3. Target and Link Logical Libraries (.db) ---
# Primary timing DB for standard cells
set_app_var target_library "NangateOpenCellLibrary_typical.db"
set_app_var link_library   "* NangateOpenCellLibrary_typical.db"

# --- 4. Physical Technology & LEF Libraries ---
# Technology File (.tf)
set TECH_FILE      "${DESIGN_REF_PATH}/tf/NangateOpenCellLibrary.tf"

# Physical LEF files (Both macro and tech LEFs are required)
# Physical LEF files (Both macro and tech LEFs are required)
set LEF_FILES      [list \
                     "${DESIGN_REF_PATH}/lef/NangateOpenCellLibrary.tech.lef" \
                     "${DESIGN_REF_PATH}/lef/NangateOpenCellLibrary.macro.mod.lef" \
                   ]

# --- 5. Parasitic Extraction Files (TLU+) ---
# Correct filenames based on the actual repository structure
set MAP_FILE   "${DESIGN_REF_PATH}/tlup/NangateOpenCellLibrary.layermap"
set TLUP_FILE  "${DESIGN_REF_PATH}/tlup/NangateOpenCellLibrary.tlup"

# Read the parasitic technology into Fusion Compiler
puts "\[INFO\] Loading TLU+ Parasitic RC models..."
read_parasitic_tech -tlup $TLUP_FILE -layermap $MAP_FILE -name typical_rc

# Apply the loaded RC models to the current design
set_parasitic_parameters -early_spec typical_rc -late_spec typical_rc