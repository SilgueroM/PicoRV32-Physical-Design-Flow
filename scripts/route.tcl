# ==============================================================================
# 5. Routing (fc_shell)
# ==============================================================================
puts "INFO: Running route.tcl..."

route_auto
route_opt

file mkdir outputs
write_verilog outputs/picorv32_routed.v
write_def outputs/picorv32.def

puts "INFO: Routing complete."