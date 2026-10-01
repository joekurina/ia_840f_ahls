cmake_minimum_required(VERSION 3.16)
project(ia840f_cpa_feedback LANGUAGES NONE)
add_custom_target(cpa_feedback
  COMMAND /opt/altera/25.1/quartus/bin/quartus_sta
    -t "${CMAKE_CURRENT_SOURCE_DIR}/query.tcl"
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/scratch/syn/board/ia840f/syn_top"
  VERBATIM USES_TERMINAL)
