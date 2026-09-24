#ifndef AHLS_QUALIFICATION_CORE_H
#define AHLS_QUALIFICATION_CORE_H
#include <stdint.h>
#include <stddef.h>
/* Bound to W13 IDQualVecOp CSR v5. See qualification/ahls-host-offline-01. */
enum { AHLS_STATUS=0x40, AHLS_START=0x48, AHLS_FINISH=0x70,
       AHLS_ARGS=0xc0, AHLS_MODE=0xc8, AHLS_RESULT=0xd0 };
enum { AHLS_OK=0, AHLS_IO=-1, AHLS_IDENTITY=-2, AHLS_STATE=-3,
       AHLS_TIMEOUT=-4, AHLS_NUMERIC=-5, AHLS_INPUT=-6 };
struct ahls_io {
    void *ctx;
    int (*read64)(void *, uint64_t, uint64_t *);
    int (*write64)(void *, uint64_t, uint64_t);
    int (*now_ms)(void *, uint64_t *);
    int (*pause_ms)(void *, unsigned);
};
struct ahls_case { int32_t a,b,mode; };
extern const struct ahls_case ahls_cases[];
extern const size_t ahls_case_count;
int ahls_reference(struct ahls_case input, uint32_t *expected);
int ahls_verify_identity(const struct ahls_io *io);
int ahls_run_case(const struct ahls_io *io, struct ahls_case input,
                  uint64_t timeout_ms, uint32_t *observed);
int ahls_unique_match(int api_success, uint32_t matches);
int ahls_parse_bdf(const char *s, uint16_t *segment, uint8_t *bus,
                   uint8_t *device, uint8_t *function);
#endif
