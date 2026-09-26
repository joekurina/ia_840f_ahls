#ifndef IA840F_VFIO_CONFIG_H
#define IA840F_VFIO_CONFIG_H
#include "cfg-file.h"
#include <string.h>
/* Effective parser table, not device isolation or a loader-path guarantee.
 * The captured VFIO matcher requires this exact basename, not an absolute path.
 */
static inline int ia840f_vfio_config_matches(const libopae_config_data *rows)
{
    return rows && rows[0].module_library &&
        rows[0].vendor_id == 0x8086 && rows[0].device_id == 0xbccf &&
        rows[0].subsystem_vendor_id == 0x8086 &&
        rows[0].subsystem_device_id == 0x1771 && !rows[0].flags &&
        !strcmp(rows[0].module_library, "libopae-v.so") &&
        rows[0].config_json && !strcmp(rows[0].config_json, "{}") &&
        !rows[1].module_library;
}
#endif
