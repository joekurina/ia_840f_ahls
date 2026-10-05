// Copyright (C) 2022 Intel Corporation
// SPDX-License-Identifier: MIT

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <stdbool.h>
#include <math.h>
#include <errno.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>

// State from the AFU's JSON file, extracted using OPAE's afu_json_mgr script
#include "afu_json_info.h"

#define CLOCK_FREQ_TEST_AFU_ID  AFU_ACCEL_UUID  // Defined in afu_json_info.h

#define AFU_DFH_REG              0x0
#define AFU_ID_LO                0x8 
#define AFU_ID_HI                0x10
#define AFU_NEXT                 0x18

static int s_error_count = 0;
static double expected_user_mhz = 0;

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
#define ON_ERR_GOTO(res, label, desc)                    \
    do {                                       \
        if ((res) != FPGA_OK) {            \
            print_err((desc), (res));  \
            s_error_count += 1; \
            goto label;                \
        }                                  \
    } while (0)


void print_err(const char *s, fpga_result res)
{
    fprintf(stderr, "Error %s: %s\n", s, fpgaErrStr(res));
}


void mmio_read_64(fpga_handle afc_handle, uint64_t addr, uint64_t *data, const char *reg_name)
{
    fpga_result res = fpgaReadMMIO64(afc_handle, 0, addr, data);
    if (res != FPGA_OK)
    {
        print_err("mmio_read_64 failure", res);
        exit(1);
    }

    printf("Reading %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, *data);
}


void mmio_write_64(fpga_handle afc_handle, uint64_t addr, uint64_t data, const char *reg_name)
{
    fpga_result res = fpgaWriteMMIO64(afc_handle, 0, addr, data);
    if (res != FPGA_OK)
    {
        print_err("mmio_write_64 failure", res);
        exit(1);
    }
    printf("MMIO Write to %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, data);
}


void print_clock_freq(
    const char *name,
    double clock_counter,
    double pclock_counter,
    double pclock_freq
)
{
    printf("  %s \t%0.1f MHz\n", name, pclock_freq * clock_counter / pclock_counter);
}


void read_final_counters(fpga_handle afc_handle)
{
    uint64_t counter_pclk_value;
    mmio_read_64(afc_handle, 0x28*4, &counter_pclk_value, "counter_pclk_value");
    uint64_t counter_pclk_div2_value;
    mmio_read_64(afc_handle, 0x2a*4, &counter_pclk_div2_value, "counter_pclk_div2_value");
    uint64_t counter_pclk_div4_value;
    mmio_read_64(afc_handle, 0x2c*4, &counter_pclk_div4_value, "counter_pclk_div4_value");
    uint64_t counter_clkusr_value;
    mmio_read_64(afc_handle, 0x2e*4, &counter_clkusr_value, "counter_clkusr_value");
    uint64_t counter_clkusr_div2_value;
    mmio_read_64(afc_handle, 0x30*4, &counter_clkusr_div2_value, "counter_clkusr_div2_value");
    uint64_t counter_clk_value;
    mmio_read_64(afc_handle, 0x32*4, &counter_clk_value, "counter_clk_value");

    uint64_t pclk_freq_value;
    mmio_read_64(afc_handle, 0x34*4, &pclk_freq_value, "pclk_freq_value");
    float PCLK_FREQUENCY = (float)pclk_freq_value;
    if (!counter_pclk_value || !counter_pclk_div2_value || !counter_pclk_div4_value ||
        !counter_clkusr_value || !counter_clkusr_div2_value || !counter_clk_value ||
        pclk_freq_value != 470) { s_error_count++; fprintf(stderr,"Invalid clock counters/reference metadata\n"); return; }
    double d2=(double)counter_pclk_div2_value/counter_pclk_value;
    double d4=(double)counter_pclk_div4_value/counter_pclk_value;
    double u2=(double)counter_clkusr_div2_value/counter_clkusr_value;
    double au=(double)counter_clk_value/counter_clkusr_value;
    double user_mhz=(double)pclk_freq_value*counter_clkusr_value/counter_pclk_value;
    double tol=expected_user_mhz*0.01; if (tol < 1.0) tol=1.0;
    if (fabs(d2-0.5)>0.005 || fabs(d4-0.25)>0.0025 || fabs(u2-0.5)>0.005 || fabs(au-1.0)>0.01 || fabs(user_mhz-expected_user_mhz)>tol) {
        s_error_count++; fprintf(stderr,"Clock ratio/frequency check FAILED\n");
    } else printf("CHECK clock_ratios_and_packaged_frequency PASS expected=%.6f measured=%.6f tolerance=%.6f MHz\n",expected_user_mhz,user_mhz,tol);
    printf("pClk reference470MHz is platform metadata; frequencies are counter ratios, not independent absolute clock metrology.\n");


    printf("\nStandard clocks:\n");
    printf("  pClk \t\t%0.1f MHz\n", PCLK_FREQUENCY);
    print_clock_freq("pClkDiv2", counter_pclk_div2_value, counter_pclk_value, pclk_freq_value);
    print_clock_freq("pClkDiv4", counter_pclk_div4_value, counter_pclk_value, pclk_freq_value);
    print_clock_freq("uClk_usr", counter_clkusr_value, counter_pclk_value, pclk_freq_value);
    print_clock_freq("uClk_usrDiv2", counter_clkusr_div2_value, counter_pclk_value, pclk_freq_value);
    printf("\n");
    print_clock_freq("AFU clk", counter_clk_value, counter_pclk_value, pclk_freq_value);
    printf("\n");
}


//
// Is the FPGA real or simulated with ASE?
//
bool probe_for_ase()
{
    fpga_result r = FPGA_OK;
    uint16_t device_id = 0;
    fpga_properties filter = NULL;
    uint32_t num_matches = 1;
    fpga_token fme_token;

    // Connect to the FPGA management engine
    fpgaGetProperties(NULL, &filter);
    fpgaPropertiesSetObjectType(filter, FPGA_DEVICE);

    // Connecting to one is sufficient to find ASE.
    fpgaEnumerate(&filter, 1, &fme_token, 1, &num_matches);
    if (0 != num_matches)
    {
        // Retrieve the device ID of the FME
        fpgaGetProperties(fme_token, &filter);
        r = fpgaPropertiesGetDeviceID(filter, &device_id);
        fpgaDestroyToken(&fme_token);
    }
    fpgaDestroyProperties(&filter);

    // ASE's device ID is 0xa5e
    return ((FPGA_OK == r) && (0xa5e == device_id));
}


int main(int argc, char *argv[])
{
    fpga_properties    filter = NULL;
    fpga_token         afc_token;
    fpga_handle        afc_handle;
    fpga_guid          guid;
    uint32_t           num_matches;
    uint64_t           data;
    bool               use_ase;
    fpga_result        res = FPGA_OK;

    if (argc != 2) { fprintf(stderr, "Usage: clock_freq_test <packaged_uClk_MHz>\n"); return 1; }
    char *end = NULL; errno = 0; expected_user_mhz = strtod(argv[1], &end);
    if (errno || !end || *end || !isfinite(expected_user_mhz) || expected_user_mhz <= 0) return 1;
    use_ase = probe_for_ase();

    if (uuid_parse(CLOCK_FREQ_TEST_AFU_ID, guid) < 0) {
        fprintf(stderr, "Error parsing guid '%s'\n", CLOCK_FREQ_TEST_AFU_ID);
        s_error_count += 1;
        goto out_exit;
    }

    /* Look for AFC with MY_AFC_ID */
    res = fpgaGetProperties(NULL, &filter);
    ON_ERR_GOTO(res, out_exit, "creating properties object");

    res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
    ON_ERR_GOTO(res, out_destroy_prop, "setting object type");

    res = fpgaPropertiesSetGUID(filter, guid);
    ON_ERR_GOTO(res, out_destroy_prop, "setting GUID");

    /* TODO: Add selection via BDF / device ID */

    res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
    ON_ERR_GOTO(res, out_destroy_prop, "enumerating AFCs");

    if (num_matches < 1) {
        fprintf(stderr, "AFC not found.\n");
        res = fpgaDestroyProperties(&filter);
        return FPGA_INVALID_PARAM;
    }

    /* Open AFC and map MMIO */
    res = fpgaOpen(afc_token, &afc_handle, 0);
    ON_ERR_GOTO(res, out_destroy_tok, "opening AFC");

    res = fpgaMapMMIO(afc_handle, 0, NULL);
    ON_ERR_GOTO(res, out_close, "mapping MMIO space");

    printf("Running Test\n");

    mmio_write_64(afc_handle, 0x24*4, 0, "disable_counter");
    mmio_write_64(afc_handle, 0x22*4, 1, "reset_counter");
    usleep(1000); /* reset remains asserted across the existing clock synchronizers */
    // Set the number of cycles to count on pClk.  All other counters will be compared
    // to this.
    mmio_write_64(afc_handle, 0x26*4,
                 use_ase ? 0x10000 : 0x1000000,
                 "counter_max");
    // Disable counter reset
    mmio_write_64(afc_handle, 0x22*4, 0, "reset_counter");
    // Start counting
    mmio_write_64(afc_handle, 0x24*4, 1, "enable_counter");

    struct timespec deadline_start, poll_now;
    clock_gettime(CLOCK_MONOTONIC, &deadline_start);
    do
    {
        clock_gettime(CLOCK_MONOTONIC, &poll_now);
        if (poll_now.tv_sec - deadline_start.tv_sec >= 10) { s_error_count++; goto out_close; }
        // Counting is done when the status register's low bit is 1.
        usleep(use_ase ? 1000000 : 100000);
        mmio_read_64(afc_handle, 0x20*4, &data, "status_reg");
    }
    while ((data & 1) == 0);

    // Read counters and print frequencies
    read_final_counters(afc_handle);

    printf("Done Running Test\n");

    /* Unmap MMIO space */
    res = fpgaUnmapMMIO(afc_handle, 0);
    ON_ERR_GOTO(res, out_close, "unmapping MMIO space");

    /* Release accelerator */
out_close:
    res = fpgaClose(afc_handle);
    ON_ERR_GOTO(res, out_destroy_tok, "closing AFC");

    /* Destroy token */
out_destroy_tok:
    res = fpgaDestroyToken(&afc_token);
    ON_ERR_GOTO(res, out_destroy_prop, "destroying token");

    /* Destroy properties object */
out_destroy_prop:
    res = fpgaDestroyProperties(&filter);
    ON_ERR_GOTO(res, out_exit, "destroying properties object");

out_exit:
    if(s_error_count > 0)
        printf("Test FAILED!\n");

    return s_error_count;
}
