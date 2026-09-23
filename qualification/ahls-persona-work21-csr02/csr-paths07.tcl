load_package project
load_package sta
namespace eval ::ia840f_csr_paths07 {
 variable out {/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_csr02/csr-paths07/csr-path-reports}
 variable prefix {afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|core|dma|csr_mgr_inst|}
 proc emit {args} {
  variable fd
  puts $fd [join $args "\t"]
  flush $fd
 }
 proc counted {label col cap} {
  set q_size [get_collection_size $col]
  emit COUNT $label $q_size $cap
  puts "CSR_TOPO_COUNT $label $q_size cap=$cap";flush stdout
  if {$q_size > $cap} {error "Topology collection $label count=$q_size cap=$cap"}
  return $q_size
 }
 proc node {label id} {
  emit NODE $label $id [get_node_info -name $id] [get_node_info -type $id] [get_node_info -location $id]
 }
 proc edges {label id} {
  foreach q_option {synch_edges asynch_edges clock_edges fanout_edges} {
   set q_edges [get_node_info -$q_option $id]
   set q_count [llength $q_edges]
   emit EDGECOUNT $label $id $q_option $q_count 2048
   if {$q_count > 2048} {error "Edge count $q_count for $label/$id/$q_option"}
   foreach q_edge $q_edges {
    set q_source [get_edge_info -src $q_edge]
    set q_dest [get_edge_info -dst $q_edge]
    emit EDGE $label $id $q_option $q_edge [get_edge_info -type $q_edge] [get_edge_info -delay_type $q_edge] [get_edge_info -is_disabled $q_edge] $q_source [get_node_info -name $q_source] [get_node_info -type $q_source] $q_dest [get_node_info -name $q_dest] [get_node_info -type $q_dest]
   }
  }
 }
 proc neighborhood {label col} {
  # Both arguments below are genuine collections, not individual node handles.
  foreach q_direction {fanins fanouts} {
   set q_neighbors [get_$q_direction $col]
   counted ${label}_${q_direction} $q_neighbors 2048
   foreach_in_collection q_neighbor $q_neighbors {
    node ${label}_${q_direction} $q_neighbor
   }
  }
 }
 proc cell_slice {label reg} {
  node ${label}_seed $reg
  edges ${label}_seed $reg
  set q_cell [get_node_info -cell $reg]
  emit CELL $label $q_cell [get_cell_info -name $q_cell] [get_cell_info -type $q_cell] [get_cell_info -wysiwyg_type $q_cell] [get_cell_info -location $q_cell]
  emit PINNAMES $label IN [get_cell_info -in_pin_names $q_cell]
  emit PINNAMES $label OUT [get_cell_info -out_pin_names $q_cell]
  set q_allpins [get_cell_info -pins $q_cell]
  counted ${label}_pins $q_allpins 64
  foreach_in_collection q_pin $q_allpins {
   node ${label}_pin $q_pin
   edges ${label}_pin $q_pin
   # Intersect genuine pin collections; no literal bus-name glob lookup.
   variable prefix;variable rolecols;variable timedpins
   set q_pin_name [get_node_info -name $q_pin]
   set q_role [lindex [split $q_pin_name |] end]
   if {![info exists rolecols($q_role)]} {
    set rolecols($q_role) [get_pins -compatibility_mode -no_duplicates [list "${prefix}*|${q_role}"]]
    counted csr_role_${q_role} $rolecols($q_role) 10000
   }
   set q_other [remove_from_collection $q_allpins $rolecols($q_role)]
   set q_pin_col [remove_from_collection $q_allpins $q_other]
   set q_np [counted ${label}_pin_lookup $q_pin_col 32]
   set q_match 0
   if {$q_np == 1} {
    foreach_in_collection q_matched $q_pin_col {
     set q_match [string equal [get_node_info -name $q_matched] $q_pin_name]
    }
   }
   if {$q_match} {
    emit PIN_ASSOC $label $q_pin_name EXACT_SINGLETON
    if {$q_role in {d ena}} {lappend timedpins [list ${label}_${q_role} $q_pin_name $q_pin_col]}
    # Clock distribution is inventoried as immediate edges, not traversed.
    if {[lsearch -exact {clk clrn prn aload} [lindex [split $q_pin_name |] end]] < 0} {
     neighborhood ${label}_pin_${q_pin_name} $q_pin_col
    } else {emit SKIP $label $q_pin_name CLOCK_OR_ASYNC_CONTROL_NEIGHBORHOOD}
   } else {emit GAP $label $q_pin_name PIN_LOOKUP_NOT_EXACT_SINGLETON}
  }
  set q_buried [get_cell_info -buried_nodes $q_cell]
  counted ${label}_buried $q_buried 64
  foreach_in_collection q_bnode $q_buried {
   node ${label}_buried $q_bnode
   edges ${label}_buried $q_bnode
  }
  set q_regs [get_cell_info -buried_regs $q_cell]
  counted ${label}_buried_regs $q_regs 64
  foreach_in_collection q_breg $q_regs {node ${label}_buried_reg $q_breg}
  # Preserve cell-union neighborhoods separately; never assign every union
  # neighbor to every individual pin when exact lookup was unavailable.
  neighborhood ${label}_input_union [get_cell_info -in_pins $q_cell]
  neighborhood ${label}_output_union [get_cell_info -out_pins $q_cell]
 }
 proc timing_pin {ci label pin_name pc metric} {
  variable out
  set q_paths [get_timing_paths -$metric -npaths 128 -nworst 1 -through $pc -detail full_path]
  set q_count [get_collection_size $q_paths]
  emit PATHCOUNT $ci $label $metric $q_count 128
  if {$q_count >= 128} {error "Representative through-pin path cap reached $label/$metric"}
  if {$q_count == 0} {emit GAP $ci $label $metric NO_TIMED_PATH;return}
  foreach_in_collection q_path $q_paths {
   set q_fc [get_path_info -from_clock $q_path]
   set q_tc [get_path_info -to_clock $q_path]
   emit PATH $ci $label $metric [get_path_info -corner $q_path] [get_path_info -slack $q_path] [get_node_info -name [get_path_info -from $q_path]] [get_node_info -name [get_path_info -to $q_path]] [get_clock_info -name $q_fc] [get_clock_info -name $q_tc] [get_path_info -clock_relationship $q_path] [get_path_info -data_delay $q_path] [get_path_info -setup_end_multicycle $q_path] [get_path_info -setup_start_multicycle $q_path] [get_path_info -hold_end_multicycle $q_path] [get_path_info -hold_start_multicycle $q_path] $pin_name
  }
  set q_report [report_timing -$metric -npaths 4 -nworst 1 -through $pc -detail full_path -show_routing -file [file join $out ${ci}_${label}_${metric}.rpt]]
  emit REPORT $ci $label $metric {*}$q_report
 }
 proc main {} {
  variable out;variable prefix;variable fd;variable timedpins
  set timedpins {}
  if {[file exists $out]} {error "Query output already exists"}
  file mkdir $out
  set fd [open [file join $out topology.tsv] {WRONLY CREAT EXCL}]
  fconfigure $fd -translation lf
  uplevel #0 {
   project_open -preserve_revision_order -revision ofs_pr_afu ofs_top
   foreach q_api {get_afu_json_user_clock_freqs get_aligned_user_clock_targets} {
    if {[llength [info commands ::$q_api]] != 1} {error "Missing global PIM helper $q_api"}
   }
   create_timing_netlist -snapshot final
   read_sdc
   update_timing_netlist
  }
  set q_clocks [get_clocks *]
  if {[counted clocks $q_clocks 150] != 81} {error "Changed clock inventory"}
  foreach_in_collection q_clock $q_clocks {
   emit CLOCK [get_clock_info -name $q_clock] [get_clock_info -type $q_clock] [get_clock_info -period $q_clock] [get_clock_info -waveform $q_clock]
  }
  set q_all [get_registers "${prefix}*"]
  if {[counted all_csr $q_all 2048] != 1139} {error "Changed CSR inventory"}
  set q_seeds [list {dma_csr_map.descriptor.length[14]~DUPLICATE.comb} {dma_csr_map.descriptor.length[0]~DUPLICATE.comb}]
  set q_locations [list FF_X259_Y66_N13 FF_X259_Y69_N26]
  foreach q_seed $q_seeds q_location $q_locations q_label {length14_duplicate length0_duplicate} {
   set q_found 0
   foreach_in_collection q_reg $q_all {
    if {[string equal [get_node_info -name $q_reg] "${prefix}${q_seed}"]} {
     incr q_found
     if {![string equal [get_node_info -location $q_reg] $q_location]} {error "Seed physical identity mismatch $q_seed"}
     cell_slice $q_label $q_reg
    }
   }
   emit SEEDCOUNT $q_label $q_seed $q_found
   if {$q_found != 1} {error "Seed count $q_seed: $q_found"}
  }
  emit TIMEDPINCOUNT [llength $timedpins]
  if {[llength $timedpins] != 4} {error "Expected four verified duplicate-branch data/enable pins"}
  set q_ops [get_available_operating_conditions]
  if {[get_collection_size $q_ops] != 5} {error "Changed corner inventory"}
  set q_ci 0
  foreach_in_collection q_op $q_ops {
   incr q_ci
   set_operating_conditions $q_op
   update_timing_netlist
   foreach q_item $timedpins {
    lassign $q_item q_label q_pin_name q_pc
    foreach q_metric {setup hold} {timing_pin $q_ci $q_label $q_pin_name $q_pc $q_metric}
   }
  }
  emit DONE 2 $q_ci
  close $fd
  uplevel #0 {project_close}
  puts CSR_PATH_QUERY_DONE
  flush stdout
 }
}
::ia840f_csr_paths07::main
