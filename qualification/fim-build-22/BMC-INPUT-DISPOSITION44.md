# Work22 BMC unused-input follow-up

**Source-level finding narrowed; no source change, new tie-off, native run or hardware test.** This answers the three unused-input warnings retained by [synthesis review39](synthesis-review39.md#integration-findings-carried-into-full-fit-review), not BMC interrupt delivery or electrical acceptance.

The bounded [generated-source readback](compile43-collection.json) verified `ipss/ia840f/bwbmc/bmc_spi_sub/synth/bmc_spi_sub.v` against the compile input hash `9fdf4bc64dea1a2394fa5cfd3d4bd5a7eb72e65fcf9e826f49d9918f5f152b51`. Its two `irq_in()` connections and `system_arbiter.hps_gp_o()` are open; this is not evidence that the wrapper ties them to a constant.

## Actual consumer logic

- The two IRQ QIPs select generated copies of `IRQ_Generator_10/synth/irq_generator.v`, both SHA256 `1e13b36a132b32d636ea2cea80b5bbd9bcc8b4f45c1188a893469e89501d9411`. These equal the maintained, already adapted board source `ofs-agx7-pcie-attach/ipss/ia840f/bwbmc/ip/irq_generator/irq_generator.v`. Lines221–225 explicitly replace the original external-cause expression with `d1_data_in <= {4'b0000, data_in};`; the external `irq_in` value is not sampled. The software causes are preserved. This adaptation predates Work22; it was not introduced to conceal this migration's warnings.
- The arbiter QIP selects `system_arbiter/Arbiter_20/synth/arbiter.vhd`, SHA256 `9085fc684a2054c1bbecd462e9371987e89f2e0a5e284911ff533a9570303d1f`. It equals the maintained `ipss/ia840f/bwbmc/ip/arbiter/hdl/arbiter_v2.vhd` byte-for-byte. `hps_gp_o` and `hps_gp_i` occur only in their port declarations (lines56–57), not in the implementation logic. No HPS control path is activated by those unconnected ports.

The exact generated-file identities and QIP source edges are retained in [dependency closure19](generated-qip-closure19.json) and [generated inventory](regeneration17-readback/qualification/fim-build-22/regeneration17/inventory.json). Source copies were independently hashed against those identities.

## Boundary

The warned unused values do not influence these selected consumer implementations. This is narrower than claiming default-low electrical behavior for every open port, complete reset/IRQ qualification, or successful BMC hardware operation. The board's BMC-to-host `pcie_irq()` connection remains intentionally absent, as documented in the selected `fim_afu_instances.sv`; generated IRQ output presence must not be called an implemented MSI-X route. Preserve the architecture and carry required management/SPI/SDM, pin and reset checks into the later fitted/deployment gates.
