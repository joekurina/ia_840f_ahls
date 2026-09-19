# Reusable source registration only. Not an AFU top selection or AHLS IP import.
# The caller must already provide the IA840F-generated PIM, its complete source
# list/SDC/IP closure and include path containing ofs_plat_if.vh.
# No oneAPI ASP design file, kernel_system, Qsys board or hostchannel is sourced.
set ahls_binding_source_dir [file dirname [file normalize [info script]]]
foreach ahls_binding_source {
    rtl/ahls_ofs_board_services.sv
    rtl/ahls_avmm_byte_to_line.sv
    rtl/ahls_mmio_aperture.sv
    rtl/ahls_mmio_to_avmm.sv
    rtl/ahls_board_binding.sv
} {
    set_global_assignment -name SYSTEMVERILOG_FILE \
        [file join $ahls_binding_source_dir $ahls_binding_source]
}
unset ahls_binding_source
unset ahls_binding_source_dir
