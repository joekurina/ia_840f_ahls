cmake_minimum_required(VERSION 3.20)
project(IA840F_ASP26 LANGUAGES NONE)
find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(IA840F_PACKAGE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}" CACHE PATH "Prepared IA840F board package")
set(IA840F_AHLS_ROOT "" CACHE PATH "AHLS 2026.1 aclsycl installation")
set(IA840F_QUARTUS_ROOT "" CACHE PATH "Quartus Pro 26.1.1 quartus directory")
set(IA840F_SOURCE "" CACHE FILEPATH "SYCL kernel source")
set(IA840F_VARIANT "ofs_ia840f" CACHE STRING "Board variant")
set(IA840F_FLOW "afu_flat" CACHE STRING "Compile flow")
set(IA840F_PLATFORM_ROOT "" CACHE PATH "Accepted OFS 2026.1 PR export")
set(IA840F_OPAE_ROOT "" CACHE PATH "Current OPAE installation")
set(IA840F_BBB_ROOT "" CACHE PATH "Current MPF/BBB source")
set(IA840F_SEED "2" CACHE STRING "PR fitter seed")
set(IA840F_AOCR "" CACHE FILEPATH "Retained same-kernel AHLS RTL container")
set(IA840F_RTL_PROJECT "" CACHE PATH "External same-kernel generated AHLS project")
if(NOT IA840F_VARIANT MATCHES "^(ofs_ia840f|ofs_ia840f_usm)$")
  message(FATAL_ERROR "Unsupported IA840F_VARIANT")
endif()
if(NOT IA840F_FLOW MATCHES "^(afu_flat|afu_flat_kclk)$")
  message(FATAL_ERROR "Unsupported IA840F_FLOW")
endif()
set(IA840F_DRIVER "${CMAKE_CURRENT_SOURCE_DIR}/cmake/build26.py")
set(IA840F_ARGS --package "${IA840F_PACKAGE_ROOT}" --sdk "${IA840F_AHLS_ROOT}"
  --quartus "${IA840F_QUARTUS_ROOT}" --source "${IA840F_SOURCE}"
  --variant "${IA840F_VARIANT}" --flow "${IA840F_FLOW}"
  --platform "${IA840F_PLATFORM_ROOT}" --opae "${IA840F_OPAE_ROOT}"
  --bbb "${IA840F_BBB_ROOT}" --seed "${IA840F_SEED}")
add_custom_target(report COMMAND "${Python3_EXECUTABLE}" "${IA840F_DRIVER}"
  report ${IA840F_ARGS} --work "${CMAKE_CURRENT_BINARY_DIR}/work-report" VERBATIM USES_TERMINAL)
add_custom_target(hardware COMMAND "${Python3_EXECUTABLE}" "${IA840F_DRIVER}"
  hardware ${IA840F_ARGS} --work "${CMAKE_CURRENT_BINARY_DIR}/work-hardware" VERBATIM USES_TERMINAL)
add_custom_target(hardware-from-rtl COMMAND "${Python3_EXECUTABLE}" "${IA840F_DRIVER}"
  rtl ${IA840F_ARGS} --aocr "${IA840F_AOCR}" --rtl-project "${IA840F_RTL_PROJECT}"
  --work "${CMAKE_CURRENT_BINARY_DIR}/work-rtl" VERBATIM USES_TERMINAL)
add_custom_target(software COMMAND "${Python3_EXECUTABLE}" "${IA840F_DRIVER}"
  software --package "${IA840F_PACKAGE_ROOT}" --sdk "${IA840F_AHLS_ROOT}"
  --quartus "${IA840F_QUARTUS_ROOT}" --platform "${IA840F_PLATFORM_ROOT}"
  --opae "${IA840F_OPAE_ROOT}" --bbb "${IA840F_BBB_ROOT}"
  --work "${CMAKE_CURRENT_BINARY_DIR}/work-software" VERBATIM USES_TERMINAL)
add_custom_target(backend COMMAND "${Python3_EXECUTABLE}" "${IA840F_DRIVER}"
  backend --kernel-dir "${IA840F_KERNEL_DIR}" --config "${IA840F_BUILD_CONFIG}"
  VERBATIM USES_TERMINAL)
