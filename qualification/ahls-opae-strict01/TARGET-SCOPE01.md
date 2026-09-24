# Strict core target01 — compile/link only

Fresh AHLS SIF work root; reuse accepted prefix/backend libraries. Configure
and build only native CMake target opae-c with the accepted SDK options. Original
SDK is read-only at /sdk, with exactly one read-only file bind overlay:
pluginmgr.c original bytes plus the private strict include. Bind/check the actual
in-container overlay digest. All1177 original host source entries remain unchanged.
Append-only include and three own strict files are separately hash-bound.

Rebuild the core, then compile/link unchanged launcher and the new strict entry;
no frontend/backend/library execution, installation, FPGA tool or hardware action.
New core config.h metadata and libopae-c.so.2.13.0 are explicit copied output roles;
all other copied inputs (including all backend libraries) stay immutable. Record
actual deltas, originals, inputs, SIF/runtime identities and every native status.
Old core and old entry remain intact in their predecessor roots.

Require the new private export plus existing referenced FPGA API exports and
three bridge symbols. Static ELF inspection only. Core RUNPATH is captured;
inherited loader and runtime limitations are not waived. Same finite resources,
owned tmux, minimal device namespace/no sysfs and no competing tools as target01
predecessor. Source-bound guards are not an OS sandbox. Separate independent
native result review is required; the39-case unit gate does not accept this build.
