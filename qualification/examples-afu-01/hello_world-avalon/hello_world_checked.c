// Copyright (C) 2022 Intel Corporation
// SPDX-License-Identifier: MIT

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <time.h>
#include <string.h>
#include <signal.h>
#include <uuid/uuid.h>

#include <opae/fpga.h>

// State from the AFU's JSON file, extracted using OPAE's afu_json_mgr script
#include "afu_json_info.h"

#define CACHELINE_BYTES 64
#define CL(x) ((x) * CACHELINE_BYTES)


//
// Search for an accelerator matching the requested UUID and connect to it.
//
static fpga_handle connect_to_accel(const char *accel_uuid)
{
    fpga_properties filter = NULL;
    fpga_guid guid;
    fpga_token accel_token;
    uint32_t num_matches;
    fpga_handle accel_handle;
    fpga_result r;

    // Don't print verbose messages in ASE by default
    setenv("ASE_LOG", "0", 0);

    // Set up a filter that will search for an accelerator
    r = fpgaGetProperties(NULL, &filter);
    if (r != FPGA_OK) return 0;
    r = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
    if (r != FPGA_OK) { fpgaDestroyProperties(&filter); return 0; }
    /* Source-bound target: PF0/VF0, not management PF1. */
    if (fpgaPropertiesSetSegment(filter, 0) != FPGA_OK ||
        fpgaPropertiesSetBus(filter, 0x4f) != FPGA_OK ||
        fpgaPropertiesSetDevice(filter, 0) != FPGA_OK ||
        fpgaPropertiesSetFunction(filter, 2) != FPGA_OK) {
        fpgaDestroyProperties(&filter);
        return 0;
    }

    // Add the desired UUID to the filter
    if (uuid_parse(accel_uuid, guid) != 0 ||
        fpgaPropertiesSetGUID(filter, guid) != FPGA_OK) {
        fpgaDestroyProperties(&filter);
        return 0;
    }

    // Do the search across the available FPGA contexts
    num_matches = 1;
    r = fpgaEnumerate(&filter, 1, &accel_token, 1, &num_matches);

    // Not needed anymore
    fpga_result destroy_result = fpgaDestroyProperties(&filter);

    if (r != FPGA_OK || destroy_result != FPGA_OK || num_matches != 1)
    {
        fprintf(stderr, "Accelerator %s not found!\n", accel_uuid);
        return 0;
    }

    // Open accelerator
    r = fpgaOpen(accel_token, &accel_handle, 0);
    if (r != FPGA_OK) {
        fpgaDestroyToken(&accel_token);
        return 0;
    }

    // Done with token
    if (fpgaDestroyToken(&accel_token) != FPGA_OK) {
        fpgaClose(accel_handle);
        return 0;
    }

    return accel_handle;
}


//
// Allocate a buffer in I/O memory, shared with the FPGA.
//
static volatile void* alloc_buffer(fpga_handle accel_handle,
                                   ssize_t size,
                                   uint64_t *wsid,
                                   uint64_t *io_addr)
{
    fpga_result r;
    volatile void* buf;

    r = fpgaPrepareBuffer(accel_handle, size, (void*)&buf, wsid, 0);
    if (FPGA_OK != r) return NULL;

    // Get the physical address of the buffer in the accelerator
    r = fpgaGetIOAddress(accel_handle, *wsid, io_addr);
    if (r != FPGA_OK) {
        fpgaReleaseBuffer(accel_handle, *wsid);
        return NULL;
    }

    return buf;
}


/* A post-submit failure must not unpin the target of potentially live DMA.
 * Park the original process with its handle/buffer intact. No recovery, reset,
 * retry, SIGCONT or termination is authorized by this program. The supervisor
 * must record STOPPED/retained ownership and stop the hardware lane.
 * This is a buffer-lifetime disposition, not cancellation or no-hang proof.
 */
static void preserve_dma_owner(const char *reason)
{
    sigset_t blocked;
    fprintf(stderr, "FAIL retained_dma_owner pid=%ld reason=%s\n",
            (long)getpid(), reason);
    fflush(NULL);
    sigfillset(&blocked);
    sigprocmask(SIG_SETMASK, &blocked, NULL);
    raise(SIGSTOP);
    /* If externally continued, remain parked without polling or cleanup. */
    sigsuspend(&blocked);
    _Exit(125);
}

int main(int argc, char *argv[])
{
    (void)argc;
    (void)argv;
    fpga_handle accel_handle = connect_to_accel(AFU_ACCEL_UUID);
    if (accel_handle == 0) return 1;
    uint64_t wsid = 0, buf_pa = 0;
    volatile char *buf = (volatile char *)alloc_buffer(
        accel_handle, getpagesize(), &wsid, &buf_pa);
    if (buf == NULL) { fpgaClose(accel_handle); return 1; }

    /* The RTL writes one full cacheline: greeting/NUL followed by zeroes. */
    const unsigned char expected[CACHELINE_BYTES] = "Hello world!";
    unsigned char observed[CACHELINE_BYTES];
    for (size_t i = 0; i < CACHELINE_BYTES; ++i) buf[i] = (char)0xa5;
    struct timespec start, now, delay = {0, 1000000};
    if (clock_gettime(CLOCK_MONOTONIC, &start) != 0) {
        fpgaReleaseBuffer(accel_handle, wsid);
        fpgaClose(accel_handle);
        return 1;
    }
    /* Prevent ordinary termination from automatically revoking live DMA. */
    sigset_t blocked;
    sigfillset(&blocked);
    if (sigprocmask(SIG_SETMASK, &blocked, NULL) != 0) {
        fpgaReleaseBuffer(accel_handle, wsid);
        fpgaClose(accel_handle);
        return 1;
    }
    fpga_result r = fpgaWriteMMIO64(accel_handle, 0, 0, buf_pa / CL(1));
    if (r != FPGA_OK) preserve_dma_owner("MMIO submit error/unknown submission");

    int matched = 0;
    /* Both monotonic deadline and finite iteration bound: no infinite spin. */
    for (unsigned int poll = 0; poll < 10000; ++poll) {
        for (size_t i = 0; i < CACHELINE_BYTES; ++i)
            observed[i] = (unsigned char)buf[i];
        if (memcmp(observed, expected, CACHELINE_BYTES) == 0) {
            matched = 1;
            break;
        }
        if (clock_gettime(CLOCK_MONOTONIC, &now) != 0)
            preserve_dma_owner("monotonic clock failure after submission");
        double elapsed = (double)(now.tv_sec - start.tv_sec)
                       + (double)(now.tv_nsec - start.tv_nsec) / 1.0e9;
        if (elapsed >= 10.0) break;
        nanosleep(&delay, NULL);
    }
    if (!matched) preserve_dma_owner("greeting/cacheline mismatch or deadline");

    printf("%s\n", (const char *)observed);
    printf("CHECK greeting_line_bytes=%d PASS\n", CACHELINE_BYTES);
    r = fpgaReleaseBuffer(accel_handle, wsid);
    if (r != FPGA_OK) preserve_dma_owner("verified DMA but buffer release failed");
    r = fpgaClose(accel_handle);
    if (r != FPGA_OK) preserve_dma_owner("verified DMA but handle close failed");
    return 0;
}
