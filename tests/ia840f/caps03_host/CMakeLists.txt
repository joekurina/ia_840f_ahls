cmake_minimum_required(VERSION 3.20)
project(ia840f_caps03_host_inert C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
get_filename_component(N "${CMAKE_CURRENT_SOURCE_DIR}/../../.." ABSOLUTE)
set(FRONTEND_SOURCE "${N}/src/host/ahls_memory_caps03.c" CACHE FILEPATH "Actual frontend under test")
set(HEADERS "${N}/qualification/caps03-host01/sdk-headers/include")
if(NOT EXISTS "${HEADERS}/opae/mmio.h")
  message(FATAL_ERROR "Captured installed OPAE headers required")
endif()
set(MOCK_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/mock_caps03_opae.c" CACHE FILEPATH "Inert API model under test")
add_executable(caps03_frontend "${FRONTEND_SOURCE}" "${MOCK_SOURCE}"
  "${N}/src/host/ahls_qualification_core.c" "${N}/src/host/ia840f_dma_transfer_core.c")
target_include_directories(caps03_frontend PRIVATE "${N}/src/host" "${HEADERS}")
target_compile_options(caps03_frontend PRIVATE -O2 -Wall -Wextra -Werror -UNDEBUG
  -fsanitize=undefined -fno-sanitize-recover=all)
target_link_options(caps03_frontend PRIVATE -fsanitize=undefined -Wl,-z,defs)
# No OPAE library/backend is linked. Native OPAE linking is a separate admitted stage.
