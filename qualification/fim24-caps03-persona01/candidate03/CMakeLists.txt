cmake_minimum_required(VERSION 3.16)
project(ia840f_matching_persona_setup LANGUAGES NONE)
set(QUARTUS_ROOT "/opt/altera/26.1.1/quartus" CACHE PATH "Pinned installation")
if(NOT QUARTUS_ROOT STREQUAL "/opt/altera/26.1.1/quartus")
  message(FATAL_ERROR "This setup requires bound Quartus26.1.1")
endif()
set(RELEASE_ROOT "/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01" CACHE PATH "Accepted Work24 release")
set(AFU_SOURCES "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/prepare01/afu_sources" CACHE PATH "Bound AFU inputs")
set(PERSONA_TARGET "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/setup01/persona" CACHE PATH "Exclusive new persona")
if(NOT RELEASE_ROOT STREQUAL "/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01" OR NOT AFU_SOURCES STREQUAL "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/prepare01/afu_sources" OR NOT PERSONA_TARGET STREQUAL "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/setup01/persona")
  message(FATAL_ERROR "Unexpected setup source/release/target root")
endif()
if(EXISTS "${PERSONA_TARGET}" OR IS_SYMLINK "${PERSONA_TARGET}")
  message(FATAL_ERROR "Persona target must be absent; no force/replay")
endif()
if(NOT EXISTS "${AFU_SOURCES}/sources.txt" OR NOT EXISTS "${RELEASE_ROOT}/hw/lib/fme-ifc-id.txt")
  message(FATAL_ERROR "Missing bound inputs")
endif()
add_custom_target(version
  COMMAND "${QUARTUS_ROOT}/bin/quartus_sh" --version
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  VERBATIM USES_TERMINAL)
add_custom_target(persona_setup
  COMMAND /usr/bin/afu_synth_setup --lib "${RELEASE_ROOT}/hw/lib" --sources "${AFU_SOURCES}/sources.txt" "${PERSONA_TARGET}"
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  VERBATIM USES_TERMINAL)
