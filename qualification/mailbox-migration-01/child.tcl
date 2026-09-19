# Reviewed invocation only: loader opens the explicit isolated QPF before Tcl.
# No FIM hooks and no implicit project creation are allowed by migration.py.
proc assert_mailbox_parameters {} {
    foreach {key expected} {
        DEVICE_FAMILY {Agilex 7}
        CMD_FIFO_DEPTH 1024 RSP_FIFO_DEPTH 1024 URG_FIFO_DEPTH 4
        CMD_USE_MEMORY_BLOCKS 1 RSP_USE_MEMORY_BLOCKS 1 URG_USE_MEMORY_BLOCKS 1
        DEBUG 0 HAS_URGENT 0 HAS_STREAM 0 HAS_OFFLOAD 0 HAS_STATUS 1
        STREAM_WIDTH 32 CRYPTO_MEMORY_TIMEOUT_VALUE 10000
    } {
        set actual [get_component_parameter_value $key]
        if {$actual ne $expected} { error "Mailbox parameter drift: $key=$actual expected=$expected" }
        puts "MAILBOX_PARAMETER $key=$actual"
    }
}
if {[catch {
    set expected /home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch/bwbmc
    if {[file normalize [pwd]] ne $expected} { error "Wrong scratch cwd" }
    if {![file exists ../evidence/child-claim.json]} { error "Missing single-use child claim" }
    load_system bmc_spi_sub.qsys
    if {![load_component sdm_mailbox]} { error "Cannot load sdm_mailbox" }
    assert_mailbox_parameters
    save_component
    assert_mailbox_parameters
    puts "SYNC_MESSAGES [sync_sysinfo_parameters sdm_mailbox]"
    if {![load_component sdm_mailbox]} { error "Cannot reload mailbox after sync" }
    assert_mailbox_parameters
    puts "RELOAD_MESSAGES [reload_component_footprint sdm_mailbox]"
    puts "VALIDATION_MESSAGES [validate_component_footprint sdm_mailbox]"
    save_system bmc_spi_sub.qsys
    puts MAILBOX_CHILD_SAVE_COMPLETE
} message options]} {
    puts stderr "MAILBOX_MIGRATION_ERROR: $message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
# Message lists are evidence, not booleans. Python + independent serialized/log
# review is mandatory even when this script returns zero.
