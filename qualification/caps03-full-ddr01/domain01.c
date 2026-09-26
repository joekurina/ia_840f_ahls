#include <assert.h>
#include <inttypes.h>
#include <stdio.h>
static uint64_t sweep_offset(unsigned index)
{
    return (uint64_t)index<<7;
}
int main(void)
{
    uint64_t end=0;
    const unsigned locations=134217728U;
    for(unsigned i=0;i<locations;++i){
        uint64_t a=sweep_offset(i);
        assert(a==end && !(a&127));
        assert(a/4096==(a+127)/4096);
        assert(a+128<=(UINT64_C(1)<<34));
        end=a+128;
    }
    assert(end==(UINT64_C(1)<<34));
    assert(4U*locations==536870912U);
    printf("FULL_DOMAIN_PASS locations=%u bytes_per_bank=%" PRIu64 " descriptors=%u\n",locations,end,4U*locations);
    return 0;
}
