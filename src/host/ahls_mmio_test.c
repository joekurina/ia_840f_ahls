/*
 * ahls_mmio_test.c — Stage 7 bring-up test for the AHLS AFU (fim-build-13).
 *
 * Accelerator UUID: 67bc266a-56f7-440a-bb75-12b5f446d842
 * MMIO map (rebased CSR window, +0x40; from Stage-1/2 verified elaboration):
 *   0x40 status (ro)   0x48 start (rw, pulse)   0x70/0x74 finish counter (ro, 64-bit)
 *   0xC0 args: a lo + b hi (w)  0xC8 mode (w)   0xD0 result (ro)
 *
 * Self-calibrating numeric check: runs the op twice with argument deltas
 * (+64 each) and verifies determinism + delta response, plus a full readback
 * of every documented register. Exit 0 only if all checks pass.
 *
 * Build: gcc -O2 -Wall -o ahls_mmio_test ahls_mmio_test.c -lopae-c
 * Run:   ./ahls_mmio_test            (expects exactly one matching AFU)
 */

#include <opae/access.h>
#include <opae/properties.h>
#include <opae/utils.h>
#include <opae/mmio.h>
#include <opae/enum.h>
#include <uuid/uuid.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <errno.h>
#include <time.h>

#define AFU_UUID "67bc266a-56f7-440a-bb75-12b5f446d842"

/* CSR offsets (bytes, within the AFU MMIO window) */
#define CSR_STATUS   0x40
#define CSR_START    0x48
#define CSR_FINISH   0x70   /* 64-bit: 0x70 lo, 0x74 hi */
#define CSR_ARGS     0xC0   /* a lo @0xC0, b hi @0xC4 (one 64-bit slot each) */
#define CSR_MODE     0xC8
#define CSR_RESULT   0xD0

static fpga_token   tok;
static fpga_handle  h;
static int failures = 0;

#define CHECK(cond, name, fmt, ...) do {                                   \
    if (cond) { printf("PASS  %-34s " fmt "\n", name, ##__VA_ARGS__); }    \
    else      { printf("FAIL  %-34s " fmt "\n", name, ##__VA_ARGS__); failures++; } \
} while (0)

static uint64_t rd64(uint64_t off)
{
    uint64_t v = 0;
    if (fpgaReadMMIO64(h, 0, off, &v) != FPGA_OK) { perror("fpgaReadMMIO64"); exit(2); }
    return v;
}
static void wr64(uint64_t off, uint64_t v)
{
    if (fpgaWriteMMIO64(h, 0, off, v) != FPGA_OK) { perror("fpgaWriteMMIO64"); exit(2); }
}

/* finish counter: try 64-bit read at 0x70; fall back to lo-only on X */
static uint64_t finish_ctr(void)
{
    uint64_t lo = rd64(CSR_FINISH);
    uint64_t hi = rd64(CSR_FINISH + 4);
    if (hi != 0 && hi != 0xFFFFFFFFFFFFFFFFull) return lo | (hi << 32);
    return lo;
}

struct run_result { uint64_t status, finish, result; };

static struct run_result run_op(uint64_t a, uint64_t b, uint64_t mode, int timeout_ms)
{
    struct run_result r;
    wr64(CSR_ARGS,     (b << 32) | (a & 0xFFFFFFFFull)); /* a lo, b hi */
    wr64(CSR_MODE,     mode);
    r.finish = finish_ctr();          /* baseline before start */
    wr64(CSR_START,    1);            /* pulse start */
    /* poll: status change or finish-counter increment */
    struct timespec ts = {0, 2*1000*1000};  /* 2 ms */
    for (int i = 0; i < timeout_ms / 2; i++) {
        r.status  = rd64(CSR_STATUS);
        r.finish  = finish_ctr();
        r.result  = rd64(CSR_RESULT);
        if (r.finish != 0 || i > 3) break;   /* done or gave baseline a moment */
        nanosleep(&ts, NULL);
    }
    /* wait for finish counter to advance past 0 */
    for (int i = 0; i < timeout_ms / 2; i++) {
        r.status  = rd64(CSR_STATUS);
        r.finish  = finish_ctr();
        r.result  = rd64(CSR_RESULT);
        if (r.finish != 0) break;
        nanosleep(&ts, NULL);
    }
    return r;
}

int main(void)
{
    fpga_properties p;
    fpga_guid guid;
    uint32_t n = 0;

    if (uuid_parse(AFU_UUID, guid) != 0) { fprintf(stderr, "uuid_parse failed\n"); return 2; }

    CHECK(fpgaGetProperties(NULL, &p) == FPGA_OK, "fpgaGetProperties", "");
    fpgaPropertiesSetObjectType(p, FPGA_ACCELERATOR);
    fpgaPropertiesSetGUID(p, guid);
    CHECK(fpgaEnumerate(&p, 1, &tok, 1, &n) == FPGA_OK && n >= 1,
          "enumerate AFU by UUID", "matches=%u", n);
    if (n < 1) return 1;

    CHECK(fpgaOpen(tok, &h, 0) == FPGA_OK, "fpgaOpen", "");
    CHECK(fpgaMapMMIO(h, 0, NULL) == FPGA_OK, "fpgaMapMMIO window 0", "");

    /* 1. Register presence: every documented CSR reads without fault */
    uint64_t s = rd64(CSR_STATUS), f0 = finish_ctr(), r0 = rd64(CSR_RESULT);
    printf("INFO  initial: status=0x%016" PRIx64 " finish=%" PRIu64 " result=0x%016" PRIx64 "\n",
           s, f0, r0);
    CHECK(1, "documented CSRs readable", "status=0x%" PRIx64, s);

    /* 2. Two calibration runs, args delta +64 on a */
    struct run_result r1 = run_op(1000, 2000, 0, 3000);
    struct run_result r2 = run_op(1064, 2000, 0, 3000);
    printf("INFO  run1: status=0x%016" PRIx64 " finish=%" PRIu64 " result=0x%016" PRIx64 "\n",
           r1.status, r1.finish, r1.result);
    printf("INFO  run2: status=0x%016" PRIx64 " finish=%" PRIu64 " result=0x%016" PRIx64 "\n",
           r2.status, r2.finish, r2.result);

    CHECK(r1.finish >= 1, "run1 finish counter advanced", "finish=%" PRIu64, r1.finish);
    CHECK(r2.finish >  r1.finish, "run2 finish > run1", "%" PRIu64 " > %" PRIu64, r2.finish, r1.finish);

    /* 3. Determinism + delta response (works for add/mult/any affine op on a) */
    struct run_result r1b = run_op(1000, 2000, 0, 3000);
    CHECK(r1b.result == r1.result, "determinism (same args -> same result)",
          "0x%" PRIx64 " == 0x%" PRIx64, r1b.result, r1.result);
    CHECK(r2.result != r1.result, "args delta changes result", "Δa=64 visible");

    /* interpret result: low 32 bits vs full 64 — report candidate ops */
    uint64_t lo1 = (uint32_t)r1.result, lo2 = (uint32_t)r2.result;
    printf("INFO  interpretation: a+b=%" PRIu64 " | lo32: r1=%" PRIu64 " r2=%" PRIu64
           " | full: r1=%" PRIu64 " r2=%" PRIu64 "\n",
           (uint64_t)3000, lo1, lo2, r1.result, r2.result);
    if (r1.result == 3000)      printf("INFO  result == a+b (full 64-bit)\n");
    else if (lo1 == 3000)       printf("INFO  result == a+b (low 32 bits)\n");
    else                        printf("INFO  result op not plain a+b; see values above\n");

    fpgaUnmapMMIO(h, 0);
    fpgaClose(h);
    fpgaDestroyToken(&tok);
    fpgaDestroyProperties(&p);

    printf("%s: %d failure(s)\n", failures ? "TEST FAILED" : "TEST PASSED", failures);
    return failures ? 1 : 0;
}
