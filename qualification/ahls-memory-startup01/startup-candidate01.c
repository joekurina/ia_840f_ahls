/* Explicit startup for CAPS01 inspection. Not a hardware-access authorization.
 * This executable links only the SDK configuration parser, never libopae-c.
 * The entry module and every transitive runtime file require external binding.
 */
#define _GNU_SOURCE
#include "ahls_qualification_core.h"
#include "cfg-file.h"
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

extern libopae_config_data *opae_parse_libopae_json(const char *, const char *);

void opae_print(int level, const char *format, ...)
{
    (void)level;
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
}

static char *read_config(const char *path, size_t *length)
{
    struct stat st;
    int fd = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
    if (fd < 0) return NULL;
    if (fstat(fd, &st) || !S_ISREG(st.st_mode) ||
        st.st_size < 1 || st.st_size > 32768) {
        close(fd); return NULL;
    }
    size_t size = (size_t)st.st_size;
    char *text = malloc(size + 1);
    if (!text) { close(fd); return NULL; }
    size_t used = 0;
    while (used < size) {
        ssize_t n = read(fd, text + used, size - used);
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) { free(text); close(fd); return NULL; }
        used += (size_t)n;
    }
    char extra;
    ssize_t n;
    do { n = read(fd, &extra, 1); } while (n < 0 && errno == EINTR);
    close(fd);
    if (n != 0 || memchr(text, '\0', size)) { free(text); return NULL; }
    text[size] = '\0';
    *length = size;
    return text;
}

static int exact_dfl_config(const char *text)
{
    char *copy = strdup(text);
    if (!copy) return 0;
    /* Call the parser directly: never use its default-table fallback wrapper. */
    libopae_config_data *rows = opae_parse_libopae_json("explicit-config", copy);
    if (!rows) return 0;
    size_t i = 0;
    for (; rows[i].module_library; ++i) {
        if (i >= 2 || rows[i].vendor_id != 0x8086 ||
            rows[i].device_id != (i == 0 ? 0xbcce : 0xbccf) ||
            rows[i].subsystem_vendor_id != 0x8086 ||
            rows[i].subsystem_device_id != 0x1771 ||
            strcmp(rows[i].module_library, "/work/sdk-build/lib/libxfpga.so") ||
            !rows[i].config_json || strcmp(rows[i].config_json, "{}")) break;
    }
    int ok = i == 2 && !rows[i].module_library;
    opae_free_libopae_config(rows);
    return ok;
}

static int seal_config(const char *text, size_t length)
{
    int fd = memfd_create("ia840f-opae-config", MFD_CLOEXEC | MFD_ALLOW_SEALING);
    if (fd < 0) return -1;
    size_t used = 0;
    while (used < length) {
        ssize_t n = write(fd, text + used, length - used);
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) { close(fd); return -1; }
        used += (size_t)n;
    }
    if (fcntl(fd, F_ADD_SEALS, F_SEAL_WRITE | F_SEAL_GROW |
              F_SEAL_SHRINK | F_SEAL_SEAL) < 0 || lseek(fd, 0, SEEK_SET) < 0) {
        close(fd); return -1;
    }
    return fd;
}

int main(int argc, char **argv)
{
    uint16_t segment;
    uint8_t bus, device, function;
    if (argc != 7 || strcmp(argv[1], "--config") ||
        strcmp(argv[3], "--module") ||
        strcmp(argv[5], "--inspect-qualified-memory-afu") ||
        ahls_parse_bdf(argv[6], &segment, &bus, &device, &function)) {
        fprintf(stderr, "Usage (separately authorized hardware only): %s "
                "--config FILE --module ABSOLUTE_MODULE "
                "--inspect-qualified-memory-afu dddd:bb:dd.f\n", argv[0]);
        return 2;
    }
    size_t length = 0;
    char *text = read_config(argv[2], &length);
    if (!text || !exact_dfl_config(text)) {
        free(text);
        fprintf(stderr, "FAIL configuration; no default or backend fallback.\n");
        return 2;
    }
    struct stat st;
    if (argv[4][0] != '/' || stat(argv[4], &st) || !S_ISREG(st.st_mode)) {
        free(text); fprintf(stderr, "FAIL entry module path.\n"); return 2;
    }
    int config_fd = seal_config(text, length);
    free(text);
    if (config_fd < 0) { perror("sealed configuration"); return 1; }
    char config_path[64];
    int count = snprintf(config_path, sizeof(config_path), "/proc/self/fd/%d", config_fd);
    if (count < 0 || (size_t)count >= sizeof(config_path) ||
        setenv("OPAE_EXPLICIT_INITIALIZE", "1", 1) ||
        setenv("LIBOPAE_CFGFILE", config_path, 1) ||
        unsetenv("WITH_ASE") || unsetenv("LIBOPAE_LOGFILE") ||
        unsetenv("LIBOPAE_LOG")) {
        close(config_fd); fprintf(stderr, "FAIL startup environment.\n"); return 1;
    }
    /* No OPAE-linked object is loaded until the checks above have completed.
     * This does not bind arbitrary module bytes or control its dependencies. */
    void *module = dlopen(argv[4], RTLD_NOW | RTLD_LOCAL);
    if (!module) { fprintf(stderr, "FAIL dlopen: %s\n", dlerror()); close(config_fd); return 1; }
    int (*initialize)(const char *) = NULL;
    int (*entry)(int, char **) = NULL;
    int (*finalize)(void) = NULL;
    _Static_assert(sizeof(initialize) == sizeof(void *), "POSIX function-pointer ABI required");
    _Static_assert(sizeof(entry) == sizeof(void *), "POSIX function-pointer ABI required");
    _Static_assert(sizeof(finalize) == sizeof(void *), "POSIX function-pointer ABI required");
    void *symbol = dlsym(module, "ia840f_memory_initialize");
    memcpy(&initialize, &symbol, sizeof(initialize));
    symbol = dlsym(module, "ia840f_memory_entry");
    memcpy(&entry, &symbol, sizeof(entry));
    symbol = dlsym(module, "ia840f_memory_finalize");
    memcpy(&finalize, &symbol, sizeof(finalize));
    if (!initialize || !entry || !finalize) {
        fprintf(stderr, "FAIL entry ABI; no initialization attempted.\n");
        close(config_fd); return 1;
    }
    if (initialize(config_path)) {
        fprintf(stderr, "FAIL explicit initialization; no retry or application call.\n");
        close(config_fd); return 1;
    }
    char *forward[] = {argv[0], argv[5], argv[6], NULL};
    int result = entry(3, forward);
    if (finalize()) result = 1;
    /* Keep the module resident until process exit; no forced unload/recovery.
     * Explicit-init remains set, so OPAE's destructor does not finalize again. */
    close(config_fd);
    return result;
}
