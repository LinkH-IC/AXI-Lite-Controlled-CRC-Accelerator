read_liberty ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set top "axi_crc_top"

read_verilog top_synth.v
link_design $top

read_sdc constraints.sdc

report_checks
report_tns
report_wns
report_clock_properties
report_check_types -max_slew -max_capacitance

exit
