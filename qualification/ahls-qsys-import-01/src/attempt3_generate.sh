#!/bin/bash
# attempt3: generate the test system (RTL, verilog synthesis output)
set -x
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus
export LM_LICENSE_FILE="$HOME/quartus_26/LR-191011_License.dat"
export PATH="/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/sopc_builder/bin:/opt/altera/26.1.1/qsys/bin:$PATH"
export SCRATCH=/home/uwb_student00/ahls/new_BSP/work_ahls_qsys_import_01
cd "$SCRATCH"
qsys-generate qual_test.qsys --synthesis=VERILOG --quartus-project="$SCRATCH/qual_test.qpf" --rev=qual_test --search-path="$SCRATCH/qual_vec_op.report.prj"
echo GENERATE_RC=$?
echo QSYSIMP_DONE_GENERATE
