#!/usr/bin/env python3
# Build GBS v3: vendor container layout, patched UUIDs, RAW payload (matches vendor format).
import json, struct, hashlib

VGBS = "/tmp/fim13-gates/pr/vendor.gbs"
OUR_RBF = "/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/output_files/ofs_top.green_region.rbf"
OUT = "/tmp/fim13-gates/pr/ahls_afu.gbs"

vb = open(VGBS, "rb").read()
ob = open(OUR_RBF, "rb").read()
jlen = struct.unpack("<I", vb[16:20])[0]
hdr = json.loads(vb[20:20+jlen])
payload = vb[20+jlen:]
vend = open("/tmp/fim13-gates/pr/vendor.rbf", "rb").read()
print("payload is raw vendor rbf:", payload == vend, len(payload), len(vend))

hdr["afu-image"]["interface-uuid"] = "c281e23b-5a95-5aa9-8678-d2ecf1f80f6c"
for c in hdr["afu-image"]["accelerator-clusters"]:
    c["name"] = "ahls_qual_vec_op"
    c["accelerator-type-uuid"] = "67bc266a-56f7-440a-bb75-12b5f446d842"
hdr["afu-image"]["magic-no"] = 488605312

jbytes = json.dumps(hdr).encode()
out = b"XeonFPGA" + b"\xb7GBSv001" + struct.pack("<I", len(jbytes)) + jbytes + ob
open(OUT, "wb").write(out)
print("wrote", OUT, len(out))
print("sha256:", hashlib.sha256(out).hexdigest())
