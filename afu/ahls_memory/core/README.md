# AHLS memory core

Additive component wrapper around the corrected AI Suite-derived DMA and generated AHLS2026.1.0 DDRIP fabric. The scalar AFU remains unchanged. See qualification/ahls-memory-dma-core01 for exact native generation/elaboration bindings. Interface connections follow the pinned donor OFS composition, not its OpenVINO software or four-bank geometry.

This is not yet an ofs_plat_afu or a deployable FIM/persona. The flat host and bank ports must be connected through one primary host mapper and the actual PIM per-bank clock/ID/USER adapters. External MMIO requires strict aperture/single-beat access control before narrowing. Standalone geometry/UUID are elaboration inputs, not live identity evidence. No hardware use until clock/reset, protocol/visibility/lifecycle, functional and signoff gates are closed.
