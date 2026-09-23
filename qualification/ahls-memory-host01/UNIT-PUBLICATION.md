# Inert memory-frontend milestone publication

Publishes only the independently reviewed and parent-accepted additive memory-AFU identity/capability frontend and completed inert API tests. [Parent acceptance](UNIT-ACCEPTANCE.md), [review](independent-review01.md).

Per-file limit: 2,000,000 bytes. Raw transport archives, embedded-source launchers, executable images, installed/vendor runtime libraries, SDK captures and native/container work remain local. Omitted frozen-context members remain bound by their exact size/hash in the publication inventory and review manifest; existing tracked prerequisites are not duplicated. The two `unit-*-process-records01.json` files are byte-identical relocations of the frozen build-local JSON testcase records, not re-execution or rewritten results.

No source-map, native-link, AHLS-environment or hardware gate is accepted by this publication. The Python assertion-optimization limitation remains recorded in the review and acceptance. Mutable checkpoints are deliberately excluded.
