#ifndef IA840F_STRICT_INIT_H
#define IA840F_STRICT_INIT_H
/* Private additive API: zero on successful exact-config initialization.
 * Only the matching source-bound core supplies this symbol. No legacy fallback.
 * Caller must use explicit startup and stop after any nonzero result.
 */
int ia840f_opae_initialize_strict(const char *config_file);
#endif
