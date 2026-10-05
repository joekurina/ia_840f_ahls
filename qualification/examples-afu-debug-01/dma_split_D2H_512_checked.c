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
#include <sys/mman.h>
#include <errno.h>
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


#define DMA_TEST_BYTES 512
#define DMA_TEST_PAGE 4096
static void dma_mmio_write(fpga_handle h, unsigned int index, uint64_t value)
{
    if (fpgaWriteMMIO64(h,0,8u*index,value)!=FPGA_OK) preserve_dma_owner("DMA MMIO write failure");
}
static uint64_t dma_status(fpga_handle h)
{
    uint64_t value=0;
    if (fpgaReadMMIO64(h,0,8u*9u,&value)!=FPGA_OK) preserve_dma_owner("DMA status API failure");
    return value;
}
static void dma_one_transfer(fpga_handle h, unsigned mode, uint64_t source, uint64_t destination)
{
    uint64_t before=dma_status(h);
    if ((before & 1u) || !(before & 2u) || (before & UINT64_C(0x2480))) preserve_dma_owner("DMA not idle/error before descriptor");
    unsigned expected=(unsigned)(((before>>28)+1u)&15u);
    dma_mmio_write(h,5,source);
    dma_mmio_write(h,6,destination);
    dma_mmio_write(h,7,DMA_TEST_BYTES/64);
    dma_mmio_write(h,8,UINT64_C(0x80000000)|((uint64_t)mode<<26));
    struct timespec start,now,delay={0,1000000};clock_gettime(CLOCK_MONOTONIC,&start);
    for (unsigned poll=0;poll<10000;poll++) {
        uint64_t status=dma_status(h);
        if (status & UINT64_C(0x2480)) preserve_dma_owner("DMA response/engine error");
        if (!(status & 1u) && (status & 2u) && ((status>>28)&15u)==expected) return;
        clock_gettime(CLOCK_MONOTONIC,&now);
        if (now.tv_sec-start.tv_sec>=10) break;
        nanosleep(&delay,NULL);
    }
    preserve_dma_owner("DMA descriptor completion deadline");
}

/* Diagnostic: split only the host-bound write leg into legal 256-byte WRAP bursts. */
static void dma_one_transfer_bytes(fpga_handle h, unsigned mode, uint64_t source, uint64_t destination, unsigned bytes)
{
    uint64_t before=dma_status(h);
    if ((before & 1u) || !(before & 2u) || (before & UINT64_C(0x2480))) preserve_dma_owner("DMA not idle/error before descriptor");
    unsigned expected=(unsigned)(((before>>28)+1u)&15u);
    dma_mmio_write(h,5,source);
    dma_mmio_write(h,6,destination);
    if (bytes!=256) preserve_dma_owner("unreviewed chunk size");
    dma_mmio_write(h,7,bytes/64);
    dma_mmio_write(h,8,UINT64_C(0x80000000)|((uint64_t)mode<<26));
    struct timespec start,now,delay={0,1000000};clock_gettime(CLOCK_MONOTONIC,&start);
    for (unsigned poll=0;poll<10000;poll++) {
        uint64_t status=dma_status(h);
        if (status & UINT64_C(0x2480)) preserve_dma_owner("DMA response/engine error");
        if (!(status & 1u) && (status & 2u) && ((status>>28)&15u)==expected) return;
        clock_gettime(CLOCK_MONOTONIC,&now);
        if (now.tv_sec-start.tv_sec>=10) break;
        nanosleep(&delay,NULL);
    }
    preserve_dma_owner("DMA descriptor completion deadline");
}
int main(void)
{
    fpga_handle h=connect_to_accel(AFU_ACCEL_UUID);
    if (!h) return 1;
    void *src=mmap(NULL,DMA_TEST_PAGE,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS|MAP_32BIT,-1,0);
    void *dst=mmap(NULL,DMA_TEST_PAGE,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS|MAP_32BIT,-1,0);
    if (src==MAP_FAILED || dst==MAP_FAILED) { fprintf(stderr,"Low-address allocation failed\n");return 1; }
    uint64_t src_wsid=0,dst_wsid=0,src_iova=0,dst_iova=0;
    if (fpgaPrepareBuffer(h,DMA_TEST_PAGE,&src,&src_wsid,FPGA_BUF_PREALLOCATED)!=FPGA_OK) return 1;
    if (fpgaPrepareBuffer(h,DMA_TEST_PAGE,&dst,&dst_wsid,FPGA_BUF_PREALLOCATED)!=FPGA_OK) return 1;
    if (fpgaGetIOAddress(h,src_wsid,&src_iova)!=FPGA_OK || fpgaGetIOAddress(h,dst_wsid,&dst_iova)!=FPGA_OK) return 1;
    /* Original source-path geometry is preserved. Do not silently truncate an IOVA. */
    if ((src_iova&63u)||(dst_iova&63u)||src_iova>UINT64_C(0xffffffff)-DMA_TEST_PAGE||dst_iova>UINT64_C(0xffffffff)-DMA_TEST_PAGE) {
        fprintf(stderr,"IOVA outside the qualified original low32-bit datapath\n");
        fpgaReleaseBuffer(h,src_wsid);fpgaReleaseBuffer(h,dst_wsid);fpgaClose(h);return 1;
    }
    volatile uint64_t *s=src,*d=dst;
    for (unsigned i=0;i<DMA_TEST_BYTES/8;i++) { s[i]=i; d[i]=UINT64_C(0xa5a5a5a5a5a5a5a5); }
    printf("DMA test bank0 bytes=%u source_iova=0x%lx destination_iova=0x%lx\n",DMA_TEST_BYTES,src_iova,dst_iova);
    /* Single16-beat descriptor per direction is legal for the existing WRAP path.
       Distinct buffers stay pinned; source is never cleared during the roundtrip. */
    dma_one_transfer(h,1,src_iova,0);
    dma_one_transfer_bytes(h,2,0,dst_iova,256);
    dma_one_transfer_bytes(h,2,256,dst_iova+256,256);
    unsigned errors=0, delayed_errors=0, source_errors=0;
    struct timespec snapshot_begin, snapshot_later, snapshot_delay={0,100000000};
    clock_gettime(CLOCK_MONOTONIC,&snapshot_begin);
    printf("DMA_SNAPSHOT phase=immediate status=0x%016lx monotonic_sec=%ld monotonic_nsec=%ld\n", dma_status(h), (long)snapshot_begin.tv_sec, snapshot_begin.tv_nsec);
    for (unsigned i=0;i<DMA_TEST_BYTES/8;i++) {
        uint64_t actual=d[i], source_actual=s[i];
        if (actual!=(uint64_t)i) errors++;
        if (source_actual!=(uint64_t)i) source_errors++;
        printf("DMA_WORD phase=immediate index=%u expected=0x%016lx source=0x%016lx actual=0x%016lx\n",i,(uint64_t)i,source_actual,actual);
    }
    fflush(stdout);
    while (nanosleep(&snapshot_delay,&snapshot_delay)!=0) {
        if (errno!=EINTR) preserve_dma_owner("diagnostic snapshot delay failure");
    }
    clock_gettime(CLOCK_MONOTONIC,&snapshot_later);
    printf("DMA_SNAPSHOT phase=delayed status=0x%016lx monotonic_sec=%ld monotonic_nsec=%ld\n", dma_status(h), (long)snapshot_later.tv_sec, snapshot_later.tv_nsec);
    for (unsigned i=0;i<DMA_TEST_BYTES/8;i++) {
        uint64_t actual=d[i], source_actual=s[i];
        if (actual!=(uint64_t)i) delayed_errors++;
        if (source_actual!=(uint64_t)i) source_errors++;
        printf("DMA_WORD phase=delayed index=%u expected=0x%016lx source=0x%016lx actual=0x%016lx\n",i,(uint64_t)i,source_actual,actual);
    }
    printf("CHECK DMA diagnostic bank=0 bytes=%u words=%u immediate_errors=%u delayed_errors=%u source_errors=%u %s\n",DMA_TEST_BYTES,DMA_TEST_BYTES/8,errors,delayed_errors,source_errors,(errors||delayed_errors||source_errors)?"FAIL":"PASS");
    errors += delayed_errors + source_errors;
    if (fpgaReleaseBuffer(h,src_wsid)!=FPGA_OK || fpgaReleaseBuffer(h,dst_wsid)!=FPGA_OK || fpgaClose(h)!=FPGA_OK) return 1;
    munmap(src,DMA_TEST_PAGE);munmap(dst,DMA_TEST_PAGE);
    return errors?1:0;
}
