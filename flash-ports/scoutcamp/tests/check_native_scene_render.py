"""Compare actual Scouts rendering with the frozen pre-optimization renderer.

Native GraphX, all 17 maps, both framebuffer addresses, camera edges, actors,
status pips, towers, HUD/briefing/results and nonzero cache canaries.
Synthetic states, not campaign wins.
"""
from pathlib import Path
import argparse,hashlib,json,re,struct,subprocess
p=argparse.ArgumentParser();p.add_argument("--stop",type=int,default=0);args=p.parse_args()
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
snapshot={n:hashlib.sha256((GAME/'src'/n).read_bytes()).hexdigest() for n in ['art.c','main.c','engine.h','combat.h']}
OUT=HERE/'render-native';(OUT/'src').mkdir(parents=True,exist_ok=True)
names=['artBanks','art_error','art_open','art_sprite','art_draw','art_cache_level','art_background','art_map_data']
(OUT/'src/ref_art.c').write_text(r'''#include <stdbool.h>
#include "../../../src/art.h"
bool ref_art_open(void){return true;}
void ref_art_cache_level(const uint8_t*a,const uint8_t*b,const uint8_t*c,int n,int t){(void)a;(void)b;(void)c;(void)n;(void)t;}
gfx_sprite_t *ref_art_sprite(int id,int frame){return art_sprite(id,frame);}
void ref_art_draw(int id,int frame,int x,int y){
 if(id<0||id>=ART_COUNT)return;const Art*a=&artTable[id];
 if(x>=320||y>=240||x+a->width<=0||y+a->height<=0)return;
 if(x>=0&&y>=0&&x+a->width<=320&&y+a->height<=240)gfx_TransparentSprite_NoClip(art_sprite(id,frame),x,y);
 else gfx_TransparentSprite(art_sprite(id,frame),x,y);
}
void ref_art_background(int left){
 gfx_Sprite_NoClip(art_sprite(left,0),0,0);gfx_Sprite_NoClip(art_sprite(left,1),0,120);
 gfx_Sprite_NoClip(art_sprite(left+1,0),160,0);gfx_Sprite_NoClip(art_sprite(left+1,1),160,120);
}
''')
reference=(HERE/'reference/render_v7.c').read_text()
for n in ['drawTowerArt','drawArt','renderGame','art_draw','art_background','art_sprite']:
 reference=re.sub(r'\b'+n+r'\b','ref_'+n,reference)
source=r'''#define main scout_game_main
#include "../../../src/main.c"
#undef main
bool ref_art_open(void);
void ref_art_cache_level(const uint8_t*,const uint8_t*,const uint8_t*,int,int);
void ref_art_draw(int,int,int,int);
void ref_art_background(int);
gfx_sprite_t *ref_art_sprite(int,int);
REFERENCE
unsigned art_guards(void);
void art_guard_init(void);
volatile uint16_t render_diag[5];
volatile uint24_t debug_stop __attribute__((section(".data")))=DEBUG_STOP;
#define PHASE(n) do{render_diag[0]=(n);if(debug_stop==(n))while(1){kb_Scan();}}while(0)
volatile uint32_t render_ticks[2];
int main(void){
 PHASE(90);boot_Set48MHzMode();gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);
 gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);gfx_SetPalette(artPalette,sizeof artPalette,0);pickColors();
 timer_Set(1,0);timer_Enable(1,TIMER_32K,TIMER_NOINT,TIMER_UP);
 PHASE(91);if(!art_open()||!ref_art_open()){render_diag[0]=2;while(1){}}
 art_guard_init();PHASE(92);load();PHASE(93);
 for(int surface=0;surface<2;surface++)for(int stage=0;stage<17;stage++){
  level=stage;startLevel();PHASE(94);int theme=level==16?2:level>11?3:level>7?2:level>3?1:0;
  ref_art_cache_level(layers[0],layers[1],layers[2],map->width*map->height,ART_TILES0+theme);
  for(int k=0;k<8;k++){
   cx=(map->width-1)*(k%4)/3;cy=(map->height-1)*((k*3)%5)/4;tick=37*k;
   money=120+k*137;wave=k%waveCounts[level];playerLevel=1+k;xp=k*13;
   mode=k==7?MODE_LOST:k==6?MODE_WON:MODE_PLAY;showTip=k==5;paused=k==4;speedThirds=k==3?0:12;
   statusTicks=k&1;focusEnemy=-1;
   memset(enemies,0,sizeof enemies);memset(bullets,0,sizeof bullets);memset(towers,0,sizeof towers);
   enemyTop=10;bulletTop=4;
   for(int i=0;i<10;i++)enemies[i]=(Enemy){.active=1,.type=i,.x=(cx*16+(i%5)*30-60)*FP,.y=(cy*16+(i/5)*40)*FP,.hp=50,.maxhp=100,.facing=i&1?-1:1,.scale=10000,.wobble=1000,.freeze=k==1?3:0,.poison=k==2?3:0,.immune=k==3,.born=k==4?3:0,.birthLength=20,.flat=k==6?3:0};
   for(int i=0;i<4;i++)bullets[i]=(Bullet){.active=1,.type=i,.x=(cx*16+i*20)*FP,.y=cy*16*FP};
   for(int i=0;i<4;i++){Tower*t=&towers[i];t->active=1;t->cell=cy*map->width+(cx+i)%map->width;t->type=baseTypes[i];t->level=k%6;t->born=k==2?3:0;towerStats(t);}
   if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();gfx_FillScreen(17);
   PHASE(95);uint32_t start=timer_GetSafe(1,TIMER_UP);ref_renderGame();PHASE(96);render_ticks[0]+=timer_GetSafe(1,TIMER_UP)-start;
   if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();gfx_FillScreen(17);
   start=timer_GetSafe(1,TIMER_UP);renderGame();PHASE(97);render_ticks[1]+=timer_GetSafe(1,TIMER_UP)-start;
   if(memcmp(gfx_vram,gfx_vram+76800,76800)){render_diag[2]++;if(!render_diag[4])render_diag[4]=render_diag[1]+1;}
   render_diag[3]+=art_guards();render_diag[1]++;
  }
 }
 render_diag[0]=1;while(1){kb_Scan();}
}
'''.replace('REFERENCE',reference).replace('DEBUG_STOP',str(args.stop))
(OUT/'src/main.c').write_text(source)
art=(GAME/'src/art.c').read_text().replace('#include "art.h"','#include "../../../src/art.h"').replace('#include "input.h"','#include "../../../src/input.h"')
art=art.replace('static uint8_t hudCache[2+41*(125+64)]={1};','static struct {uint8_t before[64],pixels[2+41*(125+64)],after[64];} hudGuard={{1}};\n#define hudCache hudGuard.pixels')
art=art.replace('static uint8_t skyCache[13000], tileCache[16][410];','static uint8_t skyCache[13000];\nstatic struct {uint8_t before[64],pixels[16][410],after[64];} tileGuard;\n#define tileCache tileGuard.pixels')
art+='\nvoid art_guard_init(void){memset(hudGuard.before,0xa5,64);memset(hudGuard.after,0xa5,64);memset(tileGuard.before,0xa5,64);memset(tileGuard.after,0xa5,64); }\nunsigned art_guards(void){unsigned n=0;for(unsigned i=0;i<64;i++)n+=hudGuard.before[i]!=0xa5||hudGuard.after[i]!=0xa5||tileGuard.before[i]!=0xa5||tileGuard.after[i]!=0xa5;return n;}\n'
(OUT/'src/art.c').write_text(art)
(OUT/'src/input.c').write_text('#include "../../../src/input.c"\n')
(OUT/'makefile').write_text('NAME = SCREND\nDESCRIPTION = "Native scene pixels"\nCOMPRESSED = NO\nARCHIVED = NO\nLTO = NO\nCFLAGS = -Wall -Wextra -Oz -std=c11 -I../../src\nEXTRA_LDFLAGS += -T ../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
assert snapshot=={n:hashlib.sha256((GAME/'src'/n).read_bytes()).hexdigest() for n in snapshot}
mapping=(OUT/'bin/SCREND.map').read_text()
def addr(name):return int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_'+name+r'\s*$',mapping,re.M)[1],16)
def crc(data):
 v=0xffffffff
 for b in data:
  v^=b
  for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
 return f'{v^0xffffffff:08X}'
lib=ROOT/'local-tools/cemu/clibs/clibs'
files=[lib/(s+'.8xv') for s in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[OUT/'bin/SCREND.8xp']
expected=[1,272,0,0,0]
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='SCREND',isASM=True),delay_after_step=0,sequence=['action|launch','delay|1000','hashWait|pixels'],hashes=dict(pixels=dict(description='272 native scene comparisons',start=hex(addr('render_diag')),size=10,expected_CRCs=[crc(struct.pack('<5H',*expected))],timeout=240000)))
if args.stop:config['hashes']['pixels'].update(size=2,timeout=1000,expected_CRCs=[crc(struct.pack('<H',args.stop))])
(OUT/'smoke.json').write_text(json.dumps(config,indent=2))
r=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(OUT/'smoke.json')],cwd=OUT,capture_output=True,text=True,timeout=650,creationflags=0x08000040)
(OUT/'smoke.log').write_text(r.stdout+r.stderr);print(r.stdout+r.stderr)
ram=(OUT/'native-ram.bin').read_bytes();values=list(struct.unpack_from('<5H',ram,addr('render_diag')-0xd00000));ticks=list(struct.unpack_from('<2I',ram,addr('render_ticks')-0xd00000))
failed=bool(r.returncode or 'NMI' in r.stdout+r.stderr or (values[0]!=args.stop if args.stop else values!=expected))
result=dict(debug_only=bool(args.stop),stop=args.stop,program_sha256=hashlib.sha256((OUT/'bin/SCREND.8xp').read_bytes()).hexdigest(),expected=([args.stop] if args.stop else expected),timing_scope="Synthetic raw-sprite oracle versus candidate; not a production FPS comparison",observed=values,failed=failed,render_ticks=ticks,mean_render_ms=[n*1000/32768/272 for n in ticks],source_sha256=snapshot,scope=__doc__)
(OUT/('result-stop%d.json'%args.stop if args.stop else 'result.json')).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));raise SystemExit(failed)
