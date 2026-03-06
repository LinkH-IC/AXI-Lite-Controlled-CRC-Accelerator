read_liberty ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set top "axi_crc_top"

read_verilog top_synth.v
link_design $top

read_sdc constraints.sdc

report_clock_properties

report_checks

puts "--- Setup (Max) Summary ---"
report_wns
report_tns
puts "--- Hold (Min) Summary ---"
report_wns -min
report_tns -min

report_check_types -max_slew -max_capacitance

exit
