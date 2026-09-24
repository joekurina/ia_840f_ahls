#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cfg-file.h"

/* Test logger only: the runtime constructor and plugin manager are not linked. */
void opae_print(int level, const char *format, ...)
{
    (void)level;
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
}

int main(int argc, char **argv)
{
    if (argc != 2) return 2;
    char *input = NULL;
    if (strcmp(argv[1], "--null") != 0) {
        FILE *file = fopen(argv[1], "rb");
        if (!file) return 3;
        if (fseek(file, 0, SEEK_END) != 0) { fclose(file); return 4; }
        long size = ftell(file);
        if (size < 0 || size > 32768 || fseek(file, 0, SEEK_SET) != 0) {
            fclose(file); return 5;
        }
        input = malloc((size_t)size + 1);
        if (!input) { fclose(file); return 6; }
        if (fread(input, 1, (size_t)size, file) != (size_t)size) {
            free(input); fclose(file); return 7;
        }
        input[size] = '\0';
        if (fclose(file) != 0) { free(input); return 8; }
    }
    /* This actual SDK parser takes ownership of input; no backend is loaded. */
    libopae_config_data *table = opae_parse_libopae_config(argv[1], input);
    if (!table) return 9;
    size_t rows = 0;
    for (libopae_config_data *p = table; p->module_library; ++p) {
        if (++rows > 512) { opae_free_libopae_config(table); return 10; }
        printf("%04x %04x %04x %04x %s %s\n",
               (unsigned)p->vendor_id, (unsigned)p->device_id,
               (unsigned)p->subsystem_vendor_id,
               (unsigned)p->subsystem_device_id,
               p->module_library, p->config_json);
    }
    opae_free_libopae_config(table);
    return 0;
}
