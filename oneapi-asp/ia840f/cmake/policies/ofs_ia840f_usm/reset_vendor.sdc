# Exact BittWare reset exception classes, translated and natively bound.
set asp73_reset_d [get_pins -compatibility_mode -nocase {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|d}]
set asp73_reset_from [get_keepers {afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|clocks|port[0].r|uClk_usrDiv2_reset|cc|ofs_plat_cc_reg_vec*}]
set asp73_reset_to [get_keepers {*kernel_wrapper_inst|kernel_system_inst*}]
puts "ASP73_RESET_D [get_collection_size $asp73_reset_d]"
puts "ASP73_RESET_FROM [get_collection_size $asp73_reset_from]"
puts "ASP73_RESET_TO [get_collection_size $asp73_reset_to]"
if {[get_collection_size $asp73_reset_d] < 1 || [get_collection_size $asp73_reset_d] > 256 || [get_collection_size $asp73_reset_from] != 4 || [get_collection_size $asp73_reset_to] < 1 || [get_collection_size $asp73_reset_to] > 60000} {puts stderr {ASP73_RESET_BIND_REJECTED}; qexit -error}
set_false_path -to $asp73_reset_d
set_false_path -from $asp73_reset_from -to $asp73_reset_to
# The historical prescaler[?] exception covers prescaler, NOT prescaler_div2.
set asp73_prescale_all [get_keepers {afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|qph_user_clk_freq|prescaler*}]
set asp73_prescale_div2 [get_keepers {afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|qph_user_clk_freq|prescaler_div2*}]
set asp73_prescale [remove_from_collection $asp73_prescale_all $asp73_prescale_div2]
puts "ASP73_PRESCALER [get_collection_size $asp73_prescale]"
if {[get_collection_size $asp73_prescale] != 4} {puts stderr {ASP73_PRESCALER_BIND_REJECTED}; qexit -error}
foreach_in_collection asp73_node $asp73_prescale {
    set asp73_name [get_node_info -name $asp73_node]
    puts "ASP73_PRESCALER_NODE $asp73_name"
    if {![regexp {\|prescaler\[[0-3]\]$} $asp73_name]} {puts stderr {ASP73_PRESCALER_SCOPE_REJECTED}; qexit -error}
}
set_false_path -from $asp73_prescale -to $asp73_prescale
