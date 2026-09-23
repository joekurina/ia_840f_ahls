load_package project
load_package sta
namespace eval ::ia840f_csr_paths01 {
 variable out {/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_csr02/csr-paths01/csr-path-reports}
 variable prefix {afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|core|dma|csr_mgr_inst|}
 proc emit {args} {
  variable fd
  puts $fd [join $args "\t"]
  flush $fd
 }
 proc names {label col cap require} {
  variable prefix
  set q_count [get_collection_size $col]
  emit COUNT $label $q_count $cap
  puts "CSR_COUNT $label $q_count cap=$cap";flush stdout
  if {$q_count > $cap || ($require && $q_count == 0)} {error "CSR collection $label count=$q_count cap=$cap"}
  foreach_in_collection q_n $col {
   set q_name [get_node_info -name $q_n]
   if {![string match "${prefix}*" $q_name]} {error "Unexpected CSR member $q_name"}
   emit NODE $label $q_name [get_node_info -type $q_n] [get_node_info -location $q_n]
  }
 }
 proc clkname {id} {
  if {$id == ""} {return NONE}
  return [get_clock_info -name $id]
 }
 proc cone {ci label metric from to} {
  variable out
  set q_args [list -$metric -npaths 1024 -nworst 1 -from $from -to $to -detail full_path]
  set q_paths [get_timing_paths {*}$q_args]
  set q_n [get_collection_size $q_paths]
  emit PATHCOUNT $ci $label $metric $q_n 1024
  puts "CSR_PATHCOUNT $ci $label $metric $q_n";flush stdout
  if {$q_n >= 1024} {error "CSR path cap reached for $ci $label $metric count=$q_n"}
  if {$q_n == 0} {emit GAP $ci $label $metric NO_TIMED_PATH;return}
  foreach_in_collection q_p $q_paths {
   emit PATH $ci $label $metric [get_path_info -corner $q_p] [get_path_info -slack $q_p] [get_node_info -name [get_path_info -from $q_p]] [get_node_info -name [get_path_info -to $q_p]] [clkname [get_path_info -from_clock $q_p]] [clkname [get_path_info -to_clock $q_p]] [get_path_info -clock_relationship $q_p] [get_path_info -data_delay $q_p] [get_path_info -setup_end_multicycle $q_p] [get_path_info -setup_start_multicycle $q_p] [get_path_info -hold_end_multicycle $q_p] [get_path_info -hold_start_multicycle $q_p]
  }
  set q_ret [report_timing -$metric -npaths 4 -nworst 1 -from $from -to $to -detail full_path -show_routing -file [file join $out ${ci}_${label}_${metric}.rpt]]
  emit REPORT $ci $label $metric {*}$q_ret
 }
 proc main {} {
  variable out;variable prefix;variable fd
  if {[file exists $out]} {error "Query output already exists"}
  file mkdir $out
  set fd [open [file join $out observations.tsv] {WRONLY CREAT EXCL}]
  fconfigure $fd -translation lf
  project_open -preserve_revision_order -revision ofs_pr_afu ofs_top
  create_timing_netlist -snapshot final
  read_sdc
  update_timing_netlist
  set q_clocks [get_clocks *]
  set q_nc [get_collection_size $q_clocks]
  emit CLOCKCOUNT $q_nc
  if {$q_nc < 1 || $q_nc > 150} {error "Clock count $q_nc"}
  foreach_in_collection q_clock $q_clocks {
   set q_type [get_clock_info -type $q_clock]
   emit CLOCK [get_clock_info -name $q_clock] $q_type [get_clock_info -period $q_clock] [get_clock_info -waveform $q_clock]
  }
  set q_all [get_registers "${prefix}*"]
  set q_src [get_registers "${prefix}src_last_q*"]
  set q_dst [get_registers "${prefix}dst_last_q*"]
  set q_length [get_registers "${prefix}dma_csr_map.descriptor.length*"]
  names all_csr $q_all 2048 1
  names source_endpoint $q_src 256 1
  names destination_endpoint $q_dst 256 1
  names descriptor_length $q_length 256 1
  set q_ops [get_available_operating_conditions]
  set q_nop [get_collection_size $q_ops]
  emit CORNERCOUNT $q_nop
  if {$q_nop != 5} {error "Expected five operating conditions, found $q_nop"}
  set q_ci 0
  foreach_in_collection q_op $q_ops {
   incr q_ci
   set_operating_conditions $q_op
   update_timing_netlist
   foreach q_metric {setup hold} {
    cone $q_ci arithmetic_to_src $q_metric $q_all $q_src
    cone $q_ci arithmetic_to_dst $q_metric $q_all $q_dst
    cone $q_ci src_to_admission $q_metric $q_src $q_all
    cone $q_ci dst_to_admission $q_metric $q_dst $q_all
    cone $q_ci length_feedback $q_metric $q_length $q_length
    cone $q_ci csr_full $q_metric $q_all $q_all
   }
  }
  emit DONE $q_ci
  close $fd
  project_close
  puts CSR_PATH_QUERY_DONE
  flush stdout
 }
}
::ia840f_csr_paths01::main
