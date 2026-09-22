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


# Welcome!
#
# Run this script to turn the generated ed_synth.qsys file into a
# synthesizable Quartus II project.
#
# The following generates a Quartus II project targeting a default
# device for the device family you have chosen during IP generation:
#
#    quartus_sh -t make_qii_design.tcl
#

proc error_and_exit {msg} {
   post_message -type error "SCRIPT_ABORTED!!!"
   foreach line [split $msg "\n"] {
      post_message -type error $line
   }
   qexit -error
}

proc ls_recursive {base glob} {
    set files [list]

    foreach f [glob -nocomplain -types f -directory $base $glob] {
        set file_path [file join $base $f]
        lappend files $file_path
    }

    foreach d [glob -nocomplain -types d -directory $base *] {
        set files_recursive [ls_recursive [file join $base $d] $glob]
        lappend files {*}$files_recursive
    }

    return $files
}

proc ls_dirs_recursive {base glob} {
    set dirs [list]

    foreach d [glob -nocomplain -types d -directory $base $glob] {
        set dir_path [file join $base $d]
        lappend dirs $dir_path
    }

    foreach d [glob -nocomplain -types d -directory $base *] {
        set dirs_recursive [ls_dirs_recursive [file join $base $d] $glob]
        lappend dirs {*}$dirs_recursive
    }

    return $dirs
}

proc get_relative_path {base path} {
    return [string trimleft [ string range $path [string length $base] [string length $path] ] "/"]
}

proc deep_copy {ifn ofn} {
   set ifh       [open $ifn r]
   set ofh       [open $ofn w]
   
   # treat file as binary to avoid any line-ending conversion
   fconfigure $ifh -translation binary
   fconfigure $ofh -translation binary
   
   set blob [read $ifh]
   puts -nonewline $ofh $blob

   close $ofh
   close $ifh
}

proc parse_extra_configs {str} {
   array set retval {}
   foreach item [split $str ",; "] {
      set tmp [split $item "="]
      if {[llength $tmp] == 2} {
         set name [string toupper [lindex $tmp 0]]
         set val [lindex $tmp 1]
         set retval($name) $val
      }
   }
   return [array get retval]
}

if {[string compare -nocase $quartus(nameofexecutable) "quartus"] == 0} {
   set gui_mode 1
} else {
   set gui_mode 0
}

set script_path [file dirname [file normalize [info script]]]

# source in parameters
source "$script_path/params.tcl"

# The script always creates a new project from scratch. If there's an
# existing project we must close it first. In the GUI this will cause
# the user to be prompted to save modified files, etc.
if {[is_project_open]} {
   post_message "Closing currently opened project..."
   project_close
}

set ex_design_path         "$script_path/qii"
set system_name            $ed_params(SYNTH_QSYS_NAME)
set qsys_file              "${system_name}.qsys"
set family                 $ip_params(SYS_INFO_DEVICE_FAMILY)
set issp_en                false
if {[info exists ip_params(DIAG_EX_DESIGN_ISSP_EN)]} {
    set issp_en                $ip_params(DIAG_EX_DESIGN_ISSP_EN)
}    
set extra_config_str        $ip_params(DIAG_EXTRA_PARAMETERS)
set extra_config_dict       [parse_extra_configs $extra_config_str]

set arg [lindex $argv 0]
if {$argc > 1} {
   error_and_exit "make_qii_design.tcl can only take one argument.\nThe argument must be a valid device OPN,"
} elseif {$argc == 1} {
   set device $arg 
} else {
   set device $ed_params(DEFAULT_DEVICE)
}

post_message " "
post_message "*************************************************************************"
post_message "Intel External Memory Interface IP Example Design Builder"
post_message " "
post_message "Type  : Quartus Prime Project"
post_message "Family: $family"
post_message "Device: $device"
post_message " "
post_message "This script takes ~1 minute to execute..."
post_message "*************************************************************************"
post_message " "

# Check if a QII project already exists
if {[file isdirectory $ex_design_path]} {
   error_and_exit "Directory $ex_design_path has already been generated.\nThis script cannot overwrite generated example designs.\nIf you would like to regenerate the design by re-running the script, please remove the directory."
}

# Copy qsys file to target directory
file mkdir $ex_design_path
file copy -force "${script_path}/$qsys_file" "${ex_design_path}/$qsys_file"

# Copy ip files to target directory
file mkdir "${ex_design_path}/ip"
file copy -force "${script_path}/ip/${system_name}" "${ex_design_path}/ip/."

# # Copy JTAG SDC to target directory
# # Use deep copy to copy a file from the build to avoid copying symlinks
deep_copy "$::env(QUARTUS_ROOTDIR)/../ip/altera/emif_ph2/ip_phy/ex_design/jtag_example.sdc" "${ex_design_path}/jtag_example.sdc"

# If quartus.ini exists, copy into target directory so that generation uses the same quartus.ini
if {[file exists "${script_path}/quartus.ini"]} {
   file copy -force "${script_path}/quartus.ini" "${ex_design_path}/quartus.ini"
}

# Run qsys-generate to generate the example design system
post_message "Generating example design files..."

set qsys_generate_exe_path "$::env(QUARTUS_ROOTDIR)/sopc_builder/bin/qsys-generate"
set quartus_py_exe_path "$::env(QUARTUS_ROOTDIR)/bin/quartus_py"
if {![file exists $quartus_py_exe_path]} { set quartus_py_exe_path "$::env(QUARTUS_ROOTDIR)/bin64/quartus_py" }

cd $ex_design_path
exec -ignorestderr $qsys_generate_exe_path $qsys_file --pro --quartus-project=none --synthesis --family=$family --part=$device --search-path=$::env(QUARTUS_ROOTDIR)/../not_shipped/ip/altera/**/*,$ >>& ip_generate.out

# Create QII project
post_message "Creating Quartus Prime project..."
project_new -family $family -part $device $system_name
set_global_assignment -name QSYS_FILE ${system_name}.qsys

if {$issp_en} {
   set_global_assignment -name VERILOG_MACRO "\"ALTERA_EMIF_ENABLE_ISSP=1\""
}
# lsort is required to add files in a deterministic order which is required
# for deterministic compilation results through Quartus
foreach ip_file [lsort [ls_recursive "${ex_design_path}/ip" "*.ip"]] {
   # Add the relative path from the project dir to the IP files
   set ip_file [get_relative_path $ex_design_path $ip_file]
   set_global_assignment -name IP_FILE $ip_file
}

# Add JTAG SDC to example design
set_global_assignment -name SDC_FILE jtag_example.sdc

# Adding SDM Oscillator clock frequency assignment
if {[dict exists $extra_config_dict OSC_1_CLOCK_FREQUENCY]} {
   set_global_assignment -name DEVICE_INITIALIZATION_CLOCK [dict get $extra_config_dict OSC_1_CLOCK_FREQUENCY]
} else {
   set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_100MHZ
}

# Add assignments when using a SM device with only one bonded IO96
# We want to route the usr_pll refclk into the fabric; can either to this with a specific pin for the
# IO96 pins, or with a IOSTD for an HVIO Pin
if {[regexp "A5E.*B23A" $device] || [regexp "A5E.00\[57\].*B23B" $device] || [regexp "SM7REVB_EC_A_V839A" $device]} {
   set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to ref_clk_usr_pll_clk -entity ed_synth
   set_instance_assignment -name IO_STANDARD "1.8-V LVCMOS" -to ref_clk_usr_pll_clk
}

# set ASIC PROTOTYPING for ND7M parts 
if ([string match "1SG10MHN3F74C2LGS1*"  $device]) {
    set_global_assignment -name ASIC_PROTOTYPING on 
}

project_close

# source NoC Address mapping logic
source $script_path/noc_address_maps.tcl

# Open qsf file to append
post_message "Post processing ${ed_synth}.qsf for NOC assignments..."


set ed_synth_file    "$ex_design_path/${ed_synth}.qsf"
set fh [open $ed_synth_file a]
if {$ip_params(AXI_SIDEBAND_ACCESS_MODE_AUTO_BOOL)} {
   set sideband_access $ip_params(AXI_SIDEBAND_ACCESS_MODE_AUTO)
} else {
   set sideband_access $ip_params(AXI_SIDEBAND_ACCESS_MODE)
}
if {$ip_params(PHY_NOC_EN_AUTO_BOOL)} {
   set noc_enable $ip_params(PHY_NOC_EN_AUTO)
} else {
   set noc_enable $ip_params(PHY_NOC_EN)
}
if {[string is true $noc_enable] || ($sideband_access == "NOC")}  {
   puts $fh [get_noc_qsf_assgn]
   #puts $fh "set_instance_assignment -name VIRTUAL_PIN ON -to *refclk* -entity $ed_synth"
   puts $fh ""
}

set extra_config_str        $ip_params(DIAG_EXTRA_PARAMETERS);
puts $extra_config_str
array set extra_config_arr       [parse_extra_configs $extra_config_str]

if {[info exists extra_config_arr(USE_HYDRA)]} {
   set use_hydra $extra_config_arr(USE_HYDRA)
} else {
   set use_hydra "true"
}

if {$use_hydra} {
   set hydra_prog emif_tg_emulation

    if {[info exists extra_config_arr(HYDRA_PROG)]} {
      set hydra_prog $extra_config_arr(HYDRA_PROG)
   } else {
      set hydra_prog $ip_params(EX_DESIGN_HYDRA_PROG)
   }

   # Copy Hydra software files to target directory
   set srcdir [ls_dirs_recursive "${ex_design_path}/ip" "hydra_software*"]
   set srcdir [ls_dirs_recursive "$srcdir" "sw"]
   set dstdir "$ex_design_path/hydra_sw"
   file mkdir $dstdir
   foreach script_file [lsort [ls_recursive $srcdir "*"]] {
      # output path
      set dst_script_file [file join $dstdir [get_relative_path $srcdir $script_file]]
      # create any sub-dirs
      file mkdir [file dirname $dst_script_file]
      # copy
      deep_copy $script_file $dst_script_file
   }

   # Compile Hydra software to provide users with a default traffic pattern
   set cmd [concat [list exec -ignorestderr $quartus_py_exe_path ${dstdir}/main.py --ipdir=${ex_design_path} --prog=$hydra_prog >>& hydra_compile.out]]
   cd $ex_design_path
   eval $cmd
} 

# Copy pmon system console script
if {$ip_params(EX_DESIGN_PMON_ENABLED)} {
   set srcfile [ls_recursive "${ex_design_path}/ip" "pmon_library.tcl"]
   set srcfile [lindex $srcfile 0]
   deep_copy $srcfile "$ex_design_path/pmon_library.tcl"
}

# If we're in GUI mode, open the project for user
if {$gui_mode} {
   project_open $system_name
}

post_message " "
post_message "*************************************************************************"
post_message "Successfully generated example design at the following location:"
post_message " "
post_message "   $ex_design_path"
post_message " "
post_message "*************************************************************************"
post_message " "
