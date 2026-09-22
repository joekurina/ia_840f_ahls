# Guard02 component acceptance

**ACCEPTED — experimental guard component only.** [SPEC](spec-review01.md) PASS and [QUALITY](quality-review01.md) APPROVED are independently complete and consumed. [Parent verification](parent-consumption01.json) rechecks the seven component inputs,25 protected bindings, exact predecessor diffs, original helper prefix and saved36-case outcomes. The parent did not claim another replay at this consumption.

- Manifest SHA256: `35417e3c6c7e46c87d2dca78cf09602c5d9646c2f0bc3a816af5ce4d76f273df`.
- Helper SHA256: `4967de098cd857a936ccaeb16b22092259872292488ca44d5bce46b594af8bdc`.
- SPEC SHA256: `d51a86383b068360352a843cf51700ef52e8e2d5311e8b1634c7f19f0f14ea5b`.
- QUALITY SHA256: `6b2b89079870d81aaaa0683630a685f5999579a820edcea13de539b4f723a04a`.
- Parent consumption SHA256: `ff15bf1e3538775b29de99a3df278a47389c49f3a12181ff9f592aafa4d28e0c`.

The component separates output driving association from explicit clock definition, permits only the expected upstream master, creates once with the exact modern divide-by-two grammar, and rejects unexpected source/target/master/ratio/period/waveform/propagation. The F1 successor logs/flushes the actual postcreation pin count before rejection. Created state persists and re-entry is denied after failure. Both independent reviewers replayed the unchanged36-case inert harness with rc0, empty stderr and complete saved-output equality. This proves tested control flow, not Quartus semantics or insertion-time state.

The [rejected predecessor](../guard-spec-review01.md) and its frozen files remain BLOCKED F1 provenance. Original4865-byte helper functions are retained unchanged; `apply` is not an approved future entry. Future preparation must select this guard02 helper, invoke `apply_v2` at the normal integration-SDC insertion point and `verify_created_v2` after full SDC. Actual full prepared bytes still require fresh SPEC→QUALITY→parent acceptance and a separately inspected one-use issuer.

**Not accepted here:** unfinished query components, assembled A/B package, clock-only domain coverage, native execution, maintained top.sdc repair, build readiness, timing, hardware or mission completion. No experiment04 remote preparation or native authorization exists. `ready_for_build=false`. All prior native attempts remain spent; experiment03's candidate remains blocked. Work14's independent EMIF1 hold/DRC, matching-persona and hardware qualification blockers remain.
