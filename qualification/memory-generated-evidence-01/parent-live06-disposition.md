# Parent integration of live06 calibration review

Accepted the bounded findings in `calibration-live06-review.md`, not calibration qualification.

Parent independently rechecked the container and all three payload hashes, parsed the actual synthesis hex record lengths/checksums, and verified 25 four-byte data records plus EOF. Record address fields advance by one from 0x7400 through 0x7418. Values 00000064 and 00010264 occur at record fields 0x7409 and 0x740A. These are literal record/value facts, not processor addresses, pointer definitions, or loader semantics.

The newly captured controller wrappers forward quoted SYN/SIM strings and whole table nets to the two architecture modules identified by F65:771 and F71:771. The reviewer has supplied literal next dependencies; actual packing/coercion/mode-selection remains unresolved. No slot/channel swap or metadata patch is justified.

This closes capture/consistency of the prior missing wrappers and actual synthesis GPT artifact only. Primitive/firmware semantics, slot-permutation safety, donor compatibility and functional calibration remain open. Preserve both 16-GiB channel identities, BOT/BOT and pins. No source changes, vendor execution, new remote capture or readiness promotion in this integration step. `ready_for_build=false`.
