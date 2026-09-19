# IA840F general-purpose ASP modernization review

## Outcome and qualification boundary

The active ASP is again a **general-purpose standard/USM source baseline**, not
an application-specific streaming transport. Five common files were restored
byte-for-byte to pinned OFS upstream after lossless preservation. Eight added
hostchannel implementation/source-list files were removed from the active tree
only after their saved bytes and hashes were verified. The explicit IA840F MMD
identity selection and all existing board-local gates remain unchanged.

This is source preparation, **not a working generated BSP or qualified runtime**.
No setup/configure, compiler, IP generator, simulator, project test, project
executable, vendor tool, installation, programming, remote operation, commit or
push was run. Verification consists of Python standard-library source parsing,
hashing, diffs and read-only Git inspection. Quartus 26.1.1 compatibility remains
unverified. The board-specific FIM/PIM port and fresh PR template remain separate
prerequisites; historical images/QDBs are not imported.

## Reference hierarchy

1. **Board authority:** `old_bsp/ia-840/IOFS_BUILD_ROOT/oneapi-asp/ia840f`, together
   with the original `ofs-ia840f` memory IP sources. The vendor supplies the
   actual IA840F device, memory sizes, UUIDs, standard/USM split and historical
   feature flags. These original trees were read only.
2. **Modern common implementation/interface reference:** OFS `oneapi-asp`
   commit `1af2ca74c452cb6ebbf54beb86e758e53489e826`, locally at
   `new_bsp/oneapi-asp`. Its HEAD was confirmed at that pin and working tree was
   clean. N6001 supplies modern naming/layout, **not board identity or physical
   memory assumptions**. Its four-bank device geometry is not substituted for
   the two-bank BittWare configuration.
3. **Host-pipe runtime evidence:** Intel `fpga-runtime-for-opencl` commit
   `32a36fe51d3bab2c7caff98e744e7ee3dd55da7d`, retained under
   `new/reference/hostpipe-abi/`. Its retained source-manifest hashes were
   checked. This establishes runtime mechanisms, not an IA840F reference DMA
   hostchannel engine or a compiler-qualified IA840F CSR integration.

Reference file sizes and SHA-256 values are recorded in
[`static-check-evidence.json`](../experiments/asp-baseline-separation/static-check-evidence.json).
No current upstream HEAD was substituted for the pinned source.

## Standard and USM audit

| Property | `ofs_ia840f` | `ofs_ia840f_usm` | Basis/disposition |
|---|---|---|---|
| Device model | `agfb027r25a2e2v_dm.xml` | Same | Vendor device/resource attributes preserved |
| Local banks | Two, each `0x400000000` bytes | Same | 16 GiB per bank, 32 GiB aggregate; vendor values |
| Local base addresses | `0x000000000`, `0x400000000` | `0x1000000000000`, `0x1000400000000` | Exact vendor bases; nonoverlap checked |
| Host/shared window | None | Base zero, size `0x1000000000000` | Vendor extent and current reference `kernel_host0` interface |
| Common local interface | `device0`, `kernel_device0_0/1` | Same | Current upstream kernel-wrapper naming |
| Address width / data / burst | 34-bit byte address / 512 / 16 | Same | Two 16-GiB banks rather than N6001 four 4-GiB banks |
| DMA | One channel | One channel | Existing modern DMA path retained |
| USM flags | Disabled | Enabled, including single-burst partial writes | Vendor behavior and modern reference retained |
| Local write ACK | Enabled | Enabled | XML `bsp_avmm_write_ack=1` agrees with RTL flags |
| H2F IRQ | Enabled | Enabled | Existing vendor/reference behavior, not new qualification |
| Kernel/F2H IRQ, DMA write-fence flag | Disabled | Disabled | Vendor/reference flags preserved; no completion/fence guarantees invented |
| HSSI/UDP I/O pipes | Disabled | Disabled | No inferred physical-lane mapping |
| XML version / revision | `24.1` / `ofs_pr_afu` | Same | Upstream interface schema, not a toolchain support claim |

The physical banks are **not two interchangeable devkit DDR channels**. Original
`ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_0.ip`
selects `MEM_FORMAT_DISCRETE`; `...intf_1.ip` selects `MEM_FORMAT_RDIMM`.
Both select DQ width 64. Preserving two logical ASP banks does not prove modern
FIM physical routing, ordering, clock/reset or generated macro compatibility.

The candidate's existing two-bank XML, parameter and RTL configurations already
match these board constraints and the pinned modern interfaces. They were
retained byte-for-byte rather than making speculative geometry or protocol
changes. Historical used-resource estimates remain explicitly historical. The
existing N6001-derived two-EMIF SDC hierarchy remains unqualified, not silently
rewritten into invented IA840F timing paths. The existing disabled
Quartus-23.3-specific INI workaround remains disabled.

### MMD identity retained

- Standard UUID: `51ED2F4A-FEA2-4261-A595-918500575509`.
- USM UUID: `5D9FEF7B-C491-4DCE-95FC-F979F6F061BE`.
- `common/source/CMakeLists.txt` retains explicit `ASP_AFU_ID=IA840F`,
  `BOARD_TYPE=1`, and fatal rejection of unsupported selectors. This whole file
  is unchanged from the pre-separation candidate.
- JSON UUIDs, Tcl high/low halves and both vendor/current MMD declarations agree.
  The vendor used those UUIDs and derived board type 1 through its N6001 UUID
  comparison; this is not evidence that the physical boards are interchangeable.
- Restoring `mmd_device.cpp` does not remove that selection: the pinned current
  implementation consumes `BOARD_TYPE`. Temperature lookup and shared-UUID
  discovery collisions remain deployment-review items, not runtime-qualified
  board management.

## Experimental transport separation

The custom transport had added a shared queue ABI include path, an MMD source,
four `aocl_mmd_hostchannel_*` exports, recursive lifecycle locking, altered
close/program/destructor behavior, and six hardware implementation/source-list
files. These form one experiment; retaining only some of its lifecycle hooks
would leave the baseline inconsistent. All affected files were archived whole,
then the five modified upstream files were restored together.

Active common source/hardware now differs from pinned upstream only in the
intentional MMD board-selection CMake file. The custom transport no longer
appears in the active common source list, host implementation or hardware tree.
Unchanged generic API declarations in upstream headers are not advertised
exports. Upstream `mmd_iopipes` and OFS host-memory channels are not replaced or
misrepresented as SYCL streaming hostpipes.

### Lossless preservation

[`../experiments/asp-baseline-separation/`](../experiments/asp-baseline-separation/)
contains **44 pre-edit files**: all **36 ASP deltas** against pinned upstream
(including the full IA840F board additions and legitimate MMD selector), plus
eight related ABI/application/documentation files copied as context. The
manifest records original absolute path, saved relative path, size, SHA-256,
mode, symlink metadata and corresponding upstream metadata when applicable.
All archived hashes were independently rechecked after the active restoration.

Related `new/interfaces/dma_hostchannel`, `new/afu/hostpipe_csr` and earlier
`new/docs/*hostchannel*` files were copied read-only into this archive; their
original paths are outside this ASP worker's edit scope. Their presence does
not reconnect them to the ASP. Parent-level documentation/experiment labeling
must keep those paths explicitly separate from active board support.

The archive is historical evidence, **not a supported implementation or an
alternative build path**. Do not execute its preserved scripts. The exact
before/after diff and full changed-path inventory accompany the hashes.

## Host pipes: reference-derived scope only

The retained Intel runtime has two distinct paths:

- Non-CSR pipes create MMD channels using compiler physical name and direction
  (`acl_program.cpp`, approximately lines 1349–1365); the HAL converts queue depth
  to bytes (`acl_hal_mmd.cpp`, approximately lines 2318–2328). A runtime API or
  sample XML does not supply a board's DMA engine, queue ownership or completion
  contract. No corresponding complete IA840F/OFS reference implementation was
  established here. The custom engine is therefore archived, not modernized
  into the general-purpose baseline.
- CSR-backed pipes skip channel creation and use ordinary synchronous MMD
  kernel-interface reads/writes (`acl_hal_mmd.cpp`, approximately lines
  3122–3135). `acl_hostch.cpp` contains data/handshake handling, and
  `acl_auto_configure.cpp` parses CSR metadata. Thus removing hostchannel exports
  is **not proof that every form of host pipe is impossible**.

No hostpipe XML advertisement, generated stream-port naming, queue protocol,
stream width or DMA/fence architecture was invented. No new hostpipe code was
added. The existing CSR example is only separate source evidence: compiler
metadata, generated RTL/CSR routing, address-window behavior and the selected
runtime must still be reconciled before enabling a board support claim. DDR
write ACK, USM and PCIe posted-write acceptance do not by themselves establish
host-visible output completion for an application protocol.

## Exact active changed paths

Restored to pinned upstream:

1. `oneapi-asp/common/hardware/common/build/asp_design_files.tcl`
2. `oneapi-asp/common/source/host/CMakeLists.txt`
3. `oneapi-asp/common/source/host/mmd.cpp`
4. `oneapi-asp/common/source/host/mmd_device.cpp`
5. `oneapi-asp/common/source/host/mmd_device.h`

Removed from active locations only after verified preservation:

6. `oneapi-asp/common/source/host/mmd_hostchannel.cpp`
7. `oneapi-asp/common/source/host/mmd_hostchannel.h`
8. `oneapi-asp/common/hardware/common/build/rtl/hostchannel/asp_hostchannel_engine.sv`
9. `oneapi-asp/common/hardware/common/build/rtl/hostchannel/asp_hostchannel_fifo.sv`
10. `oneapi-asp/common/hardware/common/build/rtl/hostchannel/asp_hostchannel_integration.sv`
11. `oneapi-asp/common/hardware/common/build/rtl/hostchannel/asp_hostchannel_pkg.sv`
12. `oneapi-asp/common/hardware/common/build/rtl/hostchannel/asp_hostchannel_share.sv`
13. `oneapi-asp/common/hardware/common/build/rtl/hostchannel/asp_hostchannel_sources.tcl`

Documentation correction:

14. `oneapi-asp/ia840f/README.md`: vendor-first provenance, physical memory
    distinction, archived transport and precise hostpipe qualification scope.

New evidence includes this review and the experiment directory's preservation
script, static parser, manifests, source snapshots, before/after diff and README.
The machine-readable `changed-files.json` lists all added/modified/deleted paths.

## Static evidence and remaining gates

`static-audit.py` completed **145 source checks**, all passing: 44 archived-file
hashes, exact upstream restorations, absence of experiment dependencies, sole
intentional common delta, vendor and modern variant contracts, UUIDs, memory
ranges/capacity, RTL feature flags, reference source hashes and preservation of
**nine board-local gate files**. XML generate/synthesize entries remain blocked.
The initial parser compared serialized XML including indentation and flagged
the existing historical-resource comment; it was corrected to compare actual
element tags/attributes. No source values or historical pins were weakened.
`git diff --check` completed without whitespace errors; Git status in the active
ASP reports only the pre-existing common selection delta and IA840F addition
against upstream. The experiment was not committed upstream.

Gates are unchanged source safeguards, not a security boundary. Untouched common
scripts can be invoked directly, which is not authorized. Neither successful
source checks nor retained upstream bodies justify unlocking anything. Future
work requires explicit authorization plus reviewed FIM/PIM memory/PCIe/clock
contracts, current toolchain compatibility, a new matching PR template,
resource/timing accounting, MMD/USM runtime qualification and separately proven
hostpipe integration if desired.
