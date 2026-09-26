/* Append only to an owned copy of the captured VFIO plugin.c.
 * Compile that copy with
 * opae_plugin_configure=ia840f_vfio_legacy_configure.
 * Original configure/initialize/finalize functions remain available.
 */
#include "ia840f_vfio_config.h"
extern libopae_config_data *opae_parse_libopae_json(const char *, const char *);
static int ia840f_vfio_plugin_attempted;

int ia840f_vfio_plugin_initialize_strict(void)
{
    const char *path;
    char *raw;
    libopae_config_data *table;
    /* One startup attempt; finalization cannot silently enable a retry. */
    if (ia840f_vfio_plugin_attempted || opae_v_supported_devices) return 1;
    ia840f_vfio_plugin_attempted = 1;
    path = getenv("LIBOPAE_CFGFILE");
    if (!path || path[0] != '/' || !getenv("OPAE_EXPLICIT_INITIALIZE") ||
        getenv("WITH_ASE")) return 1;
    /* The matched launcher supplies its stable sealed memfd path.
     * Neither discovery of another config nor the SDK default wrapper is used.
     */
    raw = opae_read_cfg_file(path);
    if (!raw) return 1;
    table = opae_parse_libopae_json(path, raw); /* consumes raw */
    if (!ia840f_vfio_config_matches(table)) {
        opae_free_libopae_config(table);
        return 1;
    }
    opae_v_supported_devices = table;
    /* Ordinary supported enumeration behavior is unchanged after admission.
     * No success here proves a matching token, isolation, or safe MMIO.
     */
    return vfio_pci_discover(NULL);
}

#undef opae_plugin_configure
int __VFIO_API__ opae_plugin_configure(opae_api_adapter_table *adapter,
                                      const char *json_config)
{
    int rc = ia840f_vfio_legacy_configure(adapter, json_config);
    if (!rc) adapter->initialize = ia840f_vfio_plugin_initialize_strict;
    return rc;
}
