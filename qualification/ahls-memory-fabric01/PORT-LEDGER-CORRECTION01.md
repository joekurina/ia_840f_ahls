# F-01 port-ledger correction

The frozen top-ports03.json and RESULTS03.md reported243ports. Independent review and parent parsing show244uniqueports/11interfaces. The old parser required a trailing comma and omitted only final `input wire [1:0] bank_out1_ruser` (native top HDL line250, instanceconnection497).

[top-ports04.json](top-ports04.json) supersedes only that ledger/count. It is regenerated from the actual HDL including the final declaration, matches native SOPCINFO name/direction/width for every244port, and preserves all243original entries. No RTL, native artifact or frozen review-package member was changed. This is an evidence correction, not a repaired missing hardware port or reason to rerun native generation.
