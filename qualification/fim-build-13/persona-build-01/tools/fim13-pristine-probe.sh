#!/bin/bash
# PRISTINE BOOT PROBE — run FIRST after BMC power cycle + host reboot.
# No PR attempts, no register writes. Read-only.
set -x
date
fpgainfo fme 2>/dev/null | grep -E "Bitstream|Pr Interface" | head -4
sudo -n dmesg | grep -iE "dfl|fpga" | tail -8
sudo -n python3 - <<'PYEOF'
import mmap, os, struct, uuid
f = os.open("/sys/bus/pci/devices/0000:4f:00.0/resource0", os.O_RDWR | os.O_SYNC)
m = mmap.mmap(f, 0x100000)
def rd(o): return struct.unpack_from("<Q", m, o)[0]
print("PORT_CONTROL @0x71038: 0x%x (bit0 SFreset=%d)" % (rd(0x71038), rd(0x71038) & 1))
print("PR_MGMT CTRL=0x%x STS=0x%x ERR=0x%x" % (rd(0x70008), rd(0x70010), rd(0x70020)))
print("green region 0x80000..0x81000:")
for o in range(0x80000, 0x81000, 8):
    v = rd(o)
    if v:
        print("  0x%06x: 0x%016x" % (o, v))
g1, g2 = rd(0x80008), rd(0x80010)
print("UAFU GUID words: 0x%016x 0x%016x" % (g1, g2))
if g1 or g2:
    print("UUID:", uuid.UUID(int=g1 | (g2 << 64)))
PYEOF
echo RC=$?
