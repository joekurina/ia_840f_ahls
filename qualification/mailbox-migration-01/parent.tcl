# Separate reviewed invocation, only after child saved-state acceptance.
if {[catch {
    set expected /home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch/bwbmc
    if {[file normalize [pwd]] ne $expected} { error "Wrong scratch cwd" }
    if {![file exists ../evidence/parent-claim.json]} { error "Missing single-use parent claim" }
    load_system bw_840_support.qsys
    puts "SYNC_MESSAGES [sync_sysinfo_parameters bmc_spi_sub_0]"
    puts "RELOAD_MESSAGES [reload_component_footprint bmc_spi_sub_0]"
    puts "VALIDATION_MESSAGES [validate_component_footprint bmc_spi_sub_0]"
    save_system bw_840_support.qsys
    puts MAILBOX_PARENT_SAVE_COMPLETE
} message options]} {
    puts stderr "MAILBOX_MIGRATION_ERROR: $message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
