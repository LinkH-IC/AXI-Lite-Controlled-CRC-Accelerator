create_clock -name sys_clk -period 10 [get_ports ACLK]

set_input_delay 1 -clock sys_clk [all_inputs]

set_input_delay 0 -clock sys_clk [get_ports ACLK]

set_output_delay 1 -clock sys_clk [all_outputs]
