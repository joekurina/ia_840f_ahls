cmake_minimum_required(VERSION 3.16)
project(ia840f_migrated_persona_synthesis LANGUAGES NONE)
set(PERSONA_PROJECT "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_implementation01/base01/build/syn/board/ia840f/syn_top" CACHE PATH "Bound fresh matching PR project")
set(QUARTUS_ROOT "/opt/altera/26.1.1/quartus" CACHE PATH "Bound Quartus installation")
if(NOT PERSONA_PROJECT STREQUAL "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_implementation01/base01/build/syn/board/ia840f/syn_top" OR NOT QUARTUS_ROOT STREQUAL "/opt/altera/26.1.1/quartus")
  message(FATAL_ERROR "Unexpected persona/tool root")
endif()
if(NOT EXISTS "${PERSONA_PROJECT}/ofs_pr_afu.qsf" OR NOT EXISTS "${PERSONA_PROJECT}/ofs_top.qdb")
  message(FATAL_ERROR "Prepared PR project and matching static QDB required")
endif()
add_custom_target(version COMMAND "${QUARTUS_ROOT}/bin/quartus_syn" --version VERBATIM USES_TERMINAL)
add_custom_target(synthesis
  COMMAND "${QUARTUS_ROOT}/bin/quartus_syn" --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
  WORKING_DIRECTORY "${PERSONA_PROJECT}"
  VERBATIM USES_TERMINAL)
