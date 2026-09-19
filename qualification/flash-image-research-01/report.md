# Flash-Image (.rpd) Conversion Research — flash-image-research-01

Date: 2026-09-19 (PDT)
Operator: Hermes subagent (read-only research; no vendor-tree writes, no commits)
Local tree: `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`
Remote: `uwb_student00@100.101.227.97` (Agilex7Workstation)

Question (from `N/docs/hw-programming-recovery.md` open items, line 94):
how is a `.rpd` flash image produced from our OFS 26.1.1 compile output
(ofs_top.sof), for this card?

## Verdict (short)

**The conversion tool is Quartus `quartus_pfg` (Programming File Generator),
already installed in our 26.1.1 toolchain at
`/opt/altera/26.1.1/quartus/bin/quartus_pfg`.** No BittWare-side tool exists or
is needed to *create* the image; BittWare tooling only *writes* a finished
`.rpd` into QSPI.

Recommended command for our 26.1.1 `ofs_top.sof` (application/user image for
the card's existing factory layout):

```bash
quartus_pfg -c ofs_top.sof ofs_top_user.rpd -o mode=ASX4 -o bitswap=ON
```

- `mode=ASX4` — Active Serial x4 = the card's QSPI (RSU) configuration scheme.
- `bitswap=ON` — produces the bit-reversed ("Big Endian") RPD that
  `bw_agilex_flash_programmer` expects (see §1: the tool bit-flips every byte
  on read; the Altera guide documents `-o bitswap=ON` for the application
  image command).

Caveat before first use (see §5): one open formatting question remains —
whether the flash-image `.rpd` should additionally carry the RSU header
("application image" flavor vs. plain bitstream rpd). This cannot be resolved
from the trees alone; the vendor image is signed/wrapped, so byte-identity
with `quartus_pfg` output is impossible to confirm locally. Verify against the
BittWare **IA-840f FPGA Developer Guide** (portal) before flashing, or
empirically via JTAG-first bring-up already planned (hw-programming-recovery
§2a) + `flash_map`/`rsu-status` checks.

## 1. What the BittWare flash programmer actually does with a `.rpd`

Primary evidence: the installed tool source
`uwb_student00@agilex7workstation:.local/lib/python3.9/site-packages/bw_agilex/tools/bw_agilex_flash_programmer.py`
(bw-agilex-product 0.1.49, from BittWare SDK; `/usr/share/bittware-sdk` only
ships wheels + `bw_ls`/`bw_pip`/`bw_sem_unlock` binaries, no image-creation
tool):

- line 338–341 `def bitflip(data)` — "Reverse the bits in a byte" (LUT).
- line 343–363 `def read_rpd_file(rpd_file)` — "Read an RPD binary file into a
  bytes string, **reversing each byte**"; line 346–347: file must end `.rpd`
  or `.bin` (raw binary; no SOF/POF container accepted).
- line 438–458 `handle_program` — `qspi_erase(addr, len)` →
  `qspi_write_flash(addr, data)` → `qspi_read_flash` → `verify_flash`
  (built-in readback compare; this is why the vendor guide says don't run a
  separate `verify`).
- line 506–528 `handle_erase` — end address rounded up to 64 KB
  (`sector_mask` / `flash_64k_alignment`, lines 515–516).
- line 407–417 `handle_flash_map` — `construct_flash_map()` prints partition
  offsets; **run `bw_agilex_flash_programmer -i PCI -c 0 flash_map` on the
  live card to confirm `User_Image_1` sits at 0x04000000 before our first
  program**.
- `components/sdm_mailbox.py` line 214: `_flash_code = {"23": 0x800000, "24":
  0x1000000, "25": 0x2000000, "32": 0x4000000, "33": 0x8000000, "34":
  0x10000000}` — flash **size in bytes** lookup keyed by density code read
  via QSPI `RDID` (0x9E, line 212); entry "34" → 0x10000000 = 256 MiB = the
  card's 2Gb QSPI part (this is flash geometry, not the partition layout).

**Format semantics:** an `.rpd` for this tool is a raw binary of exactly what
should land in QSPI, except each byte is stored bit-reversed (LSB-first) on
disk; the tool flips it back (MSB-first) at write time. This is the classic
Altera RPD convention, confirmed in the 26.1.1 PFG library strings: "Swap bit
order within a byte of Raw Programming Data File (*.rpd). bitswap = ON|OFF
(default)" (`strings /opt/altera/26.1.1/quartus/linux64/libpgm_pfg_common.so`)
and `RBF|HEX|TTF|JIC|POF|RPD|...` is an accepted output-file type in the same
binary — i.e. 26.1.1 `quartus_pfg` natively emits `.rpd`.

## 2. The canonical SOF→RPD command (Altera documented)

Agilex™ 7 Configuration User Guide, "5.5.2. Generating an Application Image"
(docs.altera.com, doc 683673; verified via cached copy
`/home/joe/.hermes/cache/web/docs.altera.com-ea9afd1487.md`):

```
quartus_pfg -c fpga.sof application.rpd -o mode=ASX4 -o bitswap=ON
```

Same guide, "5.5.3. Generating a Factory Update Image":

```
quartus_pfg -c fpga.sof factory_update.rpd -o mode=ASX4 -o bitswap=ON -o rsu_upgrade=ON
```

The guide states RSU is only supported in Active Serial x4 (ASX4). Macnica
(Macnica/Macnica Altera FPGA Insights, "File format for programming general
purpose QSPI Flash with 3rd party programming writers for Stratix 10 /
Agilex 7", malt.zendesk.com article 900006261163) independently confirms:
RPD with **Bit swap: ON** = Big Endian format required for 3rd-party QSPI
programming; and the RSU example from Altera FPGA Developer Site
(altera-fpga.github.io, "SoC HPS Remote System Update Example", rel-24.3.1)
uses `.rpd` as the RSU user/application image artifact for Agilex 7.

## 3. Flash address 0x04000000 — what it implies about layout

The vendor's own PFG file for this exact card (pristine archive copy
`uwb_student00:"Documents/IA-840f installation/IOFS_BUILD_ROOT/ofs-ia840f/syn/syn_top/ofs_top_pof_flash.pfg"`,
md5 `ba27b31d578e56700603238b9a6580ee`, byte-identical copy at
`N/../old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/syn/syn_top/ofs_top_pof_flash.pfg`)
defines the QSPI map (flash device `CFI_2Gb`, `mode="AVSTX8"`):

| Partition | start | end (max variant `ofs_top_pof.pfg`) |
|---|---|---|
| OPTIONS | auto | — |
| Option_Bits_VAB | 0x00010000 | — |
| Factory_Image | 0x00020000 | 0x381F000 |
| **User_Image_1** | **0x04000000** | 0x77FF000 |
| factory_image_info | 0x07FF6000 | — |
| user1_image_info | 0x07FF7000 | — |
| user2_image_info | 0x07FF8000 | — |
| User_Image_2 | 0x08000000 | 0xB7FF000 |

**So 0x04000000 is literally the start of the `User_Image_1` partition** in
the card's 2Gb (256 MiB) QSPI. Writing our `.rpd` there updates only the user
page; the factory image at 0x20000 (and BMC/flash-info tables at 0x7FF6000+)
are untouched. This matches the ASP README ("update the user page",
`oneapi-asp/ia840f/README.md` line 327–331) and Vollo SDK docs for the same
card (vollo.myrtle.ai, "Programming the Agilex" — `USER_IMAGE` partition
RSU update). The vendor image is 8,478,720 B = 0x816000 ≈ 8.09 MiB — the
user slot 0x04000000–0x07FF5FFF (~64 MiB) and the full 256 MiB part leave
ample headroom for our 8.7 MB 26.1.1 SOF's converted image.

Note the OFS `build_flash.sh` script (same content at
`ofs-agx7-pcie-attach/syn/board/n6000/syn_top/build_flash/build_flash.sh` and
vendor `ofs-ia840f/syn/syn_top/build_flash/build_flash.sh`, verified
identical by `diff`) is the **OPAE/PACSign path** for `fpgasupdate`
(POF → hexout → bin → extract partitions → PACSign); it does not produce a
`.rpd`. It is not our path (we program via BittWare SDM mailbox, not OPAE
RSU), but its PFG files document the same partition map.

## 4. Does the vendor's 23.1-era flow work for a 26.1.1 SOF?

The vendor never shipped a generation script — `flash_image/ia840f-ofs-23.1-2-flash-image.rpd`
(md5 `d2fe879db65d9d7816402f4ef9f24bb6`, 8,478,720 B; shipped inside
`ia840f-ofs-hldasp-2023.1.2-002.tar.gz` alongside the OFS tree) is a
pre-built artifact; no script in the archive references producing it (grep
for `rpd` across all scripts in the vendor OFS tree: zero hits). There is no
"23.1-era script" to reuse — the answer is the direct `quartus_pfg` call.

`quartus_pfg` is a file converter; it reads a SOF's bitstream records and
rewraps them. It is not version-locked to the SOF producer beyond file-format
compatibility, and 26.1.1 supports RPD output (§1) — the same one-line command
converts a 26.1.1 SOF. Since our FIM already compiles under 26.1.1 and the
SOF is a standard assembler output, the conversion is expected to work
unchanged; the only version-sensitive parts are:

- VAB option bits (`vab_option_bits.bin` in PFG inputs; vendor copy at
  `ofs-ia840f/syn/syn_top/vab_option_bits.bin`, md5
  `7c8718723f7984d075a9a635faf5b8c5`) — needed only for the full POF/flash
  image, not for the simple user-image RPD.
- `fme_id.mif` / image-info hex files — only for the PACSign/fpgasupdate path.

For our stated goal (flash user image only, keep vendor factory), the
one-liner in the Verdict is the entire conversion path.

## 5. Residual uncertainty (honest limits)

1. **Application-image vs plain RPD:** the Altera guide's RSU "application
   image" (`application.rpd` via the 5.5.2 command) wraps the bitstream with
   RSU metadata (boot-info/TOC) so the SDM can select it at the user
   partition. The vendor image is signed/wrapped (binary inspection: no SOF
   container magic; nonzero data 0x0–0x815b42 after bit-flip = raw flash
   image with headers, not a bare bitstream; no TOC0 0xAA5555AA magic found
   in either polarity — structure is SDM-signed, not parseable offline). I
   could not confirm from the trees whether BittWare's flow used exactly
   `application.rpd` semantics or added signing. **Action:** confirm in the
   BittWare **IA-840f FPGA Developer Guide** (named as the flash-programming
   reference by the IA-840F Hardware Reference Guide, which says "The latter
   method [SDM mailbox] requires a .rpd file. For more detail on programming
   the flash, refer to the IA-840f FPGA Developer Guide"; pdftotext line
   1434–1437 and 2753–2756 of /tmp/hwguide.txt on the workstation). That
   guide is the authoritative next source if the portal copy differs from
   the plain `quartus_pfg` output.
2. **First-flash safety:** regardless, the image must pass the planned
   volatile JTAG SOF test first (hw-programming-recovery §2a), and
   `flash_map` should be run to confirm the live partition map before the
   first `-a 0x04000000` write. Record output hashes.
3. The OPAE `fpgasupdate` path (build_flash.sh + PACSign) remains an
   alternative for RSU-capable OFS images but is not the BittWare flow this
   card's deployment uses.

## 6. Provenance ledger (hashes & citations)

| Artifact | Path | md5 / size |
|---|---|---|
| Vendor flash image | remote `~/IA-840f/IOFS_BUILD_ROOT/flash_image/ia840f-ofs-23.1-2-flash-image.rpd` | `d2fe879db65d9d7816402f4ef9f24bb6`, 8,478,720 B (local old_bsp copy verified byte-identical) |
| Vendor ia840f flash PFG | remote `…/ofs-ia840f/syn/syn_top/ofs_top_pof_flash.pfg` | `ba27b31d578e56700603238b9a6580ee` |
| Vendor ia840f max-size PFG | remote `…/ofs_top_pof.pfg` (User_Image_1 e_addr=0x77FF000) | `fb99127e298fa77f4fd92e2ce4b2dc18` |
| VAB option bits | remote `…/ofs-ia840f/syn/syn_top/vab_option_bits.bin` | `7c8718723f7984d075a9a635faf5b8c5` |
| Vendor 23.1-2 SOF | remote `…/work-ofs-23.1-2-build/syn/syn_top/output_files/ofs_top.sof` | `84dad02ce4296733f4c12c429ca2c030`, 9,551,870 B |
| **Our 26.1.1 SOF (fim-12)** | remote `~/ahls/new_BSP/work_ia840f_fim_12/syn/board/ia840f/syn_top/output_files/ofs_top.sof` | `8c43d8054a7e2a88dd3151f9720d3aa9`, 8,744,710 B |
| BittWare flash programmer | remote `~/.local/…/bw_agilex/tools/bw_agilex_flash_programmer.py` | bw-agilex-product 0.1.49 (SDK 2025.3.0+/2026.1.0 wheels present) |

Command transcripts: all ssh reads via `ssh -o BatchMode=yes
uwb_student00@100.101.227.97` (BatchMode, plain commands, no tmux needed for
reads), 2026-09-19. Hex/flip analysis of the vendor .rpd performed locally in
Python (session kernel): raw first bytes `a9 12 94 46 0c 00 …`; bit-flipped
(what QSPI receives) `95 48 29 62 30 00 …` — consistent with RPD bit-reversal
semantics, no SOF-magic present.
