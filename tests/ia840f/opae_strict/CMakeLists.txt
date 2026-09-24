cmake_minimum_required(VERSION 3.20)
project(ia840f_opae_strict_inert C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
if(NOT SDK_CAPTURE OR NOT JSON_PREFIX)
  message(FATAL_ERROR "Require hash-bound SDK and JSON-C capture")
endif()
add_executable(strict_probe strict_probe.c
  ${SDK_CAPTURE}/libraries/libopae-c/cfg-file.c
  ${SDK_CAPTURE}/libraries/libopae-c/opae-cfg.c)
target_include_directories(strict_probe PRIVATE ${SDK_CAPTURE}
  ${SDK_CAPTURE}/include ${SDK_CAPTURE}/libraries/libopae-c
  ${SDK_CAPTURE}/tests/framework ${JSON_PREFIX}/usr/include)
target_compile_definitions(strict_probe PRIVATE STATIC=static HAVE_CONFIG_H=1)
set_source_files_properties(${SDK_CAPTURE}/libraries/libopae-c/cfg-file.c
  ${SDK_CAPTURE}/libraries/libopae-c/opae-cfg.c PROPERTIES COMPILE_DEFINITIONS _GNU_SOURCE)
if(STRICT_ADDITION)
  target_compile_definitions(strict_probe PRIVATE TEST_STRICT=1)
  target_include_directories(strict_probe PRIVATE ${STRICT_ADDITION})
endif()
target_compile_options(strict_probe PRIVATE -O2 -Wall -Wextra -Werror -UNDEBUG
  -ffunction-sections -fdata-sections -fsanitize=undefined -fno-sanitize-recover=all)
target_link_options(strict_probe PRIVATE -fsanitize=undefined -Wl,--gc-sections
  -Wl,--wrap=dlopen -Wl,--wrap=dlsym -Wl,--wrap=dlclose -Wl,--wrap=dlerror
  -Wl,--wrap=readdir -Wl,-Map=${CMAKE_BINARY_DIR}/strict.map)
target_link_libraries(strict_probe PRIVATE ${JSON_PREFIX}/usr/lib/x86_64-linux-gnu/libjson-c.so pthread)
