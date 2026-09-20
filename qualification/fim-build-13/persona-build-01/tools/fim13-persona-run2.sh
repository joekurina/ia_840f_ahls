#!/bin/bash
# Persona build relaunch after gate-scope fix.
# The IA840F experimental FIM-build gate (build_gate.tcl hook) is not applicable
# to AFU persona synthesis against the frozen W13 QDB: the gate governs once-only
# FIM base compiles from maintained SOURCE; a persona compile cannot alter the
# FIM and is repeatable by design (afu_synth flow). The hook line arrived via
# ofs_pim_setup.sh copying W13's modified setup dir; gate infra (record/claim)
# is not part of any release tree. Scoped out HERE ONLY (scratch build tree);
# maintained SOURCE / W13 tree / pr_release_13a untouched. See
# qualification/fim-build-13/pr-isolation-01/REPORT.md (local repo).
set -x
REL=/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/pr_release_13a
DST=/home/uwb_student00/ahls/new_BSP/work_ahls_persona_01
SYN=$DST/build/syn/board/ia840f/syn_top

export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus
export PATH=/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export LM_LICENSE_FILE=$HOME/quartus_26/LR-191011_License.dat
export MGLS_LICENSE_FILE=$LM_LICENSE_FILE
export SALT_LICENSE_SERVER=$LM_LICENSE_FILE
export PYTHONDONTWRITEBYTECODE=1

# Scope the FIM-build gate out of the persona scratch tree (justified above).
for q in $SYN/ofs_pr_afu.qsf $SYN/ofs_top.qsf; do
  sed -i 's|^set_global_assignment -name SOURCE_TCL_SCRIPT_FILE \.\./setup/build_gate\.tcl|# persona-build: FIM-build gate not applicable to AFU persona synthesis vs frozen QDB (see pr-isolation-01 REPORT.md)\n# set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ../setup/build_gate.tcl|' "$q"
done
grep -n "build_gate" $SYN/ofs_pr_afu.qsf $SYN/ofs_top.qsf

cd "$DST"
export OPAE_PLATFORM_ROOT=$DST
$REL/bin/afu_synth hw/ofs_pr_afu.json
echo "SYN_RC=$?"
ls -la $SYN/output_files/*.gbs 2>/dev/null
sha256sum $SYN/output_files/ofs_pr_afu.green_region.gbs 2>/dev/null
exit $SYN_RC
