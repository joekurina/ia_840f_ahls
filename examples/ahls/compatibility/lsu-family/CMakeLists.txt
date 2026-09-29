cmake_minimum_required(VERSION 3.20)
project(ia840f_ahls_lsu_family_overlay LANGUAGES NONE)

set(FPGA_DEVICE "AGFB027R25A2E2V" CACHE STRING "Exact supported IA-840F part")
set(AHLS_LSU_TOP "" CACHE FILEPATH "Unmodified HLS IP Gen 2026.1.0 ip/lsu_top.sv")
if(NOT FPGA_DEVICE STREQUAL "AGFB027R25A2E2V")
  message(FATAL_ERROR "This overlay is bound to the IA-840F Agilex 7 part")
endif()
if(NOT EXISTS "${AHLS_LSU_TOP}")
  message(FATAL_ERROR "Provide the original HLS IP Gen lsu_top.sv")
endif()
file(SHA256 "${AHLS_LSU_TOP}" original_sha256)
if(NOT original_sha256 STREQUAL "873549f18428fe6ba0797fef228c2028bf1df62076e85f1942c9dca5310cf8a0")
  message(FATAL_ERROR "Unreviewed HLS support source: do not apply this release-specific overlay")
endif()
file(READ "${AHLS_LSU_TOP}" patched)
foreach(indent IN ITEMS "            " "                ")
  set(old "lsu_bursting_read #(
${indent}.KERNEL_SIDE_MEM_LATENCY")
  set(new "lsu_bursting_read #(
${indent}.DEVICE(\"Agilex 7\"),
${indent}.KERNEL_SIDE_MEM_LATENCY")
  string(FIND "${patched}" "${old}" found)
  if(found EQUAL -1)
    message(FATAL_ERROR "Expected legacy bursting-read instantiation was not found")
  endif()
  string(REPLACE "${old}" "${new}" patched "${patched}")
endforeach()
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/lsu_top.sv" "${patched}")
file(SHA256 "${CMAKE_CURRENT_BINARY_DIR}/lsu_top.sv" patched_sha256)
message(STATUS "Original HLS source: ${original_sha256}")
message(STATUS "Agilex 7 source overlay: ${patched_sha256}")
# File preparation only. Use the output as a read-only bind in a private compiler
# namespace; never overwrite the installed SDK or the imported tutorial sources.
