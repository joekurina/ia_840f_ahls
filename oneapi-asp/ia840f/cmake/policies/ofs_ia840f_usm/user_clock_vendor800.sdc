# BittWare IA840F user_clock.sdc: both optimization clocks at1.25ns/800MHz.
# Current native clock identities/target collections; no N6001 selector assumptions.
foreach asp73_clock_name {
    afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk0
    afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk1
} {
    set asp73_clocks [get_clocks $asp73_clock_name]
    puts "ASP73_CLOCK_BIND $asp73_clock_name [get_collection_size $asp73_clocks]"
    if {[get_collection_size $asp73_clocks] != 1} {puts stderr {ASP73_CLOCK_REJECTED}; qexit -error}
    foreach_in_collection asp73_clock $asp73_clocks {
        set asp73_targets [get_clock_info -targets $asp73_clock]
        puts "ASP73_TARGET_COUNT $asp73_clock_name [get_collection_size $asp73_targets]"
        if {[get_collection_size $asp73_targets] != 1} {puts stderr {ASP73_TARGET_REJECTED}; qexit -error}
        foreach_in_collection asp73_target $asp73_targets {puts "ASP73_TARGET $asp73_clock_name [get_node_info -name $asp73_target]"}
    }
    remove_clock $asp73_clocks
    create_clock -name $asp73_clock_name -period 1.25 $asp73_targets
}
