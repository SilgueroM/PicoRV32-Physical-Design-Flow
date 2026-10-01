# ==============================================================================
# 7. Static Timing Analysis & Signoff (fc_shell)
# ==============================================================================
puts "INFO: Running sta.tcl..."

file mkdir "$proj_root/reports"

report_timing -delay_type max > "$proj_root/reports/signoff_setup_timing.rpt"
report_timing -delay_type min > "$proj_root/reports/signoff_hold_timing.rpt"
report_area > "$proj_root/reports/signoff_area.rpt"
report_power > "$proj_root/reports/signoff_power.rpt"

puts "INFO: STA and Signoff complete."