"""Compare the game's bounded formatter with host snprintf, with canaries.

24-bit int / 32-bit long boundaries are included; native fixtures additionally
exercise the actual CE ABI. Unsupported formats must not enter game sources.
"""
from pathlib import Path
import hashlib, json, os, re, subprocess

HERE=Path(__file__).resolve().parent; GAME=HERE.parent; ROOT=GAME.parents[1]
formats=set()
for path in (GAME/'src').glob('*'):
 if path.suffix not in ['.c','.h'] or path.name=='small_format.c':continue
 for literal in re.findall(r'"(?:[^"\\]|\\.)*"',path.read_text()):
  if '%' not in literal:continue
  for conversion in re.findall(r'%[^%]*?(?:[a-zA-Z%]|$)',literal):
   # Only strings passed to snprintf matter; gameplay text can contain percent signs.
   if re.match(r'%(?:0?\d*)?(?:l?[duX]|s|%)$',conversion):formats.add(conversion)
source=r'''#include <stdio.h>
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
'''
(HERE/'small_format_dump.c').write_text(source)
cache=HERE/'compiler-cache';cache.mkdir(exist_ok=True)
env=dict(os.environ,ZIG_LOCAL_CACHE_DIR=str(cache/'local'),ZIG_GLOBAL_CACHE_DIR=str(cache/'global'),TMP=str(cache),TEMP=str(cache))
subprocess.run([str(ROOT/'local-tools/ziglang/zig.exe'),'cc','-O1','-fno-builtin',str(HERE/'small_format_dump.c'),'-o',str(HERE/'small_format_dump.exe')],check=True,env=env)
r=subprocess.run([str(HERE/'small_format_dump.exe')],check=True,capture_output=True,text=True)
checks,failures=map(int,r.stdout.split())
result=dict(checks=checks,failures=failures,source_sha256=hashlib.sha256((GAME/'src/small_format.c').read_bytes()).hexdigest(),observed_conversions=sorted(formats),scope=__doc__)
(HERE/'small-format-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
