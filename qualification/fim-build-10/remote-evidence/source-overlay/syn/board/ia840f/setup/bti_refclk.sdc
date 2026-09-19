# Standalone preservation clock only; donor eth_top.sdc:16. No Ethernet timing paths.
create_clock -name qsfp_ref_clk -period 6.400 -waveform {0.000 3.200} [get_ports {qsfp_ref_clk}]
