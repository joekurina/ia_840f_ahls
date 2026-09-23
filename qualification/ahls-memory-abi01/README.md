# AHLS memory ABI source evidence

The [saved source review](ABI-SOURCE-REVIEW01.md) resolves the generated component's CSR and pointer encoding while identifying a write-retirement blocker. See the [parent disposition](RESULT-ACCEPTANCE.md) for the narrow accepted scope.

## Artifact policy

The default repository artifact cap is 2,000,000 bytes. This package also retains the full captured AHLS support RTL and its compressed transfer **locally only**, regardless of size; those vendor-library captures are not added to the public evidence commit. Their local paths, byte counts and SHA-256 values are bound by [verified-source-manifest01.json](verified-source-manifest01.json). Original generated-inventory membership was checked for every member. The collector [collect-rtl01.py](collect-rtl01.py) records the exact finite acquisition set.

Local-only archive: `result01.json.gz`, SHA-256 `433f3bb0135bb3c955a1598c03237d52fe230d09f8fe93e25210f7777a2ea263`. Local extracted root: `artifacts/build/mmhost_ia840f.report.prj/`. The report's file/line citations refer to those retained original bytes. The public commit is the research record, not a self-contained redistributable AHLS library or build package.

No FPGA access, AHLS regeneration, Quartus execution, or DDR simulation is part of this source acceptance. DDR simulation remains **SKIPPED BY USER**; hardware qualification is open.
