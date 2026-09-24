/* IA-840F opt-in addition for the bound OPAE 2.13 pluginmgr.c.
 * Append this include to an isolated copy; preserve the original file bytes.
 * This is not a hardware-access authorization or a backend-recovery policy.
 */
extern libopae_config_data *opae_parse_libopae_json(const char *, const char *);
static int ia840f_strict_attempted;

static int ia840f_strict_table_matches(const libopae_config_data *rows)
{
    size_t i = 0;
    if (!rows) return 0;
    for (; rows[i].module_library; ++i) {
        if (i >= 2 || rows[i].vendor_id != 0x8086 ||
            rows[i].device_id != (i == 0 ? 0xbcce : 0xbccf) ||
            rows[i].subsystem_vendor_id != 0x8086 ||
            rows[i].subsystem_device_id != 0x1771 || rows[i].flags ||
            strcmp(rows[i].module_library,"/work/sdk-build/lib/libxfpga.so") ||
            !rows[i].config_json || strcmp(rows[i].config_json,"{}")) return 0;
    }
    return i == 2;
}

__attribute__((visibility("default")))
int ia840f_opae_initialize_strict(const char *cfg_file)
{
    int lock_rc, errors = 1, platforms_detected = 0;
    char *raw;
    libopae_config_data *table;
    if (opae_mutex_lock(lock_rc, &adapter_list_lock)) return 1;
    /* One attempt in a fresh process; never reuse unknown legacy/partial state. */
    if (ia840f_strict_attempted || initialized || finalizing || adapter_list ||
        platform_data_table) goto out_unlock;
    ia840f_strict_attempted = 1;
    if (!cfg_file || cfg_file[0] != '/' ||
        !getenv("OPAE_EXPLICIT_INITIALIZE") || getenv("WITH_ASE")) goto out_unlock;

    /* Caller supplies its sealed regular-file snapshot. No path discovery and
     * no default-returning parse wrapper, including read/allocation failures. */
    raw = opae_read_cfg_file(cfg_file);
    if (!raw) goto out_unlock;
    table = opae_parse_libopae_json(cfg_file, raw); /* consumes raw */
    if (!ia840f_strict_table_matches(table)) {
        opae_free_libopae_config(table);
        goto out_unlock;
    }
    platform_data_table = table;
    initialized = 1; /* preserve SDK reentrancy guard while loading */
    errors = opae_plugin_mgr_load_plugins(&platforms_detected);
    if (!errors && platforms_detected && adapter_list)
        errors = opae_plugin_mgr_initialize_all();
    else if (!errors)
        errors = 1; /* no detected/registered adapter is not success */
    initialized = errors == 0;
    if (!initialized) {
        opae_free_libopae_config(platform_data_table);
        platform_data_table = NULL;
    }
    /* Partial adapter state is deliberately not retried or force-unloaded.
     * Caller must stop on error; this does not qualify real backend cleanup. */
out_unlock:
    if (opae_mutex_unlock(lock_rc, &adapter_list_lock)) return 1;
    return errors;
}
