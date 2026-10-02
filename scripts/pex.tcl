# ==============================================================================
# 6. Parasitic Extraction (fc_shell)
# ==============================================================================
puts "INFO: Running pex.tcl..."

set proj_root [pwd]

file mkdir "$proj_root/outputs"
write_parasitics -output "$proj_root/outputs/picorv32.spef"

puts "INFO: Extraction complete."