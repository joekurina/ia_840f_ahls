/* CAPS01 memory AFU identity/capability inspection, not the scalar test.
 * Build/test offline first. Even OPAE initialization and reads may touch
 * hardware; seven reads and exact filters are NOT a host-safety guarantee.
 * See qualification/ahls-memory-host01/SCOPE.md. No raw BAR or write path.
 */
#include "ahls_qualification_core.h"
#include "ia840f_dma_capabilities.h"
#include <opae/access.h>
#include <opae/enum.h>
#include <opae/properties.h>
#include <opae/mmio.h>
#include <opae/utils.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

static int memory_api_ok(fpga_result rc, const char *operation)
{
    if (rc == FPGA_OK) return 1;
    fprintf(stderr, "FAIL %s: %s (%d). No retry/reset.\n",
            operation, fpgaErrStr(rc), (int)rc);
    return 0;
}

int main(int argc, char **argv)
{
    fpga_properties props = NULL;
    fpga_token token = NULL;
    fpga_handle handle = NULL;
    fpga_guid guid = {0x67,0x3c,0x03,0xa1,0xce,0xf3,0x4c,0x82,
                      0xbf,0x10,0xb1,0x2c,0x24,0x7d,0x97,0x18};
    const uint64_t identity_offsets[] = {0,8,16};
    const uint64_t identity_words[] = {UINT64_C(0x1000010000000000),
        UINT64_C(0xbf10b12c247d9718), UINT64_C(0x673c03a1cef34c82)};
    const uint64_t capability_offsets[] = {IA840F_DMA_CAP_ID_OFFSET,
        IA840F_DMA_CAP_GEOMETRY_OFFSET, IA840F_DMA_CAP_ADDRESS_OFFSET,
        IA840F_DMA_CAP_LIMITS_OFFSET};
    uint16_t segment;
    uint8_t bus, device, function;
    uint32_t matches = 0;
    uint64_t words[4] = {0};
    struct ia840f_dma_capabilities capabilities = {0};
    int mapped = 0, exit_code = 1;
    if (argc != 3 || strcmp(argv[1], "--inspect-qualified-memory-afu") ||
        ahls_parse_bdf(argv[2], &segment, &bus, &device, &function)) {
        fprintf(stderr, "Usage (separately authorized hardware only): %s "
                "--inspect-qualified-memory-afu dddd:bb:dd.f\n", argv[0]);
        return 2;
    }
#define REQUIRE(call) do { if (!memory_api_ok((call), #call)) goto cleanup; } while (0)
    REQUIRE(fpgaGetProperties(NULL, &props));
    REQUIRE(fpgaPropertiesSetObjectType(props, FPGA_ACCELERATOR));
    REQUIRE(fpgaPropertiesSetGUID(props, guid));
    REQUIRE(fpgaPropertiesSetSegment(props, segment));
    REQUIRE(fpgaPropertiesSetBus(props, bus));
    REQUIRE(fpgaPropertiesSetDevice(props, device));
    REQUIRE(fpgaPropertiesSetFunction(props, function));
    REQUIRE(fpgaPropertiesSetVendorID(props, 0x8086));
    REQUIRE(fpgaPropertiesSetDeviceID(props, 0xbccf));
    REQUIRE(fpgaPropertiesSetSubsystemVendorID(props, 0x8086));
    REQUIRE(fpgaPropertiesSetSubsystemDeviceID(props, 0x1771));
    fpga_result enum_rc = fpgaEnumerate(&props, 1, &token, 1, &matches);
    if (!memory_api_ok(enum_rc, "fpgaEnumerate") ||
        !ahls_unique_match(enum_rc == FPGA_OK, matches)) {
        fprintf(stderr, "FAIL enumeration: expected one current memory AFU "
                "at %s, found %u. No fallback.\n", argv[2], matches);
        goto cleanup;
    }
    REQUIRE(fpgaOpen(token, &handle, 0));
    REQUIRE(fpgaMapMMIO(handle, 0, NULL));
    mapped = 1;
    for (size_t i = 0; i < 3; i++) {
        uint64_t value = 0;
        printf("FPGA Test identity read 0x%" PRIx64 "\n", identity_offsets[i]);
        fflush(stdout);
        REQUIRE(fpgaReadMMIO64(handle, 0, identity_offsets[i], &value));
        if (value != identity_words[i]) {
            fprintf(stderr, "FAIL identity at 0x%" PRIx64 ": 0x%016" PRIx64 "\n",
                    identity_offsets[i], value);
            goto cleanup;
        }
    }
    for (size_t i = 0; i < 4; i++) {
        printf("FPGA Test capability read 0x%" PRIx64 "\n", capability_offsets[i]);
        fflush(stdout);
        REQUIRE(fpgaReadMMIO64(handle, 0, capability_offsets[i], &words[i]));
    }
    if (!ia840f_dma_capabilities_decode(words, &capabilities)) {
        fprintf(stderr, "FAIL unsupported raw-capability ABI/geometry.\n");
        goto cleanup;
    }
    exit_code = 0;
cleanup:
    /* No buffers are pinned and no DMA/start/write is issued by this test.
     * Backend/kernel close semantics still need a reviewed live procedure.
     * Attempt remaining cleanup after a destructor error; never retry one. */
    if (mapped && !memory_api_ok(fpgaUnmapMMIO(handle, 0), "fpgaUnmapMMIO")) exit_code = 1;
    if (handle && !memory_api_ok(fpgaClose(handle), "fpgaClose")) exit_code = 1;
    if (token && !memory_api_ok(fpgaDestroyToken(&token), "fpgaDestroyToken")) exit_code = 1;
    if (props && !memory_api_ok(fpgaDestroyProperties(&props), "fpgaDestroyProperties")) exit_code = 1;
    if (exit_code == 0) {
        printf("FPGA Test identity/capability PASSED: banks=%u beat_bytes=%u "
               "host_address_bits=%u max_descriptor_beats=%" PRIu32 "\n",
               (unsigned)capabilities.banks, (unsigned)capabilities.beat_bytes,
               (unsigned)capabilities.host_address_bits, capabilities.max_descriptor_beats);
        printf("No DDR data, DMA, kernel execution, reset, PR or durable-boot test performed.\n");
    } else {
        fprintf(stderr, "FPGA Test identity/capability FAILED. No retry/reset/fallback.\n");
    }
    return exit_code;
}
