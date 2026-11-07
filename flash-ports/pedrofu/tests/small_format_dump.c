#include <stdio.h>
#include <string.h>
#include <limits.h>
#define snprintf pd_snprintf
#include "../src/small_format.c"
#undef snprintf
static unsigned checks, failures;
#define CHECK(fmt, ...) do { \
 for(size_t cap=0;cap<=96;cap++){ \
  char a[128],b[128];memset(a,0x6b,sizeof a);memset(b,0x6b,sizeof b); \
  int x=pd_snprintf(a+8,cap,fmt,__VA_ARGS__);int y=snprintf(b+8,cap,fmt,__VA_ARGS__); \
  checks++;if(x!=y||memcmp(a,b,sizeof a))failures++; \
 } }while(0)
int main(void){
 int signed_values[]={-8388608,-65536,-100,-1,0,1,9,10,99,100,8388607,INT_MIN,INT_MAX};
 unsigned unsigned_values[]={0,1,15,16,255,65535,16777215,UINT_MAX};
 for(unsigned i=0;i<sizeof signed_values/sizeof *signed_values;i++){
  int v=signed_values[i];CHECK("%d",v);CHECK("%02d",v);CHECK("%06d",v);CHECK("%9d",v);
  CHECK("%s %d.%02d %%", "rank",v,v<0?0:v%100);
 }
 for(unsigned i=0;i<sizeof unsigned_values/sizeof *unsigned_values;i++){
  unsigned v=unsigned_values[i];CHECK("%u",v);CHECK("%06X",v);CHECK("%08X",v);
 }
 unsigned long longs[]={0UL,1UL,16777215UL,2147483648UL,4294967295UL,ULONG_MAX};
 for(unsigned i=0;i<sizeof longs/sizeof *longs;i++)CHECK("FPS%lu STEP%lu",longs[i],longs[i]);
 CHECK("%s/%s/%s", "", "short", "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz");
 failures+=pd_snprintf(NULL,0,"%d",-8388608)!=8;
 printf("%u %u\n",checks,failures);return failures!=0;
}
