#!/usr/bin/env python3
# Comprehensive green-region locator:
# 1) PF0 BAR0 size; SR-IOV VF capability/enablement state
# 2) linear UUID scan across whole BAR0 (read-only)
# 3) map DISTINCT 4K blocks 0x70000..end (facade vs real content)
# 4) CSR write probes at candidate AFU bases (args/mode/start; read status/finish/result)
#    Candidates: every 4K page start 0x80000..0x100000 + 0x81000-style mid pages.
# Writes are to scratch args/mode regs only; each candidate window is independent.
import mmap, os, struct, glob, uuid, time

BAR = "/sys/bus/pci/devices/0000:4f:00.0/resource0"
size = os.stat(BAR).st_size
print("BAR0 size:", hex(size))

# SR-IOV state
for f in ("sriov_totalvfs", "sriov_numvfs", "sriov_vf_device"):
    p = "/sys/bus/pci/devices/0000:4f:00.0/" + f
    if os.path.exists(p):
        print(f, "=", open(p).read().strip())

f = os.open(BAR, os.O_RDWR | os.O_SYNC)
m = mmap.mmap(f, size)
def rd(o): return struct.unpack_from("<Q", m, o)[0]
def wr(o, v): struct.pack_into("<Q", m, o, v)

WANT = uuid.UUID("67bc266a-56f7-440a-bb75-12b5f446d842").int
lo, hi = WANT & (2**64 - 1), WANT >> 64

# 2) full-BAR UUID scan (8-byte stride, both halves in order)
t0 = time.time()
hits = []
a = rd(0)  # touch
for o in range(0, size - 16, 8):
    if rd(o) == lo and rd(o + 8) == hi:
        hits.append(o)
print("UUID scan done in %.1fs; hits: %s" % (time.time() - t0, [hex(h) for h in hits]))

# 3) distinct 4K blocks in 0x70000..min(size, 0x180000)
print("distinct 4K blocks 0x70000..0x180000:")
seen = {}
for base in range(0x70000, min(size, 0x180000), 0x1000):
    blk = bytes(m[base:base + 0x40])  # hash first 64B
    key = blk.hex()[:32]
    seen.setdefault(key, []).append(base)
for key, bases in seen.items():
    tag = "FACADE-MIRROR" if len(bases) > 3 else "unique"
    print("  %s x%d first=0x%x last=0x%x : %s.." % (tag, len(bases), bases[0], bases[-1], key[:24]))
    if len(bases) <= 3:
        for o in range(bases[0], min(bases[0] + 0x100, size), 8):
            v = rd(o)
            if v:
                print("    0x%06x: 0x%016x" % (o, v))

# 4) CSR functional probes at candidate AFU bases
print("CSR probes (write args/mode, pulse start, read back):")
cands = [0x80000, 0x81000, 0x84000, 0x88000, 0x90000, 0xA0000, 0xC0000, 0x100000]
if size > 0x100000:
    cands += [0x140000, 0x180000]
for base in cands:
    try:
        # identity read: DFH word
        dfh = rd(base)
        pre_st = rd(base + 0x40)
        wr(base + 0xC0, (0x22222222 << 32) | 0x11111111)
        wr(base + 0xC8, 0)
        wr(base + 0x48, 1)
        time.sleep(0.02)
        st = rd(base + 0x40)
        fin = rd(base + 0x70) | (rd(base + 0x74) << 32)
        res = rd(base + 0xD0)
        args = rd(base + 0xC0)
        print("  base 0x%06x: DFH=0x%016x st=0x%x fin=0x%x res=0x%x args_rb=0x%x %s"
              % (base, dfh, st, fin, res, args,
                 "<<< LIVE" if (args == (0x22222222 << 32) | 0x11111111 or res == 0x33333333) else ""))
    except Exception as e:
        print("  base 0x%06x: error %s" % (base, e))
