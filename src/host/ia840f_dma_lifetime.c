#define _POSIX_C_SOURCE 200809L
#include "ia840f_dma_lifetime.h"
#include <inttypes.h>
#include <signal.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>

int ia840f_dma_signals_block(void)
{
    /* Startup calls this before dlopen/OPAE init, so any new threads inherit it.
     * SIGKILL, fatal faults, OOM and host loss are outside this containment. */
    sigset_t all;
    return sigfillset(&all) || sigprocmask(SIG_BLOCK,&all,NULL);
}
int ia840f_dma_wait_step(void *unused)
{
    (void)unused;
    const struct timespec delay={.tv_sec=0,.tv_nsec=1000000};
    return nanosleep(&delay,NULL);
}
_Noreturn void ia840f_dma_hold(const char *reason,const struct ia840f_dma_report *r)
{
    fprintf(stderr,"HOLD_UNKNOWN_DMA pid=%ld reason=%s phase=%d go_possible=%d "
      "local_quiescent=%d status_before=0x%016" PRIx64 " status_last=0x%016" PRIx64
      " polls=%u; buffers/FDs retained; no further device access or cleanup.\n",
      (long)getpid(),reason,(int)r->phase,r->go_may_have_been_issued,r->quiescent,
      r->status_before,r->status_last,r->polls);
    fflush(stderr);
    /* SIGCONT can resume only this loop, not DMA, cleanup or entry finalization. */
    for (;;) if (raise(SIGSTOP)) pause();
}
