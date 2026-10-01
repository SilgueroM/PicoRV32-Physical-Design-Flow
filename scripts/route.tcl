# ==============================================================================
# 5. Routing (fc_shell)
# ==============================================================================
puts "INFO: Running route.tcl..."

route_auto
route_opt

file mkdir "$proj_root/outputs"
write_verilog -output "$proj_root/outputs/picorv32_routed.v"
write_def -output "$proj_root/outputs/picorv32.def"

puts "INFO: Routing complete."