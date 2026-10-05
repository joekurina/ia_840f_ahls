# Independent tutorial source review — consumed before host preparation

Review `deleg_0a644658` completed as a read-only local source review using the assigned runtime model/provider; no substitution was reported. It did not implement, compile, access the remote workstation or execute hardware. Parent consumed the findings below, checked the actual host and Avalon RTL, and preserved original vendored sources. This is not GBS/load/hardware acceptance.

## Accepted findings and resulting corrections

- Upstream `hello_world/sw/hello_world.c` enumerates by UUID, writes one line-based IOVA through MMIO0/offset0, polls indefinitely for the first byte, prints unchecked `%s`, releases/closes and returns0. It does not perform the goal's described MMIO write/read roundtrip. The applicable hardware functional gate must instead verify the tutorial's actual MMIO-triggered DMA greeting, not invent a new CSR or fabricate a readback result.
- Avalon `hw/rtl/avalon/hello_world_avalon.sv:134–151,177–214` writes a full64-byte line containing **`Hello world!` plus terminating NUL/zero padding**. Its FSM returns idle at request acceptance, not observed DMA completion. All three hello-world variants deliberately share UUID `c6aa954a-9b91-4a37-abc1-1d9f0709dcc3`; GBS/source provenance distinguishes protocols.
- A correction must initialize a nonmatching sentinel, check API submission results, use a finite monotonic deadline with yielding, compare a bounded volatile snapshot including the NUL and print only validated data. First-byte change/exit0 alone cannot pass.
- Timeout must not unconditionally release the possibly live DMA target, exit/kill the process, reset or retry. The alternative proposed after this review retains the original process, handle and buffer on post-submit failure. Exact bytes and signal/failure semantics require the separate correction review before build; no cancellation or universal no-hang property is claimed.

## Backend/lifecycle disposition

PR is an FME management ioctl selecting a port, not self-programming through a VFIO AFU handle. DFL/xfpga management and VFIO AFU access have distinct roles. [Existing backend review](../caps01-resume02/BACKEND-REVIEW.md) shows standalone AFU DFH cannot be made into a DFL port merely by changing the VF driver. No such rebind remedy is proposed.

Actual ordinary-file discovery found PF0 `dfl-pci`, managementPF1/VF0 `vfio-pci`, user-accessible existing DFL/VFIO nodes, and an installed OPAE config matching PCI IDs8086:bcce/bccf with subsystem8086:1771. No permissions/configs/drivers were changed. Subsequent source capture found `fpgaconf` default path opens the matching FME, requires an xfpga child accelerator unless `--force`, then optionally programs user clocks and issues `opae_fme_port_pr`. **No force flag is authorized/proposed to bypass the busy check.** A normal default-path attempt still requires actual GBS and fresh ownership readiness review; library help output is not that acceptance.

Installed and SDK-build `fpgaconf`, VFIO and xfpga modules have matching captured ELF build IDs; full SHA256 differs for these stripped/unstripped pairs. Installed opae-c is byte-identical to SDK-build opae-c. This corroborates the captured implementation basis, not a fresh source rebuild or exhaustive ELF loader proof.

## Remaining gate

Completed compatible GBS/hash/build status, exact installed command/backend/loader binding, fresh exclusive ownership, timeout resource retention, real greeting comparison, successful cleanup and independent actual-result review remain mandatory. Prior private strict CAPS03 host qualification is not transferred to plain tutorial OPAE, and its normal-idle reset scope is not general PR/cold/stopped-clock/global-drain qualification.
