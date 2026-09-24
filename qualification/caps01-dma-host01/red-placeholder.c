#include "ia840f_dma_transfer_core.h"
#include <string.h>
int ia840f_dma_status_quiescent(uint64_t s){(void)s;return 0;}
enum ia840f_dma_result ia840f_dma_transfer(const struct ia840f_dma_io*i,const struct ia840f_dma_request*q,struct ia840f_dma_report*r){(void)i;(void)q;memset(r,0,sizeof(*r));return IA840F_DMA_INVALID;}
