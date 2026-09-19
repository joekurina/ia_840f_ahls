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


proc ::mem_ss_pkg::ip_mem_ss::declare {system_name} {

   set ip_dir "$::env(QUARTUS_ROOTDIR)/../ip/altera/subsystems/mem_ss_pkg/ip_mem_ss"
   load_strings "${ip_dir}/strings/package.properties"
   load_strings "${ip_dir}/strings/gui.properties"
   load_strings "${ip_dir}/strings/parameters.properties"

   declare_package $system_name
   declare_private_tables
   declare_filesets
   declare_parameters_and_gui

   source "${ip_dir}/qcp/${system_name}_hwtcl_commands.tcl"
}

proc ::mem_ss_pkg::ip_mem_ss::declare_package {system_name} {

   switch -- $system_name {
      mem_ss {
         set supported_families  {"Agilex 7" "Agilex 9"}
         set supported_die_types {HSSI_* MAIN_FM[0-9]*}
         table create package [list \
            [list @           VERSION  OUTDATED_IP_FILE        UNLOCKABLE  INTERNAL    SUPPORTED_DEVICE_FAMILIES  SUPPORTED_DIE_TYPES  VALIDATION_CALLBACK                 ELABORATION_CALLBACK                EXTRACTION_CALLBACK              DOC_LINKS                           REFERENCE_IP_ONLY_IN_VDS] \
            [list mem_ss      5.0.1    mem_ss.odip   false       false       $supported_families        $supported_die_types ::mem_ss_pkg::ip_mem_ss::validate   ::mem_ss_pkg::ip_mem_ss::elaborate  ::mem_ss_pkg::ip_mem_ss::extract {USER_GUIDE AG7_INTF_DESIGN SUPPORT_CENTER}   true] \
         ]
      }
      mem_ss_fp {
         set supported_families  {"Agilex 7" "Agilex 5"}
         set supported_die_types {HSSI_* MAIN_FP* MAIN_SM* MAIN_FMM*}
         table create package [list \
            [list @           VERSION  OUTDATED_IP_FILE        UNLOCKABLE  INTERNAL    SUPPORTED_DEVICE_FAMILIES  SUPPORTED_DIE_TYPES  VALIDATION_CALLBACK                 ELABORATION_CALLBACK                EXTRACTION_CALLBACK              DOC_LINKS                                           ] \
            [list mem_ss_fp   1.0.0    NOVAL                   false       true        $supported_families        $supported_die_types ::mem_ss_pkg::ip_mem_ss::validate   ::mem_ss_pkg::ip_mem_ss::elaborate  ::mem_ss_pkg::ip_mem_ss::extract {USER_GUIDE AG7_INTF_DESIGN AG5_INTF_DESIGN SUPPORT_CENTER} ] \
         ]
      }
   }
}

proc ::mem_ss_pkg::ip_mem_ss::declare_filesets {} {
   table create filesets [list \
      [list @              KIND           CALLBACK                                                 ] \
      [list sim_vhdl       sim_vhdl       ::mem_ss_pkg::ip_mem_ss::sim_vhdl_fileset_callback       ] \
      [list sim_verilog    sim_verilog    ::mem_ss_pkg::ip_mem_ss::sim_verilog_fileset_callback    ] \
      [list quartus_synth  quartus_synth  ::mem_ss_pkg::ip_mem_ss::quartus_synth_fileset_callback  ] \
      [list cdc            cdc            ::mem_ss_pkg::ip_mem_ss::cdc_fileset_callback            ] \
      [list cdc_vhdl       cdc_vhdl       ::mem_ss_pkg::ip_mem_ss::cdc_vhdl_fileset_callback       ] \
      [list example_design example_design ::mem_ss_pkg::ip_mem_ss::example_design_fileset_callback ] \
   ]
}

proc ::mem_ss_pkg::ip_mem_ss::declare_parameters_and_gui {} {

   ::mem_ss_pkg::util::create_parameters [::mem_ss_pkg::util::get_sysinfo_params]

   table create display_items [list \
      [list GROUP                      @                          TYPE     DISPLAY_HINT      ARGS  ] \
      [list ""                         TOP_CONTAINER_1            group    {column:98%}      NOVAL ] \
      [list ""                         TOP_CONTAINER_2            group    {column:1%}       NOVAL ] \
      [list ""                         TOP_CONTAINER_3            group    {column:1%}       NOVAL ] \
      [list ""                         TOP_CONTAINER_END          group    {group_finalize}  NOVAL ] \
      [list TOP_CONTAINER_1            RUN_COMPOSE_TEXT           text     NOVAL             "<html><i><b>NOTE:</b> Please enable the below checkbox before diving into packaged subsystem, generating HDL, or generating design example</i></html>" ] \
   ]
   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                      @                          TYPE     ALLOWED_RANGES DEFAULT_VALUE ] \
      [list TOP_CONTAINER_1            RUN_COMPOSE                boolean  NOVAL          false         ] \
   ]

   table create display_items [list \
      [list GROUP                      @                          TYPE     DISPLAY_HINT ] \
      [list ""                         TOPOLOGY_TAB               group    {tab}        ] \
      [list ""                         IMPL_TAB                   group    {tab}        ] \
      [list ""                         EX_DESIGN_TAB              group    {tab}        ] \
   ]


   table create display_items [list \
      [list GROUP                      @                          TYPE     DISPLAY_HINT ] \
      [list TOPOLOGY_TAB               MEM_INTFS_GROUP            group    NOVAL        ] \
      [list TOPOLOGY_TAB               APP_INTFS_GROUP            group    NOVAL        ] \
      [list TOPOLOGY_TAB               CONNECTIONS_GROUP          group    NOVAL        ] \
      \
      [list MEM_INTFS_GROUP            MEM_INTFS_TABLE            group    {table}      ] \
      \
      [list APP_INTFS_GROUP            APP_INTFS_TABLE            group    {table}      ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                      @                          TYPE     DEFAULT_VALUE  __FAMILY           ] \
      [list CONNECTIONS_GROUP          COLLAPSE_HBM_CHANNELS      boolean  false          {   fp           } ] \
   ]

   table create display_items [list \
      [list GROUP                      @                          TYPE     ARGS                                                  DISPLAY_HINT     ] \
      [list CONNECTIONS_GROUP          CONN_BUTTON_CONTAINER_1    group    NOVAL                                                 {column:12%}     ] \
      [list CONNECTIONS_GROUP          CONN_BUTTON_CONTAINER_2    group    NOVAL                                                 {column:12%}     ] \
      [list CONNECTIONS_GROUP          CONN_BUTTON_CONTAINER_3    group    NOVAL                                                 {column:12%}     ] \
      [list CONNECTIONS_GROUP          CONN_BUTTON_CONTAINER_PAD  group    NOVAL                                                 {column:64%}     ] \
      [list CONNECTIONS_GROUP          CONN_BUTTON_CONTAINER_END  group    NOVAL                                                 {group_finalize} ] \
      [list CONN_BUTTON_CONTAINER_1    ONE_TO_ONE_CONN            action   ::mem_ss_pkg::ip_mem_ss::one_to_one_action_callback   NOVAL            ] \
      [list CONN_BUTTON_CONTAINER_2    ALL_TO_ALL_CONN            action   ::mem_ss_pkg::ip_mem_ss::all_to_all_action_callback   NOVAL            ] \
      [list CONN_BUTTON_CONTAINER_3    CLEAR_CONN                 action   ::mem_ss_pkg::ip_mem_ss::clear_action_callback        NOVAL            ] \
      [list CONNECTIONS_GROUP          CONNECTIONS_TABLE          group    NOVAL                                                 {table rows:40}  ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                @                       TYPE           DISPLAY_HINT   DERIVED  DEFAULT_VALUE  VALUE__EXPR                               __DYNAMIC_RANGES  __FAMILY             UPDATE_CALLBACK ] \
      [list MEM_INTFS_TABLE      MEM_INTFS_IDX           integer_list   {width:10}     true     [list 0]       {[range [llength [pval MEM_INTFS_TYPE]]]} NOVAL             NOVAL                NOVAL           ] \
      [list MEM_INTFS_TABLE      MEM_INTFS_TYPE          string_list    NOVAL          false    NOVAL          NOVAL                                     1                 NOVAL                ::mem_ss_pkg::ip_mem_ss::mem_intfs_loc_update_callback ] \
      [list MEM_INTFS_TABLE      MEM_INTFS_LOCATION      string_list    NOVAL          false    NOVAL          NOVAL                                     1                 {fm fp smp sm fmm}   ::mem_ss_pkg::ip_mem_ss::mem_intfs_loc_update_callback ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                @                       TYPE           DISPLAY_HINT   DERIVED  DEFAULT_VALUE  VALUE__EXPR                               __DYNAMIC_RANGES  __FAMILY           ] \
      [list APP_INTFS_TABLE      APP_INTFS_IDX           integer_list   {width:10}     true     [list 0]       {[range [llength [pval APP_INTFS_TYPE]]]} NOVAL             NOVAL              ] \
      [list APP_INTFS_TABLE      APP_INTFS_TYPE          string_list    NOVAL          false    NOVAL          NOVAL                                     1                 {fm fp smp sm fmm} ] \
   ]

   set ip_core           [lindex [table rows package] 0]
   set max_dataflow_cols -1
   foreach fam [table cols family_features] {
      if {$ip_core == [table get family_features -> IP_CORE -> $fam]} {
         set max_dataflow_cols [table get family_features -> MAX_DATAFLOW_COLS -> $fam]
         break
      }
   }

   set conn_params [list \
      [list GROUP                @                       TYPE           DISPLAY_HINT   DERIVED  DEFAULT_VALUE  __FAMILY    ] \
      [list CONNECTIONS_TABLE    MEM_CONNS_LABELS        string_list    {fixed_size}   true     [list]         NOVAL       ] \
   ]
   for {set i 0} {$i < $max_dataflow_cols} {incr i} {
      if {$i == 0} {
         set default_val [list true]
      } else {
         set default_val [list false]
      }
      lappend conn_params \
         [list CONNECTIONS_TABLE    MEM_CH_${i}_CONNS       integer_list   {fixed_size boolean table_value:0 width:50}  false    $default_val   {fm fp smp sm fmm} ]
   }
   ::mem_ss_pkg::util::create_parameters $conn_params


   table create display_items [list \
      [list GROUP                @                       TYPE     DISPLAY_HINT   ARGS  ] \
      [list IMPL_TAB             IMPL_NOC_GROUP          group    NOVAL          NOVAL ] \
      [list IMPL_TAB             IMPL_CSR_GROUP          group    NOVAL          NOVAL ] \
      [list IMPL_TAB             IMPL_PMON_GROUP         group    NOVAL          NOVAL ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                @                       TYPE     ALLOWED_RANGES DEFAULT_VALUE  DISABLED_VALUE __FAMILY           ] \
      [list IMPL_NOC_GROUP       ENABLE_NOC              boolean  NOVAL          true           false          {   fp           } ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                @                       TYPE     __DYNAMIC_RANGES  __FAMILY           ] \
      [list IMPL_CSR_GROUP       ENABLE_MEM_CSR_INTF     string   1                 {fm fp smp sm fmm} ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                @                       TYPE     __DYNAMIC_RANGES  __FAMILY           ] \
      [list IMPL_PMON_GROUP      ENABLE_MEM_PMON         string   1                 {fm              } ] \
   ]


   table create display_items [list \
      [list GROUP                @                       TYPE     DISPLAY_HINT ] \
      [list EX_DESIGN_TAB        FILESET_GROUP           group    {}           ] \
      [list EX_DESIGN_TAB        BOARD_GROUP             group    {}           ] \
      [list EX_DESIGN_TAB        HYDRA_GROUP             group    {}           ] \
   ]

   table create display_items [list \
      [list GROUP                @                          TYPE     ARGS           DISPLAY_HINT ] \
      [list BOARD_GROUP          EX_DESIGN_BOARD_INFO_TEXT  text     "Placeholder"  NOVAL        ] \
      [list BOARD_GROUP          REMOVE_BOARD_BUTTON        action   ::mem_ss_pkg::ip_mem_ss::remove_board_action_callback \
                                                                                          NOVAL        ] \
      [list BOARD_GROUP          BOARD_HELP_GROUP           group    NOVAL          {collapsed}  ] \
      [list BOARD_HELP_GROUP     EX_DESIGN_BOARD_HELP_TEXT  text     [get_string GUI_EX_DESIGN_BOARD_HELP_TEXT] \
                                                                                          NOVAL        ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                @                                TYPE     ALLOWED_RANGES       DEFAULT_VALUE  VISIBLE  AFFECTS_ELABORATION  DISABLED_VALUE ENABLED__EXPR ] \
      [list FILESET_GROUP        EX_DESIGN_HDL_FORMAT             string   [list VERILOG \
                                                                                 VHDL]          VERILOG        true     false                VERILOG        {[pval EX_DESIGN_BOARD_PRESET] == ""} ] \
      [list FILESET_GROUP        EX_DESIGN_GEN_SIM                boolean  NOVAL                true           true     false                NOVAL          NOVAL         ] \
      [list FILESET_GROUP        EX_DESIGN_GEN_SYNTH              boolean  NOVAL                true           true     false                NOVAL          NOVAL         ] \
      \
      [list BOARD_GROUP          EX_DESIGN_BOARD_DATA_FILE        string   ""                   ""             false    false                NOVAL          NOVAL         ] \
      [list BOARD_GROUP          EX_DESIGN_BOARD_PRESET           string   ""                   ""             false    false                NOVAL          NOVAL         ] \
      [list BOARD_GROUP          EX_DESIGN_BOARD_NAME             string   ""                   ""             false    false                NOVAL          NOVAL         ] \
      [list BOARD_GROUP          EX_DESIGN_BOARD_VENDOR           string   ""                   ""             false    false                NOVAL          NOVAL         ] \
      [list BOARD_GROUP          EX_DESIGN_BOARD_PRODUCT_URL      string   ""                   ""             false    false                NOVAL          NOVAL         ] \
      [list BOARD_GROUP          EX_DESIGN_BOARD_DEVICE_FAMILY    string   ""                   ""             false    false                NOVAL          NOVAL         ] \
      [list BOARD_GROUP          EX_DESIGN_BOARD_DEVICE_PART      string   ""                   ""             false    false                NOVAL          NOVAL         ] \
      \
      [list HYDRA_GROUP          EX_DESIGN_HYDRA_HOST_INTF        string   [list DISABLED \
                                                                                 EXPORT \
                                                                                 REMOTE_JTAG]   DISABLED       true     false                NOVAL          NOVAL         ] \
   ]

   ::mem_ss_pkg::util::create_parameters [list \
      [list GROUP                @                       TYPE     ALLOWED_RANGES DEFAULT_VALUE  VISIBLE ] \
      [list HYDRA_GROUP          DIAG_EXTRA_PARAMETERS   string   ""             ""             false   ] \
   ]
}

proc ::mem_ss_pkg::ip_mem_ss::declare_private_tables {} {

   ::mem_ss_pkg::util::create_device_features

   table create family_features [list \
      [list @                       fm          fp                   smp               sm                fmm            ] \
      [list IP_CORE                 mem_ss      mem_ss_fp            mem_ss_fp         mem_ss_fp         mem_ss_fp      ] \
      [list MAX_DATAFLOW_COLS       20          50                   50                50                50             ] \
      [list ALLOW_XBAR_EXPR         0           {[ptrue ENABLE_NOC]} 0                 0                 0              ] \
      [list DEFAULT_DEVICE_FOR_ED   FM6_PART1   FP8_PART1            A5EC065AB32AE1V   A5EC065BB32AE4S   FMM3_PART1     ] \
   ]



   table create range__MEM_INTFS_TYPE [list \
      [list @              MAX_PORTS   COLLAPSE_PORTS__EXPR             FAMILY               IP_INST_REGEXP             LEGAL_APPS                          param__ENABLE_NOC ENABLED__EXPR ] \
      [list DDR5COMP       2           0                                {   fp smp    fmm}   {^emif_[0-9]*_ddr5comp$}   {STORAGE -1 HPS -1                } NOVAL             1             ] \
      [list DDR5DIMM       2           0                                {   fp        fmm}   {^emif_[0-9]*_ddr5comp$}   {STORAGE -1 HPS -1                } NOVAL             1             ] \
      \
      [list DDR4           1           0                                {fm              }   {^emif_[0-9]*$}            {STORAGE -1 HPS -1 ASSOC_STORAGE 1} NOVAL             1             ] \
      [list DDR4COMP       1           0                                {   fp smp sm fmm}   {^emif_[0-9]*_ddr5comp$}   {STORAGE -1 HPS -1                } NOVAL             1             ] \
      [list DDR4DIMM       1           0                                {   fp        fmm}   {^emif_[0-9]*_ddr5comp$}   {STORAGE -1 HPS -1                } {false     }      1             ] \
      \
      [list LPDDR5         4           0                                {   fp smp sm fmm}   {^emif_[0-9]*_ddr5comp$}   {STORAGE -1 HPS -1                } NOVAL             1             ] \
      \
      [list LPDDR4         4           0                                {      smp sm fmm}   {^emif_[0-9]*_ddr5comp$}   {STORAGE -1 HPS -1                } NOVAL             1             ] \
      \
      [list HBM2E          16          {[ptrue COLLAPSE_HBM_CHANNELS]}  {   fp           }   {^hbm_[0-9]*$}             {STORAGE -1 HPS -1                } {      true}      {[table get device_features -> has_hbm -> VALUE]}  ] \
      \
      [list M20K           1           0                                {fm              }   {^cam_[0-9]*$}             {                  ASSOC_STORAGE 1} NOVAL             1             ] \
   ]

   table create range__MEM_INTFS_LOCATION [list \
      [list @              FAMILY               param__MEM_INTFS_TYPE      ENABLED__EXPR ] \
      [list TOP            {fm fp smp sm fmm}   {DDR* LPDDR* HBM*     }    1             ] \
      [list BOT            {fm fp smp sm fmm}   {DDR* LPDDR* HBM*     }    1             ] \
      [list M20K           {fm              }   {                 M20K}    1             ] \
   ]

   table create range__APP_INTFS_TYPE [list \
      [list @              MAX_PORTS   COLLAPSE_PORTS                   FAMILY               IP_INST_REGEXP                      LEGAL_MEMS           ENABLED__EXPR ] \
      [list STORAGE        1           0                                {fm fp smp sm fmm}   {^iniu_[0-9]*$}                     {*DDR* -1 HBM* -1}   1             ] \
      [list ASSOC_STORAGE  2           0                                {fm              }   {^cam_[0-9]*$}                      {DDR4 1 M20K 2}      1             ] \
      [list HPS            1           0                                {fm fp smp sm fmm}   {^hps_emif$|^hps_emif_refclk_gpio$} {DDR4 1 *DDR* 2}     {[table get device_features -> has_hps -> VALUE] && (![table get device_features -> has_noc -> VALUE] || [ptrue ENABLE_NOC])} ] \
   ]

   table create range__ENABLE_MEM_CSR_INTF [list \
      [list @                 FAMILY               param__ENABLE_NOC    ENABLED__EXPR ] \
      [list DISABLED          {fm fp smp sm fmm}   {false true}         1             ] \
      [list ENABLED           {fm fp smp sm fmm}   {false     }         1             ] \
      [list DEDICATED_BRIDGE  {   fp           }   {      true}         1             ] \
      [list SHARED_BRIDGE     {   fp           }   {      true}         1             ] \
   ]

   table create range__ENABLE_MEM_PMON [list \
      [list @                 FAMILY               ENABLED__EXPR ] \
      [list DISABLED          {fm              }   1             ] \
      [list EXPORT            {fm              }   1             ] \
      [list TOOLKIT           {fm              }   1             ] \
   ]


   set ip_core         [lindex [table rows package] 0]
   set ip_families     [list]
   foreach fam [table cols family_features] {
      if {$ip_core == [table get family_features -> IP_CORE -> $fam]} {
         lappend ip_families $fam
      }
   }

   foreach table_name [table names "range__*"] {
      foreach range [table rows $table_name] {
         set enabled_expr   [table get $table_name -> $range -> ENABLED__EXPR]
         set range_families [table get $table_name -> $range -> FAMILY]

         set common_families [lintersect $ip_families $range_families]
         if {[lequal $common_families $ip_families]} {
         } elseif {[llength $common_families] == 0} {
            table unset $table_name $range
            continue
         } else {
            if {$enabled_expr != "NOVAL"} {
               table set $table_name -> $range -> ENABLED__EXPR "[expr {$enabled_expr}] && \[table get device_features -> family -> VALUE\] in {$range_families}"
            } else {
               table set $table_name -> $range -> ENABLED__EXPR "                          \[table get device_features -> family -> VALUE\] in {$range_families}"
            }
         }
      }
   }
}

