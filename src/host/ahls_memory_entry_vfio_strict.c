/* Additive alternative to ahls_memory_entry.c, which remains unchanged.
 * Requires the matching private strict-core symbol; no fpgaInitialize fallback.
 */
#include <opae/init.h>
#include "opae/ia840f_vfio_strict_init.h"
extern int ahls_memory_frontend_main(int argc, char **argv);
int ia840f_memory_initialize(const char *config)
{
    return ia840f_opae_initialize_vfio_strict(config) ? 1 : 0;
}
int ia840f_memory_entry(int argc, char **argv)
{
    return ahls_memory_frontend_main(argc, argv);
}
int ia840f_memory_finalize(void)
{
    return fpgaFinalize() == FPGA_OK ? 0 : 1;
}
