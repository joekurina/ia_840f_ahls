# Workstation-native OPAE link result

Acquisition completed; independent native-result review pending. [Scope](NATIVE-SCOPE01.md).

- Owned root `/home/uwb_student00/ahls/new_BSP/work_ahls_memory_host01/native01`, pane `%343`.
- Seven version/configure/build/static-ELF commands: native/effective 0/0; outer 0. No timeout or owned survivors. All source and recorded original bindings unchanged.
- Actual compile flags: `-g -std=c11 -O2 -Wall -Wextra -Werror -pedantic`. Build output contains no compiler warning/error diagnostics. No UBSan execution is claimed for this native link.
- Bound `/usr/lib64/libopae-c.so` resolves to `/usr/lib64/libopae-c.so.2.13.0`; SHA256 `2cc2f37de8fdbb396add0c7a61a96bd9a7051d14ccfc4c7f79d42679ff825ddf`. All seven headers used in the inert package match the current installed bytes.
- ELF: 40424 bytes, SHA256 `a68f2e2a8b374db28fd90cffde002c4c20a9c900ef00a855592b331b396b7dd8`. Remote mode 0600 after build. **Never executed or dynamically loaded.**
- Direct DT_NEEDED: `libopae-c.so.2`, `libc.so.6`. Runtime plugin choice/transitive libraries and hardware footprint remain unqualified. Static symbol readback includes subsystem filters and ReadMMIO64; no application write/reset/DMA import.
- Sixteen exported members size/hash verified against [outer receipt](outer-native01.json) and raw local archive. [Compiler/linker log](artifacts-native01/compile_link.log), [ELF dependencies](artifacts-native01/elf_dynamic.log), [symbols](artifacts-native01/elf_symbols.log).

The result establishes workstation-native API/link compatibility only, not AHLS-container compatibility, startup/cleanup safety, live OPAE enumeration, physical memory or accelerator correctness. Original image, FPGA designs and workstation installation were not changed.
