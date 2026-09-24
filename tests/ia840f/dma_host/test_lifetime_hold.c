#define _GNU_SOURCE
#include "ia840f_dma_lifetime.h"
#include <fcntl.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
int main(int argc,char **argv){
 if(argc!=2)return 2;
 int fd=open(argv[1],O_CREAT|O_EXCL|O_RDWR,0600);if(fd<0)return 2;
 volatile unsigned char *p=mmap(NULL,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED||ia840f_dma_signals_block())return 2;
 p[0]=93;
 struct ia840f_dma_report r={.phase=IA840F_DMA_POLL,.go_may_have_been_issued=1};
 printf("INERT owner fd=%d memory=%p sentinel=%u\n",fd,(const void*)p,p[0]);fflush(stdout);
 ia840f_dma_hold("inert regular-file/RAM owner; no accelerator",&r);
}
