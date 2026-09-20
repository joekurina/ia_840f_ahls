#!/bin/bash
# Live PR register probe during fpgaconf of our sanctioned persona GBS.
# Samples PR_MGMT CTRL/STS/ERR every 50ms while fpgaconf runs.
set -x
GBS=/home/uwb_student00/ahls/new_BSP/work_ahls_persona_01/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs
OUT=/tmp/fim13-gates/pr_live_probe.txt

: > $OUT
# sampler in background
sudo -n python3 -c "
import mmap, os, struct, time
f=os.open('/sys/bus/pci/devices/0000:4f:00.0/resource0', os.O_RDWR|os.O_SYNC)
m=mmap.mmap(f, 0x80000)
end=time.time()+60
while time.time()<end:
    c=struct.unpack_from('<Q',m,0x70008)[0]
    s=struct.unpack_from('<Q',m,0x70010)[0]
    e=struct.unpack_from('<Q',m,0x70020)[0]
    print(f'{time.time():.2f} CTRL=0x{c:x} STS=0x{s:x} ERR=0x{e:x}', flush=True)
    time.sleep(0.05)
" >> $OUT 2>&1 &
SAMPLER=$!

sleep 1
sudo -n fpgaconf $GBS
echo "FPGACONF_RC=$?" >> $OUT
sleep 2
kill $SAMPLER 2>/dev/null
echo DONE >> $OUT
