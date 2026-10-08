# Copyright 2026. SPDX-License-Identifier: MIT
# The compiler invokes this copied variant hook from its kernel work directory.
if {[llength $quartus(args)] != 1} {puts stderr {IA840F requires one flow argument}; exit 2}
set ia840f_flow [lindex $quartus(args) 0]
if {[info exists ::env(IA840F_REQUIRE_IMAGE_REUSE)] && $::env(IA840F_REQUIRE_IMAGE_REUSE) eq "1"} {
    puts stderr {Native -reuse-exe did not reuse the image; refuse a new FPGA fit}
    exit 2
}
if {$ia840f_flow ni {afu_flat afu_flat_kclk}} {puts stderr {Unsupported IA840F flow}; exit 2}
set ia840f_driver [file normalize [file join [file dirname [info script]] build26.py]]
if {[info exists ::env(IA840F_BUILD_CONFIG)] && $::env(IA840F_BUILD_CONFIG) ne ""} {
    set ia840f_config $::env(IA840F_BUILD_CONFIG)
    set ia840f_command [list /usr/bin/python3 $ia840f_driver backend --kernel-dir [pwd] --config $ia840f_config --flow $ia840f_flow]
} else {
    # Normal -Xstarget link: infer only the selected package location. SDK,
    # Quartus and matching PR export still come from explicit environment roots.
    set ia840f_board [file normalize [file join [file dirname [info script]] ../../../..]]
    set ia840f_command [list /usr/bin/python3 [file join $ia840f_board cmake auto26.py] --package $ia840f_board --kernel-dir [pwd] --flow $ia840f_flow]
}
if {[catch {exec {*}$ia840f_command >@stdout 2>@stderr} ia840f_error]} {
    puts stderr "IA840F backend failed: $ia840f_error"
    exit 1
}
