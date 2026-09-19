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


proc ::mem_ss_pkg::ip_msa::declare {} {
   set ip_dir "$::env(QUARTUS_ROOTDIR)/../ip/altera/subsystems/mem_ss_pkg/ip_msa"
   load_strings "${ip_dir}/strings/module.properties"
   load_strings "${ip_dir}/strings/gui.properties"
   load_strings "${ip_dir}/strings/interfaces.properties"
   load_strings "${ip_dir}/strings/parameters.properties"

   declare_module
   declare_filesets
   declare_display_items
   declare_parameters
   declare_interfaces
}

proc ::mem_ss_pkg::ip_msa::declare_module {} {
   table create module [list \
      [list @           VERSION  OUTDATED_IP_FILE  INTERNAL SUPPORTED_DEVICE_FAMILIES  SUPPORTED_DIE_TYPES  EDITABLE   INSTANTIATE_IN_SYSTEM_MODULE  REPORT_HIERARCHY  OPAQUE_ADDRESS_MAP VALIDATION_CALLBACK            ELABORATION_CALLBACK             DOC_LINKS                   ] \
      [list mem_ss_msa  1.0.5    mem_ss_msa.odip   true     NOVAL                      NOVAL                true       true                          true              false              ::mem_ss_pkg::ip_msa::validate ::mem_ss_pkg::ip_msa::elaborate  {USER_GUIDE SUPPORT_CENTER} ] \
   ]
}

proc ::mem_ss_pkg::ip_msa::declare_filesets {} {
   table create filesets [list \
      [list @              KIND           TOP_LEVEL      CALLBACK                                             ] \
      [list sim_vhdl       sim_vhdl       mem_ss_msa_top ::mem_ss_pkg::ip_msa::sim_vhdl_fileset_callback      ] \
      [list sim_verilog    sim_verilog    mem_ss_msa_top ::mem_ss_pkg::ip_msa::sim_verilog_fileset_callback   ] \
      [list quartus_synth  quartus_synth  mem_ss_msa_top ::mem_ss_pkg::ip_msa::quartus_synth_fileset_callback ] \
      [list cdc            cdc            mem_ss_msa_top ::mem_ss_pkg::ip_msa::cdc_fileset_callback           ] \
      [list cdc_vhdl       cdc_vhdl       mem_ss_msa_top ::mem_ss_pkg::ip_msa::cdc_vhdl_fileset_callback      ] \
   ]
}

proc ::mem_ss_pkg::ip_msa::declare_display_items {} {
   table create display_items [list \
      [list GROUP    @                 TYPE     DISPLAY_HINT ] \
      [list ""       PERF_OPT_GROUP    GROUP    NOVAL        ] \
      [list ""       AXI_INTF_GROUP    GROUP    NOVAL        ] \
   ]
}

proc ::mem_ss_pkg::ip_msa::declare_parameters {} {
   table create parameters [::mem_ss_pkg::util::get_sysinfo_params]

   table create parameters [list \
      [list GROUP          @                    TYPE     ALLOWED_RANGES       DEFAULT_VALUE     VISIBLE DERIVED  HDL_PARAMETER  AFFECTS_VALIDATION   AFFECTS_ELABORATION ] \
      [list ""             DEVICE_FAMILY        string   ""                   ""                false   true     true           false                false               ] \
      [list ""             NUM_USER_POOLS       integer  [list 1 2]           1                 false   true     true           false                false               ] \
      [list ""             SCHEDULER_POLICY     string   [list NATURAL \
                                                               TXN_WINDOW \
                                                               CLK_WINDOW]    TXN_WINDOW        false   true     true           false                false               ] \
      [list ""             READY_LATENCY        integer  ""                   3                 false   true     true           false                false               ] \
      [list ""             VALID_LATENCY        integer  ""                   0                 false   true     true           false                false               ] \
      [list ""             ROW_ADDR_WIDTH       integer  ""                   1                 false   false    true           false                false               ] \
      [list ""             COL_ADDR_WIDTH       integer  ""                   1                 false   false    true           false                false               ] \
      [list ""             BANK_ADDR_WIDTH      integer  ""                   1                 false   false    true           false                false               ] \
      [list ""             BANK_GROUP_WIDTH     integer  ""                   1                 false   false    true           false                false               ] \
      [list ""             CHIP_ID_WIDTH        integer  ""                   1                 false   false    true           false                false               ] \
      [list ""             CHIP_SELECT_WIDTH    integer  ""                   1                 false   false    true           false                false               ] \
      \
      [list ""             CSR_EN               boolean  ""                   false             false   false    false          true                 true                ] \
      [list ""             ECC_EN               boolean  ""                   false             false   false    false          true                 true                ] \
      [list ""             PRIORITY_EN          boolean  ""                   false             false   false    false          true                 true                ] \
      [list ""             MBL_TRAFFIC_EN       boolean  ""                   false             false   false    true           true                 true                ] \
   ]

   table create parameters [list \
      [list GROUP          @                    TYPE     UNITS       DISPLAY_UNITS  ALLOWED_RANGES          DEFAULT_VALUE  DERIVED  HDL_PARAMETER   AFFECTS_VALIDATION   AFFECTS_ELABORATION ] \
      [list PERF_OPT_GROUP AUTO_PRECHARGE       string   NOVAL       NOVAL          [list DISABLED \
                                                                                          SS_CONTROLLED \
                                                                                          USER_CONTROLLED]  SS_CONTROLLED  false    true            true                 true                ] \
      \
      [list PERF_OPT_GROUP NUM_COPIES           integer  NOVAL       NOVAL          [list 1 2 4 8]          1              false    true            true                 true                ] \
      \
      [list PERF_OPT_GROUP NUM_BANK_FIFOS       integer  NOVAL       NOVAL          [list 0 2 4 8]          0              false    true            true                 true                ] \
      \
      [list PERF_OPT_GROUP SCHEDULER_NUM_READ   integer  NOVAL       NOVAL          {1:1024}                16             false    true            false                false               ] \
      [list PERF_OPT_GROUP SCHEDULER_NUM_WRITE  integer  NOVAL       NOVAL          {1:1024}                16             false    true            false                false               ] \
   ]

   table create parameters [list \
      [list GROUP          @                    TYPE     UNITS       ALLOWED_RANGES    DEFAULT_VALUE    VISIBLE  DERIVED  HDL_PARAMETER  AFFECTS_VALIDATION   AFFECTS_ELABORATION ] \
      [list AXI_INTF_GROUP ASYNC_EN             boolean  NOVAL       NOVAL             true             true     false    true           true                 true                ] \
      \
      [list AXI_INTF_GROUP RESP_BUS_PROTOCOL    string   NOVAL       [list AXI4]       AXI4             false    false    false          true                 true                ] \
      [list AXI_INTF_GROUP RESP_WR_DATA_WIDTH   integer  bits        ""                256              true     false    false          true                 true                ] \
      [list AXI_INTF_GROUP RESP_RD_DATA_WIDTH   integer  bits        ""                256              true     false    false          true                 true                ] \
      [list AXI_INTF_GROUP RESP_USE_WSTRB       boolean  NOVAL       ""                true             true     false    true           true                 true                ] \
      \
      [list AXI_INTF_GROUP INIT_BUS_PROTOCOL    string   NOVAL       [list AVMM AXI4]  AVMM             false    false    false          true                 true                ] \
      [list AXI_INTF_GROUP INIT_ID_WIDTH        integer  bits        NOVAL             9                false    false    true           true                 true                ] \
      [list AXI_INTF_GROUP INIT_AWADDR_WIDTH    integer  bits        NOVAL             32               false    false    true           true                 true                ] \
      [list AXI_INTF_GROUP INIT_ARADDR_WIDTH    integer  bits        NOVAL             32               false    false    true           true                 true                ] \
      [list AXI_INTF_GROUP INIT_WR_DATA_WIDTH   integer  bits        ""                256              false    false    false          true                 true                ] \
      [list AXI_INTF_GROUP INIT_RD_DATA_WIDTH   integer  bits        ""                256              false    false    false          true                 true                ] \
   ]

   table create parameters [list \
      [list GROUP          @                    TYPE     UNITS       DEFAULT_VALUE  VISIBLE  DERIVED  HDL_PARAMETER AFFECTS_VALIDATION   AFFECTS_ELABORATION ] \
      [list ""             RESP_ID_WIDTH        integer  bits        9              false    true     true          false                false               ] \
      [list ""             RESP_AWADDR_WIDTH    integer  bits        32             false    true     true          false                false               ] \
      [list ""             RESP_ARADDR_WIDTH    integer  bits        32             false    true     true          false                false               ] \
      [list ""             RESP_WDATA_WIDTH     integer  bits        32             false    true     true          false                false               ] \
      [list ""             RESP_USE_WUSER       boolean  NOVAL       false          false    true     true          false                false               ] \
      [list ""             RESP_WUSER_WIDTH     integer  bits        32             false    true     true          false                false               ] \
      [list ""             RESP_RDATA_WIDTH     integer  bits        32             false    true     true          false                false               ] \
      [list ""             RESP_USE_RUSER       boolean  NOVAL       false          false    true     true          false                false               ] \
      [list ""             RESP_RUSER_WIDTH     integer  bits        32             false    true     true          false                false               ] \
      \
      [list ""             INIT_WDATA_WIDTH     integer  bits        32             false    true     true          false                false               ] \
      [list ""             INIT_USE_WUSER       boolean  NOVAL       false          false    true     true          false                false               ] \
      [list ""             INIT_WUSER_WIDTH     integer  bits        32             false    true     true          false                false               ] \
      [list ""             INIT_RDATA_WIDTH     integer  bits        32             false    true     true          false                false               ] \
      [list ""             INIT_USE_RUSER       boolean  NOVAL       false          false    true     true          false                false               ] \
      [list ""             INIT_RUSER_WIDTH     integer  bits        32             false    true     true          false                false               ] \
   ]
}

proc ::mem_ss_pkg::ip_msa::declare_interfaces {} {

   table create interfaces [list \
      [list @        TYPE        DIRECTION   ENABLED__EXPR  associatedClock   synchronousEdges ] \
      [list s_clk    clock       sink        NOVAL          NOVAL             NOVAL            ] \
      [list s_reset  reset       sink        NOVAL          NOVAL             none             ] \
      \
      [list m_clk    clock       sink        NOVAL          NOVAL             NOVAL            ] \
      [list m_reset  reset       sink        NOVAL          NOVAL             none             ] \
   ]

   table create interfaces [list \
      [list @        TYPE        DIRECTION   ENABLED__EXPR associatedClock   associatedReset   maximumOutstandingReads maximumOutstandingWrites   maximumOutstandingTransactions   readAcceptanceCapability   writeAcceptanceCapability  combinedAcceptanceCapability ] \
      [list s_axi4   axi4        subordinate NOVAL         s_clk             s_reset           NOVAL                   NOVAL                      NOVAL                            64                         64                         64                           ] \
   ]

   table create interfaces [list \
      [list @        TYPE        DIRECTION   ENABLED__EXPR  associatedClock   associatedReset   addressUnits   bitsPerSymbol  constantBurstBehavior   maximumPendingReadTransactions ] \
      [list m_avmm   avalon      manager     NOVAL          m_clk             m_reset           SYMBOLS        8              NOVAL                   64                             ] \
   ]

   table create interfaces [list \
      [list @                       TYPE        DIRECTION   ENABLED__EXPR                    ] \
      [list status                  conduit     start       NOVAL                            ] \
      [list status_in               conduit     end         NOVAL                            ] \
      [list ctrl_auto_precharge     conduit     start       {![peq AUTO_PRECHARGE DISABLED]} ] \
      [list ctrl_user_priority      conduit     start       {[peq PRIORITY_EN true]}         ] \
      [list ctrl_ecc_user_interrupt conduit     end         {[peq ECC_EN true]}              ] \
      [list ctrl_ecc_readdataerror  conduit     end         {[peq ECC_EN true]}              ] \
   ]

   table create interfaces [list \
      [list @                       TYPE        DIRECTION   ENABLED__EXPR                    ] \
      [list msa_csr                 conduit     start       {[peq CSR_EN true]}              ] \
   ]



   table create ports [list \
      [list @                             ROLE                 DIRECTION   WIDTH_EXPR           TERMINATION__EXPR             TERMINATION_VALUE VHDL_TYPE ] \
      [list s_clk:s_clk                   clk                  input       1                    NOVAL                         0                 AUTO      ] \
      \
      [list s_reset:s_reset_n             reset_n              input       1                    NOVAL                         0                 AUTO      ] \
      \
      [list m_clk:m_clk                   clk                  input       1                    NOVAL                         0                 AUTO      ] \
      \
      [list m_reset:m_reset_n             reset_n              input       1                    NOVAL                         0                 AUTO      ] \
   ]

   table create ports [list \
      [list @                             ROLE                 DIRECTION   WIDTH_EXPR           TERMINATION__EXPR             TERMINATION_VALUE VHDL_TYPE ] \
      [list s_axi4:s_axi4_awready         awready              output      1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awvalid         awvalid              input       1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awid            awid                 input       "RESP_ID_WIDTH"      NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awaddr          awaddr               input       "RESP_AWADDR_WIDTH"  NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awlen           awlen                input       8                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awsize          awsize               input       3                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awburst         awburst              input       2                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awlock          awlock               input       1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awcache         awcache              input       4                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awprot          awprot               input       3                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awqos           awqos                input       4                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_awuser          awuser               input       14                   NOVAL                         0                 AUTO      ] \
      \
      [list s_axi4:s_axi4_arready         arready              output      1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arvalid         arvalid              input       1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arid            arid                 input       "RESP_ID_WIDTH"      NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_araddr          araddr               input       "RESP_ARADDR_WIDTH"  NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arlen           arlen                input       8                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arsize          arsize               input       3                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arburst         arburst              input       2                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arlock          arlock               input       1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arcache         arcache              input       4                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arprot          arprot               input       3                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_arqos           arqos                input       4                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_aruser          aruser               input       14                   NOVAL                         0                 AUTO      ] \
      \
      [list s_axi4:s_axi4_wready          wready               output      1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_wvalid          wvalid               input       1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_wdata           wdata                input       "RESP_WDATA_WIDTH"   NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_wuser           wuser                input       "RESP_WUSER_WIDTH"   NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_wstrb           wstrb                input       "RESP_WDATA_WIDTH/8" NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_wlast           wlast                input       1                    NOVAL                         0                 AUTO      ] \
      \
      [list s_axi4:s_axi4_bready          bready               input       1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_bvalid          bvalid               output      1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_bid             bid                  output      "RESP_ID_WIDTH"      NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_bresp           bresp                output      2                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_buser           buser                output      1                    NOVAL                         0                 AUTO      ] \
      \
      [list s_axi4:s_axi4_rready          rready               input       1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_rvalid          rvalid               output      1                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_rid             rid                  output      "RESP_ID_WIDTH"      NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_rresp           rresp                output      2                    NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_rdata           rdata                output      "RESP_RDATA_WIDTH"   NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_ruser           ruser                output      "RESP_RUSER_WIDTH"   NOVAL                         0                 AUTO      ] \
      [list s_axi4:s_axi4_rlast           rlast                output      1                    NOVAL                         0                 AUTO      ] \
   ]

   table create ports [list \
      [list @                             ROLE                 DIRECTION   WIDTH_EXPR           TERMINATION__EXPR             TERMINATION_VALUE VHDL_TYPE ] \
      [list m_avmm:m_avmm_ready           waitrequest_n        input       1                    NOVAL                         0                 AUTO      ] \
      [list m_avmm:m_avmm_read            read                 output      1                    NOVAL                         0                 AUTO      ] \
      [list m_avmm:m_avmm_write           write                output      1                    NOVAL                         0                 AUTO      ] \
      [list m_avmm:m_avmm_address         address              output      "INIT_AWADDR_WIDTH"  NOVAL                         0                 AUTO      ] \
      [list m_avmm:m_avmm_burstcount      burstcount           output      7                    NOVAL                         0                 AUTO      ] \
      [list m_avmm:m_avmm_writedata       writedata            output      "INIT_WDATA_WIDTH"   NOVAL                         0                 AUTO      ] \
      [list m_avmm:m_avmm_byteenable      byteenable           output      "INIT_WDATA_WIDTH/8" {![ptrue RESP_USE_WSTRB]}     0                 AUTO      ] \
      [list m_avmm:m_avmm_readdata        readdata             input       "INIT_RDATA_WIDTH"   NOVAL                         0                 AUTO      ] \
      [list m_avmm:m_avmm_readdatavalid   readdatavalid        input       1                    NOVAL                         0                 AUTO      ] \
   ]

   table create ports [list \
      [list @                                               ROLE                       DIRECTION   WIDTH_EXPR  TERMINATION__EXPR TERMINATION_VALUE VHDL_TYPE ] \
      [list status:local_cal_success                        local_cal_success          output      1           NOVAL             0                 AUTO      ] \
      [list status:local_cal_fail                           local_cal_fail             output      1           NOVAL             0                 AUTO      ] \
      \
      [list status_in:local_cal_success_in                  local_cal_success          input       1           NOVAL             0                 AUTO      ] \
      [list status_in:local_cal_fail_in                     local_cal_fail             input       1           NOVAL             0                 AUTO      ] \
      \
      [list ctrl_auto_precharge:ctrl_auto_precharge_req     ctrl_auto_precharge_req    output      1           NOVAL             0                 AUTO      ] \
      \
      [list ctrl_user_priority:ctrl_user_priority_hi        ctrl_user_priority_hi      output      1           NOVAL             0                 AUTO      ] \
      \
      [list ctrl_ecc_user_interrupt:ctrl_ecc_user_interrupt ctrl_ecc_user_interrupt    input       1           NOVAL             0                 AUTO      ] \
      \
      [list ctrl_ecc_readdataerror:ctrl_ecc_readdataerror   ctrl_ecc_readdataerror     input       1           NOVAL             0                 AUTO      ] \
   ]

   table create ports [list \
      [list @                                               ROLE                       DIRECTION   WIDTH_EXPR  TERMINATION__EXPR TERMINATION_VALUE VHDL_TYPE ] \
      [list msa_csr:msa_csr_slverr                          msa_csr_slverr             output      1           NOVAL             0                 AUTO      ] \
      [list msa_csr:msa_csr_decerr                          msa_csr_decerr             output      1           NOVAL             0                 AUTO      ] \
   ]
}

