cmake_minimum_required(VERSION 3.16)
project(ia840f_ofs2026_migration LANGUAGES NONE)

set(FIM_PROJECT "" CACHE PATH "Fresh, source-bound IA840F project directory")
set(QUARTUS_ROOT "/opt/altera/26.1.1/quartus" CACHE PATH "Pinned Quartus installation")
set(IP_INVENTORY_OUTPUT "" CACHE FILEPATH "Fresh project-IP inventory output")
if(NOT QUARTUS_ROOT STREQUAL "/opt/altera/26.1.1/quartus")
  message(FATAL_ERROR "This migration requires Quartus Prime Pro 26.1.1 Build 130")
endif()
if(NOT EXISTS "${FIM_PROJECT}/ofs_top.qsf" OR NOT IS_ABSOLUTE "${IP_INVENTORY_OUTPUT}")
  message(FATAL_ERROR "A prepared project and absolute fresh IP inventory path are required")
endif()
get_filename_component(FIM_ROOT "${FIM_PROJECT}/../../../.." ABSOLUTE)

# Independent native targets; no default build or automatic next-stage launch.
# Admission remains in the copied, source-bound project callback.
add_custom_target(ip_inventory
  COMMAND "${QUARTUS_ROOT}/bin/quartus_ipgenerate"
    -t "${FIM_ROOT}/ofs-common/scripts/common/syn/emit_project_ip.tcl"
    --project=ofs_top --revision=ofs_top "--output=${IP_INVENTORY_OUTPUT}"
  WORKING_DIRECTORY "${FIM_PROJECT}"
  VERBATIM USES_TERMINAL)

add_custom_target(ip_regeneration
  COMMAND "${QUARTUS_ROOT}/bin/quartus_ipgenerate"
    ofs_top -c ofs_top --generate_project_ip_files
    --synthesis=verilog --clear_ip_generation_dirs --parallel=off
  WORKING_DIRECTORY "${FIM_PROJECT}"
  VERBATIM USES_TERMINAL)

add_custom_target(headers
  COMMAND "${QUARTUS_ROOT}/bin/quartus_sh"
    -t "${FIM_ROOT}/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl"
    --project=ofs_top --revision=ofs_top
  WORKING_DIRECTORY "${FIM_PROJECT}"
  VERBATIM USES_TERMINAL)

add_custom_target(compile
  COMMAND "${QUARTUS_ROOT}/bin/quartus_sh"
    --flow compile ofs_top -c ofs_top
  WORKING_DIRECTORY "${FIM_PROJECT}"
  VERBATIM USES_TERMINAL)
