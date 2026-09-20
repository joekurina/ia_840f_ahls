#!/usr/bin/env python3
# Scan the UAFU aperture (0x71000..0x100000 of PF0 BAR0) for our AHLS AFU's
# DFH GUID halves and dump any DFH-looking headers. Read-only.
import mmap, os, struct, uuid

BASE = 0x71000
END = 0x100000
WANT = uuid.UUID("67bc266a-56f7-440a-bb75-12b5f446d842")
w_lo = WANT.int & 0xFFFFFFFFFFFFFFFF          # low 64 bits
w_hi = (WANT.int >> 64) & 0xFFFFFFFFFFFFFFFF  # high 64 bits

f = os.open("/sys/bus/pci/devices/0000:4f:00.0/resource0", os.O_RDWR | os.O_SYNC)
m = mmap.mmap(f, END)

print(f"scanning 0x{BASE:x}..0x{END:x} for GUID halves lo=0x{w_lo:016x} hi=0x{w_hi:016x}")
hits = []
for off in range(BASE, END - 16, 8):
    a = struct.unpack_from("<Q", m, off)[0]
    if a in (w_lo, w_hi):
        b = struct.unpack_from("<Q", m, off + 8)[0]
        other = w_hi if a == w_lo else w_lo
        if b == other:
            hits.append(off)
            print(f"  UUID MATCH at 0x{off:x}: {uuid.UUID(int=a | (b << 64))}")

# DFH chain walk from 0x71000 using next-pointer semantics
print("DFH chain from 0x71000:")
off = BASE
for _ in range(40):
    v = struct.unpack_from("<Q", m, off)[0]
    fid = v & 0xFFF
    rev = (v >> 12) & 0xF
    ftype = (v >> 60) & 0xF
    nxt = (v >> 16) & 0xFFFFFF
    eol = (v >> 40) & 1
    hdr = (v >> 41) & 0x3FFF if ftype == 2 else 0
    g = ""
    if ftype == 2 or fid != 0:
        try:
            g1 = struct.unpack_from("<Q", m, off + 8)[0]
            g2 = struct.unpack_from("<Q", m, off + 16)[0]
            g = str(uuid.UUID(int=g1 | (g2 << 64)))
        except Exception:
            pass
    print(f"  0x{off:06x}: DFH=0x{v:016x} id=0x{fid:x} type=0x{ftype:x} next=0x{nxt:x} eol={eol} {g}")
    if eol or nxt == 0:
        break
    off = off + nxt * 4  # next is in dwords

# If UUID found, show surrounding registers (potential CSR window)
for h in hits:
    print(f"context around 0x{h:x}:")
    for o in range(h - 0x40, h + 0x120, 8):
        val = struct.unpack_from("<Q", m, o)[0]
        print(f"  0x{o:06x}: 0x{val:016x}")
