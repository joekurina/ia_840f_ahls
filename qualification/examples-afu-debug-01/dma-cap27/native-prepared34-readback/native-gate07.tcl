if {[catch {exec /usr/bin/env -u LD_LIBRARY_PATH -u PYTHONOPTIMIZE /usr/bin/python3 -I -B /home/uwb_student00/ahls/new_BSP/work_examples_afu_debug01/dma-cap27/native-gate07.py quartus 2>@1} examples_afu_result]} {
 puts stderr "EXAMPLES_AFU_GATE_REJECTED: $examples_afu_result"
 exit 1
}
puts $examples_afu_result
