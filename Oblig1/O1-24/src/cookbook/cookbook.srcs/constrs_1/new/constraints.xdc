set_property PACKAGE_PIN U21 [get_ports {count[3]}]
set_property PACKAGE_PIN U22 [get_ports {count[2]}]
set_property PACKAGE_PIN T21 [get_ports {count[1]}]
set_property PACKAGE_PIN T22 [get_ports {count[0]}]
set_property PACKAGE_PIN F21 [get_ports {inp[3]}]
set_property PACKAGE_PIN H22 [get_ports {inp[2]}]
set_property PACKAGE_PIN G22 [get_ports {inp[1]}]
set_property PACKAGE_PIN F22 [get_ports {inp[0]}]
set_property PACKAGE_PIN T18 [get_ports clk]
set_property PACKAGE_PIN P16 [get_ports reset]
set_property PACKAGE_PIN M15 [get_ports load]
set_property PACKAGE_PIN U14 [get_ports max_count]
set_property PACKAGE_PIN U19 [get_ports min_count]
set_property PACKAGE_PIN H17 [get_ports up]

set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]

set_property IOSTANDARD LVCMOS33 [get_ports {inp[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {inp[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {inp[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {inp[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports load]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports up]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]

create_clock -period 10.000 -waveform {0.000 5.000} [get_ports clk]
