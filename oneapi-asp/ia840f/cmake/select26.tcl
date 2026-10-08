package require ::quartus::project
package require ::quartus::sta
package require ::quartus::report
project_open -revision afu_flat ofs_top
create_timing_netlist
read_sdc
update_timing_netlist
load_report afu_flat
source ofs_partial_reconfig/vendor_clock_helpers.tcl
set asp78_low {afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk1}
set asp78_high {afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk0}
set asp78_instances [get_entity_instances -nowarn afu_main]
if {[llength $asp78_instances] != 1} {error "Expected exactly one AFU instance"}
set asp78_instance [lindex $asp78_instances 0]
set asp78_keepers [get_keepers "$asp78_instance|*"]
set asp78_count [get_collection_size $asp78_keepers]
puts "ASP78_KEEPERS $asp78_count"
if {$asp78_count < 1 || $asp78_count > 300000} {error "AFU keeper count outside bound"}
# Structural driving-clock association, not missing slack, determines2x usage.
set asp78_driving [get_clocks -of_objects $asp78_keepers]
set asp78_high_used 0
set asp78_low_used 0
foreach_in_collection asp78_clock $asp78_driving {
    set asp78_name [get_clock_info -name $asp78_clock]
    puts "ASP78_DRIVING_CLOCK $asp78_name"
    if {$asp78_name eq $asp78_high} {set asp78_high_used 1}
    if {$asp78_name eq $asp78_low} {set asp78_low_used 1}
}
if {!$asp78_low_used} {error "Required low clock lacks structural AFU consumers"}
set asp78_fmax_low [lindex [asp78_vendor_fmax $asp78_low 1 0.01] 0]
set asp78_fmax_high [lindex [asp78_vendor_fmax $asp78_high $asp78_high_used 0.0] 0]
if {$asp78_high_used} {
    set asp78_selected_low [expr {int(floor(min($asp78_fmax_low,400.0,$asp78_fmax_high/2.0)))}]
    set asp78_selected_high [expr {$asp78_selected_low*2}]
} else {
    set asp78_selected_low [expr {int(floor(min($asp78_fmax_low,800.0)))}]
    if {$asp78_selected_low > 400} {
        set asp78_selected_high $asp78_selected_low
    } else {
        set asp78_selected_high [expr {$asp78_selected_low*2}]
    }
}
if {$asp78_selected_low < 1 || $asp78_selected_high < 1} {error "Invalid selected rate"}
puts "ASP78_SELECTED low=$asp78_selected_low high=$asp78_selected_high high_used=$asp78_high_used fmax_low=$asp78_fmax_low fmax_high=$asp78_fmax_high"
set asp78_file [open vendor_operating_point.txt w]
puts $asp78_file "low=$asp78_selected_low"
puts $asp78_file "high=$asp78_selected_high"
puts $asp78_file "high_used=$asp78_high_used"
puts $asp78_file "fmax_low=$asp78_fmax_low"
puts $asp78_file "fmax_high=$asp78_fmax_high"
close $asp78_file
project_close
