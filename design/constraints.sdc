################################################################################
# Synopsys Design Constraints (SDC) for PicoRV32
# Target Frequency: 500 MHz (2.0ns period)
################################################################################

# --- 1. Clock Definition ---
# Define the main system clock on the 'clk' port with a 2.0ns period
create_clock -name clk -period 2.0 [get_ports clk]

# Model clock network non-idealities (jitter, skew)
set_clock_uncertainty 0.1 [get_clocks clk]

# Model the expected slew rate (transition time) of the clock
set_clock_transition 0.1 [get_clocks clk]

# --- 2. Input/Output Delays ---
# Constrain inputs: assume external logic consumes 0.8ns (40%) of the 2.0ns cycle
# We exclude the clock port itself from this constraint.
set_input_delay 0.8 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

# Constrain outputs: assume external downstream logic needs 0.8ns to setup
set_output_delay 0.8 -clock clk [all_outputs]

# --- 3. Environmental Attributes ---
# Apply a realistic transition time on all input signals (models external drivers)
set_input_transition 0.1 [all_inputs]

# Apply a generic capacitive load to all outputs to force realistic sizing of output drivers
set_load 0.05 [all_outputs]