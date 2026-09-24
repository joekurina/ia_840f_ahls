# Workstation-native OPAE link-check scope

Validate that the already tested CAPS01 identity/capability frontend compiles and links against the workstation's installed OPAE headers and core library. Only configure/compiler/linker and static readelf inspection may run. Never execute the resulting program, including help, and never load OPAE for inspection. No FPGA access, driver changes, installation, reset or programming.

Use the exact existing source/decoder/core in a fresh source-bound tmux root with finite child supervision, all allowed CPUs and 64GiB per-process address-space limit. Bind tool, installed-header/core-library and source identities; retain diagnostics, outer/native/effective results and preservation. Record the executable bytes/hash and direct ELF dependencies. No claim of full transitive compiler/runtime closure.

This is valid intermediate compatibility evidence. The AHLS environment is the eventual application target; workstation-native linking does not replace that target check. The source-map research and inert frontend review are separate gates.
