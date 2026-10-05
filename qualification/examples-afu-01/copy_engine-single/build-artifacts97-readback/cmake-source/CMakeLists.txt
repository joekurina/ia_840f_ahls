cmake_minimum_required(VERSION 3.20)
project(examples_afu NONE)
add_custom_target(setup COMMAND /usr/bin/afu_synth_setup --lib "/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01/hw/lib" --sources "/home/uwb_student00/ahls/new_BSP/work_examples_afu01/sources/copy_engine/hw/rtl/sources.txt" "/home/uwb_student00/ahls/new_BSP/work_examples_afu01/copy_engine-single/persona" VERBATIM)
add_custom_target(compile COMMAND /opt/altera/26.1.1/quartus/bin/quartus_sh --flow compile ofs_top -c ofs_pr_afu WORKING_DIRECTORY "/home/uwb_student00/ahls/new_BSP/work_examples_afu01/copy_engine-single/persona/build/syn/board/ia840f/syn_top" VERBATIM)
