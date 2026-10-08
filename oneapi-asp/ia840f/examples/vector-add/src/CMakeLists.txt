# The original2025 CPU/GPU/emulator/simulator recipes are retained in the
# reference file. These targets use the matched AHLS board/runtime path.
if(ASP_VARIANT STREQUAL "ofs_ia840f_usm")
  set(SOURCE_FILE vector-add-usm.cpp)
  set(TARGET_NAME vector-add-usm)
else()
  set(SOURCE_FILE vector-add-buffers.cpp)
  set(TARGET_NAME vector-add-buffers)
endif()

# Adapt only the rebranded FPGA header/selector names in a build-local copy.
# Preserve the sample source, addition lambda, size and complete CPU oracle.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_FILE}" AHLS_SOURCE)
string(REPLACE "sycl/ext/intel/fpga_extensions.hpp" "sycl/ext/altera/fpga_extensions.hpp" AHLS_SOURCE "${AHLS_SOURCE}")
string(REPLACE "sycl::ext::intel::" "sycl::ext::altera::" AHLS_SOURCE "${AHLS_SOURCE}")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/adapted")
set(SOURCE_PATH "${CMAKE_CURRENT_BINARY_DIR}/adapted/${SOURCE_FILE}")
if(EXISTS "${SOURCE_PATH}")
  file(READ "${SOURCE_PATH}" EXISTING_AHLS_SOURCE)
else()
  set(EXISTING_AHLS_SOURCE "")
endif()
if(NOT "${EXISTING_AHLS_SOURCE}" STREQUAL "${AHLS_SOURCE}")
  file(WRITE "${SOURCE_PATH}" "${AHLS_SOURCE}")
endif()
set(FPGA_TARGET "${CMAKE_BINARY_DIR}/${TARGET_NAME}__${ASP_VARIANT}__${ASP_FLOW}.fpga")
set(REPORT_IMAGE "${CMAKE_BINARY_DIR}/${TARGET_NAME}__${ASP_VARIANT}__${ASP_FLOW}.fpga.a")
# Match the vendor oneAPI pattern: compile the SYCL object, then target the
# BSP at hardware link time. The BSP callbacks own Quartus and clock policy.
set(OBJECT_IMAGE "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}.ahls.o")
set(COMPILE_FLAGS -DFPGA_HARDWARE -c)
set(HARDWARE_LINK_FLAGS -Xshardware "-Xstarget=${ASP_ROOT}:${ASP_VARIANT}" "-Xsbsp-flow=${ASP_FLOW}")
if(AHLS_REUSE_EXECUTABLE)
  if(NOT EXISTS "${AHLS_REUSE_EXECUTABLE}")
    message(FATAL_ERROR "AHLS_REUSE_EXECUTABLE must name an existing SYCL .fpga executable")
  endif()
  list(APPEND HARDWARE_LINK_FLAGS "-reuse-exe=${AHLS_REUSE_EXECUTABLE}")
endif()
add_custom_command(OUTPUT "${OBJECT_IMAGE}"
  COMMAND "${BASH_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ahls-env.sh"
    "${AHLS_COMPILER}" ${COMPILE_FLAGS} "${SOURCE_PATH}" -o "${OBJECT_IMAGE}"
  DEPENDS "${SOURCE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_FILE}"
    "${CMAKE_BINARY_DIR}/ahls-env.sh"
  VERBATIM USES_TERMINAL)
add_custom_target(compile_fpga DEPENDS "${OBJECT_IMAGE}")
set(FAT_BINARY_COMMAND "${AHLS_COMPILER}" ${HARDWARE_LINK_FLAGS} "${OBJECT_IMAGE}" -o "${FPGA_TARGET}")
set(IMAGE_DEPENDENCY)
set(OBJECT_DEPENDENCY "${OBJECT_IMAGE}")
if(AHLS_PREBUILT_ARCHIVE)
  if(NOT EXISTS "${AHLS_PREBUILT_ARCHIVE}")
    message(FATAL_ERROR "AHLS_PREBUILT_ARCHIVE does not exist")
  endif()
  if(AHLS_REUSE_EXECUTABLE OR AHLS_REUSE_RTL_ARCHIVE OR AHLS_REUSE_AOCX)
    message(FATAL_ERROR "Select one image reuse mode; prebuilt import is exclusive")
  endif()
  set(FAT_BINARY_COMMAND "${AHLS_COMPILER}" ${HARDWARE_LINK_FLAGS}
    "${AHLS_PREBUILT_ARCHIVE}" -o "${FPGA_TARGET}")
  set(IMAGE_DEPENDENCY "${AHLS_PREBUILT_ARCHIVE}")
  set(OBJECT_DEPENDENCY)
elseif(AHLS_REUSE_RTL_ARCHIVE)
  if(NOT EXISTS "${AHLS_REUSE_RTL_ARCHIVE}")
    message(FATAL_ERROR "AHLS_REUSE_RTL_ARCHIVE does not exist")
  endif()
  set(FAT_BINARY_COMMAND "${AHLS_COMPILER}" ${HARDWARE_LINK_FLAGS}
    "${AHLS_REUSE_RTL_ARCHIVE}" -o "${FPGA_TARGET}")
  set(IMAGE_DEPENDENCY "${AHLS_REUSE_RTL_ARCHIVE}" "${ASP_BUILD_CONFIG}")
  set(OBJECT_DEPENDENCY)
elseif(AHLS_REUSE_AOCX)
  message(FATAL_ERROR "Raw AOCX host-link recovery is retired; use AHLS_PREBUILT_ARCHIVE and the native driver")
  # Historical diagnostic implementation retained, not the application route.
  if(NOT EXISTS "${AHLS_REUSE_AOCX}")
    message(FATAL_ERROR "AHLS_REUSE_AOCX does not exist")
  endif()
  find_package(Python3 REQUIRED COMPONENTS Interpreter)
  set(FAT_BINARY_COMMAND "${Python3_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/cmake/host-link.py"
    --compiler "${AHLS_COMPILER}" --image "${AHLS_REUSE_AOCX}"
    --source "${SOURCE_PATH}" --output "${FPGA_TARGET}"
    --target "${ASP_ROOT}:${ASP_VARIANT}" --flow "${ASP_FLOW}")
  set(IMAGE_DEPENDENCY "${AHLS_REUSE_AOCX}")
endif()
add_custom_command(OUTPUT "${FPGA_TARGET}"
  COMMAND "${BASH_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ahls-env.sh" ${FAT_BINARY_COMMAND}
  DEPENDS ${OBJECT_DEPENDENCY} "${SOURCE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_FILE}" ${IMAGE_DEPENDENCY}
    "${CMAKE_BINARY_DIR}/ahls-env.sh" "${CMAKE_SOURCE_DIR}/cmake/host-link.py"
  VERBATIM USES_TERMINAL)
add_custom_target(fpga DEPENDS "${FPGA_TARGET}")
add_custom_target(${TARGET_NAME}.fpga DEPENDS "${FPGA_TARGET}")
add_custom_command(OUTPUT "${REPORT_IMAGE}"
  COMMAND "${BASH_EXECUTABLE}" "${CMAKE_BINARY_DIR}/ahls-env.sh"
    "${AHLS_COMPILER}" -DFPGA_HARDWARE ${HARDWARE_LINK_FLAGS} -fsycl-link=early "${SOURCE_PATH}" -o "${REPORT_IMAGE}"
  DEPENDS "${SOURCE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_FILE}"
  VERBATIM USES_TERMINAL)
add_custom_target(report DEPENDS "${REPORT_IMAGE}")
if(VECTOR_ADD_RUN_WITH_SUDO)
  set(RUN_PREFIX sudo -n)
else()
  set(RUN_PREFIX)
endif()
configure_file("${CMAKE_SOURCE_DIR}/cmake/runtime-run.cmake.in"
  "${CMAKE_BINARY_DIR}/runtime-run.cmake" @ONLY)
add_custom_target(run_fpga
  COMMAND ${RUN_PREFIX} "${CMAKE_COMMAND}" -P "${CMAKE_BINARY_DIR}/runtime-run.cmake"
  DEPENDS fpga VERBATIM USES_TERMINAL)
message(STATUS "AHLS compiler: ${AHLS_COMPILER}")
message(STATUS "BSP/flow: ${ASP_VARIANT} / ${ASP_FLOW}")
message(STATUS "SYCL fat binary: ${FPGA_TARGET}")
