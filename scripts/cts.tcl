################################################################################
# 4. Clock Tree Synthesis (CTS) Script (fc_shell)
################################################################################
puts "\[INFO\] Running cts.tcl..."

# --- 0. Setup and Load Placed Database ---
source scripts/setup.tcl

set NDM_LIB "work/${DESIGN_NAME}_lib.ndm"
if {[current_block -quiet] eq ""} {
    puts "\[INFO\] Opening NDM library and placed block..."
    open_lib $NDM_LIB
    open_block ${DESIGN_NAME}_placed
}

# --- 1. Synthesize Clock Tree ---
# Synthesizes clock buffers, balances skew, and optimizes hold/setup around the clock network
clock_opt -from_clock_tree -to_clock_tree

# --- 2. Generate CTS QoR Reports ---
file mkdir reports
redirect reports/02_cts_qor.rpt { report_qor }
redirect reports/02_cts_timing.rpt { report_timing -delay_type max }
redirect reports/02_cts_clock.rpt { report_clock_tree }

# --- 3. Save the Database ---
save_block -as ${DESIGN_NAME}_cts

puts "\[INFO\] CTS complete. Database saved to ${DESIGN_NAME}_cts."