"""Compare actual food updates with frozen v7 on all original maps in CEmu.

Sparse/full enemy slots, pickup-distance boundaries, held/dropped/inactive
food and excluded enemy states. Every food/enemy byte and escape count must
match; graphics-cache initialization is stubbed, gameplay rules are real.
"""
from pathlib import Path
import argparse,hashlib,json,re,struct,subprocess
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--stop',type=int,default=0);args=parser.parse_args()
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1];OUT=HERE/'food-native';(OUT/'src').mkdir(parents=True,exist_ok=True)
engine_sha=hashlib.sha256((GAME/'src/engine.h').read_bytes()).hexdigest()
reference=(HERE/'reference/stepFood_v7.c').read_text().replace('stepFood(','reference_stepFood(')
source=r'''#include <tice.h>
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
REFERENCE
/* Initialized storage stays in the guarded resident region. */
static Enemy initial_enemies[MAXEN]={{.hp=1}},old_enemies[MAXEN]={{.hp=1}};
static Food initial_food[5],old_food[5];
volatile uint32_t food_diag[5];
volatile uint32_t food_time[2];
volatile uint24_t debug_stop __attribute__((section(".data")))=DEBUG_STOP;
#define PHASE(n) do{*(volatile uint32_t*)0xd3f000=0xf00d0000u+(n);food_diag[0]=(n);if(debug_stop==(n))while(1){kb_Scan();}}while(0)
int main(void){
 PHASE(90);
 boot_Set48MHzMode();gfx_Begin();gfx_SetDrawBuffer();
 PHASE(91);
 timer_Set(1,0);timer_Enable(1,TIMER_32K,TIMER_NOINT,TIMER_UP);
 if(!art_open()){food_diag[0]=3;while(1){kb_Scan();}}
 PHASE(92);
 for(int stage=0;stage<17;stage++)for(int c=0;c<48;c++){
  level=stage;startLevel();PHASE(93);srand(1200+stage*48+c);memset(enemies,0,sizeof enemies);enemyTop=MAXEN;
  int active=c%4==0?0:c%4==1?1:c%4==2?25:MAXEN;
  for(int j=0;j<active;j++){
   int slot=active==1&&c&4?159:j;Enemy *e=&enemies[slot];
   e->active=1;e->type=j%10;e->carry=-1;e->advancing=j&1;e->facing=j&1?-1:1;e->born=j%7==3;e->escaping=j%11==4;e->action=j%9==5?1:0;
   e->x=(rand()%(mapWidth*16+16)-8)*FP;e->y=(rand()%(mapHeight*16+16))*FP;
  }
  for(int i=0;i<5;i++){
   foods[i].active=1;foods[i].holder=-1;
   foods[i].x=(rand()%(mapWidth*16-1))*FP;foods[i].y=(rand()%(mapHeight*16))*FP;foods[i].vy=(c%3)*FP*17;
  }
  if(c<16){
   const int dxs[]={-16,-15,-12,-11,0,11,12,15,16};
   int dx=dxs[c%9],dy=dxs[(c*3)%9];
   Food*f=&foods[0];f->x=(campTileX*16+8)*FP;f->y=(campTileY*16+8)*FP;f->vy=0;
   Enemy*e=&enemies[0];memset(e,0,sizeof *e);e->active=1;e->carry=-1;e->advancing=1;e->facing=1;
   e->x=(f->x_pixel+dx)*FP;e->y=(f->y_pixel+dy+monsterHeight[0]/2)*FP;
  }
  if(c%5==1)foods[1].active=0;
  if(c%5==2)foods[1].holder=0;
  if(c%5==3)foods[2].holder=159;
  memcpy(initial_enemies,enemies,sizeof enemies);memcpy(initial_food,foods,sizeof foods);escaped=0;
  PHASE(94);
  uint32_t start=timer_GetSafe(1,TIMER_UP);reference_stepFood();food_time[0]+=timer_GetSafe(1,TIMER_UP)-start;
  PHASE(95);
  memcpy(old_enemies,enemies,sizeof enemies);memcpy(old_food,foods,sizeof foods);int old_escaped=escaped;
  memcpy(enemies,initial_enemies,sizeof enemies);memcpy(foods,initial_food,sizeof foods);escaped=0;
  start=timer_GetSafe(1,TIMER_UP);stepFood();food_time[1]+=timer_GetSafe(1,TIMER_UP)-start;
  PHASE(96);
  if(memcmp(enemies,old_enemies,sizeof enemies)||memcmp(foods,old_food,sizeof foods)||escaped!=old_escaped){food_diag[2]++;food_diag[3]=stage+1;food_diag[4]=c;food_diag[0]=2;while(1){kb_Scan();}}
  food_diag[1]++;
 }
 food_diag[0]=1;while(1){kb_Scan();}
}
'''.replace('REFERENCE',reference).replace('DEBUG_STOP',str(args.stop))
(OUT/'src/main.c').write_text(source);(OUT/'src/art.c').write_text('#include "../../../src/art.c"\n')
(OUT/'makefile').write_text('NAME = SCFOOD\nDESCRIPTION = "v7 food trace comparison"\nCOMPRESSED = NO\nARCHIVED = NO\nCFLAGS = -Wall -Wextra -Oz -std=c11\nEXTRA_LDFLAGS += -T ../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
assert engine_sha==hashlib.sha256((GAME/'src/engine.h').read_bytes()).hexdigest(),'Source changed during build'
mapping=(OUT/'bin/SCFOOD.map').read_text()
def address(name):return int(re.search(r'^\s*(0x[\da-f]+)\s+_'+name+r'\s*$',mapping,re.M)[1],16)
expected=[args.stop] if args.stop else [1,816,0,0,0];test_bytes=struct.pack('<'+'I'*len(expected),*expected);v=0xffffffff
for b in test_bytes:
 v^=b
 for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
lib=ROOT/'local-tools/cemu/clibs/clibs';files=[lib/(n+'.8xv')for n in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[OUT/'bin/SCFOOD.8xp']
c=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='SCFOOD',isASM=True),delay_after_step=0,sequence=['action|launch','delay|1000','hashWait|food'],hashes=dict(food=dict(description='Native food comparisons' if not args.stop else 'Debug phase only',start=hex(address('food_diag')),size=len(test_bytes),expected_CRCs=[f'{v^0xffffffff:08X}'],timeout=1000 if args.stop else 240000)))
(OUT/'smoke.json').write_text(json.dumps(c,indent=2));r=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(OUT/'smoke.json')],cwd=OUT,capture_output=True,text=True,timeout=900,creationflags=0x08000040);(OUT/'smoke.log').write_text(r.stdout+r.stderr);print(r.stdout+r.stderr)
ram=(OUT/'native-ram.bin').read_bytes();values=list(struct.unpack_from('<5I',ram,address('food_diag')-0xd00000));times=list(struct.unpack_from('<2I',ram,address('food_time')-0xd00000));failed=bool(r.returncode or 'NMI' in r.stdout+r.stderr or values[:len(expected)]!=expected)
result=dict(free_ram_phase=hex(struct.unpack_from('<I',ram,0x3f000)[0]),expected=expected,observed=values,failed=failed,reference_candidate_timer_ticks=times,source_sha256=engine_sha,reference_sha256=hashlib.sha256((HERE/'reference/stepFood_v7.c').read_bytes()).hexdigest(),program_sha256=hashlib.sha256((OUT/'bin/SCFOOD.8xp').read_bytes()).hexdigest(),scope=__doc__)
result['debug_stop']=args.stop
(OUT/('result-stop'+str(args.stop)+'.json' if args.stop else 'result.json')).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));raise SystemExit(failed)
