"""Execute actual open_banks with complete/missing/truncated AppVar stubs."""
from pathlib import Path
import hashlib,json,os,re,subprocess
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
world=(GAME/'src/world.c').read_text();m=re.search(r'static bool open_banks\(void\)\s*\{',world);start=m.start();end=m.end();depth=1
while depth:depth+=(world[end]=='{')-(world[end]=='}');end+=1
function=world[start:end]
source='''#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../src/bundle.h"
#define COUNT(a) (sizeof(a)/sizeof((a)[0]))
static const uint8_t *banks[BUNDLE_BANKS];
static uint8_t bytes[BUNDLE_BANKS][32768];static unsigned sizes[BUNDLE_BANKS];static int missing=-1;
static uint8_t ti_Open(const char*n,const char*m){(void)m;int i=atoi(n+3);return i==missing?0:i+1;}
static unsigned ti_GetSize(uint8_t f){return sizes[f-1];}
static uint8_t *ti_GetDataPtr(uint8_t f){return bytes[f-1];}
static void ti_Close(uint8_t f){(void)f;}
FUNCTION
static void valid_banks(void){for(unsigned i=0;i<BUNDLE_BANKS;i++){sizes[i]=bundle_bank_sizes[i];memcpy(bytes[i],bundle_signature,8);bytes[i][8]=i;bytes[i][9]=sizes[i]&255;bytes[i][10]=sizes[i]>>8;}}
int main(void){valid_banks();
 printf("R complete_banks %d 1\\n",open_banks());missing=3;printf("R missing_bank %d 0\\n",open_banks());missing=-1;
 sizes[3]--;printf("R truncated_bank %d 0\\n",open_banks());sizes[3]=0;printf("R empty_bank %d 0\\n",open_banks());
 valid_banks();bytes[3][0]^=1;printf("R mismatched_signature %d 0\\n",open_banks());
 valid_banks();bytes[3][8]=4;printf("R wrong_bank_index %d 0\\n",open_banks());
 valid_banks();bytes[3][9]^=1;printf("R wrong_declared_length %d 0\\n",open_banks());return 0;}
'''.replace('FUNCTION',function)
(HERE/'bank_validation_dump.c').write_text(source)
cache=HERE/'compiler-cache';cache.mkdir(exist_ok=True)
env=dict(os.environ,ZIG_LOCAL_CACHE_DIR=str(cache/'local'),ZIG_GLOBAL_CACHE_DIR=str(cache/'global'),TMP=str(cache),TEMP=str(cache))
subprocess.run([str(ROOT/'local-tools/ziglang/zig.exe'),'cc','-O1',str(HERE/'bank_validation_dump.c'),'-o',str(HERE/'bank_validation_dump.exe')],check=True,env=env)
run=subprocess.run([str(HERE/'bank_validation_dump.exe')],capture_output=True,text=True,timeout=15);tests=[]
for line in run.stdout.splitlines():
 r=line.split();tests.append(dict(name=r[1],actual=int(r[2]),expected=int(r[3]),passed=r[2]==r[3]))
(HERE/'bank-validation-results.json').write_text(json.dumps(dict(tests=tests,source_sha256=hashlib.sha256(world.encode()).hexdigest(),returncode=run.returncode),indent=2));print(run.stdout)
raise SystemExit(run.returncode or any(not t['passed'] for t in tests))
