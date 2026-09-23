# CSR02 completed setup and synthesis — pending independent acceptance

Completed setup and mapped synthesis have native/effective/outer **0/0/0**; archive/member and source bindings were parent rechecked. Independent evidence acceptance is pending, not inferred from success. [Parent checks](parent-setup-synth-verification01.json), [source delta](source-delta01.json).

- Setup archive SHA256 `40f353c993c53d51235dcac64422b8b85c77652196d01581219a854670cbc997`,7 embedded members. Version/setup commands complete without timeout or surviving owned groups; AFU inputs, generated originals, release and tools unchanged; application header correct.
- Synthesis archive SHA256 `24caf48cc162519ef1a1a0256df76077b2e9f47d22cff15f7937c5e267ba537d`,11 embedded members. Native PID128094/start14846952,2026-09-23T17:39:57.727306Z to17:44:28.242473Z. All four preservation flags true; no diagnostic errors/postflight errors/timeouts/surviving owned groups.
- Parent verified13 embedded authored AFU sources and exact sole changed CSR binding;255 generated identities unchanged;4925 setup entries,851 enumerated copiedDNI exclusions,4345 synthesis critical bindings. Configs are parsed with AST/literal_eval, never imported/executed for inspection.
- Native summary whole-design estimate **96883 ALMs**,**252804 dedicated registers**. These include imported design context; not an attributed green-region-only count. Native report contains four successful partition mappings. Reviewer should inspect partition/entity panels and endpoint register retention directly.
- Native log has **443 warning occurrences**, including indented child messages; footer reports **230 warnings**,0errors. [Full ledger](warning-ledger-synth01.json) does not double-count report copies or assert443 unique defects. Critical20580 importedPR-type wording and19854 initial values remain.
- Synthesized DRC **5 of13 rules failed**: RES-30132(2),LNT-30023(1),LNT-30010(6),TMC-20501(4),TMC-20500(1); all listed waivers0. These are not complete timing/reset/CDC signoff. See raw synthesized and partitioned DRC reports for full rule scope/disabled rules.

The current fitter and eventual final STA are separate; no changed timing pass is claimed. No FPGA/device access. Prior trusted negative timing evidence remains FAIL, and physical/hardware qualification remains incomplete. See [scope](SYNTH-SCOPE01.md).
