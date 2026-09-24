#ifndef IA840F_DMA_LIFETIME_H
#define IA840F_DMA_LIFETIME_H
#include "ia840f_dma_transfer_core.h"
int ia840f_dma_signals_block(void);
int ia840f_dma_wait_step(void *unused);
_Noreturn void ia840f_dma_hold(const char *reason, const struct ia840f_dma_report *report);
#endif
