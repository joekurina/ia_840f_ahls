# IA-840F Flash Recovery — Vendor-Image Restore + Correct W13 Reflash Path

Date: 2026-09-19/20 (PDT) — Workstation Agilex7Workstation (100.101.227.97)

## Situation

After flashing our W13 bare `ofs_top_user.rpd` (6,369,280 B) to P1 @ 0x04000000 with
`bw_agilex_flash_programmer`, the card disappeared from PCIe entirely across multiple
cold power cycles (DID 12ba:0037 / no endpoint; root port 4e:00.0 BIOS-hidden).

## Root cause (established)

1. The vendor's known-good flash image (`ia840f-ofs-23.1-2-flash-image.rpd`,
   8,478,720 B) is a **full flash layout image**, not a bare bitstream rpd.
2. Quartus-native `quartus_pfg -c <sof> <jic> -o device=MT25QL02G -o mode=ASX4
   -o flash_loader=AGFB027R25A` produces a JIC whose map is:
   - `BOOT_INFO 0x00000000 – 0x001FFFFF`
   - `P1         0x00200000 – 0x009B6FFF`
   (verified via generated `.map`; checksum 0x9872261C for the vendor SOF)
3. The SDM requires a **self-consistent BOOT_INFO + P1 layout**. A bare rpd written
   into the OLD map's P1 slot (0x04000000) does not boot. Additionally, the FPGA
   must configure **during host POST** (cold power cycle); a post-POST JTAG/BMC
   reconfig cannot enumerate on a BIOS-hidden root port.

Note: the vendor tree's `.pfg` recipe files under
`/home/uwb_student00/IA-840f/IOFS_BUILD_ROOT/ofs-ia840f/work-ofs-23.1-2-build/syn/syn_top/`
are dead symlinks to `/home/testfpga/...`; the options above were derived from
`quartus_pfg` documented options and validated by the generated map + successful boot.

## Recovery sequence (all RC=0 unless noted)

1. Built vendor JIC from vendor SOF:
   `/home/uwb_student00/IA-840f/IOFS_BUILD_ROOT/ofs-ia840f/work-ofs-23.1-2-build/syn/syn_top/output_files/ofs_top.sof`
   → `/tmp/fim13-gates/vendor_recover.jic`
   SHA256 `91838954740346724d05c267d265899c46200a1483113e97ce0f8904d8778ec9` (268,435,713 B)
2. JTAG-programmed it (erase+program+verify, 8m24s, 19:39:30–19:47:48, RC=0, 0 errors):
   `quartus_pgm -c "IA-840F [1-3.2]" -m JTAG -o "PV;/tmp/fim13-gates/vendor_recover.jic@1"`
   (log /tmp/fim13-gates/vendor_jic1.log — lost in reboot; summary preserved here)
3. BMC reconfig attempt (post-POST): `bw_bmc_configure -i USB -d USB:0 fpga_load -c User --force`
   → FPGA configured ("Configured Normal") but no PCIe enumeration (root port hidden
   since POST) — proved enumeration requires config during POST.
4. Cold power cycle via `sudo -n reboot` (host idle, NOPASSWD sudo now available;
   all reboots on this host are cold power cycles).
5. **Post-boot: card restored** — `0000:4f:00.0 [8086:bcce]` dfl-pci bound,
   `0000:4f:00.1 [12ba:0070]`, LnkSta x16 @8GT/s, FME Bitstream 5.0.1,
   PR interface `c1459fb4-d7e3-5539-a400-2140717fe862`, PR slot empty (GUID zeros).

## W13 reflash with correct path (in flight / subsequent)

- Our JIC: `…/work_ia840f_fim_13/syn/board/ia840f/syn_top/output_files/ofs_top_recover.jic`
  SHA256 `2576dde0cbf2f36b02cedb234952dd8654f61bc8edde415a657ed11c34d6d968` (268,435,713 B)
  built from our `ofs_top.sof` (SHA256 `fe566004accde825cb910e69fd458f87669ad2c67f0c7f36e81a115f57298c37`,
  7,846,742 B) with identical device/mode/loader → same BOOT_INFO + P1@0x00200000 layout.
- Programmed via JTAG `PV` @ FPGA tap index 1 (same command as vendor recovery).
- Activation: cold power cycle (required — BIOS-hidden root port means no post-POST enumeration).

## Failed alternative paths (do not retry)

- `quartus_pfg` rpd→jic conversion: crashes; JIC must be built from a SOF.
- RSU `rsu_image_update -a 0x04000000` with bare rpd: configures but PCIe never retrains.
- JTAG-configuring SOF directly into CRAM then rescanning: root port hidden, no PERST path.
- `bw_agilex_flash_programmer -i PCI`: requires BWVFIO server / card on bus (unusable while
  card absent; also the tool whose bare-rpd write caused the outage).
- BMC log readback: BMC 1.3.6-2 does not support log reading.
