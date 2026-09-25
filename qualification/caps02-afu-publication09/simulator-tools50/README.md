# Isolated observer-regression simulator

Project-local extraction of Debian trixie's Icarus Verilog package, requested version `12.0-2+b1`, for digital observer/mailbox regression. No system package installation, maintainer scripts, remote workstation action or hardware access is intended.

The package must match APT's package-index size/SHA256 and version/architecture before extraction. Record actual binary paths and a compiled/executed smoke test in `PROVISION.json`; extraction or a version banner alone is not functional verification. This simulator is not the Quartus 25.1 fitter/STA toolchain and does not qualify timing or generated-HLS integration.
