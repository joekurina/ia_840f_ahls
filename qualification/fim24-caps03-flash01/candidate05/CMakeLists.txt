cmake_minimum_required(VERSION 3.20)
project(migrated_caps03_sdk_flash_package LANGUAGES NONE)
# File-only conversion. Neither this project nor its JIC is a JTAG operation.
# Parent must bind accepted SOF/tool hashes and create the exclusive convert05 leaf.
add_custom_target(flash_image
  COMMAND "/opt/altera/26.1.1/quartus/bin/quartus_pfg" -c "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01/base01/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sof"
    "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/convert05/migrated-caps03-sdk.jic"
    "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/convert05/migrated-caps03-sdk.map"
    "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/convert05/migrated-caps03-sdk.rpd"
    -o device=MT25QU02G -o mode=ASX4 -o flash_loader=AGFB027R25A -o bitswap=OFF
  VERBATIM)
add_custom_target(source_info
  COMMAND "/opt/altera/26.1.1/quartus/bin/quartus_pfg" -i "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01/base01/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sof" VERBATIM)
add_custom_target(image_info
  COMMAND "/opt/altera/26.1.1/quartus/bin/quartus_pfg" -i "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/convert05/migrated-caps03-sdk.jic" VERBATIM)
