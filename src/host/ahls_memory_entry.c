/* Build the unchanged ahls_memory_inspect.c with main renamed to
 * ahls_memory_frontend_main. This bridge is loaded only by the separate launcher.
 */
#include <opae/init.h>
extern int ahls_memory_frontend_main(int argc, char **argv);
int ia840f_memory_initialize(const char *config)
{
    return fpgaInitialize(config) == FPGA_OK ? 0 : 1;
}
int ia840f_memory_entry(int argc, char **argv)
{
    return ahls_memory_frontend_main(argc, argv);
}
int ia840f_memory_finalize(void)
{
    return fpgaFinalize() == FPGA_OK ? 0 : 1;
}
