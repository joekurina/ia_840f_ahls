cmake_minimum_required(VERSION 3.16)
project(ia840f_ahls_persona LANGUAGES NONE)

set(PERSONA_PROJECT "" CACHE PATH "Prepared Work21-compatible PR project directory")
set(QUARTUS_ROOT "/opt/altera/25.1/quartus" CACHE PATH "Validated Quartus 25.1 installation")
if(NOT QUARTUS_ROOT STREQUAL "/opt/altera/25.1/quartus")
  message(FATAL_ERROR "This qualification uses Quartus Prime Pro 25.1")
endif()
if(NOT EXISTS "${PERSONA_PROJECT}/ofs_pr_afu.qsf" OR NOT EXISTS "${PERSONA_PROJECT}/ofs_top.qdb")
  message(FATAL_ERROR "A prepared PR project and accepted static root QDB are required")
endif()

# Native stages only. No default build, IP regeneration, full FIM build or hardware.
# Stage admission and immutable input checks remain in the prepared QSF callback.
add_custom_target(synthesis
  COMMAND "${QUARTUS_ROOT}/bin/quartus_syn"
    --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
  WORKING_DIRECTORY "${PERSONA_PROJECT}"
  VERBATIM USES_TERMINAL)
add_custom_target(fit
  COMMAND "${QUARTUS_ROOT}/bin/quartus_fit"
    --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
  WORKING_DIRECTORY "${PERSONA_PROJECT}"
  VERBATIM USES_TERMINAL)
