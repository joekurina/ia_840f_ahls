#ifndef IA840F_VFIO_STRICT_INIT_H
#define IA840F_VFIO_STRICT_INIT_H
/* Private VFIO-only initialization; no legacy/DFL/default fallback. */
int ia840f_opae_initialize_vfio_strict(const char *config_file);
#endif
