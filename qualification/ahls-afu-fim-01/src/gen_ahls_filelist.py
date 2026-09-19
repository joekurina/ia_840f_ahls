#!/usr/bin/env python3
"""Mechanically derive a Quartus-native source filelist from the AHLS-generated
_di_hw.tcl QUARTUS_SYNTH fileset.

Why: qual_vec_op_report_di_hw.tcl is a Platform Designer component script.
Its fileset entries use PD kernel procs (add_fileset_file), which do not exist
in a quartus_sh project script context, so afu.tcl cannot source it. The
qsys-import (ahls-qsys-import-01) proved the exact same fileset compiles
cleanly under Quartus 26.1.1 when qsys-generate translates it to
qual_test_k0.qip SYSTEMVERILOG_FILE entries. This script performs the same
mechanical translation (add_fileset_file <name> SYSTEM_VERILOG PATH <relpath>
-> set_global_assignment -name SYSTEMVERILOG_FILE <abs path>) with no
semantic edits. Input hash + output are recorded as evidence.

Usage: gen_ahls_filelist.py <prj_dir> <out_tcl>
  <prj_dir>  directory containing qual_vec_op_report_di_hw.tcl and the fileset
             files (./ip/..., ./kernel_hdl/...)
  <out_tcl>  output Tcl appending SYSTEMVERILOG_FILE + SEARCH_PATH entries
"""
import hashlib
import sys
from pathlib import Path

def main() -> int:
    prj = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]).resolve()
    hw_tcl = prj / "qual_vec_op_report_di_hw.tcl"
    text = hw_tcl.read_text()

    # QUARTUS_SYNTH fileset only (SIM_VERILOG is a duplicate for sim).
    files: list[str] = []
    in_synth = False
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("add_fileset QUARTUS_SYNTH"):
            in_synth = True
            continue
        if s.startswith("add_fileset ") and in_synth:
            in_synth = False  # next fileset (SIM_VERILOG) begins
            continue
        if not in_synth:
            continue
        if not s.startswith("add_fileset_file"):
            continue
        parts = s.split()
        # add_fileset_file "<name>" SYSTEM_VERILOG PATH "<rel>"
        if len(parts) < 5 or parts[2] != "SYSTEM_VERILOG" or parts[3] != "PATH":
            continue
        rel = parts[4].strip('"')
        f = prj / rel
        if not f.is_file():
            print(f"ERROR: fileset entry missing on disk: {f}", file=sys.stderr)
            return 1
        files.append(str(f))

    if not files:
        print("ERROR: no QUARTUS_SYNTH entries parsed", file=sys.stderr)
        return 1

    lines = [
        "# AHLS component synthesis filelist — MECHANICALLY DERIVED, DO NOT EDIT BY HAND.",
        f"# Source: {hw_tcl}",
        f"# Source SHA-256: {hashlib.sha256(hw_tcl.read_bytes()).hexdigest()}",
        f"# Translation rule: add_fileset_file <n> SYSTEM_VERILOG PATH <rel>",
        f"#   -> set_global_assignment -name SYSTEMVERILOG_FILE <abs>",
        f"# Entries: {len(files)} (deduplicated, order preserved)",
        "",
    ]
    seen: set[str] = set()
    n = 0
    for f in files:
        if f in seen:
            continue
        seen.add(f)
        n += 1
        lines.append(f'set_global_assignment -name SYSTEMVERILOG_FILE "{f}"')
    lines.append("")
    lines.append(f"# Unique entries emitted: {n}")

    out.write_text("\n".join(lines) + "\n")
    print(f"OK entries={n} (parsed {len(files)}) out={out}")
    print(f"hw_tcl_sha256={hashlib.sha256(hw_tcl.read_bytes()).hexdigest()}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
