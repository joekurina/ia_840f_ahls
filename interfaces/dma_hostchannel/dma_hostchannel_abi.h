/* SPDX-License-Identifier: MIT
 * Candidate source ABI v1. See transport-contract.md; not hardware qualification.
 */
#ifndef DMA_HOSTCHANNEL_ABI_H
#define DMA_HOSTCHANNEL_ABI_H
#include <stdint.h>
#define DHC_BASE UINT64_C(0x30000)
#define DHC_STRIDE UINT64_C(0x100)
#define DHC_IDENT_VALUE UINT64_C(0x4941383448430001)
#define DHC_IDENT 0x00
#define DHC_CONTROL 0x08
#define DHC_STATUS 0x10
#define DHC_RING_IOVA 0x18
#define DHC_RING_BYTES 0x20
#define DHC_HOST_POSITION 0x28
#define DHC_DEVICE_POSITION 0x30
#define DHC_ERROR 0x38
#define DHC_ELEMENT_BYTES 0x40
#define DHC_RUN UINT64_C(1)
#define DHC_QUIESCE UINT64_C(2)
/* Only accepted while QUIESCED; resets both positions and sticky errors. */
#define DHC_RESET_POSITIONS UINT64_C(4)
#define DHC_RUNNING UINT64_C(1)
#define DHC_QUIESCED UINT64_C(2)
#define DHC_FAILED UINT64_C(4)
#define DHC_ELEMENT_SIZE 64
#define DHC_MAX_RING_BYTES (64u * 1024u * 1024u)
#define DHC_H2D_NAME "host_to_kernel"
#define DHC_D2H_NAME "kernel_to_host"
#endif
