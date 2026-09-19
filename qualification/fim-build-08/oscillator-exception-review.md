# Work08 oscillator-exception applicability: bounded independent review

## Disposition

**S1 remains an applicability evidence gap, not an established failure. Leave the running Work08 inputs and flow unchanged. Do not add a speculative clock-group exception.** The bounded installed-source inspection did not establish that TRS oscillator insertion is conditional only on INCLUDE_HSSI, nor that PRESERVE_UNUSED_XCVR_CHANNEL ON excludes or requires it. A single post-fit timing-netlist query is the necessary discriminator. RTL absence is not evidence of absence for this tool-inserted resource.

The standalone 6.400 ns qsfp reference-clock correction is not contradicted by this finding. This review does not justify stopping/restarting that experiment or relaxing timing acceptance.

## Evidence and provenance

Paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new` unless absolute. Read `qualification/fim-build-08/spec-review.md` in full and inspected the candidate patch. Independently hash-matched the following local supplemental sources against `qualification/fim-build-08/remote-evidence/compile-authorization.json` → `source_sha256`; its SHA256 is `81ebc5ae0c4811d3618af78dd8db034a7310bad7f2bbb18272224c66763f9bf7`.

| Evidence | Location / SHA256 |
|---|---|
| Removed unqualified exception | `ofs-agx7-pcie-attach/syn/shared_config/eth_top.sdc:17`; `d0dd24b81e87ba23da0d4d98af42ed8468492d3f0d7353fb57509101a7254183` |
| Other existing clock groups | `ofs-agx7-pcie-attach/syn/shared_config/top.sdc`; `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |
| Actual device / preservation / disabled macro | `ofs-agx7-pcie-attach/syn/board/ia840f/syn_top/ofs_top.qsf:11,20,103`; `30149d42e1c4f17bd4f9222fb9b48a55c783ba6dd9169b3364eddc811dd568fb` |
| Wholesale SDC replacement and clock retained | `qualification/fim-build-08/candidate.patch:47-60`; `2628add9fb97e1bfb061a24a443dd7628d7b9b7a68df6d9c286d20d787865527` |
| New reference SDC, recorded overlay hash | `qualification/fim-build-08/candidate/syn/board/ia840f/setup/bti_refclk.sdc:1-2`; overlay records `01b76a80f664c4ec0bf553874c68c7f71878642f205080e29727e50ce71c3cac` |

Device is AGFB027R25A2E2V; preservation is ON and INCLUDE_HSSI is commented out. Candidate patch lines 36–44 carry CC19/BW19 and 156250000 Hz, with modern BTI TRUE. These are configuration evidence, not an insertion-rule proof.

## Braces: suspicious does not mean harmless

Removed line:

```tcl
set_clock_groups -exclusive -group {get_clocks ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk}
```

Tcl braces suppress command substitution: this does not execute `get_clocks`. Crucially, that alone does **not** establish a no-op. Installed TimeQuest source emits braced lists of clock names as valid group arguments, so this inherited argument may be a two-name list containing the literal `get_clocks` plus the actual oscillator clock name. Do not dismiss the oscillator token merely because the first token is suspicious; equally, do not assert whether unmatched-name handling discards only that token or the whole group without parser/report evidence.

Read-only installed precedent on verified `Agilex7Workstation`, UID 1000:

- `/opt/altera/26.1.1/quartus/common/tcl/internal/qsta_helper.tcl`, SHA256 `c60d39bd7b33dc5aedfd745e65a1e1fb077584e6b8248eb493980233dbf60ebc`.
- Lines 314–318 describe generation of a clock-group SDC. Lines 378–389 emit `set_clock_groups -exclusive` and `-group { $clock_group($key) }`.
- Lines 1436–1442 describe cutting clock transfers, iterate `get_clocks`, obtain a clock name with `get_clock_info -name`, and issue a single `set_clock_groups -asynchronous -group $clk_name`.

This establishes installed name-list and single-group precedent, not the complete native parser grammar or a device-specific justification for an exclusive cut. If an exception is eventually demonstrated necessary, use an explicitly resolved, nonempty clock collection and reviewed relationship semantics; do not blindly copy the inherited text or change exclusive to asynchronous without justification.

## Bounded inspection and its limit

Read workstation `/home/uwb_student00/quartus_26/instructions.md`. All remote operations used independent window `osc_review` under owned tmux session `ia840f_mailbox_monitored_01`. Inspected installed `common/tcl`, `common/help`, and `common/htdocs`, limiting individual files to 3 MB, for the exact oscillator names and `proc set_clock_groups`; no matches. This is only a bounded negative source search, not proof about compiled fitter behavior.

Also inspected static printable strings in `/opt/altera/26.1.1/quartus/linux64/libtsm_sta.so`, SHA256 `7b499b158c007af933578aca5701bd1a553d9ce2da88eee188a64acf1d4e6aed`. The selected strings only exposed `sta_auto_set_clock_groups_exclusive` symbols (byte offsets 15577966 and 15587482), not usable command grammar or insertion conditions. No vendor executable was invoked. This does not warrant further installation-wide archaeology.

## One precise follow-up after the fitter database is ready

Use the already assigned monitor's existing fit/STA reports first; do not duplicate polling. If they do not close S1, obtain one bounded read-only timing-netlist interrogation in a separately authorized post-run context, never while the current project is running:

1. Bind the completed Work08 revision, part and loaded SDC set. Confirm normal generated/IP constraints have been read and the netlist updated; otherwise an empty clock collection is inconclusive.
2. Enumerate all clock names containing `ALTERA_INSERTED_INTOSC_FOR_TRS` or `divided_osc_clk`, including hierarchical variants. Query the exact clock with `get_clocks {ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk}` and record collection size; enumerate each matching clock's name, period, source/target and generated/master relationship. Also inspect fitted resource names for the inserted oscillator: a present resource without a clock is not a clean absence result.
3. For each matching clock, report transfers to/from all other clocks, effective clock-group/false-path exceptions and their origins, and any ignored/unmatched constraints. Determine whether there are actual timed cross-clock paths and whether generated/vendor constraints already handle them. Obtain installed `set_clock_groups` command help in that permitted context to settle name-list/unmatched-token handling and single-group exclusive semantics, rather than evaluating the removed exception on the active project.
4. If neither the fitted resource nor any associated timing clock exists in the complete netlist, the removed exception is inapplicable to this exact configuration. If it exists but no cross-clock paths exist, or equivalent effective constraints already cover them, document that narrower redundancy finding. If real unconstrained relationships remain, source/functional evidence of their relationship is still required before proposing any cut; mere oscillator existence is not permission to suppress paths.

**Acceptance remains unproven until that result.** No build, simulation, installation, hardware operation, project edit, inventory modification, gate execution, commit or push occurred. No existing fit/STA reports were polled. DDR simulation remains SKIPPED BY USER. The sole project artifact created by this review is this file. An initial local bare `python` command failed before remote execution; subsequent inspection used `python3`.
