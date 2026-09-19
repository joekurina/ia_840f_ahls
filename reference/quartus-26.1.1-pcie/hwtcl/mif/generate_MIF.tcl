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


#!/usr/bin/env tclsh

#################################################################################################################################################################
#                                                        HELPER FUNCTIONS                                                                                       #
#                                                                                                                                                               #
#                                                                                                                                                               #
#################################################################################################################################################################
proc list_to_dict { data } {
   set this_dict [dict create]
 
   set headers [lindex $data 0]  
   set length [llength $data]
   set nameindex [lsearch $headers NAME]
   for {set i 1} {$i < $length} {incr i} {
     set this_entry [lindex $data $i]
     set key [lindex $this_entry $nameindex]
     for {set j 0} {$j < [llength $this_entry]} {incr j} {
       dict set this_dict $key [lindex $headers $j] [lindex $this_entry $j]
     }
   }
   return $this_dict
}

proc convert_data_to_binary { data total_bits } {
    if {[string range $data 0 1] eq "0x"} {
        # ex to binary conversion
        set hex_data [format %X $data]
        set numBits [expr [string length $hex_data] * 4]
        binary scan [binary format H* $hex_data] B${numBits} bits
    } elseif {[string range $data 0 1] eq "0b"} {
        # remove 0b at the front for binary data
        set bits [string range $data 2 [string length $data]]
    } else {
        # decimal to binary conversion
        binary scan [binary format I* $data] B* bits
    }

    set bits [string range $bits [expr [string length $bits] - $total_bits] [string length $bits]]
    set bits [format [subst %0${total_bits}s] $bits]
    return $bits
}

proc parse_parameters_file { file } {
    set parameters_file [open $file r]

    # loop through each line of the parameters file:
    while { [gets $parameters_file line] >= 0 } {
        set parameter_name_value [split $line "="]
        lassign $parameter_name_value param_name param_value 
        dict set parameters $param_name $param_value
    }

    close $parameters_file
    return $parameters
}

proc convert_mapping_to_dict { mapping } {
    set mapping_split [split $mapping " "]

    foreach temp $mapping_split {
        set hwtcl_value [lindex [split $temp ":"] 0]
        set mapped_mif_value [lindex [split $temp ":"] 1]
        dict set mapping_dict $hwtcl_value $mapped_mif_value
    }

    return $mapping_dict
}

proc incr_hex { hex {increment 1} } {
    upvar 1 $hex newHex
    incr newHex $increment
    set newHex "0x[format %X $newHex]"

}

proc sub_parameter_into_default { default_val struct_dict val_or_attribute param_list hwtcl_name hwtcl_to_bit_mapping start_bit end_bit } {
    if { $val_or_attribute == "value" } {
        set row_bits [expr [dict get $struct_dict NUM_BYTES] * 8]
    } elseif { $val_or_attribute == "attribute" } {
        set row_bits [expr [dict get $struct_dict NUM_BYTES] * 16]
    } else {
        error "invalid value for val_or_attribute, expecting 'value' or 'attribute' but got '${val_or_attribute}'"
    }
    set start_bit_modified [expr $row_bits - 1 - $start_bit ] 
    set end_bit_modified [expr $row_bits - 1 - $end_bit ]

    # check if hwtcl parmaeter exists
    if { [dict exists $param_list $hwtcl_name] } {
        # sub value into the default based on mapping
        set sub_val [dict get $hwtcl_to_bit_mapping [dict get $param_list $hwtcl_name] ]
        set begin_bits [string range $default_val 0 [expr $start_bit_modified - 1]]
        set end_bits [string range $default_val [expr $end_bit_modified + 1] [string length $default_val]]

        set together_bits ${begin_bits}${sub_val}${end_bits}
        return $together_bits
    } else {
        return $default_val
    } 
}

# Below is the proc for direct substitution, it will take in a hwtcl parameter through "hwtcl_name",
# convert the value of the hwtcl param from dec to binary and then use that to replace the start_bit 
# to end_bit section of the default value which is obtained from struct_dict.
#
# Example usage: (replaces bit 10:2 of default with the binary value of TEST_HWTCL_PARAM)
#                set new_val [direct_sub_parameter_into_default $struct_dict "value" $param_list "TEST_HWTCL_PARAM" 10 2] 

proc direct_sub_parameter_into_default { default_val struct_dict val_or_attribute param_list hwtcl_name start_bit end_bit } {
    if { $val_or_attribute == "value" } {
        set row_bits [expr [dict get $struct_dict NUM_BYTES] * 8]
    } elseif { $val_or_attribute == "attribute" } {
        set row_bits [expr [dict get $struct_dict NUM_BYTES] * 16]
    } else {
        error "invalid value for val_or_attribute, expecting 'value' or 'attribute' but got '${val_or_attribute}'"
    }
    set start_bit_modified [expr $row_bits - 1 - $start_bit ] 
    set end_bit_modified [expr $row_bits - 1 - $end_bit ]

    # check if hwtcl parameter exists
    if { [dict exists $param_list $hwtcl_name] } {
        # sub value into the default based on mapping
        set sub_val [convert_data_to_binary [dict get $param_list $hwtcl_name] [expr $end_bit_modified - $start_bit_modified + 1 ]]

        set begin_bits [string range $default_val 0 [expr $start_bit_modified - 1]]
        set end_bits [string range $default_val [expr $end_bit_modified + 1] [string length $default_val]]

        set together_bits ${begin_bits}${sub_val}${end_bits}
        return $together_bits
    } else {
        return $default_val
    } 
}

proc sub_string_into_default { default_val struct_dict val_or_attribute string_bits start_bit end_bit } {
    if { $val_or_attribute == "value" } {
        set row_bits [expr [dict get $struct_dict NUM_BYTES] * 8]
    } elseif { $val_or_attribute == "attribute" } {
        set row_bits [expr [dict get $struct_dict NUM_BYTES] * 16]
    } else {
        error "invalid value for val_or_attribute, expecting 'value' or 'attribute' but got '${val_or_attribute}'"
    }
    set start_bit_modified [expr $row_bits - 1 - $start_bit ] 
    set end_bit_modified [expr $row_bits - 1 - $end_bit ]

    # assert string length is the same size as replacement range (end - start)
    set replacement_range [expr $end_bit_modified - $start_bit_modified + 1]
    set string_length [string length $string_bits]
    if { $string_length ne $replacement_range } {
        error "Trying to replace a range of ${replacement_range} bits with ${string_length} bits"
    }

    set begin_bits [string range $default_val 0 [expr $start_bit_modified - 1]]
    set end_bits [string range $default_val [expr $end_bit_modified + 1] [string length $default_val]]
    set together_bits ${begin_bits}${string_bits}${end_bits}

    return $together_bits
}



#################################################################################################################################################################
#                                                        SOURCE TEMPLATES                                                                                       #
#                                                                                                                                                               #
#                                                                                                                                                               #
#################################################################################################################################################################
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates type0_config_space_header.tcl ]   ; # templates/type0_config_space_header.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates type1_config_space_header.tcl ]   ; # templates/type1_config_space_header.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates power_management_cap_struct.tcl ] ; # templates/power_management_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates pci_express_cap_struct.tcl ]      ; # templates/pci_express_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates msi_cap_struct.tcl ]              ; # templates/msi_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates msix_cap_struct.tcl ]             ; # templates/msix_cap_struct.tcl
# 
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates virtio_common_config_cap_struct.tcl ]              ; # templates/virtio_common_config_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates virtio_device_specific_cap_struct.tcl ]            ; # templates/virtio_device_specific_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates virtio_isr_status_config_cap_struct.tcl ]          ; # templates/virtio_isr_status_config_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates virtio_notification_cap_struct.tcl ]               ; # templates/virtio_notification_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates virtio_pci_config_access_cap_struct.tcl ]          ; # templates/virtio_pci_config_access_config_cap_struct.tcl
# 
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates AER_extended_cap_struct.tcl ]                      ; # templates/AER_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates ARI_extended_cap_struct.tcl ]                      ; # templates/ARI_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates SRIOV_extended_cap_struct.tcl ]                    ; # templates/SRIOV_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates TPH_extended_cap_struct.tcl ]                      ; # templates/TPH_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates ATS_extended_cap_struct.tcl ]                      ; # templates/ATS_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates ACS_extended_cap_struct.tcl ]                      ; # templates/ACS_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates PRI_extended_cap_struct.tcl ]                      ; # templates/PRI_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates PASID_extended_cap_struct.tcl ]                    ; # templates/PASID_extended_cap_struct.tcl
# 
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_type0_config_space_header.tcl ]   ; # templates/vf_type0_config_space_header.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_pci_express_cap_struct.tcl ]      ; # templates/vf_pci_express_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_msix_cap_struct.tcl ]             ; # templates/vf_msix_cap_struct.tcl
# 
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_virtio_common_config_cap_struct.tcl ]              ; # templates/vf_virtio_common_config_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_virtio_device_specific_cap_struct.tcl ]            ; # templates/vf_virtio_device_specific_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_virtio_isr_status_config_cap_struct.tcl ]          ; # templates/vf_virtio_isr_status_config_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_virtio_notification_cap_struct.tcl ]               ; # templates/vf_virtio_notification_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_virtio_pci_config_access_cap_struct.tcl ]          ; # templates/vf_virtio_pci_config_access_config_cap_struct.tcl
# 
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_TPH_extended_cap_struct.tcl ]                      ; # templates/vf_TPH_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_ATS_extended_cap_struct.tcl ]                      ; # templates/vf_ATS_extended_cap_struct.tcl
# source [file join [file dirname [dict get [ info frame 0 ] file ] ] templates vf_ACS_extended_cap_struct.tcl ]                      ; # templates/vf_ACS_extended_cap_struct.tcl
# 
# 
# package require type0_config_space_header
# package require type1_config_space_header
# package require power_management_cap_struct
# package require pci_express_cap_struct
# package require msi_cap_struct
# package require msix_cap_struct
# 
# package require virtio_common_config_cap_struct
# package require virtio_device_specific_cap_struct
# package require virtio_isr_status_config_cap_struct
# package require virtio_notification_cap_struct
# package require virtio_pci_config_access_cap_struct
# 
# package require AER_extended_cap_struct
# package require ARI_extended_cap_struct
# package require SRIOV_extended_cap_struct
# package require TPH_extended_cap_struct
# package require ATS_extended_cap_struct
# package require ACS_extended_cap_struct
# package require PRI_extended_cap_struct
# package require PASID_extended_cap_struct
# 
# package require vf_type0_config_space_header
# package require vf_pci_express_cap_struct
# package require vf_msix_cap_struct
# 
# package require vf_virtio_common_config_cap_struct
# package require vf_virtio_device_specific_cap_struct
# package require vf_virtio_isr_status_config_cap_struct
# package require vf_virtio_notification_cap_struct
# package require vf_virtio_pci_config_access_cap_struct
# 
# package require vf_TPH_extended_cap_struct
# package require vf_ATS_extended_cap_struct
# package require vf_ACS_extended_cap_struct

#################################################################################################################################################################
#                                                        CAPABILITY OUTPUT                                                                                      #
#                                                                                                                                                               #
#                                                                                                                                                               #
#################################################################################################################################################################
proc output_cap_value { file param_list namespace start {up_dn_ep "swup"} {slot_ep_num 0} {pf_num 0} } {
    upvar $start newStart
    # loop through struct
    set capability_struct [list_to_dict [subst $[subst ::${namespace}::struct]]]
    set cap_size [subst $[subst ::${namespace}::size]]

    set end $newStart
    incr_hex end [expr $cap_size/4 - 1]

    set curr_hex_addr $newStart
    set numBytes 0
    dict for {struct_name struct_value_dict} $capability_struct {
        # write the hex address in the mif file at the start of a new line
        if { [expr $numBytes % 4] == 0} {
            puts $file ""
            puts -nonewline $file "[format %X ${curr_hex_addr}]: "
        }  

        # write the bytes
        if { [dict get $struct_value_dict VALUE_PROC_EXIST]} {
            set modified_val [[dict get $struct_value_dict VALUE_PROC] $struct_value_dict $param_list $up_dn_ep $slot_ep_num $pf_num] 
            puts -nonewline $file $modified_val
        } else {
            puts -nonewline $file [convert_data_to_binary [dict get $struct_value_dict DEFAULT_VALUE] [expr [dict get $struct_value_dict NUM_BYTES] * 8]]
            # puts $file ""
        }
        
        # end line
        incr numBytes [dict get $struct_value_dict NUM_BYTES]
        if { [expr $numBytes % 4] == 0} {
            puts -nonewline $file ";"

            # comments
            if {$curr_hex_addr == $newStart} {
                puts -nonewline $file "  -- ${namespace} start"
            }
            if {$curr_hex_addr == $end} {
                puts -nonewline $file "  -- ${namespace} end"
            }

            # increment
            incr curr_hex_addr
        }
    }

    # Assert start == capability end
    set actual_end [format %X [expr (${newStart} * 4) + ${numBytes} - 4] ]
    set end_modified [format %X [expr $end * 4] ]
    if { $actual_end ne $end_modified } {
        error "${namespace} capability structure ends at ${end_modified} but actual end is ${actual_end}"
    }

    # update start to end so that next start writes at the right location
    set newStart $end
    incr_hex newStart 1
}

proc output_attribute_value { file param_list namespace start {up_dn_ep "swup"} {slot_ep_num 0} {pf_num 0} } {
    upvar $start newStart
    # loop through struct
    set capability_struct [list_to_dict [subst $[subst ::${namespace}::struct]]]
    set cap_size [subst $[subst ::${namespace}::size]]

    set end $newStart
    incr_hex end [expr $cap_size/ 4 - 1]

    set curr_hex_addr $newStart
    set numBytes 0
    dict for {struct_name struct_value_dict} $capability_struct {
        # write the hex address in the mif file at the start of a new line
        if { [expr $numBytes % 4] == 0} {
            puts $file ""
            puts -nonewline $file "[format %X ${curr_hex_addr}]: "
        }  

        # write the bytes
        if { [dict get $struct_value_dict ATTRIBUTE_PROC_EXIST]} {
            set modified_val [[dict get $struct_value_dict ATTRIBUTE_PROC] $struct_value_dict $param_list $up_dn_ep $slot_ep_num $pf_num] 
            puts -nonewline $file $modified_val
        } else {
            puts -nonewline $file [convert_data_to_binary [dict get $struct_value_dict DEFAULT_ATTRIBUTE] [expr [dict get $struct_value_dict NUM_BYTES] * 16]]
            # puts $file ""
        }
        
        # end line
        incr numBytes [dict get $struct_value_dict NUM_BYTES]
        if { [expr $numBytes % 4] == 0} {
            puts -nonewline $file ";"

            # comments
            if {$curr_hex_addr == $newStart} {
                puts -nonewline $file "  -- ${namespace} start"
            }
            if {$curr_hex_addr == $end} {
                puts -nonewline $file "  -- ${namespace} end"
            }

            # increment
            incr curr_hex_addr
        }
    }

    # Assert start == capability end
    set actual_end [format %X [expr (${newStart} * 4) + ${numBytes} - 4] ]
    set end_modified [format %X [expr $end * 4] ]
    if { $actual_end ne $end_modified } {
        error "${namespace} capability structure ends at ${end_modified} but actual end is ${actual_end}"
    }

    set newStart $end
    incr_hex newStart 1
}

proc write_gap { file val_or_attribute start size} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    while {$curr_hex_addr <= $end} {
        puts $file ""
        if { $val_or_attribute == "value" } {
            set gap_value "00000000000000000000000000000000"
        } elseif { $val_or_attribute == "attribute" } {
            set gap_value "0101010101010101010101010101010101010101010101010101010101010101"
        } else {
            error "invalid value for val_or_attribute, expecting 'value' or 'attribute' but got '${val_or_attribute}' inside write_gap"
        }
        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- gap start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- gap end"
        }

        incr curr_hex_addr
    }

    set newStart $end
    incr_hex newStart 1
}

proc write_random_value { file start size size_padded pf_vf} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    set end_padded $newStart
    incr_hex end_padded [expr $size_padded - 1]

    while {$curr_hex_addr <= $end_padded} {
		set randNum [expr { int(2147483640 * rand()) }]
		#puts $randNum
		if { [expr $curr_hex_addr % 2] == 0} {
			set randNum [expr $randNum & 2147483520]
		}
		binary scan [binary format I* $randNum] B* bits
		puts $bits
        
    	puts $file ""
        set gap_value $bits

        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- ${pf_vf} start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- ${pf_vf} end"
        }

        incr curr_hex_addr
    }

    set newStart $end_padded
    incr_hex newStart 1
}

proc write_device_att_value { file start size size_padded pf_vf} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    set end_padded $newStart
    incr_hex end_padded [expr $size_padded - 1]

    while {$curr_hex_addr <= $end_padded} {

		if { [expr [expr $curr_hex_addr % 2] == 0] && [expr $curr_hex_addr <= $end] } {
			set gap_value_d 5
			binary scan [binary format I* $gap_value_d] B* gap_value
		} else {
			set gap_value "00000000000000000000000000000000"	
		}
        
    	puts $file ""
        
        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- ${pf_vf} start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- ${pf_vf} end"
        }

        incr curr_hex_addr
    }

    set newStart $end_padded
    incr_hex newStart 1
}

proc write_dfl_value { file start size size_padded pf_vf core} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    set end_padded $newStart
    incr_hex end_padded [expr $size_padded - 1]

    while {$curr_hex_addr <= $end_padded} {
        
        if { [expr [expr $curr_hex_addr % 2] == 0] } {
            set i [expr $curr_hex_addr/2]
            set gap_value_d  [ip_get "parameter.core${core}_dfl${i}_bar_hwtcl.value"]
			binary scan [binary format I* $gap_value_d] B* gap_value
         } else {
            set i    [expr $curr_hex_addr/2] 
            set gap_value_d  [ip_get "parameter.core${core}_dfl${i}_offset_hwtcl.value"]
			binary scan [binary format I* $gap_value_d] B* gap_value
          }  
         
    	        
    	puts $file ""
        
        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- ${pf_vf} start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- ${pf_vf} end"
        }

        incr curr_hex_addr
    }

    set newStart $end_padded
    incr_hex newStart 1
}

proc write_msix_value { file start size size_padded pf_vf} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    set end_padded $newStart
    incr_hex end_padded [expr $size_padded - 1]

    while {$curr_hex_addr <= $end_padded} {

    	set gap_value "00000000000000000000000000000001"
        
    	puts $file ""
        
        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- ${pf_vf} start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- ${pf_vf} end"
        }

        incr curr_hex_addr
    }

    set newStart $end_padded
    incr_hex newStart 1
}

proc write_ctrl_shadow_pf_ram_value { file start size size_padded pf_vf} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    set end_padded $newStart
    incr_hex end_padded [expr $size_padded - 1]

    while {$curr_hex_addr <= $end_padded} {
        # 18:16 bits for MRRS reset value is 0x2
    	set gap_value "00000100000000000000000"
        
    	puts $file ""
        
        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- ${pf_vf} start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- ${pf_vf} end"
        }

        incr curr_hex_addr
    }

    set newStart $end_padded
    incr_hex newStart 1
}

proc write_ctrl_shadow_vf_ram_value { file start size size_padded pf_vf} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    set end_padded $newStart
    incr_hex end_padded [expr $size_padded - 1]

    while {$curr_hex_addr <= $end_padded} {

    	set gap_value "000000000000000000000000"
        
    	puts $file ""
        
        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- ${pf_vf} start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- ${pf_vf} end"
        }

        incr curr_hex_addr
    }

    set newStart $end_padded
    incr_hex newStart 1
}

proc write_reserved_value { file start size} {
    upvar $start newStart 
    set curr_hex_addr $newStart

    set end $newStart
    incr_hex end [expr $size - 1]

    while {$curr_hex_addr <= $end} {
        puts $file ""
        set gap_value "00000000000000000000000000000000"

        puts -nonewline $file "[format %X ${curr_hex_addr}]: ${gap_value};"

        if {$curr_hex_addr == $newStart} {
            puts -nonewline $file "  -- Reserved value start"
        }

        if {$curr_hex_addr == $end} {
            puts -nonewline $file "  -- Reserved value end"
        }

        incr curr_hex_addr
    }

    set newStart $end
    incr_hex newStart 1
}
#################################################################################################################################################################
#                                                        MIF FILE OUTPUTS                                                                                       #
#                                                                                                                                                               #
#                                                                                                                                                               #
#################################################################################################################################################################
proc output_MIF_value_header { file depth } {
    puts $file "WIDTH=32;"
    puts $file "DEPTH=${depth};"
    puts $file "ADDRESS_RADIX=HEX;"
    puts $file "DATA_RADIX=BIN;"
    puts $file "CONTENT BEGIN"
}

proc output_MIF_attribute_header { file depth } {
    puts $file "WIDTH=64;"
    puts $file "DEPTH=${depth};"
    puts $file "ADDRESS_RADIX=HEX;"
    puts $file "DATA_RADIX=BIN;"
    puts $file "CONTENT BEGIN"
}

proc output_MIF_value_header_2 { file depth width} {
    puts $file "WIDTH=${width};"
    puts $file "DEPTH=${depth};"
    puts $file "ADDRESS_RADIX=HEX;"
    puts $file "DATA_RADIX=BIN;"
    puts $file "CONTENT BEGIN"
}

proc output_MIF_value_footer { file } {
    puts $file ""
    puts $file "END;"
}

proc output_MIF_attribute_footer { file } {
    puts $file ""
    puts $file "END;"
}

proc output_block_comment { file comment} {
    puts $file "\n-------------------------------------------------------------------------------"
    puts $file "-- $comment"
    puts -nonewline $file "-------------------------------------------------------------------------------"
}

#################################################################################################################################################################
#                                                        GENERATE FUNCTION                                                                                      #
#                                                                                                                                                               #
#                                                                                                                                                               #
#################################################################################################################################################################
proc generate_device_att_MIF_file { path } {
    file mkdir [file join $path output]
    
    set gen_folder_path [file join $path output ]
    set parameter_filename "parameters.txt"
    set parameter_filepath [file join $path $parameter_filename]

    # get the parameter values
    #set param_list [parse_parameters_file $parameter_filepath]

    set ip_topology [ip_get "parameter.top_topology_hwtcl.value"]
    
    set core16_total_pf_count_hwtcl [ip_get "parameter.core16_total_pf_count_hwtcl.value"]
    
    ###############################################################
    # PF Device ATT values file output                                       #
    ###############################################################
    # PF
    
    set device_att_pf_values_filename "pcie_ss_p0_device_att_pf_values.mif"
    set device_att_pf_values_filepath [file join $gen_folder_path $device_att_pf_values_filename] 
    set device_att_pf_values_file [open $device_att_pf_values_filepath w+]

    # Convert byte on the offset address of datt table to word address (byte/4) eg: 0x7FF --> 0x1FF
    set curr_addr_values 0x0
    set total_pf_bar [expr $core16_total_pf_count_hwtcl*2*6]
    
    # MIF Header
    # Total depth need to determine by which paramter: determine by the total number of address in the mif file
    set total_depth 512
    #set total_depth [expr int(pow(2,ceil(log($total_pf_bar)/log(2))))]

    output_MIF_value_header $device_att_pf_values_file $total_depth

    output_block_comment $device_att_pf_values_file "PF START HERE"
    
    write_device_att_value $device_att_pf_values_file curr_addr_values $total_pf_bar $total_depth "PF bar"
    # total depth 512
    #set reserved_pf_value [expr $total_depth-$total_pf_bar]
    #write_reserved_value $device_att_pf_values_file curr_addr_values $reserved_pf_value
    #output_block_comment $device_att_pf_values_file "PF ENDS HERE"
    
    output_MIF_value_footer $device_att_pf_values_file
    close $device_att_pf_values_file
    
    
    ###############################################################
    # VF Device ATT values file output                                       #
    ###############################################################
    # VF
    
    set device_att_vf_values_filename "pcie_ss_p0_device_att_vf_values.mif"
    set device_att_vf_values_filepath [file join $gen_folder_path $device_att_vf_values_filename] 
    set device_att_vf_values_file [open $device_att_vf_values_filepath w+]
    
    set curr_addr_values 0x0
    set total_vf_bar [expr $core16_total_pf_count_hwtcl*2*6]
    set total_depth 512
    #set total_depth [expr int(pow(2,ceil(log($total_vf_bar)/log(2))))]

    output_MIF_value_header $device_att_vf_values_file $total_depth
   
    output_block_comment $device_att_vf_values_file "VF START HERE"
    
    write_device_att_value $device_att_vf_values_file curr_addr_values $total_vf_bar $total_depth "VF bar"
    # total depth 512
    #set reserved_vf_value [expr $total_depth-$total_vf_bar]
    #write_reserved_value $device_att_vf_values_file curr_addr_values $reserved_vf_value
    #output_block_comment $device_att_vf_values_file "VF ENDS HERE"

    output_MIF_value_footer $device_att_vf_values_file
    close $device_att_vf_values_file
    
    if { [regexp "2x8" $ip_topology]} {

    	
    	set core8_total_pf_count_hwtcl [ip_get "parameter.core8_total_pf_count_hwtcl.value"]
		
    	###############################################################
		# PF Device ATT values file output                                       #
		###############################################################
		# PF
		
		set device_att_pf_values_filename "pcie_ss_p1_device_att_pf_values.mif"
		set device_att_pf_values_filepath [file join $gen_folder_path $device_att_pf_values_filename] 
		set device_att_pf_values_file [open $device_att_pf_values_filepath w+]
		
		
		# Convert byte on the offset address of datt table to word address (byte/4) eg: 0x7FF --> 0x1FF
		set curr_addr_values 0x0
		set total_pf_bar [expr $core8_total_pf_count_hwtcl*2*6]
        
        # MIF Header
		# Total depth need to determine by which paramter: determine by the total number of address in the mif file
		set total_depth 512
        #set total_depth [expr int(pow(2,ceil(log($total_pf_bar)/log(2))))]

        output_MIF_value_header $device_att_pf_values_file $total_depth
	
		output_block_comment $device_att_pf_values_file "PF START HERE"
		
		write_device_att_value $device_att_pf_values_file curr_addr_values $total_pf_bar $total_depth "PF bar"
		# total depth 512
		#set reserved_pf_value [expr $total_depth-$total_pf_bar]
		#write_reserved_value $device_att_pf_values_file curr_addr_values $reserved_pf_value
		#output_block_comment $device_att_pf_values_file "PF ENDS HERE"
		
		output_MIF_value_footer $device_att_pf_values_file
		close $device_att_pf_values_file
		
		
		###############################################################
		# VF Device ATT values file output                                       #
		###############################################################
		# VF
		
		set device_att_vf_values_filename "pcie_ss_p1_device_att_vf_values.mif"
		set device_att_vf_values_filepath [file join $gen_folder_path $device_att_vf_values_filename] 
		set device_att_vf_values_file [open $device_att_vf_values_filepath w+]
		
		set curr_addr_values 0x0
		set total_vf_bar [expr $core8_total_pf_count_hwtcl*2*6]
		set total_depth 512
        #set total_depth [expr int(pow(2,ceil(log($total_vf_bar)/log(2))))]
    
        output_MIF_value_header $device_att_vf_values_file $total_depth

		output_block_comment $device_att_vf_values_file "VF START HERE"
		
		write_device_att_value $device_att_vf_values_file curr_addr_values $total_vf_bar $total_depth "VF bar"
		# total depth 512
		#set reserved_vf_value [expr $total_depth-$total_vf_bar]
		#write_reserved_value $device_att_vf_values_file curr_addr_values $reserved_vf_value
		#output_block_comment $device_att_vf_values_file "VF ENDS HERE"
	
		output_MIF_value_footer $device_att_vf_values_file
		close $device_att_vf_values_file    	
       
    
    }
         

}

proc generate_DFL_MIF_file { path } {
    file mkdir [file join $path output]
    
    set gen_folder_path [file join $path output ]
    set parameter_filename "parameters.txt"
    set parameter_filepath [file join $path $parameter_filename]

    # get the parameter values
    #set param_list [parse_parameters_file $parameter_filepath]

    set ip_topology [ip_get "parameter.top_topology_hwtcl.value"]
    
	set core16_dfl_total_hwtcl_value  [ip_get "parameter.core16_dfl_total_hwtcl.value"]
    
    for {set i 0} {$i < 32} {incr i} {
    set core16_dfl_bar_hwtcl_value    [ip_get "parameter.core16_dfl${i}_bar_hwtcl.value"]
    set core16_dfl_offset_hwtcl_value [ip_get "parameter.core16_dfl${i}_offset_hwtcl.value"]
    
    set dfl_registers_values_filename "pcie_ss_p0_dfl_registers.mif"
    set dfl_registers_values_filepath [file join $gen_folder_path $dfl_registers_values_filename] 
    set dfl_registers_values_file [open $dfl_registers_values_filepath w+]

    # Convert byte on the offset address of datt table to word address (byte/4) eg: 0x7FF --> 0x1FF
    set curr_addr_values 0x0
    set total_dfl [expr ($core16_dfl_total_hwtcl_value*2)]
    
    set total_depth $total_dfl

    output_MIF_value_header $dfl_registers_values_file $total_depth
    set core  16
    output_block_comment $dfl_registers_values_file "DFL Registers START HERE"
    
    write_dfl_value $dfl_registers_values_file curr_addr_values $total_dfl $total_depth "DFL Registers" $core
         
    output_MIF_value_footer $dfl_registers_values_file
    close $dfl_registers_values_file
    } 
    if { [regexp "2x8" $ip_topology]} {

    	set core 8    	
	    set core8_dfl_total_hwtcl_value   [ip_get "parameter.core8_dfl_total_hwtcl.value"] 
		for {set i 0} {$i <32} {incr i} {
    	set core8_dfl_bar_hwtcl_value    [ip_get "parameter.core8_dfl${i}_bar_hwtcl.value"]
        set core8_dfl_offset_hwtcl_value [ip_get "parameter.core8_dfl${i}_offset_hwtcl.value"]
        set dfl_registers_values_filename "pcie_ss_p1_dfl_registers.mif"
		set dfl_registers_values_filepath [file join $gen_folder_path $dfl_registers_values_filename] 
		set dfl_registers_values_file [open $dfl_registers_values_filepath w+]
		
		
		# Convert byte on the offset address of datt table to word address (byte/4) eg: 0x7FF --> 0x1FF
		set curr_addr_values 0x0
		set total_dfl [expr ($core8_dfl_total_hwtcl_value*2)]

        set total_depth [expr $total_dfl ]

        output_MIF_value_header $dfl_registers_values_file $total_depth
	
		output_block_comment $dfl_registers_values_file "DFL Registers START HERE"
		
		write_dfl_value $dfl_registers_values_file curr_addr_values $total_dfl $total_depth "DFL Registers" $core
		
		output_MIF_value_footer $dfl_registers_values_file
		close $dfl_registers_values_file
    }
   }      
}

proc generate_msix_MIF_file { path } {
    file mkdir [file join $path output]
    
    set gen_folder_path [file join $path output ]
    set parameter_filename "parameters.txt"
    set parameter_filepath [file join $path $parameter_filename]

    # get the parameter values
    #set param_list [parse_parameters_file $parameter_filepath]

    set ip_topology [ip_get "parameter.top_topology_hwtcl.value"]
       
        set core16_msix_table_size_hwtcl_value [ip_get "parameter.core16_msix_table_size_hwtcl.value"]
        set core16_total_pf_count_hwtcl [ip_get "parameter.core16_total_pf_count_hwtcl.value"]
	set core16_msix_vector_alloc_hwtcl [ip_get "parameter.core16_msix_vector_alloc_hwtcl.value"]

	set core16_pf0_vf_count_hwtcl [ip_get "parameter.core16_pf0_vf_count_hwtcl.value"]
	set core16_pf1_vf_count_hwtcl [ip_get "parameter.core16_pf1_vf_count_hwtcl.value"]
	set core16_pf2_vf_count_hwtcl [ip_get "parameter.core16_pf2_vf_count_hwtcl.value"]
	set core16_pf3_vf_count_hwtcl [ip_get "parameter.core16_pf3_vf_count_hwtcl.value"]
	
	set core16_pf4_vf_count_hwtcl [ip_get "parameter.core16_pf4_vf_count_hwtcl.value"]
	set core16_pf5_vf_count_hwtcl [ip_get "parameter.core16_pf5_vf_count_hwtcl.value"]
	set core16_pf6_vf_count_hwtcl [ip_get "parameter.core16_pf6_vf_count_hwtcl.value"]
	set core16_pf7_vf_count_hwtcl [ip_get "parameter.core16_pf7_vf_count_hwtcl.value"]
	
        set core16_total_vf_count_hwtcl [expr $core16_pf0_vf_count_hwtcl + $core16_pf1_vf_count_hwtcl + $core16_pf2_vf_count_hwtcl+ $core16_pf3_vf_count_hwtcl + $core16_pf4_vf_count_hwtcl+ $core16_pf5_vf_count_hwtcl +$core16_pf6_vf_count_hwtcl+$core16_pf7_vf_count_hwtcl]
	
		      
    	
    ###############################################################
    # MSIX values file output                                       #
    ###############################################################
    
    
    set msix_registers_pf_values_filename "pcie_ss_p0_msix_vector_ctrl.mif"
    set msix_registers_pf_values_filepath [file join $gen_folder_path $msix_registers_pf_values_filename] 
    set msix_registers_pf_values_file [open $msix_registers_pf_values_filepath w+]
    set curr_addr_values 0x0
    
      # Convert byte on the offset address of datt table to word address (byte/4) eg: 0x7FF --> 0x1FF
    if {$core16_msix_vector_alloc_hwtcl == "Static"} {
        set total_pf_bar [expr $core16_total_pf_count_hwtcl+ $core16_total_vf_count_hwtcl]    
        set total_msix_ram [expr $core16_msix_table_size_hwtcl_value * $total_pf_bar]
    
    } elseif {$core16_msix_vector_alloc_hwtcl == "Dynamic" } {
	      set total_count [expr $core16_total_pf_count_hwtcl == 1 & $core16_total_vf_count_hwtcl == 0]
	      set total_pf_bar [expr $total_count ? 2048:4096]
	      set total_msix_ram [expr $total_pf_bar]

    }
      
    # MIF Header
    # Total depth need to determine by which paramter: determine by the total number of address in the mif file
    set total_depth [expr int(pow(2,ceil(log($total_msix_ram)/log(2))))]     
   
    output_MIF_value_header $msix_registers_pf_values_file $total_depth

    output_block_comment $msix_registers_pf_values_file " "
    
    write_msix_value $msix_registers_pf_values_file curr_addr_values  $total_pf_bar $total_depth " "
        
    output_MIF_value_footer $msix_registers_pf_values_file
    close $msix_registers_pf_values_file  


    if { [regexp "2x8" $ip_topology]} {
    	
    	
	    set core8_msix_table_size_hwtcl_value   [ip_get "parameter.core8_msix_table_size_hwtcl.value"] 
    	    set core8_total_pf_count_hwtcl [ip_get "parameter.core8_total_pf_count_hwtcl.value"]
            set core8_msix_vector_alloc_hwtcl [ip_get "parameter.core8_msix_vector_alloc_hwtcl.value"]
	    
	    
	    set core8_pf0_vf_count_hwtcl [ip_get "parameter.core8_pf0_vf_count_hwtcl.value"]
	    set core8_pf1_vf_count_hwtcl [ip_get "parameter.core8_pf1_vf_count_hwtcl.value"]
	    set core8_pf2_vf_count_hwtcl [ip_get "parameter.core8_pf2_vf_count_hwtcl.value"]
            set core8_pf3_vf_count_hwtcl [ip_get "parameter.core8_pf3_vf_count_hwtcl.value"]
	
	    set core8_pf4_vf_count_hwtcl [ip_get "parameter.core8_pf4_vf_count_hwtcl.value"]
            set core8_pf5_vf_count_hwtcl [ip_get "parameter.core8_pf5_vf_count_hwtcl.value"]
	    set core8_pf6_vf_count_hwtcl [ip_get "parameter.core8_pf6_vf_count_hwtcl.value"]
     	    set core8_pf7_vf_count_hwtcl [ip_get "parameter.core8_pf7_vf_count_hwtcl.value"]
	
            set core8_total_vf_count_hwtcl [expr $core8_pf0_vf_count_hwtcl + $core8_pf1_vf_count_hwtcl + $core8_pf2_vf_count_hwtcl+ $core8_pf3_vf_count_hwtcl + $core8_pf4_vf_count_hwtcl+ $core8_pf5_vf_count_hwtcl +$core8_pf6_vf_count_hwtcl+$core8_pf7_vf_count_hwtcl]

	    	
    	###############################################################
		# MSIX values file output                                       #
		###############################################################
		
		set msix_registers_pf_values_filename "pcie_ss_p1_msix_vector_ctrl.mif"
		set msix_registers_pf_values_filepath [file join $gen_folder_path $msix_registers_pf_values_filename] 
		set msix_registers_pf_values_file [open $msix_registers_pf_values_filepath w+]
		
		
		# Convert byte on the offset address of datt table to word address (byte/4) eg: 0x7FF --> 0x1FF
		set curr_addr_values 0x0

   	        if {$core8_msix_vector_alloc_hwtcl == "Static"} {
		    set total_pf_bar [expr $core8_total_pf_count_hwtcl+ $core8_total_vf_count_hwtcl]
                    set total_msix_ram [expr $core8_msix_table_size_hwtcl_value * $total_pf_bar]

	        } elseif {$core8_msix_vector_alloc_hwtcl == "Dynamic" } {
	                  set total_count [expr $core8_total_pf_count_hwtcl == 1 & $core8_total_vf_count_hwtcl == 0]
	                  set total_pf_bar [expr $total_count ? 2048:4096]
	                  set total_msix_ram [expr $total_pf_bar]

                }

	        
        # MIF Header
		# Total depth need to determine by which paramter: determine by the total number of address in the mif file
        
        #set total_depth 2048
        set total_depth [expr int(pow(2,ceil(log($total_msix_ram)/log(2))))]     
      	
        output_MIF_value_header $msix_registers_pf_values_file $total_depth
	
		output_block_comment $msix_registers_pf_values_file " "
		
		write_msix_value $msix_registers_pf_values_file curr_addr_values $total_pf_bar $total_depth " "
		
		output_MIF_value_footer $msix_registers_pf_values_file
		close $msix_registers_pf_values_file
			              

    }

    
}



proc generate_ctrl_shadow_ram_reset_MIF_file { path } {
    file mkdir [file join $path output]
    
    set gen_folder_path [file join $path output ]
    set parameter_filename "parameters.txt"
    set parameter_filepath [file join $path $parameter_filename]
    
    set ip_topology [ip_get "parameter.top_topology_hwtcl.value"]

    #FOR PF RAM
    # 18:16 bits for MRRS reset value is 0x2
    set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p0_ctrl_shadow_pf_ram_reset.mif"
    set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
    set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]

    set curr_addr_values 0x0
    set total_ctrl_shadow_pf_ram 8

    set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
    #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
    set total_width 23
    
    output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
    
    # 18:16 bits for MRRS reset value is 0x2
    write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
    
    output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
    close $ctrl_shadow_pf_ram_registers_values_file
    
    #FOR VF RAM
    # Initial value 0x0
    set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p0_ctrl_shadow_vf_ram_reset.mif"
    set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
    set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]

    set curr_addr_values 0x0
    set total_ctrl_shadow_vf_ram 512

    set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
    #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
    set total_width 24

    output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
    
    write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
    
    output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
    close $ctrl_shadow_vf_ram_registers_values_file

    if { [regexp "2x8" $ip_topology]} {

        #FOR PF RAM
        # 18:16 bits for MRRS reset value is 0x2
        set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p1_ctrl_shadow_pf_ram_reset.mif"
        set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
        set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_pf_ram 8

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
        set total_width 23
        
        output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
        
        # 18:16 bits for MRRS reset value is 0x2
        write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
        close $ctrl_shadow_pf_ram_registers_values_file
        
        #FOR VF RAM
        # Initial value 0x0
        set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p1_ctrl_shadow_vf_ram_reset.mif"
        set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
        set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_vf_ram 512

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
        set total_width 24

        output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
        
        write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
        close $ctrl_shadow_vf_ram_registers_values_file

    }
     if { [regexp "4x4" $ip_topology]} {
         #FOR PF RAM
        # 18:16 bits for MRRS reset value is 0x2
        set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p0_ctrl_shadow_pf_ram_reset.mif"
        set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
        set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_pf_ram 8

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
        set total_width 23
        
        output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
        
        # 18:16 bits for MRRS reset value is 0x2
        write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
        close $ctrl_shadow_pf_ram_registers_values_file
        
        #FOR VF RAM
        # Initial value 0x0
        set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p0_ctrl_shadow_vf_ram_reset.mif"
        set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
        set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_vf_ram 512

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
        set total_width 24

        output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
        
        write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
        close $ctrl_shadow_vf_ram_registers_values_file
       
        #FOR PF RAM
        # 18:16 bits for MRRS reset value is 0x2
        set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p1_ctrl_shadow_pf_ram_reset.mif"
        set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
        set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_pf_ram 8

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
        set total_width 23
        
        output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
        
        # 18:16 bits for MRRS reset value is 0x2
        write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
        close $ctrl_shadow_pf_ram_registers_values_file
        
        #FOR VF RAM
        # Initial value 0x0
        set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p1_ctrl_shadow_vf_ram_reset.mif"
        set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
        set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_vf_ram 512

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
        set total_width 24

        output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
        
        write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
        close $ctrl_shadow_vf_ram_registers_values_file


        #FOR PF RAM
        # 18:16 bits for MRRS reset value is 0x2
        set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p2_ctrl_shadow_pf_ram_reset.mif"
        set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
        set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_pf_ram 8

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
        set total_width 23
        
        output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
        
        # 18:16 bits for MRRS reset value is 0x2
        write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
        close $ctrl_shadow_pf_ram_registers_values_file
        
        #FOR VF RAM
        # Initial value 0x0
        set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p2_ctrl_shadow_vf_ram_reset.mif"
        set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
        set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_vf_ram 512

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
        set total_width 24

        output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
        
        write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
        close $ctrl_shadow_vf_ram_registers_values_file

          #FOR PF RAM
        # 18:16 bits for MRRS reset value is 0x2
        set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p3_ctrl_shadow_pf_ram_reset.mif"
        set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
        set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_pf_ram 8

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
        set total_width 23
        
        output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
        
        # 18:16 bits for MRRS reset value is 0x2
        write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
        close $ctrl_shadow_pf_ram_registers_values_file
        
        #FOR VF RAM
        # Initial value 0x0
        set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p3_ctrl_shadow_vf_ram_reset.mif"
        set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
        set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]

        set curr_addr_values 0x0
        set total_ctrl_shadow_vf_ram 512

        set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
        #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
        set total_width 24

        output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
        
        write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
        
        output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
        close $ctrl_shadow_vf_ram_registers_values_file



    }
    if { [regexp "2x4" $ip_topology]} {
       #FOR PF RAM
       # 18:16 bits for MRRS reset value is 0x2
       set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p0_ctrl_shadow_pf_ram_reset.mif"
       set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
       set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]
   
       set curr_addr_values 0x0
       set total_ctrl_shadow_pf_ram 8
   
       set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
       #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
       set total_width 23
       
       output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
       
       # 18:16 bits for MRRS reset value is 0x2
       write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
       
       output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
       close $ctrl_shadow_pf_ram_registers_values_file
       
       #FOR VF RAM
       # Initial value 0x0
       set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p0_ctrl_shadow_vf_ram_reset.mif"
       set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
       set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]
   
       set curr_addr_values 0x0
       set total_ctrl_shadow_vf_ram 512
   
       set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
       #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
       set total_width 24
   
       output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
       
       write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
       
       output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
       close $ctrl_shadow_vf_ram_registers_values_file
   
       # Repeat for the second set (pcie_ss_p2)
       #FOR PF RAM
       # 18:16 bits for MRRS reset value is 0x2
       set ctrl_shadow_pf_ram_registers_values_filename "pcie_ss_p2_ctrl_shadow_pf_ram_reset.mif"
       set ctrl_shadow_pf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_pf_ram_registers_values_filename] 
       set ctrl_shadow_pf_ram_registers_values_file [open $ctrl_shadow_pf_ram_registers_values_filepath w+]
   
       set curr_addr_values 0x0
       set total_ctrl_shadow_pf_ram 8
   
       set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_pf_ram)/log(2))))]
       #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_pf_ram_value
       set total_width 23
       
       output_MIF_value_header_2 $ctrl_shadow_pf_ram_registers_values_file $total_depth $total_width
       
       # 18:16 bits for MRRS reset value is 0x2
       write_ctrl_shadow_pf_ram_value $ctrl_shadow_pf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_pf_ram $total_depth ""
       
       output_MIF_value_footer $ctrl_shadow_pf_ram_registers_values_file
       close $ctrl_shadow_pf_ram_registers_values_file
       
       #FOR VF RAM
       # Initial value 0x0
       set ctrl_shadow_vf_ram_registers_values_filename "pcie_ss_p2_ctrl_shadow_vf_ram_reset.mif"
       set ctrl_shadow_vf_ram_registers_values_filepath [file join $gen_folder_path $ctrl_shadow_vf_ram_registers_values_filename] 
       set ctrl_shadow_vf_ram_registers_values_file [open $ctrl_shadow_vf_ram_registers_values_filepath w+]
   
       set curr_addr_values 0x0
       set total_ctrl_shadow_vf_ram 512
   
       set total_depth [expr int(pow(2,ceil(log($total_ctrl_shadow_vf_ram)/log(2))))]
       #if this value changed, please change the numbers of "0" in proc write_ctrl_shadow_vf_ram_value
       set total_width 24
   
       output_MIF_value_header_2 $ctrl_shadow_vf_ram_registers_values_file $total_depth $total_width
       
       write_ctrl_shadow_vf_ram_value $ctrl_shadow_vf_ram_registers_values_file curr_addr_values $total_ctrl_shadow_vf_ram $total_depth ""
       
       output_MIF_value_footer $ctrl_shadow_vf_ram_registers_values_file
       close $ctrl_shadow_vf_ram_registers_values_file
}


}
#################################################################################################################################################################
#                                                        MAIN                                                                                                   #
#                                                                                                                                                               #
#                                                                                                                                                               #
#################################################################################################################################################################



# file mkdir [file join [pwd] output]
# generate_MIF_file [file join [pwd] output]
# file mkdir [file join [pwd] output]

# Remove the following line if using this file for ACDS branch
