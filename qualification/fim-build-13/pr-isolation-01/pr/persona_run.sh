#!/bin/bash
# AHLS persona (runtime-PR) build via W13's pr_release_13a tree.
# Generates rtl_src_config sources file, runs afu_synth_setup + afu_synth.
set -x
E=/tmp/fim13-gates/persona
REL=/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/pr_release_13a
DST=/home/uwb_student00/ahls/new_BSP/work_ahls_persona_01
SRC13=/tmp/fim13-gates
MNT=/home/uwb_student00/ahls/new_BSP

# --- env ---
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus
export PATH=/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export LM_LICENSE_FILE=$HOME/quartus_26/LR-191011_License.dat
export MGLS_LICENSE_FILE=$LM_LICENSE_FILE
export SALT_LICENSE_SERVER=$LM_LICENSE_FILE
export PYTHONDONTWRITEBYTECODE=1

# --- 1) sources file for rtl_src_config ---
python3 - <<'PYEOF'
import re, sys, os
E = "/tmp/fim13-gates/persona"
MNT = "/home/uwb_student00/ahls/new_BSP"
txt = open(f"{E}/ahls_files.tcl").read()
paths = re.findall(r'SYSTEMVERILOG_FILE "(.*)"', txt)
assert len(paths) >= 80, f"filelist parse failed: {len(paths)}"
lines = []
# 1. AFU metadata JSON (must be the single .json)
lines.append("/tmp/fim13-gates/ofs_pr_afu.json")
# 2. our PIM AFU top
lines.append("/tmp/fim13-gates/ofs_plat_afu.sv")
# 3. AHLS binding library (5 files)
for f in ["ahls_board_binding.sv","ahls_ofs_board_services.sv","ahls_mmio_aperture.sv",
          "ahls_mmio_to_avmm.sv","ahls_avmm_byte_to_line.sv"]:
    p = f"{MNT}/afu/ahls/rtl/{f}"
    assert os.path.exists(p), f"missing binding file {p}"
    lines.append(p)
# 4. AHLS generated kernel files (81)
for p in paths:
    assert os.path.exists(p), f"missing AHLS file {p}"
    lines.append(p)
open(f"{E}/afu_sources.txt","w").write("\n".join(lines)+"\n")
print(f"SOURCES_OK n={len(lines)}")
PYEOF
[ $? -ne 0 ] && { echo "SOURCES_FILE_FAIL"; exit 1; }

# --- 2) afu_synth_setup ---
rm -rf "$DST"
OPAE_PLATFORM_ROOT=$REL afu_synth_setup -s $E/afu_sources.txt -p ofs_agilex -l $REL/hw/lib "$DST"
SETUP_RC=$?
echo "SETUP_RC=$SETUP_RC"
[ $SETUP_RC -ne 0 ] && exit $SETUP_RC

# --- 3) afu_synth (full PR compile; ~30-60 min) ---
cd "$DST"
export OPAE_PLATFORM_ROOT=$DST
$REL/bin/afu_synth hw/ofs_pr_afu.json
SYN_RC=$?
echo "SYN_RC=$SYN_RC"
ls -la "$DST"/build/syn/board/ia840f/syn_top/output_files/*.gbs 2>/dev/null
sha256sum "$DST"/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs 2>/dev/null
exit $SYN_RC
