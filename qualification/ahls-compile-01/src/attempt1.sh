#!/bin/bash
# AHLS qualification compile — attempt 1 (report/RTL generation, standalone IP)
# Target part: AGFB027R25A2E2V (BittWare IA-840F). No board/BSP flow.
# Logs: B/qualification/ahls-compile-01/logs/attempt1.log (tee from caller)
set -x
source /home/uwb_student00/ahls/altera_hls/aclsycl/fpgavars.sh
cd /home/uwb_student00/ahls/new_BSP/work_ahls_compile_01 || exit 90

echo "=== ENV ==="
date -u
which ahls
ahls --version 2>&1 | head -2

echo "=== STAGE 1: compile (SPIR-V) ==="
ahls -DFPGA_HARDWARE -Wall -c qual_vec_op.cpp -o qual_vec_op.o
rc1=$?
echo "RC_COMPILE=$rc1"
if [ $rc1 -ne 0 ]; then echo "ATTEMPT1_RESULT=compile_failed rc=$rc1"; exit $rc1; fi

echo "=== STAGE 2: early link -> RTL/IP report generation ==="
ahls -Xshardware -Xstarget=AGFB027R25A2E2V -fsycl-link=early qual_vec_op.o -o qual_vec_op.report
rc2=$?
echo "RC_LINK=$rc2"
echo "ATTEMPT1_RESULT=done rc_link=$rc2"
date -u
exit $rc2
