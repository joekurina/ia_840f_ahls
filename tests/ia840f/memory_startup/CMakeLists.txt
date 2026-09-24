cmake_minimum_required(VERSION 3.20)
project(ia840f_memory_startup C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
get_filename_component(N "${CMAKE_CURRENT_SOURCE_DIR}/../../.." ABSOLUTE)
if(NOT OPAE_CAPTURED_INCLUDE_DIR OR NOT SDK_CAPTURE OR NOT JSON_PREFIX)
  message(FATAL_ERROR "Hash-bound header/parser/dependency inputs are required")
endif()
add_executable(direct_inert "${N}/src/host/ahls_memory_inspect.c"
  "${N}/src/host/ahls_qualification_core.c"
  "${N}/tests/ia840f/memory_host/mock_memory_opae.c" inert_startup.c)
target_include_directories(direct_inert PRIVATE "${N}/src/host" "${OPAE_CAPTURED_INCLUDE_DIR}")
target_compile_options(direct_inert PRIVATE -O2 -Wall -Wextra -Werror -pedantic -UNDEBUG -fsanitize=undefined -fno-sanitize-recover=all)
target_link_options(direct_inert PRIVATE -fsanitize=undefined)

add_library(frontend_object OBJECT "${N}/src/host/ahls_memory_inspect.c")
set_target_properties(frontend_object PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(frontend_object PRIVATE main=ahls_memory_frontend_main)
target_include_directories(frontend_object PRIVATE "${N}/src/host" "${OPAE_CAPTURED_INCLUDE_DIR}")
add_library(memory_entry_inert SHARED $<TARGET_OBJECTS:frontend_object>
  "${N}/src/host/ahls_memory_entry.c" "${N}/src/host/ahls_qualification_core.c"
  "${N}/tests/ia840f/memory_host/mock_memory_opae.c" inert_startup.c)
target_include_directories(memory_entry_inert PRIVATE "${N}/src/host" "${OPAE_CAPTURED_INCLUDE_DIR}")
add_executable(memory_startup "${N}/src/host/ahls_memory_startup.c"
  "${N}/src/host/ahls_qualification_core.c"
  "${SDK_CAPTURE}/libraries/libopae-c/cfg-file.c"
  "${SDK_CAPTURE}/libraries/libopae-c/opae-cfg.c"
  "${SDK_CAPTURE}/tests/framework/mock/opae_std.c")
target_include_directories(memory_startup PRIVATE "${N}/src/host"
  "${SDK_CAPTURE}/include" "${SDK_CAPTURE}/libraries/libopae-c"
  "${SDK_CAPTURE}/tests/framework" "${JSON_PREFIX}/usr/include")
target_compile_definitions(memory_startup PRIVATE STATIC=static)
set_source_files_properties(
  "${SDK_CAPTURE}/libraries/libopae-c/cfg-file.c"
  "${SDK_CAPTURE}/libraries/libopae-c/opae-cfg.c"
  "${SDK_CAPTURE}/tests/framework/mock/opae_std.c"
  PROPERTIES COMPILE_DEFINITIONS _GNU_SOURCE)
target_compile_options(memory_startup PRIVATE -ffunction-sections -fdata-sections)
target_link_options(memory_startup PRIVATE -Wl,--gc-sections -Wl,-Map=${CMAKE_BINARY_DIR}/startup.map)
target_link_libraries(memory_startup PRIVATE "${JSON_PREFIX}/usr/lib/x86_64-linux-gnu/libjson-c.so" ${CMAKE_DL_LIBS})
foreach(target frontend_object memory_entry_inert memory_startup)
  target_compile_options(${target} PRIVATE -O2 -Wall -Wextra -Werror -UNDEBUG -fsanitize=undefined -fno-sanitize-recover=all)
  target_link_options(${target} PRIVATE -fsanitize=undefined)
endforeach()

add_library(missing_entry_inert SHARED inert_startup.c)
target_include_directories(missing_entry_inert PRIVATE "${OPAE_CAPTURED_INCLUDE_DIR}")
target_compile_options(missing_entry_inert PRIVATE -O2 -Wall -Wextra -Werror -UNDEBUG -fsanitize=undefined -fno-sanitize-recover=all)
target_link_options(missing_entry_inert PRIVATE -fsanitize=undefined)
