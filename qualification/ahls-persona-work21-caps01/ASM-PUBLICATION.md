# CAPS01 ASM milestone publication

Publish only the independently reviewed and parent-accepted ASM gate. [Acceptance](ASM-ACCEPTANCE.md) and its FINAL review define the boundary. No full Design Closure, live hardware, deployment, runtime PR or durable boot acceptance. Other stages retain their own dispositions; the new host frontend is not included.

File cap: 2,000,000 bytes. Raw transport archives, expanded generated runners, binary images/containers and installed runtime captures stay local with exact sizes and SHA256 references. Payload-free metadata projections are not executable replacements; reconstruction after resolving external inventory fields was checked equal to the original with base64 bodies removed. No splitting of raw payloads to evade the cap.

Only explicit allowlisted files are staged. Immutable native settings/report/log whitespace may be retained through exact-path/hash-bound exceptions in ASM-PUBLICATION-AUDIT01.json; authored prose/code must be clean. Preserve unrelated edits, all frozen packages, and pending host work. Verify every committed blob and local/tracking/actual remote-main agreement. No secrets, licenses or programming bytes are published.
