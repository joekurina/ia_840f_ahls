# CAPS03 mapped synthesis completed

Native Quartus 25.1.0 Build129 synthesis completed through the direct CMake
`synthesis` target. Native/CMake/effective/outer exits are all zero; no diagnostic
errors, timeouts, live owned descendants or preservation failures. See
[synthesis receipt](synth01-outer.json), [hash-bound compact record](SYNTHESIS-RECEIPT02.json),
[source selection](source-selection01.json)
and [native summary](synth01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.syn.summary).

The selected application UUID is `d48dde9f-f551-578d-8bb0-69483ac95ec6`.
The real top compiled; the completion entity remains in the native resource table
with 581 combinational ALUTs and 246 dedicated logic registers. The reset integration
is also present. The partition table labels `green_region` Reconfigurable; retain
Critical20580 rather than interpreting it as proof PR is absent. Critical19854
reports explicit initial values and remains subject to implementation review.

Synthesis estimates whole-project usage at 98863 ALMs and 257871 dedicated logic
registers, including the imported static shell. These are not isolated monitor or
post-fit costs. The generated kernel/fabric and accepted static QDB were reused.

No warning suppression or constraint repair was made. The native footer reports
244 warnings, while [the full log occurrence ledger](synthesis-warnings01.json)
contains 457 warning/critical-warning occurrences (436 distinct exact entries).
The [parent verification](synthesis-review-verification02.json) confirms the native
stage split: the first 213 log diagnostics exactly match A&E's 213 warnings, in
order and text; the remaining 242 warnings plus two critical warnings match the
244-warning footer. The full-log population remains 457 occurrences / 436 distinct
tuples. This reconciles these captures without asserting an undocumented general
Quartus counting rule. Review `deleg_9fda88cf/task-0` gives bounded synthesis
acceptance; no identified completion-datapath defect requires interrupting fit02.
The direct source-file warning filter did not name the newly authored monitor or
reset adapter, but DRC and initial-state findings do implicate application reset
and guard logic; [the bounded review](SYNTHESIS-ACCEPTANCE02.md) retains them.
The synthesized DRC still reports reset-usage/duplication findings, including the
application reset's mixed CLRN/SCLR/ENA fanout. Those require the actual fitted
reset/timing review; this stage does not waive them or certify reset safety.

[Fresh-copy preflight](fitprep01-result.json) reverified the completed 5375-file
persona, 602 QDB members and 4374 bound inputs. The fresh fitter uses the existing
stage-role exclusions, protects partitioned/synthesized snapshots and static QDB,
and binds newly named generated clearbox HDL immutably. The removed publication
constraint file is not reinstated. See [role delta](fit01-source-role-delta.json).

This result permits the next offline native fitter experiment. Final 3.000 ns timing,
reset/CDC, deployment, hardware arithmetic and all final system gates remain open.
