# OPAE backend identity follow-up — ordinary-file evidence only

## Result and limits

The two library pairs left unresolved by
[spec review02](../offline-milestone-review-01/spec-review02.md) have matching
`.text`, `.rodata` and GNU build-ID sections. Whole-file hashes still differ.
This is additional **static identity evidence**, not an executed runtime,
complete dependency closure, or permission to load OPAE. It was collected
after the original spec input manifest and does not retroactively change it.
Independent acceptance of this supplement is pending.

| Pair | Equal / compared allocated file-backed ELF sections | Differing sections |
|---|---|---|
| Installed/build `libopae-u.so` | 20 / 22 | `.dynamic`, `.dynstr` |
| Installed/build `libopaevfio.so.2.13.0` | 19 / 21 | `.dynamic`, `.dynstr` |

All four whole-file hashes match their prior ordinary-file captures in source
batches05/06. [Verification](verification01.json) records each comparison.
The captured `readelf -d -n` output shows identical NEEDED lists and build IDs
within each pair; only build copies advertise the build-directory RPATH.
That supports an install-path metadata explanation for the two differing
sections, but is not a claim that every differing byte has been decoded.
No files from these binaries were exported, loaded with dlopen, or executed.

- UIO build ID: `037cf77d7242ff8a1b0aabd6a2437b25626195a2`.
- Lower-level VFIO build ID: `d1b5cfe2dff39c93d395ec5475f98263a63a437c`.
- UIO depends on `libopaeuio.so.2`; VFIO support depends on `libopaemem.so.2`.
  This follow-up does **not** establish the identities or loaded resolution
  of those dependencies or the complete process-wide access behavior.

## Capture and transport

The inspected [collector](collect01.py) reads exactly four bounded regular ELF
files, verifies the ELF64 little-endian section layout, hashes file-backed
SHF_ALLOC sections, and captures `readelf -d -n`. It verifies each file hash
again after inspection to reject capture-time drift. No ldd, native OPAE
command, sysfs attribute, PCI configuration, device open or ioctl is used.

[Launch receipt](launch01.json): owned session `ia840f_mailbox_monitored_01`,
new window `opae_binding_01`, **@17 / %17**. SSH commands only interact with
tmux. Input/output buffer names are unique; existing buffers/windows were
checked before dispatch. The collector records its own pane and PID. Target
hostname assertion and exact regular-file paths constrain this collection.

[Pane receipt](receipt01.json) reported COMPLETE True. Exported
[batch JSON](batch01.json) and [gzip archive](batch01.json.gz) were checked
against the independently captured pane digests:

- JSON SHA256: `426ff18c8b7df72dd8a30e55648f33491af3bb4181ea701fad07f6c14b4a7a17`
- Gzip SHA256: `3fcf9dda78c4e921d2c0bca6a5ee334d7aea930946023b5d40b0c44c5d17ec6e`

Exact retrieval commands and prior-capture comparisons are in
[verification01.json](verification01.json). No host configuration or installed
library was modified. Prior source/evidence artifacts remain unchanged.

## Native execution is still blocked

The highest-priority remaining issue is **access before application token
filtering**, not merely library hashes. Parent inspection confirms captured
`source-resume-01/remote/home/uwb_student00/opae-sdk/libraries/plugins/xfpga/enum.c`
lines742–765 invoke `sync_fme`/`sync_afu` before `matches_filters`.
`sync_afu`, lines451–489, opens the DFL port O_RDWR, requests port information,
closes it and reads GUID metadata. Exact frontend BDF/UUID filters therefore
do not isolate the process to one VF when xfpga is also loaded.
The captured default configuration enables xfpga, VFIO and UIO; see
[spec review02's source chain](../offline-milestone-review-01/spec-review02.md).

Any future native plan must resolve the selected backend configuration and
its entire relevant initialization/enumeration/open/close footprint, current
image/function/driver/BAR and clock/reset state, exclusive ownership, exact
minimum operation and independent recovery. No config override is applied or
authorized here. No FPGA Test, udev activation, PR, programming or new FPGA
compile took place in this follow-up.
