cmake_minimum_required(VERSION 3.20)
project(ia840f_opae_config_test LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
if(NOT SDK_CAPTURE OR NOT JSON_PREFIX)
    message(FATAL_ERROR "Provide hash-verified SDK_CAPTURE and JSON_PREFIX")
endif()
add_executable(opae_config_probe opae_config_probe.c
    "${SDK_CAPTURE}/libraries/libopae-c/cfg-file.c"
    "${SDK_CAPTURE}/libraries/libopae-c/opae-cfg.c"
    "${SDK_CAPTURE}/tests/framework/mock/opae_std.c")
target_include_directories(opae_config_probe PRIVATE
    "${SDK_CAPTURE}/include" "${SDK_CAPTURE}/libraries/libopae-c"
    "${SDK_CAPTURE}/tests/framework" "${JSON_PREFIX}/usr/include")
target_compile_definitions(opae_config_probe PRIVATE _GNU_SOURCE STATIC=static)
target_compile_options(opae_config_probe PRIVATE -O2 -Wall -Wextra -Werror
    -ffunction-sections -fdata-sections -fsanitize=undefined -fno-sanitize-recover=all)
target_link_options(opae_config_probe PRIVATE -Wl,--gc-sections
    -Wl,-Map=${CMAKE_BINARY_DIR}/parser.map -fsanitize=undefined)
target_link_libraries(opae_config_probe PRIVATE
    "${JSON_PREFIX}/usr/lib/x86_64-linux-gnu/libjson-c.so")
