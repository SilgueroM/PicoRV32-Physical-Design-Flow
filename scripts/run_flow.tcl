################################################################################
# Master RTL-to-GDSII Flow Script for Fusion Compiler
################################################################################
puts "\[INFO\] Starting full RTL-to-GDSII flow for picorv32..."

source scripts/setup.tcl
source scripts/floorplan.tcl
source scripts/place.tcl
source scripts/cts.tcl
source scripts/route.tcl
source scripts/pex.tcl
source scripts/sta.tcl
source scripts/gds_out.tcl

puts "\[INFO\] Full RTL-to-GDSII flow completed successfully! All outputs generated."