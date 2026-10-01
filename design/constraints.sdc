# ==============================================================================
# PicoRV32 Timing Constraints (constraints.sdc)
# ==============================================================================

# Define main clock: 10ns clock period (100 MHz)
create_clock -name clk -period 10.0 [get_ports clk]

# Set clock uncertainties
set_clock_uncertainty 0.1 [get_clocks clk]

# Input and Output delays relative to the clock
set_input_delay 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock clk [all_outputs]

# Typical driving cell and load configuration
set_driving_cell -lib_cell BUFX2 [all_inputs]
set_load 0.05 [all_outputs]