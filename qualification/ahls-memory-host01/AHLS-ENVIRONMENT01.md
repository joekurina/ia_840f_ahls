# Existing AHLS Apptainer environment: verified build prerequisites

This is environment discovery, not an OPAE runtime or hardware pass. The workstation-native compile/link result remains a valid intermediate check; the AHLS environment is the eventual application target.

## Observed identities and execution

- Image `/home/uwb_student00/ahls/ubuntu-ahls.sif`, 422,834,176 bytes; SHA256 `7f10d218cb18b9a33c4a8fff076cdf12a72ae528db5d3c2b2a224fa3f26c6fab`.
- Runtime is **user-local**, not on the tested PATH: `/home/uwb_student00/ahls/apptainer/bin/apptainer`. Wrapper SHA256 `55ae0ec39abf785e3812fe2eb6626ada05a078c3f41431dc37107741a7218f9a`; real x86_64 executable SHA256 `f18f7ca8cc134ec17bd903e80ecf4575c9b78d048313202fac8ee3d8bd4d6a45`. Reports Apptainer1.5.2-1.el8.
- Existing image is Ubuntu22.04.5. Its environment sources empty `/env.sh`, then sets Quartus/AHLS-related paths; `run` would separately source the bound HLS environment. Inspection used `exec`, not that runscript, and did not bind the HLS installation, workstation `/usr`, or FPGA device directories. This is an image prerequisite check, not full AHLS activation.
- Installed `exec` help and config were read before container inventory. Invocation used `--containall --cleanenv --no-home --no-mount sys,hostfs,cwd,bind-paths --no-eval`, a fresh workdir and only the owned `/work` bind. The recorded minimal `/dev` contains no VFIO/DFL/FPGA/UIO names; mountinfo is retained. This is observed isolation for these ordinary-file inventory commands, not a universal hardware-safety claim.
- Inventory ran Python with `-I -S`; no OPAE executable, library load, compiler test, device open, MMIO, reset, driver change or programming occurred. The source image was hash-checked unchanged.

## Concrete missing prerequisites

[Inventory05](outer-apptainer-inventory05.json) found GCC11-family binaries, CMake, make, readelf and Python3.10, but no OPAE headers/libraries in the named installation paths. [Prerequisite06](outer-apptainer-sdk-prereq06.json) additionally found no OPAE-named paths in `/usr/include`, `/usr/lib`, `/usr/local`, or `/opt`; do not extend this into an unbounded whole-filesystem assertion.

The image has runtime `libuuid1`2.37.2-4ubuntu3.5 and `libjson-c5`0.15-3~ubuntu1.22.04.2, but lacks `uuid/uuid.h`, `json-c/json.h` and their unversioned linker symlinks. Thus a direct build against *already installed* container OPAE is unavailable. Workstation Rocky libraries were **not** substituted or injected.

The existing remote `/home/uwb_student00/opae-sdk` build definitions were captured in `sdk-sources01.json` (raw source transport, local only). They identify2.13.0 and a normal `opae-c` shared-library target. Its dependencies include json-c, uuid, dl and threads. Top-level defaults can fetch many optional dependencies; `OPAE_MINIMAL_BUILD` is applied **after** early dependency handling and also forces install prefix `/usr`. Therefore do not assume that setting it alone avoids downloads or installation scope. No SDK configure, dependency download, package installation or image rebuild has yet occurred.

The next target build can use an explicitly scoped user-owned dependency/build prefix, matching Ubuntu development packages/source and source-bound OPAE build flags. Preserve the original SIF and workstation installation; do not run install hooks, ldconfig, hardware utilities or the resulting FPGA-access executable. Complete source/build prerequisite checks before dispatch.

## Preserved failures

`inspect01` ended outer125 at preflight with no native commands; subsequent discovery identified the runtime outside the searched PATH. Do not call this container execution failure. `static03` obtained SIF filesystem offset36864, but its `unsquashfs -help` returned1; retain that receipt rather than relabeling it a clean run. Its help text supported the separate successful selected-file extraction in `startup04`. `inspect02`, `startup04`, `inventory05` and `sdk-prereq06` completed with outer0. Raw records remain local; no unchanged retry is required.
