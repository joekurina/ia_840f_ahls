# Strict initialization — actual-manager inert evidence

**Own tests passed; independent/parent acceptance pending.**

Source defect reproduced with the byte-bound SDK pluginmgr/config parser and
explicit inert IO/loader substitutions. A NULL config read in the original
initializer returned0, scanned the synthetic PCI directory and made10 loader
attempts selecting two default modules (`libopae-v.so`, `libopae-u.so`), followed
by two inert initializer calls. This is a semantic RED, not a native crash or
real backend/device access. [RED receipt](red-result01.json).

The additive `src/host/opae/ia840f_strict_init.inc` supplies an opt-in private
initializer in the same manager translation unit. It keeps every original SDK
function unchanged; requires fresh explicit-init/no-ASE state and one attempt;
uses the direct parser and exact two-row CAPS01 table; rejects absent/malformed/
wrong/allocation-failed configuration before discovery/loading. No detected
adapter is an error, and repeated calls cannot silently reuse or retry state.
A sibling `ahls_memory_entry_strict.c` names only the private strict API; the old
entry, launcher, frontends and SDK originals remain unchanged.

GCC14.2 O2/Werror/UNDEBUG/UBSan GREEN02 passes39 finite cases: valid startup,
read failure, first/second parser opae_calloc failures, CLI environment/path/state
prerequisites, empty/nonmatching/failing discovery, loader/symbol/configure/init
failures, repeat after success/partial-init failure, and21 exact config mutations.
[Driver](../../tests/ia840f/opae_strict/test_strict.py),
[full result](green-results02.json), [commands](commands-green02.json).
All fixtures have JSON-C/UBSan/libc direct dependencies only. dlopen/dlsym/dlclose/
dlerror/readdir are intercepted; opae_opendir/fopen and config IO are local test
substitutes. The only real fopen reads the named ordinary JSON fixture at test
startup. No OPAE initializer constructor, api-shell or hardware backend is linked.
ELF/undefined-symbol inspection precedes each test execution.

GREEN01 failed to compile because the fixture undefined its config-read rename
before including the new fragment. Preserve that build rc2 and fixture snapshot.
GREEN02 moves the test-only undef after both sources; the production fragment
was unchanged, no warning was suppressed, and no incomplete binary was run.

## Limits and next integration

This proves the exercised decision boundaries, not a real backend or generic
sandbox. Sysfs content, loader handles and adapter callbacks are synthetic.
Actual syscall/library failure mechanics, every allocation, concurrency and
teardown are not exhaustively tested. Existing loader prefix searches remain;
there is no complete namespace/dependency/BDF isolation. Legacy initialization
is unchanged and can still choose defaults; callers must select the new private
API and stop on failure. The attempted latch is per-process, including after
finalization; no real hardware recovery/cancellation is implied.

Partial adapter state follows the SDK's retained failure behavior; the strict
addition does not force cleanup, reset or unload. A real target core/entry build
and separate startup integration remain required. No installation, real runtime
loading, MMIO, DDR/DMA, numerical AHLS, lifecycle/full-signoff or boot pass.
Vendor DDR simulation remains SKIPPED BY USER.
