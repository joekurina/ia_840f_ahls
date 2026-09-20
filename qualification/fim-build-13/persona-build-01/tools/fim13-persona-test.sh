#!/bin/bash
# Post-persona-build: verify GBS, load via fpgaconf, verify UAFU GUID, run MMIO test.
# Usage: bash /tmp/fim13-gates/persona_test.sh
set -x
SYN=/home/uwb_student00/ahls/new_BSP/work_ahls_persona_01/build/syn/board/ia840f/syn_top
LOG=/tmp/fim13-gates/persona_test.log

GBS=$SYN/output_files/ofs_pr_afu.green_region.gbs
[ -f "$GBS" ] || { echo "NO_GBS"; exit 1; }
sha256sum "$GBS"
packager gbs-info "$GBS" 2>&1 | head -20

# Load via kernel PR path
sudo -n fpgaconf "$GBS"
LOAD_RC=$?
echo "LOAD_RC=$LOAD_RC"
[ $LOAD_RC -ne 0 ] && { dmesg | tail -15; exit $LOAD_RC; }

# Verify UAFU DFH GUID = our persona
sudo -n python3 -c "
import mmap, os, struct, uuid
f=os.open('/sys/bus/pci/devices/0000:4f:00.0/resource0', os.O_RDWR|os.O_SYNC)
m=mmap.mmap(f, 0x80000)
g1=struct.unpack_from('<Q', m, 0x71008)[0]
g2=struct.unpack_from('<Q', m, 0x71010)[0]
u=uuid.UUID(int=g1 | (g2<<64))
print('UAFU GUID =', u)
assert str(u) == '67bc266a-56f7-440a-bb75-12b5f446d842', 'PERSONA UUID MISMATCH'
print('PERSONA_UUID_VERIFIED')
"

# Run the MMIO qualification test (self-calibrating vector-op check)
/tmp/ahls_mmio_test
echo "MMIO_RC=$?"
