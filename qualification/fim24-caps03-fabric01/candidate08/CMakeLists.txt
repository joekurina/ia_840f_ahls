cmake_minimum_required(VERSION 3.16)
project(ia840f_work24_caps03_fabric LANGUAGES NONE)
set(QUARTUS_ROOT "/opt/altera/26.1.1/quartus" CACHE PATH "Pinned toolchain")
if(NOT QUARTUS_ROOT STREQUAL "/opt/altera/26.1.1/quartus")
  message(FATAL_ERROR "Requires bound Quartus26.1.1")
endif()
set(FABRIC_ROOT "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01" CACHE PATH "Bound prepared fabric")
if(NOT FABRIC_ROOT STREQUAL "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01")
  message(FATAL_ERROR "Unexpected fabric root")
endif()
foreach(input make-system.tcl ahls_memory_dma_fabric.qpf ahls_memory_dma_fabric.qsf ia840f_ahls_memory_fabric_dma_fullwidth_hw.tcl)
  if(NOT EXISTS "${FABRIC_ROOT}/${input}")
    message(FATAL_ERROR "Missing prepared input ${input}")
  endif()
endforeach()
add_custom_target(version
  COMMAND "${QUARTUS_ROOT}/bin/quartus_sh" --version
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  VERBATIM USES_TERMINAL)
add_custom_target(fabric_import
  COMMAND "/opt/altera/26.1.1/quartus/sopc_builder/bin/qsys-script"
    "--quartus-project=/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01/ahls_memory_dma_fabric.qpf"
    "--rev=ahls_memory_dma_fabric"
    "--package-version=26.1"
    "--search-path=/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01/mmhost_ia840f.report.prj,/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01,$"
    "--script=/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01/make-system.tcl"
  WORKING_DIRECTORY "${FABRIC_ROOT}"
  VERBATIM USES_TERMINAL)
add_custom_target(fabric_generate
  COMMAND "/opt/altera/26.1.1/quartus/sopc_builder/bin/qsys-generate"
    "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01/ahls_memory_dma_fabric.qsys"
    "--synthesis=VERILOG"
    "--quartus-project=/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01/ahls_memory_dma_fabric.qpf"
    "--rev=ahls_memory_dma_fabric"
    "--part=AGFB027R25A2E2V"
    "--search-path=/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01/mmhost_ia840f.report.prj,/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01/generate01,$"
  WORKING_DIRECTORY "${FABRIC_ROOT}"
  VERBATIM USES_TERMINAL)
