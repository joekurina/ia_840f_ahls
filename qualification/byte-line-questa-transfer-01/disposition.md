# Questa package transfer procedure — explicit supersession

This supersedes only the whole-directory transfer instruction in byte-line-questa-01/README.md. Preserve that pinned historical file unchanged.

Transfer exactly the file names listed in byte-line-questa-01/package-sha256.json, plus package-sha256.json itself. The manifest SHA-256 must be ec6800e15dff71f9b57ce51e39111cb1db9b4c55d9683896a7aa00bf1fae8fbe. Verify every entry's size/hash and exact remote file set before execution. Exclude spec-review.md and any subsequent reviews from the execution payload; retain them locally, without deleting or absorbing them into the pinned manifest. Do not loosen runner inventory checks.

Remote transfer/readback/execution must occur inside named tmux. Use a fresh exclusive execution-package directory and separate fresh results directory; no maintained sources or Work04 changes. No simulator execution until review acceptance. All prior execution claims remain unchanged: zero HDL cycles executed, four inert Python tests only, no BSP qualification.
