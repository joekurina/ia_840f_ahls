#!/usr/bin/env python3
# Build GBS v2: vendor GBS container, patched UUIDs, our green_region.rbf payload.
import json, zlib, struct, hashlib

VGBS = "/tmp/fim13-gates/pr/vendor.gbs"
OUR_RBF = "/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/output_files/ofs_top.green_region.rbf"
OUT = "/tmp/fim13-gates/pr/ahls_afu.gbs"

vb = open(VGBS, "rb").read()
ob = open(OUR_RBF, "rb").read()

assert vb[:8] == b"XeonFPGA", vb[:8]
assert vb[8:16] == b"\xb7GBSv001", vb[8:16]
jlen = struct.unpack("<I", vb[16:20])[0]
print("json len:", jlen)
hdr = json.loads(vb[20:20+jlen])
payload = vb[20+jlen:]
print("payload len:", len(payload))

# Try decompress payload
try:
    d = zlib.decompress(payload, wbits=-15); comp = "raw"
except Exception:
    try:
        d = zlib.decompress(payload); comp = "zlib"
    except Exception:
        d = None
if d is not None:
    print("comp:", comp, "decompressed:", len(d))
    # sanity: does decompressed match vendor.rbf we extracted earlier?
    v = open("/tmp/fim13-gates/pr/vendor.rbf", "rb").read()
    print("matches vendor.rbf:", d == v)
else:
    print("payload raw (no compression)")

hdr["afu-image"]["interface-uuid"] = "c281e23b-5a95-5aa9-8678-d2ecf1f80f6c"
for c in hdr["afu-image"]["accelerator-clusters"]:
    c["name"] = "ahls_qual_vec_op"
    c["accelerator-type-uuid"] = "67bc266a-56f7-440a-bb75-12b5f446d842"

jbytes = json.dumps(hdr).encode()
if d is not None:
    co = zlib.compressobj(9, zlib.DEFLATED, -15 if comp == "raw" else 15)
    new_payload = co.compress(ob) + co.flush()
else:
    new_payload = ob

out = b"XeonFPGA" + b"\xb7GBSv001" + struct.pack("<I", len(jbytes)) + jbytes + new_payload
open(OUT, "wb").write(out)
print("wrote", OUT, len(out))
print("sha256:", hashlib.sha256(out).hexdigest())
