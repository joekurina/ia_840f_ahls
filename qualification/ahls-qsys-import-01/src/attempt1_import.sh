#!/bin/bash
# attempt1 (v2): import qual_vec_op_report_di component via load_component + save_component
set -x
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus
export LM_LICENSE_FILE="$HOME/quartus_26/LR-191011_License.dat"
export PATH="/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/sopc_builder/bin:/opt/altera/26.1.1/qsys/bin:$PATH"
export SCRATCH=/home/uwb_student00/ahls/new_BSP/work_ahls_qsys_import_01
cd "$SCRATCH"
qsys-script --quartus-project="$SCRATCH/qual_test.qpf" --rev=qual_test --package-version=26.1 \
  --search-path="$SCRATCH/qual_vec_op.report.prj" \
  --cmd='puts "IMPORT:loading"; if {[catch {load_component qual_vec_op.report.prj} m]} { puts "IMPORT-ERR:load_component-dir: $m"; if {[catch {load_component qual_vec_op_report_di} m2]} { puts "IMPORT-ERR:load_component-name: $m2"; error "IMPORT-FATAL both load_component forms failed" } }; puts "IMPORT:loaded"; if {[catch {save_component} sc]} { puts "IMPORT-ERR:save_component: $sc"; error "IMPORT-FATAL save_component failed" }; puts "IMPORT:DONE"'
echo IMPORT_RC=$?
echo QSYSIMP_DONE_IMPORT
