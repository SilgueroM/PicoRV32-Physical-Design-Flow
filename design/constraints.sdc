################################################################################
# PicoRV32 Timing Constraints (500 MHz)
################################################################################

set CLK_PERIOD 2.0

# 1. Clock Definition
create_clock -name clk -period $CLK_PERIOD [get_ports clk]

# 2. I/O Delays
# Apply input delay to all input ports EXCEPT the clock itself
set_input_delay 0.8 -clock clk [get_ports -filter "direction == in && name != clk"]

# Apply output delay to all output ports
set_output_delay 0.8 -clock clk [all_outputs]

# 3. Environment constraints
set_load 0.05 [all_outputs]