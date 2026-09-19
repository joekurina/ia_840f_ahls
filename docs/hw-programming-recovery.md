# IA-840F Hardware Programming & Recovery — SPI Flash Procedure

Status: **planned procedure** (not yet executed). Source: Joe's verified
Rocky 9 setup guide for the vendor oneAPI BSP
(`Obsidian/School/Thesis/IA-840f/Rocky9-Setup-Guide.md`, phases 9–10),
adapted to our 26.1.1 OFS/AHLS flow. All steps run on `Agilex7Workstation`
in tmux as `uwb_student00`.

## Why SPI flash (not just SOF)

Reboots of this workstation **power-cycle the machine**, so a JTAG-loaded
SOF is volatile: it is gone on the next boot. A durable deployment means
programming the **QSPI flash** with an `.rpd` image via the BittWare SDK tool
**`bw_agilex_flash_programmer`** — the card then self-loads on every power-up.

## Preconditions (all currently open)

1. **Validated image to flash.** Our Work12-derived FIM + AHLS AFU, converted
   to the BittWare flash format (`.rpd`). Exact OFS conversion step for our
   tree must be confirmed against BittWare docs before first use — do not
   flash a wrong-format artifact.
2. **JTAG recovery verified BEFORE first flash.** `jtagconfig` must see the
   cable (current state: USB visible but `jtagconfig` exit 4; narrow udev
   permission fix for the Altera USB device `09fb:6810` identified, not yet
   applied). The JTAG SOF path is the only recovery if a bad flash image
   leaves the card unenumerated.
3. **Known-good vendor image identity saved** (running FIM version/BDF/BMC)
   and, ideally, the vendor flash image retained as fallback.
4. AER disabled before any programming (below), card healthy per
   `bw_card_monitor`, exclusive ownership of the card.

## Procedure (from the verified vendor guide, adapted)

### 1. Disable AER (prevents watchdog reboot during reprogramming)

```bash
# vendor ASP location (read-only use):
cd ~/IA-840f/IOFS_BUILD_ROOT/oneapi-asp/ia840f
sudo ./control_aer.sh 12ba:0070 off   # BittWare BMC
sudo ./control_aer.sh 8086:bcce off   # FPGA PF
sudo ./control_aer.sh 8086:bccf off   # FPGA VF
sudo ./control_aer.sh 1af4:1000 off
sudo ./control_aer.sh 12ba: off
```

### 2a. Volatile test first (JTAG SOF) — recommended before any flash

```bash
# Quartus 26.1.1 toolchain (our flow):
cd /opt/altera/26.1.1/quartus/bin/
./jtagconfig --setparam 1 JtagClockAutoAdjust 0
./jtagconfig --setparam 1 JtagClock 16M
./jtagconfig --getparam 1 JtagClock
./quartus_pgm -c 1 -m JTAG -o "p;<abs-path>/ofs_top.sof@1"
sudo shutdown -r now
```

### 2b. Durable: SPI flash via BittWare SDK

```bash
bw_agilex_flash_programmer -i PCI -c 0 program -a 0x04000000 <our-image>.rpd
```

- `program` performs erase + programming + its own QSPI readback comparison.
  Do **not** follow with a separate `verify` (per vendor guide).
- Flash address `0x04000000` matches the vendor-verified deployment.

### 3. Reboot and re-verify

```bash
sudo shutdown -r now   # warm reboot; power cycle is fallback if no enumerate
# after boot:
lspci -d 8086:bcce && lspci -d 12ba:0070   # discover current BDF
# then Stage E re-verification: dfl-pci binding, VF create + opae.io init,
# OPAE discovery — then the hw-validation-01 FPGA Tests + DDR gate.
```

### Quirks & safety (from the vendor guide)

- **Enumeration**: card takes up to ~5.5 s to initialize; may need 2–3 warm
  reboots to appear in `lspci` after first program/cold boot. Once stable it
  stays. (Optional vendor clock-chip reprogram removes the wait — separate
  decision, not part of this flow.)
- **Power safety**: never cut power abruptly during high-power FPGA operation
  — voltage spike can damage the core supply. Ramp down via BMC
  (`bw_card_monitor -i USB -c 0 -s thresholds -g All`) if a design must be
  stopped.
- **Do not reset/shared BMC SPI-SDM as an FLR workaround** (standing rule).
- PR (green region `.rbf`) updates the AFU only and never replaces the FIM in
  flash; FIM changes always go through the full flash procedure above.

## Open items

- [ ] Confirm `.rpd` conversion path for our 26.1.1 OFS image (BittWare doc /
      OFS flash-image script) and record exact command + hash.
- [ ] Apply + verify the narrow JTAG udev permission fix; `jtagconfig` green.
- [ ] Record known-good vendor image identity before first volatile test.
- [ ] First flash authorized separately (plan §1 class G) after volatile
      bring-up (class F) passes.
