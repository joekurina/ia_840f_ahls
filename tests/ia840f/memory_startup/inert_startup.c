#define _GNU_SOURCE
#include <fcntl.h>
#include <assert.h>
#include <unistd.h>
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
    const char *replace = getenv("STARTUP_REPLACE_CONFIG");
    if (replace) {
        FILE *file = fopen(replace, "w");
        assert(file);
        assert(fputs("{", file) >= 0);
        assert(fclose(file) == 0);
    }
}

fpga_result fpgaInitialize(const char *config)
{
    printf("STARTUP_INIT %s\n", config ? config : "NULL");
    fflush(stdout);
    assert(getenv("OPAE_EXPLICIT_INITIALIZE") && !getenv("WITH_ASE"));
    assert(!getenv("LIBOPAE_LOGFILE") && !getenv("LIBOPAE_LOG"));
    assert(config && !strcmp(config, getenv("LIBOPAE_CFGFILE")));
    int fd = open(config, O_RDONLY);
    assert(fd >= 0);
    int seals = fcntl(fd, F_GET_SEALS);
    assert(seals == (F_SEAL_WRITE | F_SEAL_GROW | F_SEAL_SHRINK | F_SEAL_SEAL));
    char text[32769];
    ssize_t size = read(fd, text, sizeof(text) - 1);
    assert(size > 0);
    text[size] = '\0';
    assert(strstr(text, "/work/sdk-build/lib/libxfpga.so"));
    close(fd);
    puts("STARTUP_CONFIG_SEALED");
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
