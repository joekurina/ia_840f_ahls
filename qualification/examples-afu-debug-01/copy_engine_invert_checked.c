// Copyright (C) 2022 Intel Corporation
// SPDX-License-Identifier: MIT

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <poll.h>
#include <pthread.h>
#include <time.h>
#include <string.h>
#include <signal.h>
#include <errno.h>

#include <opae/fpga.h>

typedef struct
{
    volatile char *ptr;
    uint64_t wsid;
    uint64_t pa;
}
t_pinned_buffer;

static fpga_handle s_accel_handle;
static int qualification_cleanup_errors;
static int qualification_api_error;
static bool s_is_ase_sim;
static volatile uint64_t *s_mmio_buf;

// Shorter runs for ASE
#define TOTAL_COPY_COMMANDS 32L /* one command per retained buffer; functional qualification, not throughput benchmark */

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
    if (r!=FPGA_OK) { fpgaReleaseBuffer(accel_handle,*wsid); return NULL; }

    return buf;
}


//
// Allocate a group of pinned buffers that will be used round-robin in
// the command loop.
//
static t_pinned_buffer* alloc_buffer_group(fpga_handle accel_handle,
                                           ssize_t size,
                                           uint32_t num_bufs)
{
    t_pinned_buffer *bufs;
    bufs = malloc(sizeof(t_pinned_buffer) * num_bufs);
    assert(NULL != bufs);

    for (uint32_t i = 0; i < num_bufs; i += 1)
    {
        // Allocate a single page memory buffer
        bufs[i].ptr = (volatile char*)alloc_buffer(accel_handle, size,
                                                   &bufs[i].wsid, &bufs[i].pa);
        if (NULL == bufs[i].ptr)
        {
            fprintf(stderr, "Pinned buffer allocation failed!\n");
            for (uint32_t j=0;j<i;j++) if (fpgaReleaseBuffer(accel_handle,bufs[j].wsid)!=FPGA_OK) qualification_cleanup_errors++;
            free(bufs);
            return NULL;
        }

        bufs[i].ptr[0] = 0;
    }

    return bufs;
}


static void free_buffer_group(fpga_handle accel_handle,
                              uint32_t num_bufs,
                              t_pinned_buffer* bufs)
{

    for (uint32_t i = 0; i < num_bufs; i += 1)
    {
        if (fpgaReleaseBuffer(accel_handle, bufs[i].wsid)!=FPGA_OK) qualification_cleanup_errors++;
    }

    free(bufs);
}


//
// Read a 64 bit CSR. When a pointer to CSR buffer is available, read directly.
// Direct reads can be significantly faster.
//
static inline uint64_t readMMIO64(uint32_t idx)
{
    if (s_mmio_buf)
    {
        return s_mmio_buf[idx];
    }
    else
    {
        fpga_result r;
        uint64_t v;
        r = fpgaReadMMIO64(s_accel_handle, 0, 8 * idx, &v);
        if (r!=FPGA_OK) { qualification_api_error=1; fprintf(stderr,"MMIO read failed\n"); return 0; }
        return v;
    }
}


//
// Write a 64 bit CSR. When a pointer to CSR buffer is available, write directly.
//
static inline void writeMMIO64(uint32_t idx, uint64_t v)
{
    if (s_mmio_buf)
    {
        s_mmio_buf[idx] = v;
    }
    else
    {
        fpga_result r = fpgaWriteMMIO64(s_accel_handle, 0, 8 * idx, v);
        if (r != FPGA_OK) { qualification_api_error=1; fprintf(stderr,"MMIO write failed\n"); }
    }
}


static fpga_event_handle intr_handle;

//
// Thread created by pthread to handle interrupts and update the credit count.
//
static void* intr_wait_thread(void *args)
{
    fpga_result result;

    volatile uint64_t *num_intrs_rcvd = args;

    int fd;
    result = fpgaGetOSObjectFromEventHandle(intr_handle, &fd);
    assert(FPGA_OK == result);

    while (true)
    {
        uint64_t count;
        ssize_t bytes_read = read(fd, &count, sizeof(count));
        if (bytes_read <= 0)
        {
            fprintf(stderr, "read error: %s\n",
                    (bytes_read < 0 ? strerror(errno) : "zero bytes read"));
            pthread_exit((void*)1);
        }

        // Count should be 1. The AFU is expected to wait for the MMIO write
        // to register 12 below before sending another interrupt. PCIe does
        // not guarantee to deliver all interrupts unless each one is
        // acknowledged by software. (See PCIe spec. 6.1.4.6)
        // You could, in theory, modify the AFU and protocol here to
        // handle missed delivery of interrupts, though using a host memory
        // location to signal completion remains a faster option than
        // interrupts.
        if (count != 1)
        {
            fprintf(stderr, "count error: %ld\n", count);
            pthread_exit((void*)1);
        }

        *num_intrs_rcvd += 1;
        writeMMIO64(12, 0);
    }

    // Success
    pthread_exit(NULL);
}


static int copy_qualification_wait(volatile uint64_t *status, uint64_t used, uint64_t limit, bool final, uint64_t base, const struct timespec *start)
{
    struct timespec now, delay={0,1000000};
    for (unsigned poll=0;poll<30000;poll++) {
        if (qualification_api_error) return -1;
        uint64_t completed=*status-base;
        if (completed>used) return -1;
        if (final ? completed==used : used-completed<limit) return 0;
        clock_gettime(CLOCK_MONOTONIC,&now);
        if (now.tv_sec-start->tv_sec>=30) { fprintf(stderr,"Copy completion deadline\n");return -1; }
        nanosleep(&delay,NULL);
    }
    return -1;
}

int copy_engine(
    fpga_handle accel_handle, bool is_ase_sim,
    uint32_t chunk_size,
    uint32_t completion_freq,
    bool use_interrupts,
    uint32_t max_reqs_in_flight)
{
    fpga_result r;
    pthread_t intr_thread = 0;

    s_accel_handle = accel_handle;
    qualification_cleanup_errors = 0;
    qualification_api_error = 0;
    s_is_ase_sim = is_ase_sim;
    if (use_interrupts) { fprintf(stderr,"Qualification uses memory completion mode\n"); return 1; }
    completion_freq = 1;

    // Get a pointer to the MMIO buffer for direct access. The OPAE functions will
    // be used with ASE since true MMIO isn't detected by the SW simulator.
    if (1) /* use the original OPAE API fallback for checked register accesses */
    {
        s_mmio_buf = NULL;
    }
    else
    {
        uint64_t *tmp_ptr;
        r = fpgaMapMMIO(accel_handle, 0, &tmp_ptr);
        assert(FPGA_OK == r);
        s_mmio_buf = tmp_ptr;
    }

    // Get AFU info
    uint64_t v = readMMIO64(5);
    const uint32_t clock_mhz = v & 0xffff;
    const uint32_t data_bus_num_bytes = (v >> 16) & 0xff;
    const uint32_t num_interrupt_ids = (v >> 24) & 0xff;
    const uint32_t max_avail_reqs_in_flight = (v >> 32) & 0xffff;
    const uint32_t max_burst_len = (v >> 48) & 0xffff;

    if (qualification_api_error || !data_bus_num_bytes || (data_bus_num_bytes&(data_bus_num_bytes-1)) || !max_avail_reqs_in_flight || !max_burst_len) return 1;
    printf("AFU properties:\n");
    printf("  Clock MHz: %d\n", clock_mhz);
    printf("  Data bus number of bytes: %d\n", data_bus_num_bytes);
    printf("  Number of interrupt IDs available: %d\n", num_interrupt_ids);
    printf("  Maximum burst length: %d\n", max_burst_len);
    printf("  Maximum allowed requests in flight: %d\n", max_avail_reqs_in_flight);
    printf("\n");

    uint32_t rounded_chunk_size = (chunk_size + data_bus_num_bytes - 1) &
                                  ~(data_bus_num_bytes - 1);
    if (rounded_chunk_size > (max_burst_len * data_bus_num_bytes))
    {
        rounded_chunk_size = max_burst_len * data_bus_num_bytes;
    }
    if (rounded_chunk_size != chunk_size)
    {
        printf("Aligned requested chunk size to bus: %d -> %d\n",
               chunk_size, rounded_chunk_size);
        chunk_size = rounded_chunk_size;
    }

    if ((max_reqs_in_flight == 0) || (max_reqs_in_flight > max_avail_reqs_in_flight))
        max_reqs_in_flight = max_avail_reqs_in_flight;

    if (completion_freq == 0)
    {
        // Default completion frequency: 1/8th of the max. requests
        completion_freq = max_reqs_in_flight / 8;
        if (completion_freq == 0) completion_freq = 1;
    }
    else if (completion_freq > max_reqs_in_flight)
    {
        // Can't wait too long for completion messages or there will be
        // no credit to send more requests.
        completion_freq = max_reqs_in_flight;
    }
    
    // completion_freq and max_reqs_in_flight should be powers of 2. This is
    // supposed to be guaranteed by the command line processing, but check here.
    if ((completion_freq & (completion_freq - 1)) != 0) {
        fprintf(stderr, "Completion frequency must be a power of 2: %d\n", completion_freq);
        return -1;
    }
    if ((max_reqs_in_flight & (max_reqs_in_flight - 1)) != 0) {
        fprintf(stderr, "Maximum requests in flight must be a power of 2: %d\n", max_reqs_in_flight);
        return -1;
    }


    printf("Test parameters:\n");
    printf("  Chunk size (bytes per read or write request): %d\n", chunk_size);
    printf("  Completion frequency (commands between completions): %d\n", completion_freq);
    printf("  Use interrupts: %s\n", use_interrupts ? "Yes" : "No");
    printf("  Maximum requests in flight: %d\n", max_reqs_in_flight);
    printf("\n");


    t_pinned_buffer *src_bufs;
    t_pinned_buffer *dst_bufs;
    const uint32_t num_bufs = 32;

    // Use 4KB buffers as long as they are large enough for each copy command.
    // When copies are longer than 4KB, request 2MB pages instead. Of course
    // this algorithm could be improved and is wasting most of the 2MB pages,
    // but it works for an example. Runs will fail if 2MB huge pages aren't
    // available.
    ssize_t buf_size = sysconf(_SC_PAGESIZE);
    if (chunk_size > buf_size) buf_size *= 512;

    src_bufs = alloc_buffer_group(accel_handle, buf_size, num_bufs);
    if (NULL == src_bufs) return -1;
    dst_bufs = alloc_buffer_group(accel_handle, buf_size, num_bufs);
    if (NULL == dst_bufs) {
        free_buffer_group(accel_handle, num_bufs, src_bufs);
        return -1;
    }


    for (uint32_t b=0;b<num_bufs;b++) for (uint32_t j=0;j<chunk_size;j++) {
        src_bufs[b].ptr[j]=(char)((b*37u+j*13u+0x52u)&255u);
        dst_bufs[b].ptr[j]=(char)0xa5;
    }

    volatile uint64_t *status_line;
    bool status_allocated=false;
    uint64_t status_wsid = 0;
    uint64_t status_line_pa = 0;

    if (use_interrupts)
    {
        // Interrupt mode. The status line is managed in the intr_wait_thread.
        static uint64_t local_status_line;
        status_line = &local_status_line;

        // Allocate a handle
        r = fpgaCreateEventHandle(&intr_handle);
        assert(FPGA_OK == r);

        // Register user interrupt with event handle
        r = fpgaRegisterEvent(accel_handle, FPGA_EVENT_INTERRUPT, intr_handle, 0);
        assert(FPGA_OK == r);

        // An external thread will wait for interrupts and update the
        // count of committed commands in status_line[0].
        pthread_create(&intr_thread, NULL, &intr_wait_thread, (void*)status_line);
    }
    else
    {
        // No interrupts. The status line will be written only by the FPGA.
        status_line = (volatile uint64_t*)alloc_buffer(accel_handle, sysconf(_SC_PAGESIZE),
                                                       &status_wsid, &status_line_pa);
        if (!status_line) { free_buffer_group(accel_handle,num_bufs,src_bufs);free_buffer_group(accel_handle,num_bufs,dst_bufs);return 1; }
        status_allocated=true;

        status_line[0] = 0;
        // Set the completion status line address in the AFU. This tells it
        // to use host memory writes for completion notification instead of
        // interrupts.
        writeMMIO64(13, status_line_pa | 1);
    }


    // AXI-MM request length: number of bus-width beats minus 1
    const uint64_t burst_len = (chunk_size / data_bus_num_bytes) - 1;
    // Set the length by writing CSRs
    writeMMIO64(8, burst_len);
    writeMMIO64(10, burst_len);

    // Required credit to send a new request. When interrupts are not used, the
    // status line updates are always the total number of commands processed,
    // independent of the frequency with which status updates are written.
    uint64_t required_credit = max_reqs_in_flight;
    if (use_interrupts)
    {
        // When interrupts are used, status_line[0] is the count of interrupts
        // and not the count of commands processed. Both values here are
        // guaranteed to be powers of 2.
        required_credit = max_reqs_in_flight / completion_freq;
    }

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);


    // ====================================================================
    //
    // Primary command loop
    //
    // ====================================================================

    const uint64_t baseline_rd_lines=readMMIO64(6), baseline_wr_lines=readMMIO64(7);
    if (qualification_api_error) goto active_failure;
    writeMMIO64(9,src_bufs[0].pa);
    if (qualification_api_error) goto active_failure;
    writeMMIO64(11,dst_bufs[0].pa|1);
    if (qualification_api_error) goto active_failure;
    /* First completion reveals the cumulative command baseline. */
    struct timespec baseline_now, baseline_delay={0,1000000};
    for (unsigned poll=0;status_line[0]==0;poll++) {
        clock_gettime(CLOCK_MONOTONIC,&baseline_now);
        if (poll>=30000 || baseline_now.tv_sec-start_time.tv_sec>=30) goto active_failure;
        nanosleep(&baseline_delay,NULL);
    }
    const uint64_t completion_base=status_line[0]-1;
    uint64_t credits_used = 1;
    for (uint64_t i = 1; i < TOTAL_COPY_COMMANDS; i += 1)
    {
        // Wait until the credit threshold says more commands can be written.
        // The status line will be updated either by writes from the FPGA or,
        // in interrupt mode, by intr_wait_thread() above.
        if (copy_qualification_wait(&status_line[0], credits_used, required_credit, false, completion_base, &start_time)!=0) goto active_failure;

        // Read command. Writing the address triggers the read.
        uint32_t buf_idx = i & (num_bufs - 1);
        writeMMIO64(9, src_bufs[buf_idx].pa);
        if (qualification_api_error) goto active_failure;

        // Bit 0 of the write command indicates whether to generate a
        // completion (interrupt or status line write).
        uint32_t need_cpl = (i & (completion_freq-1)) == (completion_freq-1);
        // A completion is always required on the last command.
        if (i == TOTAL_COPY_COMMANDS-1) need_cpl = 1;
        writeMMIO64(11, dst_bufs[buf_idx].pa | need_cpl);
        if (qualification_api_error) goto active_failure;

        if (use_interrupts)
            // For interrupts, each command requesting an interrupt consumes a credit
            credits_used += need_cpl;
        else
            // For status line credit updates, each command consumes a credit
            credits_used += 1;
    }


    // Wait for the last command to finish
    if (copy_qualification_wait(&status_line[0], credits_used, required_credit, true, completion_base, &start_time)!=0) goto active_failure;

    clock_gettime(CLOCK_MONOTONIC, &end_time);
    double total_sec = end_time.tv_sec - start_time.tv_sec +
                       1e-9 * (end_time.tv_nsec - start_time.tv_nsec);

    if (use_interrupts)
    {
        pthread_cancel(intr_thread);
        void *retval = NULL;
        pthread_join(intr_thread, &retval);
        if (PTHREAD_CANCELED != retval)
        {
            fprintf(stderr, "pthread_cancel failed!\n");
        }

        r = fpgaUnregisterEvent(accel_handle, FPGA_EVENT_INTERRUPT, intr_handle);
        assert(FPGA_OK == r);
    }

    // Gather statistics
    const uint64_t rd_lines = readMMIO64(6)-baseline_rd_lines;
    printf("Total lines read: %ld\n", rd_lines);
    const uint64_t wr_lines = readMMIO64(7)-baseline_wr_lines;
    printf("Total lines written: %ld\n", wr_lines);
    const uint64_t total_bytes = (rd_lines + wr_lines) * data_bus_num_bytes;
    const double total_gb = total_bytes / 1073741824.0;
    printf("Total data moved (GB): %f\n", total_gb);
    printf("Total time: %f (sec)\n", total_sec);
    printf("Throughput %0.2f GB/s\n", total_gb / total_sec);

    int qualification_errors=0;
    unsigned qualification_mismatch_samples=0;
    for (uint32_t b=0;b<num_bufs;b++) for (uint32_t j=0;j<chunk_size;j++) {
        /* Tutorial data_stream_engine applies bitwise NOT, not identity. */
        unsigned char source_byte=(unsigned char)((b*37u+j*13u+0x52u)&255u);
        unsigned char expected=(unsigned char)~source_byte;
        unsigned char observed=(unsigned char)dst_bufs[b].ptr[j];
        if (observed != expected) {
            qualification_errors++;
            if (qualification_mismatch_samples++ < 8)
                printf("MISMATCH buffer=%u byte=%u source=%02x expected_inverted=%02x observed=%02x\n", b, j, source_byte, expected, observed);
        }
    }
    printf("CHECK copy_payload transform=bitwise_not buffers=%u bytes_per_buffer=%u errors=%d %s\n",num_bufs,chunk_size,qualification_errors,qualification_errors?"FAIL":"PASS");
    // What was the expected total data?

    const uint64_t total_expected_bytes = TOTAL_COPY_COMMANDS * 2 * chunk_size;
    if (total_expected_bytes != total_bytes)
    {
        qualification_errors++;
        printf("\n*** Expected %ld bytes but counted %ld ***\n",
               total_expected_bytes, total_bytes);
    }
    if (rd_lines != wr_lines)
    {
        qualification_errors++;
        printf("\n*** Mismatch between read lines (%ld) and write lines (%ld) ***\n",
               rd_lines, wr_lines);
    }

    free_buffer_group(accel_handle, num_bufs, src_bufs);
    free_buffer_group(accel_handle, num_bufs, dst_bufs);

    if (status_allocated && fpgaReleaseBuffer(accel_handle,status_wsid)!=FPGA_OK) qualification_errors++;
    qualification_errors += qualification_cleanup_errors;
    return (qualification_errors || qualification_api_error) ? 1 : 0;
active_failure:
    /* Stop issuing commands. Keep workspaces registered until the enclosing
       main performs normal supported OPAE handle-close cleanup; never unpin a
       potentially active destination early and never park/duplicate the job. */
    fprintf(stderr,"Copy transfer/API failure; normal handle-close cleanup\n");
    free(src_bufs);free(dst_bufs);
    return 1;
}
