#!/usr/bin/env python3
"""Static UART-scope/delta checks only; no HDL simulation or device access."""
import argparse
import hashlib
import json
import re
from pathlib import Path

N = Path(__file__).resolve().parents[3]
E = N / "qualification/dfl-uart-fix-02"
W = N / "qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13"
C = N / "ofs-agx7-pcie-attach"
AFU = Path("src/board/ia840f/afu_top.sv")
ORIGINAL_SHA256 = "67c43a85a93c23c851a5f1136b05c1467bd541ab5bedb6da373af7d9d87d3bdc"
OLD = b"dummy_csr #(\n   .FEAT_ID          (12'h24),\n   .FEAT_VER         (4'h0),\n   .NEXT_DFH_OFFSET  (fabric_width_pkg::apf_uart_slv_next_dfh_offset),\n   .END_OF_LIST      (fabric_width_pkg::apf_uart_slv_eol)\n) uart_dummy_csr ("
NEW = OLD.replace(b"12'h24", b"12'h0")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def expected_candidate(original):
    require(sha(original) == ORIGINAL_SHA256, "original source hash mismatch")
    require(original.count(OLD) == 1, "original UART instance is not unique")
    return original.replace(OLD, NEW, 1)


def check_delta(candidate, original):
    require(candidate == expected_candidate(original),
            "expected only uart_dummy_csr FEAT_ID 12'h24 -> 12'h0")


def check_disabled(text):
    # Static literal-assignment check, not a general Tcl interpreter.
    for line in text.splitlines():
        active = line.split("#", 1)[0]
        for macro in ("INCLUDE_UART", "INCLUDE_HPS"):
            require(not re.search(r'VERILOG_MACRO\s+"?' + macro + r'(?:\b|=)', active),
                    "unexpected active " + macro)


def fabric_values(text):
    return {name: int(value, 16 if radix == "h" else 2)
            for name, radix, value in re.findall(
                r"localparam\s+(\w+)\s*=\s*'([hb])([0-9a-fA-F]+)\s*;", text)}


def check_links(text):
    p = fabric_values(text)
    require(p["apf_st2mm_slv_baseaddress"] + p["apf_st2mm_slv_next_dfh_offset"]
            == p["apf_uart_slv_baseaddress"], "predecessor no longer reaches UART slot")
    require(p["apf_uart_slv_baseaddress"] + p["apf_uart_slv_next_dfh_offset"]
            == p["apf_pr_slv_baseaddress"], "UART slot no longer reaches port-gasket slot")
    require(p["apf_uart_slv_next_dfh_offset"] == 0x10000, "vendor next-offset changed")
    require(p["apf_uart_slv_eol"] == 0, "UART slot unexpectedly ends DFL")
    return {k: p[k] for k in (
        "apf_st2mm_slv_baseaddress", "apf_uart_slv_baseaddress",
        "apf_uart_slv_next_dfh_offset", "apf_uart_slv_eol", "apf_pr_slv_baseaddress")}


def check(source):
    manifest = json.loads((E / "source-inputs.json").read_text())
    for entry in manifest["files"]:
        path = N / entry["path"]
        data = path.read_bytes()
        require(len(data) == entry["size"] and sha(data) == entry["sha256"],
                "bound input changed: " + entry["path"])
    original = (W / AFU).read_bytes()
    candidate = source.read_bytes()
    check_delta(candidate, original)
    vendor = (E / "vendor/afu_top.sv").read_text()
    require(re.search(r"dummy_csr\s*#\(\s*\.FEAT_ID\s*\(12'h0\).*?"
                      r"\.NEXT_DFH_OFFSET\s*\(24'h10000\).*?"
                      r"\.END_OF_LIST\s*\(1'b0\)\s*\)\s*uart_dummy_csr",
                      vendor, re.S), "vendor UART-absent precedent missing")
    for p in (E / "vendor/standard_ofs_top.qsf", E / "vendor/usm_ofs_top.qsf",
              C / "syn/board/ia840f/syn_top/ofs_top.qsf",
              W / "syn/board/ia840f/syn_top/fim_project_macros.tcl"):
        check_disabled(p.read_text())
    links = check_links((W / "src/includes/fabric_width_pkg.sv").read_text())
    return {"status": "PASS", "scope": "static UART-absent source delta and APF links only",
            "original_sha256": sha(original), "candidate_sha256": sha(candidate),
            "bound_input_count": len(manifest["files"]), "links": links,
            "hdl_simulation": "NOT RUN / excluded by user", "hardware": "NOT RUN"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=C / AFU)
    args = parser.parse_args()
    try:
        print(json.dumps(check(args.source), indent=2))
    except (ValueError, OSError, KeyError) as error:
        print(json.dumps({"status": "FAIL", "reason": str(error)}))
        raise SystemExit(1)
