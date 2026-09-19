# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


#
# altera_s10_mailbox_client_sw.tcl
#

# Create driver
create_driver altera_s10_mailbox_client

# Identify hardware component class
set_sw_property hw_class_name altera_s10_mailbox_client

# The version of this driver
set_sw_property version 1.0.0

# This driver may be incompatible with versions of hardware less
# than specified below. Updates to hardware and device drivers
# rendering the driver incompatible with older versions of
# hardware are noted with this property assignment.
set_sw_property min_compatible_hw_version 20.0.1

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# Interrupt properties: This driver supports enhanced
# interrupt APIs, as well as ISR preemption.
set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "enhanced_interrupt_api"

#
# Source file listing
#

# Header files
add_sw_property include_source HAL/inc/altera_s10_mailbox_client.h
add_sw_property include_source HAL/inc/altera_s10_mailbox_client_flash.h
add_sw_property include_source inc/altera_s10_mailbox_client_regs.h

# Header files for RSU abstarction layer
add_sw_property include_source HAL/inc/altera_s10_mailbox_client_rsu.h
add_sw_property include_source HAL/inc/altera_s10_mailbox_client_flash_rsu.h

# Header files for LibRSU
add_sw_property include_source HAL/inc/librsu.h
add_sw_property include_source HAL/inc/librsu_cb.h
add_sw_property include_source HAL/inc/librsu_cfg.h
add_sw_property include_source HAL/inc/librsu_ll.h
add_sw_property include_source HAL/inc/librsu_misc.h
add_sw_property include_source HAL/inc/librsu_qspi.h
add_sw_property include_source HAL/inc/rsu_client.h

# C/C++ Source files
add_sw_property c_source HAL/src/altera_s10_mailbox_client.c
add_sw_property c_source HAL/src/altera_s10_mailbox_client_flash.c

# C/C++ for RSU abstarction layer
add_sw_property c_source HAL/src/altera_s10_mailbox_client_rsu.c
add_sw_property c_source HAL/src/altera_s10_mailbox_client_flash_rsu.c

# C/C++ for LibRSU
add_sw_property c_source HAL/src/librsu.c
add_sw_property c_source HAL/src/librsu_cb.c
add_sw_property c_source HAL/src/librsu_cfg.c
add_sw_property c_source HAL/src/librsu_misc.c
add_sw_property c_source HAL/src/librsu_ll_qspi.c
add_sw_property c_source HAL/src/rsu_client.c

# This driver is support HAL BSP
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# Add the following per_driver configuration option to the BSP:
#  o Type of setting.
#  o Generated file to write to (public_mk_define -> public.mk)
#  o Name of setting for use with bsp command line settings tools
#    (rsu_protected_slot). This name will be combined with the
#    driver class to form a settings hierarchy to assure unique
#    settings names
#  o '#define' in driver code (and therefore string in generated
#     makefile): "RSU_PROTECTION_SLOT", which means: "emit
#     CPPFLAGS += RSU_PROTECTION_SLOT in generated makefile
#  o Default value (if the user doesn't specify at BSP creation): false
#    (which means: 'do not emit above CPPFLAGS string in generated makefile)
#  o Description text
add_sw_setting decimal_number public_mk_define rsu.rsu_protected_slot RSU_PROTECTION_SLOT -1 "This option allows protecting a certain slot number. By default, no slot is protected. Only slots between 0 and 31 can be protected by this feature."

add_sw_setting decimal_number public_mk_define rsu.rsu_log_level RSU_LOG_LEVEL 3 "This option allows customizing how much logging information is displayed. By default, the log level is HIGH, all the logging information will be displayed."

add_sw_setting boolean_define_only public_mk_define rsu.enable_spt_checksum RSU_SPT_CHECKSUM false "This option to enable the checking and maintaining of SPT checksum. By default, the SPT checksum is unable."

add_sw_setting boolean_define_only public_mk_define rsu.fpga_device.Stratix10 STRATIX10 false "This option allows configuration targeting Stratix10. By default, configuration will target Agilex."

add_sw_setting boolean_define_only public_mk_define rsu.enable_rsu RSU false "This option is enable for performing RSU. By default, it is off, It need to be on when performing RSU."

### End of file ###