package require -exact qsys 26.1
load_system model_repair.qsys
load_component ed_sim_mem
set_component_parameter_value SYS_INFO_DEVICE_DIE_REVISIONS [list {HSSI_WHR_REVA} {HSSI_CRETE3_REVA} {MAIN_FM8_REVA}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODTN [list {Rank 0} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT0 [list {(Drive) RZQ/7 (34 Ohm)} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT1 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT2 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT3 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODTN [list {Rank 0} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT0 [list {(Park) RZQ/4 (60 Ohm)} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT1 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT2 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT3 [list {-} {-} {-} {-}]
save_component
reload_component_footprint ed_sim_mem
load_component ed_sim_mem_group1
set_component_parameter_value SYS_INFO_DEVICE_DIE_REVISIONS [list {HSSI_WHR_REVA} {HSSI_CRETE3_REVA} {MAIN_FM8_REVA}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODTN [list {Rank 0} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT0 [list {(Drive) RZQ/7 (34 Ohm)} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT1 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT2 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_R_DERIVED_ODT3 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODTN [list {Rank 0} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT0 [list {(Park) RZQ/4 (60 Ohm)} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT1 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT2 [list {-} {-} {-} {-}]
set_component_parameter_value MEM_DDR4_W_DERIVED_ODT3 [list {-} {-} {-} {-}]
save_component
reload_component_footprint ed_sim_mem_group1
save_system model_repair.qsys
