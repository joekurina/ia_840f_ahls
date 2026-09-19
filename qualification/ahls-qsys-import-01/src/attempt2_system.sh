#!/bin/bash
# attempt2 (v2): create+validate+save minimal test system instantiating the AHLS component
# Import mechanism: IP search path (GUI 'Refresh System' equivalent) + add_instance
set -x
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus
export LM_LICENSE_FILE="$HOME/quartus_26/LR-191011_License.dat"
export PATH="/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/sopc_builder/bin:/opt/altera/26.1.1/qsys/bin:$PATH"
export SCRATCH=/home/uwb_student00/ahls/new_BSP/work_ahls_qsys_import_01
cd "$SCRATCH"
qsys-script --quartus-project="$SCRATCH/qual_test.qpf" --rev=qual_test --package-version=26.1 \
  --search-path="$SCRATCH/qual_vec_op.report.prj,\$" \
  --script="$SCRATCH/make_system.tcl"
echo SYSTEM_RC=$?
echo QSYSIMP_DONE_SYSTEM
