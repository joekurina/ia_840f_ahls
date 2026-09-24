# Scope — DFL-only runtime configuration and inert SDK parser

This is a source/configuration and local own-fixture test gate. Add a separate
DFL-only CAPS01 configuration, preserve SDK/system configuration and every
accepted frontend/artifact, and establish the parser's actual two-row result.
Use byte-identical SDK `cfg-file.c`, `opae-cfg.c`, required headers and libc
wrappers bound to the completed AHLS-image SDK inventory. Do not link or load
`libopae-c`, a backend, plugin manager or runtime initializer in the fixture.

RED: unmodified SDK opae.cfg must fail the project's exact two-row check.
GREEN: the additive candidate must produce exactly the expected PF/VF PCI IDs,
absolute xfpga module path and empty configuration objects. Preserve negative
and default-fallback results rather than assuming malformed JSON fails closed.
Run the parent-authored matrix normally and with Python optimization; retain
ordinary compiler/native return codes, logs and source hashes.

No real host frontend execution, backend loading, driver/system installation,
OPAE enumeration, device/sysfs/MMIO probing, FPGA build/deployment or hardware
qualification is authorized by this gate. The parser fixture reads only named
ordinary JSON files. This is not a generic sandbox or approval framework.
Acceptance requires independent specification then evidence/quality review.
