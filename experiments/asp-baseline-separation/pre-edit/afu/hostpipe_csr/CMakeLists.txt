cmake_minimum_required(VERSION 3.20)
# Source-only preparation. No compiler discovery with the option left OFF.
project(ia840f_hostpipe_csr LANGUAGES NONE)

option(IA840F_ENABLE_HOSTPIPE_CSR_FPGA_TEST
       "Expose the unqualified CSR host-pipe hardware FPGA Test target" OFF)
if(NOT IA840F_ENABLE_HOSTPIPE_CSR_FPGA_TEST)
  return()
endif()

# This opt-in is NOT permission to bypass the BSP/FIM source-preparation gates.
# Use only after separate authorization and qualification of the selected BSP.
set(IA840F_HOSTPIPE_BSP_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../oneapi-asp/ia840f"
    CACHE PATH "Exact IA840F BSP package root for a later authorized build")
set(IA840F_HOSTPIPE_BOARD_VARIANT "ofs_ia840f" CACHE STRING
    "Exact IA840F board variant (not a family-only target)")
set_property(CACHE IA840F_HOSTPIPE_BOARD_VARIANT PROPERTY STRINGS
             ofs_ia840f ofs_ia840f_usm)
if(NOT IA840F_HOSTPIPE_BOARD_VARIANT STREQUAL "ofs_ia840f" AND
   NOT IA840F_HOSTPIPE_BOARD_VARIANT STREQUAL "ofs_ia840f_usm")
  message(FATAL_ERROR "Use exactly ofs_ia840f or ofs_ia840f_usm")
endif()
get_filename_component(_hostpipe_bsp "${IA840F_HOSTPIPE_BSP_ROOT}" ABSOLUTE
                       BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
if(NOT EXISTS "${_hostpipe_bsp}/board_env.xml" OR
   NOT EXISTS "${_hostpipe_bsp}/hardware/${IA840F_HOSTPIPE_BOARD_VARIANT}/board_spec.xml")
  message(FATAL_ERROR "Selected IA840F BSP must contain board_env.xml and the exact variant's board_spec.xml")
endif()

# Caller explicitly selects the FPGA-capable icpx via CMAKE_CXX_COMPILER.
# Do not silently pick a newer oneAPI compiler without FPGA support.
if(NOT DEFINED CMAKE_CXX_COMPILER OR CMAKE_CXX_COMPILER STREQUAL "")
  message(FATAL_ERROR "Explicitly select oneAPI 2025.0 icpx with CMAKE_CXX_COMPILER")
endif()
enable_language(CXX)
if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "IntelLLVM" OR
   NOT CMAKE_CXX_COMPILER_VERSION MATCHES "^2025\\.0([.]|$)")
  message(FATAL_ERROR "This source requires the FPGA-capable Intel oneAPI 2025.0 compiler line")
endif()

add_executable(hostpipe_csr_fpga EXCLUDE_FROM_ALL hostpipe_csr.cpp)
set_target_properties(hostpipe_csr_fpga PROPERTIES
                      CXX_STANDARD 17 CXX_STANDARD_REQUIRED YES CXX_EXTENSIONS NO)
target_compile_options(hostpipe_csr_fpga PRIVATE -fsycl -fintelfpga -Wall -Wextra)
target_link_options(hostpipe_csr_fpga PRIVATE -fsycl -fintelfpga -Xshardware
                    "-Xstarget=${_hostpipe_bsp}:${IA840F_HOSTPIPE_BOARD_VARIANT}")
# No ALL, run, CTest, install, report, emulator, or simulator target is added.
# Full hardware compilation occurs only when this target is explicitly built.
message(WARNING "CSR host-pipe source is unqualified: compiler metadata, address routing, and hardware behavior remain unverified. Respect the independent BSP/FIM build gates.")
