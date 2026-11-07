"""Compare horizontal movement cache with frozen production v8 on the actual CE ABI.

All17 original maps,16 enemy/motion/status variants,160 ticks and3 substeps.
Compares every gameplay Enemy byte, food state, escape count and focus after
each call, plus the derived movement-cache invariant. The two new cache fields
are metadata and are excluded from the frozen-v8 structure comparison.
The graphics cache initializer is stubbed; actual map banks and physics run.
"""
from pathlib import Path
import hashlib,json,re,struct,subprocess
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1];OUT=HERE/'movement-native';(OUT/'src').mkdir(parents=True,exist_ok=True)
source_sha=hashlib.sha256((GAME/'src/engine.h').read_bytes()).hexdigest()
reference=(HERE/'reference/physicsEnemy_v8.c').read_text().replace('physicsEnemy(','reference_physicsEnemy(')
source=r'''#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <sys/timers.h>
#include <sys/power.h>
#include <stdint.h>
#include <stddef.h>
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
REFERENCE
volatile uint32_t trace_diag[5]; /* done, comparisons, failures, first stage, first variant */
volatile uint32_t trace_time[2];
static Enemy old_state,new_state;
static Food old_food[5],new_food[5];
int main(void){
 boot_Set48MHzMode();gfx_Begin();gfx_SetDrawBuffer();
 timer_Set(1,0);timer_Enable(1,TIMER_32K,TIMER_NOINT,TIMER_UP);
 if(!art_open()){trace_diag[0]=3;while(1){kb_Scan();}}
 for(int stage=0;stage<17;stage++)for(int variant=0;variant<16;variant++){
  level=stage;memset(skills,0,sizeof skills);skills[SK_ROCKTOWER]=1;skills[SK_REFRIGERATION]=3;startLevel();
  int home=map->routes[variant%map->routeCount].cells[0];Enemy*e=spawnEnemy(variant%10,stage*3+1,home);
  e->born=0;e->facing=variant&1?-1:1;e->ground=1;e->hp=e->maxhp=100000;
  if(variant==1)e->born=3;
  if(variant==2){e->x=(campTileX*16+8)*FP;e->y=(campTileY*16+16)*FP;}
  if(variant==3){e->x=3*FP;e->facing=-1;}
  if(variant==4){e->vy=-90*FP;e->ground=0;e->action=1;}
  if(variant==5){e->x=(mapWidth*16-3)*FP;e->facing=1;}
  if(variant==6){e->slow=200;e->slowRate=37;}
  if(variant==7){e->escaping=1;e->carry=0;e->x=(e->homeX*16+8)*FP;e->y=(e->homeY*16+monsterHeight[e->type]/2)*FP;foods[0].holder=0;}
  if(variant==8)e->freeze=10;
  if(variant==9){e->flat=5;e->fling=10;e->vx=-70*FP;}
  if(variant==10){e->speed=59;e->facing=-1;}
  if(variant==11){e->speed=60;e->facing=1;}
  if(variant==12){e->speed=61;e->facing=0;}
  if(variant==13){e->speed=65535;e->facing=2;}
  if(variant>=14){e->fling=2000;e->vx=variant==14?65535:-65535;e->ground=0;}
  old_state=new_state=*e;memcpy(old_food,foods,sizeof foods);memcpy(new_food,foods,sizeof foods);
  for(int t=0;t<160;t++)for(int sub=0;sub<3;sub++){
   tick=t;
   if(variant>=10&&variant<14)old_state.speed=new_state.speed=(uint16_t)(59+t%4);
   if(variant>=14)old_state.vx=new_state.vx=(t&1)?-65535:65535;
   enemies[0]=old_state;memcpy(foods,old_food,sizeof foods);focusEnemy=0;escaped=0;srand(123+t*3+sub);
   uint32_t start=timer_GetSafe(1,TIMER_UP);
   if(enemies[0].active)reference_physicsEnemy(&enemies[0],sub);
   trace_time[0]+=timer_GetSafe(1,TIMER_UP)-start;
   old_state=enemies[0];memcpy(old_food,foods,sizeof foods);int old_focus=focusEnemy,old_escaped=escaped;
   enemies[0]=new_state;memcpy(foods,new_food,sizeof foods);focusEnemy=0;escaped=0;srand(123+t*3+sub);
   start=timer_GetSafe(1,TIMER_UP);
   if(enemies[0].active)physicsEnemy(&enemies[0],sub);
   trace_time[1]+=timer_GetSafe(1,TIMER_UP)-start;
   new_state=enemies[0];memcpy(new_food,foods,sizeof foods);
   if(memcmp(&old_state,&new_state,offsetof(Enemy,movementVelocity))||new_state.movementStep!=new_state.movementVelocity/60||memcmp(old_food,new_food,sizeof foods)||old_focus!=focusEnemy||old_escaped!=escaped){
    trace_diag[2]++;trace_diag[3]=stage+1;trace_diag[4]=variant;trace_diag[0]=2;while(1){kb_Scan();}
   }
   trace_diag[1]++;
  }
 }
 trace_diag[0]=1;while(1){kb_Scan();}
}
'''.replace('REFERENCE',reference)
(OUT/'src/main.c').write_text(source);(OUT/'src/art.c').write_text('#include "../../../src/art.c"\n')
(OUT/'makefile').write_text('NAME = SCMOVE\nDESCRIPTION = "Movement cache comparison"\nCOMPRESSED = NO\nARCHIVED = NO\nCFLAGS = -Wall -Wextra -Oz -std=c11\nEXTRA_LDFLAGS += -T ../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
assert source_sha==hashlib.sha256((GAME/'src/engine.h').read_bytes()).hexdigest()
mapping=(OUT/'bin/SCMOVE.map').read_text()
def address(name):return int(re.search(r'^\s*(0x[\da-f]+)\s+_'+name+r'\s*$',mapping,re.M)[1],16)
expected=[1,130560,0,0,0];v=0xffffffff
for b in struct.pack('<5I',*expected):
 v^=b
 for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
lib=ROOT/'local-tools/cemu/clibs/clibs';files=[lib/(n+'.8xv')for n in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[OUT/'bin/SCMOVE.8xp']
c=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='SCMOVE',isASM=True),delay_after_step=0,sequence=['action|launch','delay|1000','hashWait|trace'],hashes=dict(trace=dict(description='130560 native byte-exact physics comparisons',start=hex(address('trace_diag')),size=20,expected_CRCs=[f'{v^0xffffffff:08X}'],timeout=240000)))
(OUT/'smoke.json').write_text(json.dumps(c,indent=2));r=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(OUT/'smoke.json')],cwd=OUT,capture_output=True,text=True,timeout=900,creationflags=0x08000040);(OUT/'smoke.log').write_text(r.stdout+r.stderr);print(r.stdout+r.stderr)
ram=(OUT/'native-ram.bin').read_bytes();values=list(struct.unpack_from('<5I',ram,address('trace_diag')-0xd00000));times=list(struct.unpack_from('<2I',ram,address('trace_time')-0xd00000));failed=bool(r.returncode or 'NMI' in r.stdout+r.stderr or values!=expected)
result=dict(expected=expected,observed=values,failed=failed,reference_candidate_timer_ticks=times,source_sha256=hashlib.sha256((GAME/'src/engine.h').read_bytes()).hexdigest(),reference_sha256=hashlib.sha256((HERE/'reference/physicsEnemy_v8.c').read_bytes()).hexdigest(),program_sha256=hashlib.sha256((OUT/'bin/SCMOVE.8xp').read_bytes()).hexdigest(),scope=__doc__)
(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));raise SystemExit(failed)
