# Installed mailbox runtime/catalog review — live01

## Outcome

**The live receipt advances the binding materially, but does not authorize execution.**
The next collection is finite: **10 exact installed-file candidates, 5 bounded
read-only queries, and one missing remote receipt-path repair requiring separate
write permission**. Seven known fileset resources are listed separately rather than
making the entire generation graph a prerequisite for a saved-state experiment.
`proposed-binding.json` is a populated, deliberately **unapproved partial candidate**;
all review flags and `ready_for_build` remain false. No scratch was created or opened.

Important correction to a tempting simplification: **HAS_STREAM=0 does not remove
the config-stream endpoint**. Actual public Tcl selects that component when DEBUG=0.
HAS_OFFLOAD=0 removes the memory-initiator endpoint and its extra clock/reset pair.
The next request preserves this distinction.

## Evidence checked

- Parsed `binding-evidence-live01.json` in Python, not by dumping its contents.
  Independently recomputed SHA-256:
  `4da8984e639dfba97ac2a5430268633a07849925bcdd449a20a3f74c74623214`.
- Receipt has **348 records, 347 successful hashes**, 294 indexed candidates,
  no index errors, no pending paths, and no uncollected indexed candidates.
  Every captured full text re-encodes to its recorded SHA-256; no text/binary-prefix
  truncation is flagged and successful records are stable during read.
- Only failed record/expected comparison is the absent remote
  `/home/uwb_student00/ahls/new_BSP/qualification/ipgen-03/installed-refresh-tool-discovery.json`.
  The local file exists and independently hashes to
  `79db4ecb18aa7eeeeadb4de914902594c99bca775bb4a0e545e8769df5954ffd`.
  This is a **receipt deployment gap, not missing help knowledge**. Retain the exact
  binding; separately authorize copying the identical receipt and verify remote bytes.
- All successful captured paths have empty symlink chains and are marked
  `harness_no_links_compatible`. Six skipped index directories are Java manual/Questa
  paths, not evidence of a missing active mailbox Tcl candidate. This does not prove
  absence of other catalog candidates or future runtime-library symlinks.
- Recorded collection context: `Agilex7Workstation`, user `uwb_student00`, remote
  qualification cwd; named tmux **ia840f_migration_preflight**, session `$4`, pane `%4`,
  pane PID `25387`. Those are historical collection observations, not permission for
  a future invocation. Current session/pane identity must be rechecked.
- Read the audit, template, implementation, both Tcl scripts, README, final spec and
  quality reports, correction report, installed help receipt, refresh procedure and
  captured workstation instructions. Prior reports' test results remain prior results;
  no vendor integration or new harness-suite pass is claimed here.

The four baseline harness hashes match local files. Template, README and test hashes
also still match the reviewed report identities. The captured source records include
all 34 bound BMC files and both active board boundary files. Hash equality of bound
files is not proof of absence of extra remote source files; the harness's exact source
inventory remains required before staging.

## Finite catalog graph

The 24 saved `.ip` leaves resolve to the following 10 distinct saved kinds. Counts
and saved versions below came from actual XML, not filenames or a remembered graph.
Installed values are declarations in captured Tcl, **not actual loader selections**.

| Kind | Leaves | Saved version | Captured installed declaration |
|---|---:|---|---|
| Arbiter | 1 | 2.0 | Custom 2.0, qsys 16.0 |
| IRQ_Generator | 2 | 1.0 | Custom 1.0, qsys 15.1 |
| altera_avalon_mm_bridge | 11 | 20.0.1 | 20.1.0, qsys 20.1 + altera_terp 1.0 |
| altera_reset_bridge | 3 | 19.2.0 | 19.2.0, exact sopc 9.1 |
| altera_clock_bridge | 2 | 19.2.0 | 19.2.0, sopc 9.1 |
| spi_slave_to_avalon_mm_master_bridge | 1 | 19.1.3 | **Definition not captured** |
| altera_avalon_onchip_memory2 | 1 | 19.3.7 | 19.3.9, qsys 20.1 |
| altera_s10_mailbox_client | 1 | 20.2.2 | 23.0.0, qsys 16.0 |
| altera_axi_bridge | 1 | 19.3.1 | 19.10.3, qsys 16.0 + altera_terp 1.0 |
| altera_avalon_sysid_qsys | 1 | 19.1.3 | 20.0.0, qsys 20.1 |

The parent/subsystem proxy records are not additional installed IP kinds to upgrade.
Unrelated installed-version differences in this table make non-target byte/semantic
rejection especially important; they are not a request to upgrade those leaves.

### Mailbox active branch, from actual parameter XML and Tcl

Scoped mailbox module parameters have **DEBUG=0, HAS_STREAM=0, HAS_OFFLOAD=0**.
Public `altera_s10_mailbox_client_hw.tcl:224–247` always composes the clock bridge,
reset bridge and internal core. Core declaration is **21.0.0**, public **23.0.0**.
At **279–280**, `if {$DEBUG == 0}` adds `altera_config_stream_endpoint` **19.2.0**;
its command/response/status paths remain active with streaming disabled. Lines
299–303 gate only stream connections. At 307–308 the memory endpoint requires
HAS_OFFLOAD=1; it is inactive here. Its captured 1.0.0 Tcl is useful conditional
reference evidence but its wrapper/transitive graph is excluded from the minimal
next request. Additional offload clocks/resets are likewise inactive.

Core fileset `:62–63` names the captured core RTL and
`/opt/altera/26.1.1/ip/altera/pgm/lib/intel_avst_dp_scfifo/intel_avst_dp_scfifo.sv`.
That FIFO identity is now known, not still a missing helper. Core RTL references
`altera_std_synchronizer_bundle` at 1120 and 1132; provider resolution is a later
HDL-generation item unless the saved-state run unexpectedly activates generation.
Config endpoint Tcl declares its wrapper fileset at 59/64/69; the wrapper is not
captured. It is explicitly listed as an active fileset resource, not misclassified
as an inactive HAS_STREAM dependency.

### Custom and installed helper edges

Arbiter's three relative VHDL files and IRQ's Verilog file are already source-bound.
IRQ's unconditional `embedded_ip_hwtcl_common.tcl` is captured at hash
`b8df91f1eae39c52727732fa05383ae5cc3c0cf0bcb7776516c411c4601d26b5`.
The helper's Perl/Europa execution is inside generation procedures, not a top-level
source command; do not demand the whole Perl/Europa graph merely to load it.

The **five exact load/package helper gaps** are:

1. Onchip-memory hw line 18: `ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common_forCDC.tcl`.
2. AXI hw line 52: `ip/altera/merlin/shared/axi5_interface.tcl`.
3. AXI hw line 53: `ip/altera/merlin/altera_axi_bridge/axi_interface.tcl`.
4. AXI hw line 2153: `ip/altera/merlin/altera_axi_bridge/axi_gui.tcl`.
5. Captured common `pkgIndex.tcl`: `ip/altera/common/hw_tcl_packages/altera_terp.tcl`.

All are relative to `/opt/altera/26.1.1`. Relative AXI source names are catalog-dir
candidates, not evidence Tcl's process cwd is that directory. Inspect one further
literal source/provider hop from these five, capped at 16 files, then stop and review.
Bridge TERP/RTL files and sysid RTL are inventoried separately as fileset/generation
resources. No HAL driver/BSP generation or simulator is requested.

SPI is the only saved installed kind with no captured definition. The collector's
filename-based index can miss alternate definition names/catalog formats. A bounded
NAME/VERSION/index query for the existing finite kind set, including this SPI kind,
is the appropriate next step—not declaring it unavailable and not demanding all IP.
Literal `custom-arbiter,custom-IRQ,$` remains unchanged. Static default search roots,
index mappings and competing NAME/version candidates still need the bounded query;
actual selected catalog implementations must be established during the experiment.

## Runtime and package evidence actually present

Both exact qsys entry points are **ELF launchers**, not shell wrappers:

- qsys-generate: `10db24cb15ba97694c1385b56f6ffde3bcfcd2249e2901c9a3f0c34b68da14df`.
- qsys-script: `a0c811ed4010961b2ae4e92711492a172be969c900709b380f3c66db875d3f75`.

Each is 101696 bytes; static interpreter is `/lib64/ld-linux-x86-64.so.2`.
Both DT_NEEDED lists contain libdl, libstdc++, libm, libgcc_s and libc. Neither
record supplies a launcher RPATH/RUNPATH. Printable strings name root/bindir overrides,
`QUARTUS_BINDIR/java17/jre64`, `libjvm.so`, `libsplashscreen.so`, qsys/bin, qsys/lib,
LD_LIBRARY_PATH and Java option variables. These are static references, not a proven
control-flow selection or a full classpath.

Captured Java identity is
`/opt/altera/26.1.1/quartus/linux64/java17/jre64/bin/java`, hash
`ff746894f128c5c18c19443f54e162b86f4b21baff2ba339bcd371f73b487711`.
Its release file declares Temurin **17.0.15+6**. Java DT_NEEDED includes libjli,
libpthread, libdl and libc, with RPATH `$ORIGIN:$ORIGIN/../lib`.
The next exact runtime candidates are version.txt, libjli, libjvm, libsplashscreen
and the JRE modules image. Conventional JRE locations are marked **candidates**,
not invented observations. Hash module/JAR files without trying to print their bytes.

Native `quartus/linux64/quartus_sh` is captured with hash
`5740e47134517eac623c1391837761d12ab18b99a2db78be790cf764af3e3bce` and RUNPATH
`$ORIGIN:$ORIGIN/../../qcore/linux64`. Its direct NEEDED list is captured, not resolved.
The shell-facing quartus/bin entry is a different bound identity. Prior memory process
listings show Java and `quartus_sh --ipc_sh` but truncate `-cp`; they cannot supply
missing mailbox classpath evidence. The new receipt captures **no qsys/lib files**.

The next native query uses the **48 distinct direct NEEDED names** already present
across the launchers/Java/quartus_sh and a closed root list, capped at 100 matched
files with no recursive closure expansion. Record every candidate and symlink chain.
OS library symlinks may be normal loader behavior but the unchanged harness rejects
symlinked binding paths: keep reference/target evidence distinct, do not silently
rewrite argv or insert links into a supposedly valid binding. Any incompatible
identity-policy change needs separate review.

The 294 index candidates mostly include unrelated pkgIndex files. The relevant common
index identifies altera_terp 1.0's provider, but no captured package-ifneeded/provide
for qsys or sopc establishes the required API compatibility levels. `::qpm::pkg::qsys`
is an archive utility package, **not** the qsys system API. One bounded launcher/JAR
manifest/provider-resource query should identify classpath/configuration and API
version declarations if statically available. No Java, jar command, Tcl, ldd or loader
execution is needed to read archives. Missing static API implementation visibility is
not a demand to prove successful Tcl execution before authorizing its first experiment.

## First bounded scratch experiment: authorization versus acceptance

After the finite batch, an independent reviewer should decide whether known identities,
provider declarations, exact command/project/environment, and explicitly recorded
residual loader uncertainty support the first controlled scratch experiment. **Do not
require already successful project opening or API execution as a circular condition.**
If that reviewer requires a separate loader-only probe, it must have its own approved
scope; no ad hoc invocation or modification of this harness is authorized here.

Pre-experiment authorization must explicitly settle the earlier reports' ambiguous
“acceptance before execution” wording: a true review flag would attest review of the
bounded experiment and its residual uncertainty, not fabricated past success. No such
flag is changed here, and no dynamic closure is claimed. If policy really demands
complete dynamic closure before authorization, escalate that policy conflict rather
than setting false evidence to true.

Installed help already establishes option spelling; generate's “all IP” wording is
reconciled with the 26.1 manual's immediate-parent/single-batch contract, not taken as
proof of selectivity. No all-IP, synthesis/simulation, implicit project, bypass or FIM
hook may be added. The existing first stage and each subsequent saved-state barrier
must reject non-target changes, changed QPF/QSF, wrong selected public/core versions,
parameter drift, incoherent persisted boundaries, validation/log errors or redirection
to original/work03 paths. Preserve failed claims; no cleanup/retry is automatic.

Actual API behavior under package 26.1, device-only QPF/QSF acceptance, resolved catalog
selection, serialized deltas and selective upgradeability are **experimental acceptance
items**. Later standalone AND nested generation, real nonconstant waitrequest,
readdatavalid, both upstream requesters and shared global reset remain separate work.

Side-effect approval is still absent: name the concrete process/write observer or
isolation policy, permitted scratch caches/logs and license behavior, stop/retain policy
for unexpected process or external writes, and current tmux context. The harness is not
an OS sandbox or timeout guarantee. Closed environment excludes override/Java injection
variables; retain it. Instructions suggest the absolute license pathname; readability
and a deliberate LM_LICENSE_FILE addition need review, so candidate env is unchanged.
Do not inherit Questa variables or copy shell exports into scratch HOME.

### Mandatory actual XML review: duplicate roles

Quality's minor finding remains live: `migration.py:183` builds a role-keyed dictionary,
which can hide an earlier conflicting duplicate waitrequest. Before **each actual
saved-state acceptance**, independently count AVMM roles and reject duplicates in
both orders in the decoded leaf locked boundary and both child proxy representations;
also check IP-XACT logical/physical mappings and physical ports for uniqueness,
1-bit output direction, nontermination and consistent real connection. Review parent
proxy/external boundary preservation too. A passing harness helper is not sufficient.
This task neither edits that helper nor claims actual migrated XML has passed review.

## Deliverables and verification

- `next-evidence-request.json`: 10 exact candidates, five bounded queries, separate
  receipt-path repair, seven deferred/conditional fileset resources, explicit caps
  and a **single-pass stop/review rule**. It is a request, not permission to collect.
- `proposed-binding.json`: six observed runtime/tool identities and fourteen catalog
  identities, plus live receipt/instructions evidence. Custom component hashes remain
  in unchanged source_hashes. Inactive memory endpoint is not added. The four original
  mailbox catalog entries remain, including software Tcl for baseline compatibility.
  No hashes were guessed. The missing remote help receipt remains deliberately bound;
  this candidate cannot pass full preflight until its deployment gap is resolved.
- All template scope fields, QPF/QSF, argv, source/harness hashes and environment were
  programmatically checked equal; only the three hash dictionaries were augmented.
  Every review flag remains false, reviewer null, readiness false. Every inserted
  installed identity was checked against a stable, no-links live record.
- Python assertions passed for exact request-path deduplication/absence from the
  existing receipt, 24 XML leaves, and DEBUG/HAS_STREAM/HAS_OFFLOAD values. All embedded
  full-text record hashes reproduced; source/harness expected comparisons have no
  additional mismatch. JSON writes passed tool lint/verified-byte checks.

No remote access, vendor/Tcl execution, build, commit, harness/template/BSP/work03 edit,
production staging or approval occurred. Only the three new review/request/candidate
files were created in this qualification directory.
