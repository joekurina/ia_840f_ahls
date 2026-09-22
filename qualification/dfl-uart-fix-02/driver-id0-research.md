# Disabled-UART ID-zero convention: captured DFL source research

**Finding: statically supported, not final acceptance.** With the existing enclosing feature-device context and unchanged valid chain/resource fields, a **private, DFHv0, ID 0** placeholder is accepted by the captured parser and remains traversable. It does **not** match the captured `8250_dfl` driver through either its type/ID or GUID alternative. ID zero does not make the placeholder disappear: it can still become a generic DFL device with an MMIO resource.

## Evidence roots and binding

All citations below refer to ordinary local files; aliases expand as follows:

- `N` = `/home/joe/Projects/Thesis/AHLS/new_bsp/new`
- `D` = `N/qualification/source-resume-01/remote/home/uwb_student00/linux-dfl-backport`
- `W` = `N/qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13`
- `R` = `N/ofs-agx7-pcie-attach`
- `V` = `/home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f`
- `A` = `/home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/oneapi-asp/ia840f/hardware`

The recorded checkout HEAD is `1d01b806f5bd7c65e2e46c37d43ba4aa6a4a047c`. Existing evidence reports installed and checkout `8250_dfl.ko` byte-identical, while preserving unrelated dirty checkout files (`N/qualification/dfl-uart-fix-01/REPORT.md:17–24`). This research uses the captured source, not HEAD alone or a fresh live/module verification. Capture provenance is documented at `N/qualification/source-resume-01/REPORT.md:24–37`.

## Vendor precedent and exact proposed identity

- Disabled UART selects `.FEAT_ID(12'h0)`, revision 0, next `0x10000`, EOL 0 (`V/src/afu_top/afu_top.sv:604–630`). Its dummy emits private type 3 and DFH version 0 (`V/src/afu_top/dummy_csr.sv:196–211`). Both standard and USM QSFs comment out `INCLUDE_HPS` and `INCLUDE_UART` (`A/ofs_ia840f/build/ofs_top.qsf:101–102`; `A/ofs_ia840f_usm/build/ofs_top.qsf:101–102`). This is concrete vendor source precedent, not a claim about every vendor image.
- The inspected maintained disabled branch advertises `12'h24` and passes generated next/EOL constants (`R/src/board/ia840f/afu_top.sv:729–755`). The shared dummy defaults to private type 3 and emits zero DFH-version bits (`R/src/afu_top/dummy_csr.sv:12–17,197–211`). Restoring only this instance's ID to zero preserves those fields.
- W13 places UART at `0x60000`, the following PR endpoint at `0x70000`, and supplies UART next `0x10000`, EOL 0 (`W/src/includes/fabric_width_pkg.sv:35–39,110–114`). A local Python calculation from these source fields gives old/new DFH **`0x3000000100000024` → `0x3000000100000000`**, XOR `0x24`, successor `0x70000`. These are derived values, not MMIO readings or executed RTL.

## Parser and traversal, not merely identifier comparison

1. **Dispatch is by DFH type.** `parse_feature()` routes type 3 to `parse_feature_private()`, not the FIU parser (`D/drivers/fpga/dfl.c:1533–1556`; type constants at `D/drivers/fpga/dfl.h:71–84`). The private parser imposes no ID-zero rejection or skip. It requires an existing feature-device context for its DFHv0 path, then calls `create_feature_instance(..., 0, 0)` (`dfl.c:1403,1506–1524`). Implementation subtlety: this context/version check reads the current mapped base DFH, **not** the private feature at `ofst`; retain the enclosing chain context.
2. **Zero is retained as a real private feature ID.** The zero argument means “derive ID from header”; `feature_id()` returns the raw ID for private features. There is no subsequent `!fid` rejection (`dfl.c:1064–1077,1286–1323`). Successful creation appends the feature and increments the feature count (`dfl.c:1380–1389`). Iteration is count-bounded, not zero-ID-terminated (`D/drivers/fpga/dfl.h:440–442`).
3. **Walking past zero remains enabled.** After parsing, `parse_feature_list()` advances by `DFH_NEXT_HDR_OFST`; it stops on EOL or a **zero next offset**, not a zero feature ID (`dfl.c:1559–1596`). Size derivation may inspect subsequent interface headers and still performs size/resource checks; errors remain possible independently of ID (`dfl.c:1038–1061,1291–1297,1311–1312`). The preserved `0x10000`/EOL-0 pair therefore retains the source-described successor, conditional on the unchanged surrounding chain being valid.
4. **Not an ignored/nonexistent device.** Features are copied with their IDs and resources; ordinary features can reach `dfl_dev_add()` (`dfl.c:871–910,489–510`). DFHv0 ID zero selects none of the feature-specific IRQ-register cases (`dfl.c:1130–1197`). This does not remove enumeration-time MMIO or resource allocation.

## Why the UART match is avoided

- `8250_dfl` has one nonterminal entry: **`FME_ID`, feature `0x24`, GUID `9e6641a6-ca26-cc04-e1df-0d4ace8e486c`** (`D/drivers/tty/serial/8250/8250_dfl.c:151–169`). Bus `type` is the enclosing FIU classification (`FME_ID = 0`), **not** the DFH private-type value 3 (`D/include/linux/dfl.h:15–30`; `D/drivers/fpga/dfl.c:419–422`).
- Matching is **valid equal device GUID OR equal bus type and feature ID**, not an AND of all three (`D/drivers/fpga/dfl.c:246–277`). Thus an FME-context ID `0x24` can bind without a UART GUID; ID zero fails that pair comparison.
- The GUID alternative also fails here: feature/device structures are zero-allocated and GUID extraction/copying occurs only for DFHv1 (`dfl.c:1314,1324–1374,831–837,891–892,398,433–434`). DFHv0 consequently has a null device GUID, which is explicitly invalid (`D/drivers/fpga/dfl.h:510–520`). Arbitrary dummy scratchpad bytes are not interpreted as a DFHv0 GUID. The captured UART probe therefore is not selected by this bus matcher; its missing-CLK_FRQ path is not “fixed” with fabricated parameters (`8250_dfl.c:35–62,111–125`).

## ID-zero / reserved-feature pitfalls

- **FIU ID 0 is different.** Raw FIU ID zero denotes FME, but only under DFH type 4. `feature_id()` maps FIUs to internal header ID **`0xfe`**; private ID zero remains zero. Internal header and AFU reservations are **`0xfe`/`0xff`**, not zero (`D/drivers/fpga/dfl.h:37–55,71–84`; `dfl.c:1064–1074,1455–1488`). Header special handling checks `id == 0xfe` (`dfl.c:547,900–910`). Do not substitute those reserved values, change type to FIU, or zero the entire header.
- **Driver-table terminator is not DFL termination.** Both bus and internal feature-driver tables stop at zero ID plus invalid/null GUID (`dfl.c:268,607–615`). The feature list itself does not. Conversely, a driver-table entry with ID zero and a valid GUID is traversed and can match through the ID alternative even if GUIDs differ. Therefore this analysis establishes **no 8250_dfl match**, not a universal promise that no possible driver can bind ID zero.
- **Keep DFHv0 and surrounding metadata unchanged.** A DFHv1 feature carrying the UART GUID could still match despite changing its ID. Zero next-offset, early EOL, invalid resource sizing or missing enclosing context can still prevent useful traversal. ID zero is not a generic safety mechanism or exemption from these checks.

## Limits and retained source identities

Core `dfl.c`, both DFL headers and `8250_dfl.c` were present and inspected. The captured `drivers/fpga` C-file inventory lacks the FME implementation; this is not a complete audit of all internal FME consumers, other DFL drivers or userspace. No formal specification-wide claim that ID zero is universally reserved/standardized is made. Installed core-module identity and present hardware state were not independently established here.

Local SHA256 checks of the inspected driver sources:

| File under D | SHA256 |
|---|---|
| `drivers/fpga/dfl.c` | `2eb1bad280e7be5f6714955868a651559f59affef02999b05c2715aa2fb15839` |
| `drivers/fpga/dfl.h` | `6ad78e19943d23b55d72be9d3edacf366d234ccefce5a620568e8ade53ed60ad` |
| `include/linux/dfl.h` | `351a3d1223595a82219730c431e738cc40588f4baec50e04da6c0ca825278d36` |
| `drivers/tty/serial/8250/8250_dfl.c` | `89e65242ba3e75bdca602db5b29fae193393852c41ddf36de1dc0ac5fac7fa11` |

Only this report was written. No source patch, build/install, remote access, driver/OPAE execution or loading, hardware/sysfs/MMIO access, or git mutation was performed. The finding supports the parent's narrowly scoped vendor-convention correction and subsequent offline review; it does **not** establish live traversal, deployment safety, timing, UART function or final acceptance. Existing hardware authorization/recovery blockers remain unchanged.
