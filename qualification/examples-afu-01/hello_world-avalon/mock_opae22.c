/* Inert OPAE substitute for tutorial host regression. No hardware API/library. */
#include <opae/fpga.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned char *buffer;
static int mode(const char *name) { const char *m = getenv("MOCK_MODE"); return m && !strcmp(m, name); }
static void receipt(const char *name) {
    FILE *f = fopen(getenv("MOCK_RECEIPT"), "a");
    if (!f) abort();
    fprintf(f, "%s\n", name); fclose(f);
}
fpga_result fpgaGetProperties(fpga_token token, fpga_properties *p) {
    (void)token; receipt("properties"); *p = (fpga_properties)(uintptr_t)1; return FPGA_OK;
}
fpga_result fpgaPropertiesSetObjectType(fpga_properties p, fpga_objtype t) { (void)p; (void)t; return FPGA_OK; }
fpga_result fpgaPropertiesSetSegment(fpga_properties p, uint16_t n) { (void)p; return n == 0 ? FPGA_OK : FPGA_EXCEPTION; }
fpga_result fpgaPropertiesSetBus(fpga_properties p, uint8_t n) { (void)p; return n == 0x4f ? FPGA_OK : FPGA_EXCEPTION; }
fpga_result fpgaPropertiesSetDevice(fpga_properties p, uint8_t n) { (void)p; return n == 0 ? FPGA_OK : FPGA_EXCEPTION; }
fpga_result fpgaPropertiesSetFunction(fpga_properties p, uint8_t n) { (void)p; return n == 2 ? FPGA_OK : FPGA_EXCEPTION; }
fpga_result fpgaPropertiesSetGUID(fpga_properties p, fpga_guid g) { (void)p; (void)g; return FPGA_OK; }
fpga_result fpgaEnumerate(const fpga_properties *f, uint32_t n, fpga_token *t, uint32_t cap, uint32_t *matches) {
    (void)f; (void)n; (void)cap; receipt("enumerate"); *matches = mode("missing") ? 0 : mode("duplicate") ? 2 : 1;
    *t = (fpga_token)(uintptr_t)2; return mode("enumerate_error") ? FPGA_EXCEPTION : FPGA_OK;
}
fpga_result fpgaDestroyProperties(fpga_properties *p) { *p = NULL; return FPGA_OK; }
fpga_result fpgaOpen(fpga_token t, fpga_handle *h, int flags) {
    (void)t; (void)flags; receipt("open"); *h = (fpga_handle)(uintptr_t)3; return FPGA_OK;
}
fpga_result fpgaDestroyToken(fpga_token *t) { *t = NULL; return FPGA_OK; }
fpga_result fpgaPrepareBuffer(fpga_handle h, uint64_t len, void **p, uint64_t *wsid, int flags) {
    (void)h; (void)flags; receipt("prepare");
    if (mode("allocation_error")) return FPGA_EXCEPTION;
    buffer = calloc(1, (size_t)len); *p = buffer; *wsid = 1; return buffer ? FPGA_OK : FPGA_NO_MEMORY;
}
fpga_result fpgaGetIOAddress(fpga_handle h, uint64_t wsid, uint64_t *addr) {
    (void)h; (void)wsid; *addr = 0x1000; return mode("iova_error") ? FPGA_EXCEPTION : FPGA_OK;
}
fpga_result fpgaWriteMMIO64(fpga_handle h, uint32_t region, uint64_t offset, uint64_t value) {
    (void)h; receipt("submit");
    if (region != 0 || offset != 0 || value != 0x40) abort();
    if (mode("submit_error")) return FPGA_EXCEPTION;
    if (mode("partial")) { buffer[0] = 'H'; return FPGA_OK; }
    if (mode("no_dma")) return FPGA_OK;
    memset(buffer, 0, 64); memcpy(buffer, "Hello world!", 13);
    if (mode("wrong_greeting")) buffer[6] = 'W';
    if (mode("wrong_padding")) buffer[63] = 1;
    return FPGA_OK;
}
fpga_result fpgaReleaseBuffer(fpga_handle h, uint64_t wsid) {
    (void)h; (void)wsid; receipt("release");
    if (mode("release_error")) return FPGA_EXCEPTION;
    free(buffer); buffer = NULL; return FPGA_OK;
}
fpga_result fpgaClose(fpga_handle h) { (void)h; receipt("close"); return mode("close_error") ? FPGA_EXCEPTION : FPGA_OK; }
