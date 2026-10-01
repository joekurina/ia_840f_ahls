cmake_minimum_required(VERSION 3.16)
project(ia840f_cpa_command_help LANGUAGES NONE)
add_custom_target(cpa_command_help
  COMMAND /opt/altera/26.1.1/quartus/bin/quartus_sta
    -t "${CMAKE_CURRENT_SOURCE_DIR}/query.tcl"
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  VERBATIM USES_TERMINAL)
