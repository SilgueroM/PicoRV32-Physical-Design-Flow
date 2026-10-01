# ==============================================================================
# 6. Parasitic Extraction (fc_shell)
# ==============================================================================
puts "INFO: Running pex.tcl..."

file mkdir "$proj_root/outputs"
write_parasitics -output "$proj_root/outputs/picorv32.spef"

puts "INFO: Extraction complete."