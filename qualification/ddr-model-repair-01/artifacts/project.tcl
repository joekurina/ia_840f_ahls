package require ::quartus::project
project_new model_repair -overwrite
set_global_assignment -name FAMILY "Agilex 7"
set_global_assignment -name DEVICE AGFB027R25A2E2V
export_assignments
project_close
