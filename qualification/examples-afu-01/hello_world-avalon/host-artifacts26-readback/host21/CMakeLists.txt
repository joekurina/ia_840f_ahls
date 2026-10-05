cmake_minimum_required(VERSION 3.20)
project(hello_world_checked C)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/afu_json_info.h
 COMMAND /usr/bin/afu_json_mgr json-info --afu-json=/home/uwb_student00/ahls/new_BSP/work_examples_afu01/sources/hello_world/hw/rtl/hello_world.json --c-hdr=${CMAKE_CURRENT_BINARY_DIR}/afu_json_info.h
 DEPENDS /home/uwb_student00/ahls/new_BSP/work_examples_afu01/sources/hello_world/hw/rtl/hello_world.json VERBATIM)
add_executable(hello_world_checked hello_world_checked.c ${CMAKE_CURRENT_BINARY_DIR}/afu_json_info.h)
target_include_directories(hello_world_checked PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_compile_options(hello_world_checked PRIVATE -O2 -g -Wall -Wextra -Wformat -Wformat-security -fstack-protector-strong -fPIE -D_FORTIFY_SOURCE=2)
target_link_options(hello_world_checked PRIVATE -pie -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now)
target_link_libraries(hello_world_checked PRIVATE opae-c uuid rt)
