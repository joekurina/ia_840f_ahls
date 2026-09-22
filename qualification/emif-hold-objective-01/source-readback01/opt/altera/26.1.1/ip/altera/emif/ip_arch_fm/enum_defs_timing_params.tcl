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


package provide altera_emif::ip_arch_fm::enum_defs_timing_params 0.1

package require altera_emif::util::enums

namespace eval ::altera_emif::ip_arch_fm::enum_defs_timing_params:: {
   namespace import ::altera_emif::util::enums::*


}


proc ::altera_emif::ip_arch_fm::enum_defs_timing_params::def_enums {} {

   def_enum_type TPARAM                                       {     TCL_NAME                      }
   def_enum      TPARAM          TPARAM_PROTOCOL              [list "PROTOCOL"                    ]
   def_enum      TPARAM          TPARAM_NUM_RANKS             [list "NUM_RANKS"                   ]
   def_enum      TPARAM          TPARAM_SLEW_RATE_DRAM        [list "SLEW_RATE_DRAM"              ]
   def_enum      TPARAM          TPARAM_SLEW_RATE_DRAM_CLOCK  [list "SLEW_RATE_DRAM_CLOCK"        ]
   def_enum      TPARAM          TPARAM_VIN_MS                [list "VIN_Ms"                      ]
   def_enum      TPARAM          TPARAM_VIN_MH                [list "VIN_Mh"                      ]
   def_enum      TPARAM          TPARAM_SLEW_RATE_PHY         [list "SLEW_RATE_PHY"               ]
   def_enum      TPARAM          TPARAM_SLEW_RATE_PHY_CLOCK   [list "SLEW_RATE_PHY_CLOCK"         ]
   def_enum      TPARAM          TPARAM_SLEW_RATE_CA          [list "SLEW_RATE_CA"                ]
   def_enum      TPARAM          TPARAM_SLEW_RATE_CLOCK       [list "SLEW_RATE_CLOCK"             ]
   def_enum      TPARAM          TPARAM_UI                    [list "UI"                          ]
   def_enum      TPARAM          TPARAM_TCK                   [list "tCK"                         ]
   def_enum      TPARAM          TPARAM_TDQSQ                 [list "tDQSQ"                       ]
   def_enum      TPARAM          TPARAM_TQH                   [list "tQH"                         ]
   def_enum      TPARAM          TPARAM_TDS                   [list "tDS"                         ]
   def_enum      TPARAM          TPARAM_TDH                   [list "tDH"                         ]
   def_enum      TPARAM          TPARAM_TIS                   [list "tIS"                         ]
   def_enum      TPARAM          TPARAM_TIH                   [list "tIH"                         ]
   def_enum      TPARAM          TPARAM_TDQSCK                [list "tDQSCK"                      ]
   def_enum      TPARAM          TPARAM_TDQSS                 [list "tDQSS"                       ]
   def_enum      TPARAM          TPARAM_TWLS                  [list "tWLS"                        ]
   def_enum      TPARAM          TPARAM_TWLH                  [list "tWLH"                        ]
   def_enum      TPARAM          TPARAM_TDSS                  [list "tDSS"                        ]
   def_enum      TPARAM          TPARAM_TDSH                  [list "tDSH"                        ]
   def_enum      TPARAM          TPARAM_BD_PKG_SKEW           [list "BD_PKG_SKEW"                 ]
   def_enum      TPARAM          TPARAM_CA_BD_PKG_SKEW        [list "CA_BD_PKG_SKEW"              ]
   def_enum      TPARAM          TPARAM_CA_TO_CK_BD_PKG_SKEW  [list "CA_TO_CK_BD_PKG_SKEW"        ]
   def_enum      TPARAM          TPARAM_DQS_BOARD_SKEW        [list "DQS_BOARD_SKEW"              ]
   def_enum      TPARAM          TPARAM_DQS_TO_CK_BOARD_SKEW  [list "DQS_TO_CK_BOARD_SKEW"        ]
   def_enum      TPARAM          TPARAM_RD_ISI                [list "RD_ISI"                      ]
   def_enum      TPARAM          TPARAM_WR_ISI                [list "WR_ISI"                      ]
   def_enum      TPARAM          TPARAM_CA_ISI                [list "CA_ISI"                      ]
   def_enum      TPARAM          TPARAM_DQSG_ISI              [list "DQSG_ISI"                    ]
   def_enum      TPARAM          TPARAM_WL_ISI                [list "WL_ISI"                      ]
   def_enum      TPARAM          TPARAM_X4                    [list "X4"                          ]
   def_enum      TPARAM          TPARAM_IS_DLL_ON             [list "IS_DLL_ON"                   ]
   def_enum      TPARAM          TPARAM_OCT_RECAL             [list "OCT_RECAL"                   ]
   def_enum      TPARAM          TPARAM_RDBI                  [list "RDBI"                        ]
   def_enum      TPARAM          TPARAM_WDBI                  [list "WDBI"                        ]
   def_enum      TPARAM          TPARAM_CUT_PATHS             [list "CUT_C2P_P2C_PATHS"           ]
   def_enum      TPARAM          TPARAM_CA_DESKEW             [list "CA_DESKEW"                   ]

   def_enum_type TPARAM_HWTCL                                 {     HWTCL_PARAM                   }
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_TARGET_SPEEDGRADE         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_TARGET_IS_ES              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_TARGET_IS_ES2             ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_TARGET_IS_ES3             ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_TARGET_IS_PRODUCTION      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_CORE_CLKS_SHARING_ENUM    ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_CONFIG_ENUM               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_PING_PONG_EN              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list IS_HPS                        ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_MEM_CLK_FREQ_MHZ          ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_REF_CLK_FREQ_MHZ          ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_REF_CLK_JITTER_PS         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_REF_CLK_FREQ_PS_STR       ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_VCO_FREQ_PS_STR           ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_VCO_TO_MEM_CLK_FREQ_RATIO ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_PHY_CLK_VCO_PHASE         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list USER_CLK_RATIO                ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list C2P_P2C_CLK_RATIO             ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_HMC_CLK_RATIO             ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list MEM_FORMAT_ENUM               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list MEM_DATA_MASK_EN              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list DIAG_TIMING_REGTEST_MODE      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list DIAG_CPA_OUT_1_EN             ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list DIAG_USE_CPA_LOCK             ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PHY_USERMODE_OCT              ]

   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list AMM_C2P_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list AMM_P2C_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list MMR_C2P_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list MMR_P2C_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list SIDEBAND_C2P_UFI_MODE         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list SIDEBAND_P2C_UFI_MODE         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list SEQ_C2P_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list SEQ_P2C_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list ECC_C2P_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list ECC_P2C_UFI_MODE              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list LANE_C2P_UFI_MODE             ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list LANE_P2C_UFI_MODE             ]

   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_NUM_OF_EXTRA_CLKS         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_LOW_3               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_HIGH_3              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_BYPASS_EN_3         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_PHASE_PS_STR_3      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_DUTY_CYCLE_3        ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_LOW_4               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_HIGH_4              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_BYPASS_EN_4         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_PHASE_PS_STR_4      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_DUTY_CYCLE_4        ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_LOW_5               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_HIGH_5              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_BYPASS_EN_5         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_PHASE_PS_STR_5      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_DUTY_CYCLE_5        ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_LOW_6               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_HIGH_6              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_BYPASS_EN_6         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_PHASE_PS_STR_6      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_DUTY_CYCLE_6        ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_LOW_7               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_HIGH_7              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_BYPASS_EN_7         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_PHASE_PS_STR_7      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_DUTY_CYCLE_7        ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_LOW_8               ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_HIGH_8              ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_BYPASS_EN_8         ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_PHASE_PS_STR_8      ]
   def_enum      TPARAM_HWTCL    _AUTO_GEN_                   [list PLL_C_CNT_DUTY_CYCLE_8        ]
	
   def_enum_type TPARAM_EXTRA_CONFIG                          {     CONFIG                    DEFAULT }
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2P_SETUP_OC_NS           0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2P_HOLD_OC_NS            0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list P2C_SETUP_OC_NS           0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list P2C_HOLD_OC_NS            0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2C_SAME_CLK_SETUP_OC_NS  0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2C_SAME_CLK_HOLD_OC_NS   0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2C_DIFF_CLK_SETUP_OC_NS  0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2C_DIFF_CLK_HOLD_OC_NS   0.000   ]
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2C_TG_FALSE_PATH         false   ]   
   def_enum      TPARAM_EXTRA_CONFIG    _AUTO_GEN_            [list C2P_P2C_PR                false   ]
}


proc ::altera_emif::ip_arch_fm::enum_defs_timing_params::_init {} {
   ::altera_emif::ip_arch_fm::enum_defs_timing_params::def_enums
}

::altera_emif::ip_arch_fm::enum_defs_timing_params::_init

