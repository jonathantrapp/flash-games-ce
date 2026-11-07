"""Reproduce a real stage-one portal->food->portal route using native physics.

One ordinary Lumpy, real map/markers/food, no towers. This is a focused route
regression, not a complete campaign or a throughput benchmark.
"""
from pathlib import Path
import argparse,hashlib,json,re,struct,subprocess
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--tag',default='route');p.add_argument('--expect-blocked',action='store_true');p.add_argument('--v7-control',action='store_true',help='Run frozen v7 physics to reproduce the known blocked route');a=p.parse_args();a.expect_blocked|=a.v7_control
OUT=HERE/'route-native';(OUT/'src').mkdir(parents=True,exist_ok=True);RUN=OUT/'runs'/a.tag;RUN.mkdir(parents=True,exist_ok=True)
control=(HERE/'reference/physicsEnemy_v7.c').read_text().replace('physicsEnemy(', 'frozen_physicsEnemy(')+'\n#define physicsEnemy frozen_physicsEnemy\n' if a.v7_control else ''
engine_sha=hashlib.sha256((GAME/'src/engine.h').read_bytes()).hexdigest()
(OUT/'src/art.c').write_text('#include "../../../src/art.c"\n')
(OUT/'src/main.c').write_text(r'''#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <sys/timers.h>
#include <sys/power.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "../../../src/art.h"
void input_poll(void){}
static void fixture_cache(const uint8_t*a,const uint8_t*b,const uint8_t*c,int n,int t){(void)a;(void)b;(void)c;(void)n;(void)t;}
#define art_cache_level fixture_cache
#include "../../../src/engine.h"
#include "../../../src/combat.h"
#undef art_cache_level
CONTROL_REFERENCE
volatile uint32_t route_trace[128];
volatile uint32_t route_diag[6]; /* done,maxx,ticks,escaped,food,pickup observed */
int main(void){
 boot_Set48MHzMode();gfx_Begin();gfx_SetDrawBuffer();
 if(!art_open()){route_diag[0]=3;while(1){kb_Scan();}}
 level=0;memset(skills,0,sizeof skills);skills[SK_ROCKTOWER]=1;startLevel();
 Enemy *e=spawnEnemy(0,1,map->routes[0].cells[0]);e->born=0;e->facing=1;
 for(int t=0;t<2500&&e->active;t++){
  tick=t;for(int sub=0;sub<3&&e->active;sub++){
   int face=e->facing;physicsEnemy(e,sub);
   if(face!=e->facing&&route_trace[0]<31){unsigned n=1+4*route_trace[0]++;route_trace[n]=t;route_trace[n+1]=ex(e);route_trace[n+2]=e->y_pixel;route_trace[n+3]=e->ground;}
  }
  stepFood();
  if(ex(e)>(int)route_diag[1])route_diag[1]=ex(e);
  if(e->carry>=0)route_diag[5]=1;
  route_diag[2]=t+1;
 }
 route_diag[3]=escaped;route_diag[4]=foodLeft();
 route_diag[0]=!e->active&&escaped==1&&foodLeft()==4&&route_diag[1]>=800&&route_diag[5]?1:2;
 while(1){kb_Scan();}
}
'''.replace('CONTROL_REFERENCE',control))
(OUT/'makefile').write_text('NAME = SCROUTE\nDESCRIPTION = "Stage-one route regression"\nCOMPRESSED = NO\nARCHIVED = NO\nCFLAGS = -Wall -Wextra -Oz -std=c11\nEXTRA_LDFLAGS += -T ../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
assert engine_sha==hashlib.sha256((GAME/'src/engine.h').read_bytes()).hexdigest()
m=(OUT/'bin/SCROUTE.map').read_text();addr=int(re.search(r'^\s*(0x[\da-f]+)\s+_route_diag\s*$',m,re.M)[1],16)
expected=2 if a.expect_blocked else 1;v=0xffffffff
for b in struct.pack('<I',expected):
 v^=b
 for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
lib=ROOT/'local-tools/cemu/clibs/clibs';files=[lib/(n+'.8xv')for n in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[OUT/'bin/SCROUTE.8xp']
c=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='SCROUTE',isASM=True),delay_after_step=0,sequence=['action|launch','delay|1000','hashWait|route'],hashes=dict(route=dict(description='Known blocked control' if a.expect_blocked else 'Native food round-trip',start=hex(addr),size=4,expected_CRCs=[f'{v^0xffffffff:08X}'],timeout=120000)))
(RUN/'smoke.json').write_text(json.dumps(c,indent=2));r=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(RUN/'smoke.json')],cwd=RUN,capture_output=True,text=True,timeout=600,creationflags=0x08000040);(RUN/'smoke.log').write_text(r.stdout+r.stderr);print(r.stdout+r.stderr)
ram=(RUN/'native-ram.bin').read_bytes();values=list(struct.unpack_from('<6I',ram,addr-0xd00000));failed=bool(r.returncode or 'NMI' in r.stdout+r.stderr or values[0]!=expected)
if a.expect_blocked:failed|=not(values[1]<512 and values[3]==0 and values[4]==5 and values[5]==0)
result=dict(frozen_v7_control=a.v7_control,control_sha256=hashlib.sha256(control.encode()).hexdigest() if control else None,observed=values,expected_done=expected,expected_blocked_control=a.expect_blocked,failed=failed,source_sha256=engine_sha,program_sha256=hashlib.sha256((OUT/'bin/SCROUTE.8xp').read_bytes()).hexdigest(),scope=__doc__)
(RUN/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));raise SystemExit(failed)
