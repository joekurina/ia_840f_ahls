cmake_minimum_required(VERSION 3.16)
project(ia840f_work24_pr_export LANGUAGES NONE)
set(QUARTUS_ROOT "/opt/altera/26.1.1/quartus" CACHE PATH "Pinned Quartus installation")
if(NOT QUARTUS_ROOT STREQUAL "/opt/altera/26.1.1/quartus")
  message(FATAL_ERROR "This export requires the bound Quartus26.1.1 installation")
endif()
foreach(required FIM_BASE RELEASE_TARGET)
  if(NOT DEFINED ${required} OR NOT IS_ABSOLUTE "${${required}}")
    message(FATAL_ERROR "${required} must be an explicit absolute path")
  endif()
endforeach()
if(NOT EXISTS "${FIM_BASE}/ofs-common/scripts/common/syn/generate_pr_release.sh")
  message(FATAL_ERROR "Prepared vendor release script is missing")
endif()
if(EXISTS "${RELEASE_TARGET}" OR IS_SYMLINK "${RELEASE_TARGET}")
  message(FATAL_ERROR "Release target must be absent; no force/replay")
endif()
add_custom_target(version
  COMMAND "${QUARTUS_ROOT}/bin/quartus_sh" --version
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  VERBATIM USES_TERMINAL)
add_custom_target(export
  COMMAND /bin/bash "${FIM_BASE}/ofs-common/scripts/common/syn/generate_pr_release.sh"
    -t "${RELEASE_TARGET}" ia840f "${FIM_BASE}"
  WORKING_DIRECTORY "${FIM_BASE}"
  VERBATIM USES_TERMINAL)
