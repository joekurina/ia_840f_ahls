# IA-840F OFS2026.1 / AHLS Support Guide — LaTeX source

The manual describes OPAE **2.14.0-3** only. It includes the final four-way
hardware results: 40,000 comparisons, four native exits of zero, and verified
private runtime/core/plugin binding. The scoped VF warning remains a limit.

## Build

Run `python3 bootstrap_tex.py` to install the checksum-bound Tectonic0.17.0
compiler locally, then:

```sh
XDG_CACHE_HOME="$PWD/.cache" .toolchain/tectonic --keep-logs \
  --keep-intermediates IA-840F_OFS2026.1_AHLS_Support_Guide.tex
```

The source bundle includes the cited-source ledger with original IDs, the
Rocky9.8 DFL compatibility patch and the configuration-only OPAE module lookup
patch. Both patches apply to the exact pins stated in the guide. The OPAE patch
changes module search configuration, not programming functions or FPGA logic.

Local engineering-evidence links refer to the project archive. Proprietary
vendor guides and licensed tool installers are not redistributed here.
Public source URLs remain in the generated bibliography. The original BittWare
support guide was read as a structural reference and left untouched.
