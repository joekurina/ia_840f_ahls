#!/usr/bin/env python3
# 1) Unwedge the PR host FSM via the PR_RST handshake (PR_CTRL bit0/bit4).
# 2) Check port PORT_CONTROL (0x71038) SF-reset state.
# 3) Re-scan the green region (UAFU @0x80000): DFH GUID + registers.
# 4) If alive, run the AHLS CSR functional sequence.
import mmap, os, struct, time, uuid

f = os.open("/sys/bus/pci/devices/0000:4f:00.0/resource0", os.O_RDWR | os.O_SYNC)
m = mmap.mmap(f, 0x100000)

def rd(o): return struct.unpack_from("<Q", m, o)[0]
def wr(o, v): struct.pack_into("<Q", m, o, v)

PR_CTRL, PR_STS, PR_ERR = 0x70008, 0x70010, 0x70020
PC = 0x71038

print("PR before: CTRL=0x%x STS=0x%x ERR=0x%x  PORT_CONTROL=0x%x" %
      (rd(PR_CTRL), rd(PR_STS), rd(PR_ERR), rd(PC)))

# PR_RST handshake: assert bit0, poll bit4 (RSTACK) self-clear of bit0
wr(PR_CTRL, rd(PR_CTRL) | 1)
for _ in range(100):
    c = rd(PR_CTRL)
    if not (c & 1):
        break
    time.sleep(0.01)
print("PR_RST done: CTRL=0x%x (bit4 RSTACK=%d)" % (rd(PR_CTRL), (rd(PR_CTRL) >> 4) & 1))
# acknowledge reset ack if set
if (rd(PR_CTRL) >> 4) & 1:
    wr(PR_CTRL, rd(PR_CTRL) | (1 << 4))
    time.sleep(0.1)
print("PR after : CTRL=0x%x STS=0x%x ERR=0x%x" % (rd(PR_CTRL), rd(PR_STS), rd(PR_ERR)))

time.sleep(0.5)
print("PORT_CONTROL now: 0x%x  (bit0 SF-reset=%d)" % (rd(PC), rd(PC) & 1))

# green region scan
print("UAFU @0x80000 after unwedge:")
for o in range(0x80000, 0x80100, 8):
    v = rd(o)
    if v:
        print("  0x%06x: 0x%016x" % (o, v))
g1, g2 = rd(0x80008), rd(0x80010)
if g1 or g2:
    print("UAFU GUID:", uuid.UUID(int=g1 | (g2 << 64)))

# CSR functional test (AHLS map)
B = 0x80000
A, Bv = 0x11111111, 0x22222222
struct.pack_into("<Q", m, B + 0xC0, (Bv << 32) | A)
struct.pack_into("<Q", m, B + 0xC8, 0)
struct.pack_into("<Q", m, B + 0x48, 1)
time.sleep(0.1)
for o in (0x40, 0x48, 0x70, 0x74, 0xC0, 0xC8, 0xD0):
    print("  CSR +0x%02x: 0x%016x" % (o, rd(B + o - 0x80000 + 0x80000) if False else struct.unpack_from("<Q", m, B + o)[0]))
res = struct.unpack_from("<Q", m, B + 0xD0)[0]
print("result=0x%x expect=0x%x match=%s" % (res, A + Bv, res == A + Bv))
