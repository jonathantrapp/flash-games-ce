"""Compare the actual complete renderer with frozen v5 across synthetic states.

Actual GraphX/fonts/assets in CEmu. This tests native pixel preservation, not
Flash fidelity, gameplay completion or physical hardware. Intro is stubbed off.
"""
from pathlib import Path
import argparse,hashlib,json,re,struct,subprocess,sys
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--debug-first',action='store_true');parser.add_argument('--sky-mode',choices=['flash','cache'],default='cache');args=parser.parse_args()
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
OUT=HERE/('scene-native' if args.sky_mode=='cache' else 'scene-native-flash');(OUT/'src').mkdir(parents=True,exist_ok=True)
def includes(s):return re.sub(r'#include "([^"]+)"',r'#include "../../../src/\1"',s)
def function(s,name):
 m=re.search(r'(?:static )?[^\n{};]+\b'+name+r'\([^;{}]*\)\s*\{',s);assert m,name
 start=m.start();end=m.end();depth=1
 while depth:depth+=(s[end]=='{')-(s[end]=='}');end+=1
 return s[start:end]
reference=(HERE/'reference/render_v5.c').read_text()
reference=re.sub(r'uint8_t cBlack,[^;]+;', 'extern uint8_t cBlack,cWhite,cYellow,cGold,cRed,cGreen,cCyan,cPanel;',reference)
reference='\n'.join('#define '+n+' ref_'+n for n in ['pick_colors','print_fit','center_text','wrap_text','shot_sprite','draw_game'])+'\n'+reference
if args.sky_mode=='flash':(OUT/'src/reference.c').write_text(includes(reference))
else:(OUT/'src/reference.c').unlink(missing_ok=True)
candidate=(GAME/'src/render.c').read_text()
candidate_hash=hashlib.sha256(candidate.encode()).hexdigest()
reference_hash=hashlib.sha256((HERE/'reference/render_v5.c').read_bytes()).hexdigest()
candidate=candidate.replace('static uint8_t notice_images[2][2+150*14]={{1}};',
 'static struct {uint8_t before[64],pixels[2+150*14],after[64];} notice_guard[2]={{{1}}};')
candidate=re.sub(r'notice_images\[([^]]+)\]',r'notice_guard[\1].pixels',candidate)
candidate=candidate.replace('static SceneCache scene_cache[2];','static struct {uint8_t before[64];SceneCache values[2];uint8_t after[64];} scene_guard;\n#define scene_cache scene_guard.values')
world=(GAME/'src/world.c').read_text()
helpers='\n'.join(function(world,n) for n in ['absi','clampi','open_banks','bundle_find','resource','load_resources','draw_sprite','draw_ui'])
profile=(GAME/'src/profile.c').read_text()
helpers+='\n'+function(profile,'maxlife')+'\n'+function(profile,'maxfury')
story=(GAME/'src/story.c').read_text();helpers+='\n'+function(story,'story_draw')
source=r'''#include "../../../src/game.h"
#include "../../../src/bundle.h"
#include "../../../src/dialogue_data.h"
#include "../../../src/render_cache.h"
Game g;Progress progress;
const uint8_t *artdata[60],*tiledata[2],*uidata[3][2],*uiimg[UI_COUNT],*pedro_flame;
static const uint8_t *banks[BUNDLE_BANKS];
HELPERS
bool intro_is_active(void){return false;}
void intro_camera(int*x,int*y){(void)x;(void)y;}
void intro_draw(int x,int y){(void)x;(void)y;}
int enemy_status_value(const Enemy*e,int which){return which==0?e->stun:0;}
void ref_draw_game(void);
CANDIDATE
volatile uint16_t scene_diag[5]; /* done,frames,pixel failures,guard failures,first failed frame */
static char changing_notice[96];
static void fixture(int stage,int k){
 g.px=((int)g.w*16-1)*(k%6)/5*16;g.py=((int)g.h*16-1)*((k*3)%7)/6*16;
 g.mode=k%7==6?DIALOGUE:PLAY;g.story_event=k%12;g.story_page=0;
 g.ticks=30+k*7;g.face=k&1?-1:1;g.action=k%19;g.actiontime=k%30;g.invul=k%3==0?4:0;
 g.hp=(k%6==0?50:100+(k*137)%1900);g.fury=(k*37)%501;g.totalmail=k%2?26:4;g.mailleft=k%5;
 memset(progress.hearts,k%2,sizeof progress.hearts);memset(progress.souls,k%2,sizeof progress.souls);
 progress.rank=k*7;progress.points=k%3?0:25;progress.xp=k*7;
 g.arena=k%4==0?0:-1;g.arenaround=k%5;g.arenatime=300-k*31;
 snprintf(changing_notice,sizeof changing_notice,"Same pointer, changed text %d, stage %d",k/2,stage);
 g.notice=changing_notice;g.notice_timer=k%5==0?0:100;
 g.carry=-1;g.enemies=4;g.props=3;
 const uint8_t types[4]={2,39,40,46};
 for(int i=0;i<4;i++)g.enemy[i]=(Enemy){.x=g.px+(i*35-55)*16,.y=g.py,.hp=700-k*19,.maxhp=1000,.active=1,.type=types[i],.face=k&1?-1:1,.fr=k%4,.freeze=k%4==1?10:0,.stun=k%4==2?10:0};
 const uint8_t props[3]={23,15,32};
 for(int i=0;i<3;i++)g.prop[i]=(Prop){.x=g.px/16+i*35,.y=g.py/16+25,.type=props[i],.active=1,.face=1};
 memset(g.shot,0,sizeof g.shot);g.shot[0]=(Shot){.x=g.px+50*16,.y=g.py,.type=56,.frame=k%6,.active=1,.face=1};
}
int main(void){
 gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);
 for(int i=0;i<2;i++){memset(notice_guard[i].before,0xa5,64);memset(notice_guard[i].after,0xa5,64);}
 memset(scene_guard.before,0xa5,64);memset(scene_guard.after,0xa5,64);
 if(!load_resources()){scene_diag[0]=2;while(1){}}
 cache_hud();pick_colors();
 SKY_START
 for(int surface=0;surface<2;surface++)for(int stage=1;stage<=15;stage++){
  char name[9];snprintf(name,sizeof name,"PDLV%02d",stage);unsigned size;const uint8_t*p=bundle_find(name,&size);
  memset(&g,0,sizeof g);g.w=p[0]+256*p[1];g.h=p[2]+256*p[3];g.n=g.w*g.h;
  memcpy(g.mapdata,p+4+g.n,g.n);memcpy(g.mapdata+g.n,p+4+3*g.n,g.n);
  g.back=p+4;g.solid=g.mapdata;g.decor=p+4+2*g.n;g.good=g.mapdata+g.n;g.level=stage-1;
  cache_stage_tiles(g.back,g.solid,g.decor,g.n);
  for(int k=0;k<12;k++){
   fixture(stage,k);
   if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();
   gfx_FillScreen(17);ref_draw_game();
   if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();
   draw_game();
   if(memcmp(gfx_vram,gfx_vram+76800,76800)){scene_diag[2]++;if(!scene_diag[4])scene_diag[4]=scene_diag[1]+1;}
   for(int i=0;i<2;i++)for(int j=0;j<64;j++)if(notice_guard[i].before[j]!=0xa5||notice_guard[i].after[j]!=0xa5)scene_diag[3]++;
   scene_diag[1]++;
  }
  if(stage==1||stage==8||stage==15)for(int j=0;j<40;j++){
   fixture(stage,j%12);g.px=g.w*8*16;g.py=g.h*8*16;g.mode=PLAY;g.ticks=100+j;
   int at=(g.py/16/16)*g.w+g.px/16/16;
   if(j==24)g.solid[at]=g.solid[at]?0:1;
   if(j==25)g.good[at]=12;if(j==28)g.good[at]=0;
   if(j==35){memset(changing_notice,'W',90);changing_notice[90]=0;g.notice_timer=100;}
   if(j==30||j==31){g.enemies=MAX_ENEMIES;for(int i=0;i<MAX_ENEMIES;i++)g.enemy[i]=(Enemy){.active=1,.type=2,.x=(camx+14+(i%12)*26)*16,.y=(camy+10+(i/12)*24)*16,.hp=100,.maxhp=100,.face=1};}
   if(j==32||j==33){g.props=j==32?25:24;for(int i=0;i<g.props;i++)g.prop[i]=(Prop){.x=camx+20+(i%5)*55,.y=camy+40+(i/5)*28,.type=23,.active=1,.face=1};}
   if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();
   gfx_FillScreen(17);ref_draw_game();
   if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();
   draw_game();
   if(memcmp(gfx_vram,gfx_vram+76800,76800)){scene_diag[2]++;if(!scene_diag[4])scene_diag[4]=scene_diag[1]+1;}
   for(int i=0;i<2;i++)for(int z=0;z<64;z++)if(notice_guard[i].before[z]!=0xa5||notice_guard[i].after[z]!=0xa5)scene_diag[3]++;
   for(int z=0;z<64;z++)if(scene_guard.before[z]!=0xa5||scene_guard.after[z]!=0xa5)scene_diag[3]++;
   scene_diag[1]++;
  }
 }
 gfx_SwapDraw();gfx_Wait();scene_diag[0]=1;while(1){kb_Scan();}
}
'''.replace('HELPERS',helpers).replace('CANDIDATE',includes(candidate)).replace('SKY_START','sky_runtime_start();if(!sky_ram_pixels){scene_diag[0]=4;while(1){}}' if args.sky_mode=='cache' else '')
if args.debug_first:source=source.replace('scene_diag[2]++;','scene_diag[0]=3;scene_diag[2]++;scene_diag[4]=scene_diag[1]+1;while(1){}')
if args.sky_mode=='cache':
 # An unarchived standalone fixture keeps its original program in RAM too.
 # Avoid embedding both renderers plus a 38 KB optional cache. The flash run
 # above establishes frozen-v5 parity; this smaller fixture checks cache vs
 # that exact flash path, forcing redraws on both surfaces (no reuse claim).
 source=source.replace('volatile uint16_t scene_diag[5];', '''void ref_draw_game(void){
 const uint8_t *saved=sky_ram_pixels;int oldx=camx,oldy=camy;sky_ram_pixels=NULL;
 invalidate_scene_cache();draw_game();sky_ram_pixels=saved;camx=oldx;camy=oldy;invalidate_scene_cache();
}
volatile uint16_t scene_diag[5];''')
(OUT/'src/main.c').write_text('\n'.join(line.rstrip() for line in source.splitlines())+'\n')
(OUT/'src/cache.c').write_text(includes((GAME/'src/render_cache.c').read_text()))
(OUT/'src/sky_runtime.c').write_text(includes((GAME/'src/sky_runtime.c').read_text()))
(OUT/'src/small_format.c').write_text((GAME/'src/small_format.c').read_text())
if (OUT/'src/sky_copy.s').exists():(OUT/'src/sky_copy.s').unlink()
(OUT/'makefile').write_text('NAME = PDSCENE\nDESCRIPTION = "Scene pixels against v5"\nCOMPRESSED = YES\nARCHIVED = YES\nCFLAGS = -Wall -Wextra -Oz -std=c11\nEXTRA_LDFLAGS += -T ../../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
# This fixture is under game/tests/scene-native, so the game's guard is ../../.
(OUT/'makefile').write_text((OUT/'makefile').read_text().replace('../../../ram_guard.ld','../../ram_guard.ld'))
(OUT/'makefile').write_text((OUT/'makefile').read_text().replace('COMPRESSED = YES','COMPRESSED = NO\nHAS_PRINTF = NO').replace('ARCHIVED = YES','ARCHIVED = NO').replace('-std=c11','-std=c11 -DSKY_FLASH_ROWS'))
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
mapping=(OUT/'bin/PDSCENE.map').read_text();addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_scene_diag\s*$',mapping,re.M)[1],16)
def crc(data):
 v=0xffffffff
 for b in data:
  v^=b
  for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
 return f'{v^0xffffffff:08X}'
lib=ROOT/'local-tools/cemu/clibs/clibs'
files=[lib/(s+'.8xv') for s in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[OUT/'bin/PDSCENE.8xp']
expected=[1,600,0,0,0]
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='PDSCENE',isASM=True),delay_after_step=0,sequence=['action|launch','delay|1000','hashWait|scene'],hashes=dict(scene=dict(description='600 native sky/scene comparisons',start=hex(addr),size=10,expected_CRCs=[crc(struct.pack('<5H',*expected))],timeout=220000)))
(OUT/'smoke.json').write_text(json.dumps(config,indent=2))
if args.debug_first:
 config['sequence'][1]='delay|3000';config['hashes']['scene']['timeout']=1;(OUT/'smoke.json').write_text(json.dumps(config,indent=2))
run=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(OUT/'smoke.json')],cwd=OUT,capture_output=True,text=True,timeout=650,creationflags=0x00000040|0x08000000)
(OUT/'smoke.log').write_text(run.stdout+run.stderr);print(run.stdout+run.stderr)
values=list(struct.unpack_from('<5H',(OUT/'native-ram.bin').read_bytes(),addr-0xD00000))
failed=bool(run.returncode or 'NMI' in run.stdout+run.stderr or values!=expected)
stats_addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_pedro_render_stats\s*$',mapping,re.M)[1],16)-0xD00000
stats=list(struct.unpack_from('<3I',(OUT/'native-ram.bin').read_bytes(),stats_addr))
failed|=not (stats[0] and stats[2] and (stats[1] or args.sky_mode=='cache'))
(OUT/'result.json').write_text(json.dumps(dict(expected=expected,observed=values,full_reused_overflow=stats,failed=failed,renderer_normalized_sha256=candidate_hash,reference_sha256=reference_hash,sky_mode=args.sky_mode,scope=__doc__ if args.sky_mode=='flash' else '600 native full-redraw comparisons of RAM cache against the flash sky path, with notice/scene canaries. Flash path independently compared with frozen v5. No retained-frame claim from this cache fixture.'),indent=2)+'\n')
print(values);raise SystemExit(failed)
