# Native Quartus25.1 AHLS memory-IP import

[Accepted import/generation gate](RESULT-ACCEPTANCE.md), [independent review](independent-review02.md), [current state](CURRENT.md), [native results](RESULTS02.md), [interface/source ledger](interface-ledger02.json), and [capture manifest](import02-manifest.json) establish this completed stage, not full HDL elaboration, AFU integration or hardware qualification. Later elaboration results are a separate milestone.

The2,000,000-byte artifact cap applies. Vendor HDL source captures, compressed transfer payloads and payload-bearing launch scripts remain local-only even below that cap. Small native metadata, logs and generation reports are published unchanged; .gitignore preserves this separation. Raw files are under artifacts-import02/, with exact per-member hashes in the manifest and frozen review-package02.json. The archive SHA256 is4e86b60a26c5cd0ec19557d5aa4cde3d2fc4c31a3b7b3572416615568cb6a705. Failed probe/import attempts are retained separately. No license bytes or installed runtime payloads are tracked.

The standalone exported-interface system is not a board image to flash. DDR simulation remains SKIPPED BY USER. The completed Work21 FIM and original AHLS generation remain preserved.
