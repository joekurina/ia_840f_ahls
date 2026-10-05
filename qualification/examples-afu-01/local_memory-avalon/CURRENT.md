# local_memory / Avalon — two-bank commanded-data FPGA Test accepted

**PASS at the named tutorial scope**, FINAL `deleg_e6797d57`. [Disposition86](FINAL-DISPOSITION86.json), [summary83](end-to-end-summary83.json), [review83](review-manifest83.json).

Native CMake/Quartus26.1.1 PR build/effective0/0, all24boundinputs preserved; unchanged tutorial RTL. GBS SHA256 `2a1990d4d1c9c3c4fce37406ccd3d869314cf7cb00753145f2940fe7bf494691`, interfacefc603c44-5c8f-5e94-bcbe-a5780030947c, AFU35f9452b-25c2-434c-93d5-6f8c60db361c. [Build receipts](build-artifacts80-collection.json).

Card command `/usr/bin/fpgaconf 0000:4f:00.0 <bound GBS>` exited0 silently, followed serially by `hello_mem_afu_checked 0` and `hello_mem_afu_checked 1`, each nativeEXITED0 with durable receipts. Host binarySHA256 `77231a98040014fe12d85e4bcf40f0264dbca8da4d1d97d21e25a1783da09f72`. [Hardware receipts](hardware-result81-collection.json), [host build](host-build79-collection.json).

Both report NUM_LOCAL_MEM_BANKS=2, selectedbank0/1,11NoMemoryErrors/TestPassed markers and DoneRunningTest; stderr empty. Existing RTL checks all512enabled bits against the repeated test word. Perbank9nonzero-mask cases plus2vacuous zero-mask cases; unchecked historical sweep excluded. [Data summary82](data-check-summary82.json). No bank-isolation/address-aliasing/fullcapacity/simultaneous/sustained qualification claimed.

Sameboot/scopedroot-visible holders/maps/D/errors/relevants empty at successful postflight. Original sources/rejected drafts preserved; reviewed alternative only. No force flags or system/driver/permission changes. No active job; livecampaignstate remains local in ../CURRENT.md until closure. Images/oversized logs stay remote-only, hash-referenced.
