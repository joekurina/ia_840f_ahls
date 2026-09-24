# IA-840F OPAE configuration candidate

`ia840f_caps01_dfl.cfg` is an additive, **not installed** DFL-only candidate.
It selects `/work/sdk-build/lib/libxfpga.so` for the source-derived
`8086:bcce / 8086:1771` and `8086:bccf / 8086:1771` ID tuples. The two names
are labels, not BDF/PF isolation. The path belongs to the existing isolated
AHLS-image build context, not a general installed runtime prefix.

[Runtime source review and inert parser tests](../../../qualification/ahls-opae-runtime01/RESULTS01.md)
explain the observed constructor and configuration-fallback behavior.
The SDK parser accepts this file, but that does not qualify driver binding,
plugin initialization, enumeration, MMIO or hardware. Do not install or load it
as a discovery experiment. Original SDK/system configurations and all prior
frontend/build artifacts are preserved. VFIO was built separately and is not
a fallback selected by this candidate.
