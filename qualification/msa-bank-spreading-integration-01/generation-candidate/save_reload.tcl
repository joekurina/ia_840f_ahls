# First command is an ancestry-bound execution-review gate.
exec /usr/bin/python3 -B /home/uwb_student00/ahls/new_BSP/qualification/msa-bank-spreading-integration-01/generation-candidate/run_generation.py --active save-reload
package require -exact qsys 26.1
set_project_property DEVICE {AGFB027R25A2E2V}
set_project_property DEVICE_FAMILY {agilex}
set_project_property BOARD {default}
set_validation_property AUTOMATIC_VALIDATION false
add_component mem_ss /home/uwb_student00/ahls/new_BSP/work_ia840f_msa_generation_01/mem_ss.ip mem_ss mem_ss
load_component mem_ss
apply_component_preset {ia840f_discrete_rdimm_source}
save_component
file copy /home/uwb_student00/ahls/new_BSP/work_ia840f_msa_generation_01/mem_ss.ip /home/uwb_student00/ahls/new_BSP/work_ia840f_msa_generation_01/first-save.ip
load_component mem_ss
save_component
