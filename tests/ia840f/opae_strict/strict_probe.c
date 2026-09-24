#define _GNU_SOURCE
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdarg.h>
#include <dirent.h>
#include <dlfcn.h>
#include <config.h>
#define opae_read_cfg_file inert_read_cfg_file
#define opae_find_cfg_file inert_find_cfg_file
#include "pluginmgr.c"
#ifdef TEST_STRICT
#include "ia840f_strict_init.inc"
#define INIT ia840f_opae_initialize_strict
#else
#define INIT opae_plugin_mgr_initialize
#endif
#undef opae_read_cfg_file
#undef opae_find_cfg_file
static const char *mode;
static char *json_text;
static int reads, discovers, scans, file_reads, loads, unloads, configs, inits, finis;
static int calloc_calls, strdup_calls, entries;
static unsigned char fake_dir;
void opae_print(int level, const char *format, ...)
{
    (void)level; va_list ap; va_start(ap,format);vfprintf(stderr,format,ap);va_end(ap);
}
char *inert_find_cfg_file(void) { ++discovers; return strdup("inert.cfg"); }
char *inert_read_cfg_file(const char *path)
{
    assert(path); ++reads;
    return !strcmp(mode,"read-fail") ? NULL : strdup(json_text);
}
void *opae_malloc(size_t n) { return malloc(n); }
void *opae_calloc(size_t n,size_t s)
{
    ++calloc_calls;
    if ((!strcmp(mode,"calloc-1") && calloc_calls==1) ||
        (!strcmp(mode,"calloc-2") && calloc_calls==2)) return NULL;
    return calloc(n,s);
}
char *opae_strdup(const char *s) { ++strdup_calls; return strdup(s); }
void opae_free(void *p) { free(p); }
DIR *opae_opendir(const char *path)
{
    assert(!strcmp(path,"/sys/bus/pci/devices")); ++scans; entries=0;
    if (!strcmp(mode,"scan-fail")) return NULL;
    return (DIR *)&fake_dir;
}
struct dirent *__wrap_readdir(DIR *dir)
{
    static struct dirent ent;
    assert(dir==(DIR *)&fake_dir);
    if (!strcmp(mode,"no-device") || entries++) return NULL;
    strcpy(ent.d_name,"0000:ab:00.0"); return &ent;
}
int opae_closedir(DIR *dir) { assert(dir==(DIR *)&fake_dir);return 0; }
FILE *opae_fopen(const char *path,const char *open_mode)
{
    assert(!strcmp(open_mode,"r"));++file_reads;
    assert(!strncmp(path,"/sys/bus/pci/devices/0000:ab:00.0/",
                    sizeof("/sys/bus/pci/devices/0000:ab:00.0/")-1));
    const char *leaf=strrchr(path,'/')+1;
    const char *value=NULL;
    if (!strcmp(leaf,"vendor") || !strcmp(leaf,"subsystem_vendor")) value="0x8086\n";
    else if (!strcmp(leaf,"device")) value=!strcmp(mode,"wrong-device") ? "0xffff\n" : "0xbccf\n";
    else if (!strcmp(leaf,"subsystem_device")) value="0x1771\n";
    assert(value);return fmemopen((void *)value,strlen(value),"r");
}
int opae_fclose(FILE *f) { return fclose(f); }
static int inert_initialize(void) { ++inits;return !strcmp(mode,"init-fail") || !strcmp(mode,"init-fail-repeat"); }
static int inert_finalize(void) { ++finis;return 0; }
static int inert_configure(opae_api_adapter_table *a,const char *json)
{
    ++configs;assert(json);a->initialize=inert_initialize;a->finalize=inert_finalize;
    return !strcmp(mode,"configure-fail");
}
void *__wrap_dlopen(const char *path,int flags)
{
    assert(flags==(RTLD_LAZY|RTLD_LOCAL));++loads;
    printf("INERT_LOAD %s\n",path);
    if (!strcmp(mode,"load-fail")) return NULL;
    if (!strcmp(path,"/work/sdk-build/lib/libxfpga.so") || !strchr(path,'/'))
        return &fake_dir;
    return NULL;
}
void *__wrap_dlsym(void *handle,const char *name)
{
    assert(handle==&fake_dir && !strcmp(name,"opae_plugin_configure"));
    if (!strcmp(mode,"symbol-fail")) return NULL;
    int (*function)(opae_api_adapter_table *,const char *)=inert_configure;
    void *pointer=NULL;_Static_assert(sizeof(pointer)==sizeof(function),"POSIX ABI");
    memcpy(&pointer,&function,sizeof(pointer));return pointer;
}
int __wrap_dlclose(void *handle) { assert(handle==&fake_dir);++unloads;return 0; }
char *__wrap_dlerror(void) { return "inert loader failure"; }
int main(int argc,char **argv)
{
    assert(argc==3);mode=argv[1];
    FILE *f=fopen(argv[2],"rb");assert(f && !fseek(f,0,SEEK_END));
    long length=ftell(f);assert(length>=0 && length<32768 && !fseek(f,0,SEEK_SET));
    json_text=malloc((size_t)length+1);assert(json_text);
    assert(fread(json_text,1,(size_t)length,f)==(size_t)length && !fclose(f));json_text[length]=0;
    assert(!setenv("OPAE_EXPLICIT_INITIALIZE","1",1));assert(!unsetenv("WITH_ASE"));
    if (!strcmp(mode,"ase")) assert(!setenv("WITH_ASE","0",1));
    if (!strcmp(mode,"implicit")) assert(!unsetenv("OPAE_EXPLICIT_INITIALIZE"));
    if (!strcmp(mode,"already-initialized")) initialized=1;
    int rc=INIT(!strcmp(mode,"null-path") ? NULL : !strcmp(mode,"relative-path") ? "relative" : "/inert/sealed/config");
    int first_reads=reads,first_scans=scans,first_loads=loads,first_inits=inits;
    int rc2=-1;
    if (!strcmp(mode,"repeat") || !strcmp(mode,"init-fail-repeat"))
        rc2=INIT("/inert/sealed/config");
    printf("RESULT rc=%d rc2=%d reads=%d discovers=%d scans=%d file_reads=%d loads=%d configs=%d inits=%d finis=%d unloads=%d initialized=%d calloc=%d strdup=%d first_reads=%d first_scans=%d first_loads=%d first_inits=%d\n",
           rc,rc2,reads,discovers,scans,file_reads,loads,configs,inits,finis,unloads,initialized,calloc_calls,strdup_calls,first_reads,first_scans,first_loads,first_inits);
    free(json_text);return 0;
}
