#!/usr/bin/env python3
# Strict DFH next-pointer walk from PF0 BAR0 offset 0. Prints every feature,
# its body qwords, and a PR-engine register decode. Usage: walk.py [reset]
import sys, os, mmap, struct, time

BAR = "/sys/bus/pci/devices/0000:4f:00.0/resource0"

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "dump"
    fd = os.open(BAR, os.O_RDWR | os.O_SYNC)
    m = mmap.mmap(fd, 0x100000)
    rd = lambda o: struct.unpack("<Q", m[o:o + 8])[0]
    wr = lambda o, v: m.__setitem__(slice(o, o + 8), struct.pack("<Q", v))

    off, seen, pr_off, hops = 0, set(), None, 0
    while off < 0x100000 and hops < 64:
        if off in seen:
            print("loop at 0x%x — stop" % off); break
        seen.add(off)
        v = rd(off)
        t, fid = (v >> 60) & 0xF, v & 0xFFFF
        nxt, eol, rev = (v >> 16) & 0xFFFFFF, (v >> 40) & 1, (v >> 52) & 0xFFF
        print("feat @0x%06x DFH=0x%016x type=%d id=0x%04x rev=0x%x next=0x%x eol=%d"
              % (off, v, t, fid, rev, nxt, eol))
        body_end = min(off + (nxt if nxt else 0x40), off + 0x40)
        row = []
        for o in range(off + 8, body_end, 8):
            row.append("+0x%02x:%016x" % (o - off, rd(o)))
        for i in range(0, len(row), 4):
            print("   " + "  ".join(row[i:i + 4]))
        if t in (3, 1) and fid == 0x5:
            pr_off = off
        if eol:
            print("-- EOL --"); break
        if nxt == 0:
            print("-- next==0, stop --"); break
        off += nxt; hops += 1

    if pr_off is None:
        print("!! PR feature (id 5) NOT in chain"); m.close(); os.close(fd); return

    print("== PR engine @0x%x ==" % pr_off)
    ctrl, stat, err = rd(pr_off + 0x08), rd(pr_off + 0x10), rd(pr_off + 0x20)
    print("PR_CTRL =0x%016x  PR_STAT=0x%016x  PR_ERR =0x%016x" % (ctrl, stat, err))
    print("  ctrl: reset=%d rate_req=%d rblock=%d req_len(b17:16)=%d"
          % (ctrl & 1, (ctrl >> 2) & 7, (ctrl >> 5) & 1, (ctrl >> 16) & 3))
    print("  stat: cvers=%d speed=%d corests(b9:8)=%d idle(b12)=%d prog(b17:16)=%d "
          "pass(b20)=%d err(b21)=%d crc(b23)=%d incompatible(b25)=%d"
          % (stat & 0xF, (stat >> 4) & 7, (stat >> 8) & 3, (stat >> 12) & 1,
             (stat >> 16) & 3, (stat >> 20) & 1, (stat >> 21) & 1,
             (stat >> 23) & 1, (stat >> 25) & 1))

    if mode == "reset":
        print("-- writing PR_CTRL reset=1 --")
        wr(pr_off + 0x08, ctrl | 1)
        ack = 0; t0 = time.time()
        while time.time() - t0 < 3:
            if (rd(pr_off + 0x08) >> 1) & 1: ack = 1; break
            time.sleep(0.02)
        print("ack=%d  after: CTRL=0x%016x STAT=0x%016x ERR=0x%016x"
              % (ack, rd(pr_off + 0x08), rd(pr_off + 0x10), rd(pr_off + 0x20)))

    m.close(); os.close(fd)

main()
