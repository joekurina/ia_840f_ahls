#!/usr/bin/env python3
# PR engine probe: pre/post snapshot + live sampling loop.
# Usage: pr_probe.py pre|post|sample
import sys, os, mmap, struct, time

fd = os.open("/sys/bus/pci/devices/0000:4f:00.0/resource0", os.O_RDWR | os.O_SYNC)
m = mmap.mmap(fd, 0x80000)
rd = lambda o: struct.unpack("<Q", m[o:o + 8])[0]
wr = lambda o, v: m.__setitem__(slice(o, o + 8), struct.pack("<Q", v))
p = 0x70000

def snap(tag):
    ctrl, sts, err = rd(p + 8), rd(p + 0x10), rd(p + 0x20)
    print("%s t=%d CTRL=0x%x STS=0x%x ERR=0x%x host=%d prog=%d pass=%d errb=%d crc=%d incompat=%d"
          % (tag, time.time(), ctrl, sts, err, (sts >> 8) & 0xF, (sts >> 16) & 3,
             (sts >> 20) & 1, (sts >> 21) & 1, (sts >> 23) & 1, (sts >> 25) & 1))

mode = sys.argv[1] if len(sys.argv) > 1 else "pre"
if mode == "pre":
    snap("PRE")
    print("reset engine"); wr(p + 8, rd(p + 8) | 1); time.sleep(0.3)
    snap("PRE-POSTRESET")
elif mode == "post":
    for i in range(3):
        snap("POST"); time.sleep(1)
else:  # sample
    prev = None
    t0 = time.time()
    while time.time() - t0 < 300:
        s = (rd(p + 8), rd(p + 0x10), rd(p + 0x20))
        if s != prev:
            ctrl, sts, err = s
            print("S t=%.2f CTRL=0x%x STS=0x%x ERR=0x%x" % (time.time() - t0, ctrl, sts, err))
            prev = s
        time.sleep(0.5)
m.close(); os.close(fd)
