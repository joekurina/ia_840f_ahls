cmake_minimum_required(VERSION 3.16)
project(ia840f_migrated_persona_first_fit LANGUAGES NONE)
set(PERSONA_PROJECT "" CACHE PATH "Prepared matching mapped-persona project")
set(QUARTUS_ROOT "/opt/altera/26.1.1/quartus" CACHE PATH "Selected Quartus installation")
if(NOT QUARTUS_ROOT STREQUAL "/opt/altera/26.1.1/quartus")
  message(FATAL_ERROR "This qualification uses Quartus Pro 26.1.1")
endif()
if(NOT PERSONA_PROJECT STREQUAL "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01/base01/build/syn/board/ia840f/syn_top")
  message(FATAL_ERROR "The exact fresh mapped project is required")
endif()
if(NOT EXISTS "${PERSONA_PROJECT}/ofs_pr_afu.qsf" OR NOT EXISTS "${PERSONA_PROJECT}/ofs_top.qdb" OR NOT IS_DIRECTORY "${PERSONA_PROJECT}/qdb")
  message(FATAL_ERROR "A prepared PR project, static QDB and mapped database are required")
endif()
add_custom_target(version
  COMMAND "${QUARTUS_ROOT}/bin/quartus_fit" --version
  WORKING_DIRECTORY "${PERSONA_PROJECT}"
  VERBATIM USES_TERMINAL)
add_custom_target(fit
  COMMAND "${QUARTUS_ROOT}/bin/quartus_fit"
    --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
  WORKING_DIRECTORY "${PERSONA_PROJECT}"
  VERBATIM USES_TERMINAL)
