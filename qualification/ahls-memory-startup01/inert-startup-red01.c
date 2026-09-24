#include <opae/init.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__attribute__((constructor)) static void startup_ctor(void)
{
    printf("STARTUP_CTOR explicit=%d ase=%d logfile=%d\n",
           getenv("OPAE_EXPLICIT_INITIALIZE") != NULL,
           getenv("WITH_ASE") != NULL, getenv("LIBOPAE_LOGFILE") != NULL);
    fflush(stdout);
}

fpga_result fpgaInitialize(const char *config)
{
    printf("STARTUP_INIT %s\n", config ? config : "NULL");
    fflush(stdout);
    const char *fault = getenv("STARTUP_FAIL_INIT");
    return fault && !strcmp(fault, "1") ? FPGA_EXCEPTION : FPGA_OK;
}

fpga_result fpgaFinalize(void)
{
    puts("STARTUP_FINALIZE");
    fflush(stdout);
    const char *fault = getenv("STARTUP_FAIL_FINALIZE");
    return fault && !strcmp(fault, "1") ? FPGA_EXCEPTION : FPGA_OK;
}
