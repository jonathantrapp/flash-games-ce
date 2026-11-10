"""Differential test of the scrolling-frame sky skip against forced full redraws.

The actual render.c runs in CEmu on alternating framebuffers along continuous pseudo-random
trajectories (walking, jumping, scrolling both axes, notices, mail, arena text, many enemies,
scenery, pause/dialogue frames). Each frame is hashed; the identical trajectory is then replayed
with every cache invalidated, which forces the plain full redraw, and the per-frame hashes must be
identical. The full-redraw path itself is compared with frozen v5 by check_native_scene_render.py.
This tests native pixel preservation only, not Flash fidelity or physical hardware.
"""
from pathlib import Path
import argparse,hashlib,json,re,struct,subprocess
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--frames',type=int,default=48);parser.add_argument('--seed',type=int,default=1);parser.add_argument('--stages',default='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15');parser.add_argument('--tag',default='',help='suffix for the output folder so runs can go in parallel');parser.add_argument('--idle',type=int,default=0,help='re-roll walking mode only every N frames (long idle stretches give reuse frames)');args=parser.parse_args()
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
OUT=HERE/('sky-track-native'+args.tag);(OUT/'src').mkdir(parents=True,exist_ok=True)
def includes(s):return re.sub(r'#include "([^"]+)"',r'#include "../../../src/\1"',s)
def function(s,name):
 m=re.search(r'(?:static )?[^\n{};]+\b'+name+r'\([^;{}]*\)\s*\{',s);assert m,name
 start=m.start();end=m.end();depth=1
 while depth:depth+=(s[end]=='{')-(s[end]=='}');end+=1
 return s[start:end]
candidate=(GAME/'src/render.c').read_text()
candidate_hash=hashlib.sha256(candidate.encode()).hexdigest()
assert 'static uint8_t notice_images[2][2+150*14];' in candidate
candidate=candidate.replace('static uint8_t notice_images[2][2+150*14];',
 'static struct {uint8_t before[64],pixels[2+150*14],after[64];} notice_guard[2];')
candidate=re.sub(r'notice_images\[([^]]+)\]',r'notice_guard[\1].pixels',candidate)
candidate=candidate.replace('static SceneCache scene_cache[2];','static struct {uint8_t before[64];SceneCache values[2];uint8_t after[64];} scene_guard;\n#define scene_cache scene_guard.values')
world=(GAME/'src/world.c').read_text()
helpers='\n'.join(function(world,n) for n in ['absi','clampi','open_banks','bundle_find','resource','load_resources','draw_sprite','draw_ui'])
profile=(GAME/'src/profile.c').read_text()
helpers+='\n'+function(profile,'maxlife')+'\n'+function(profile,'maxfury')
story=(GAME/'src/story.c').read_text();helpers+='\n'+function(story,'story_draw')
FRAMES=args.frames;STAGES=[int(x) for x in args.stages.split(',')]
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
CANDIDATE
#define FRAMES NFRAMES
volatile uint16_t track_diag[6]; /* done,frames compared,hash mismatches,guard failures,first mismatch (stage*256+frame+1),skipped-sky frames */
static uint32_t hashes[FRAMES][2];
static char changing_notice[96];
static unsigned rng=1;
static unsigned rnd(unsigned n){rng=(rng*25173u+13849u)&0xffffu;return (rng>>3)%n;}
static void frame_hash(uint32_t *out){
 const uint8_t *p=gfx_vbuffer;unsigned a=1,b=0,c=0;
 for(unsigned i=0;i<76800;i++){a+=p[i];b+=a;c+=p[i]^(uint8_t)i;}
 out[0]=((uint32_t)a<<8)^b;out[1]=((uint32_t)c<<4)^(b>>3);
}
static int walk_vx,walk_vy,walk_left;
static void trajectory(int stage,int f){
 if(f==0||f%REROLL==0||rnd(REROLL*2)==0){
  int mode=rnd(8);
  walk_vx=mode<2?0:mode<4?3:mode<5?7:mode<6?-4:mode<7?12:-9;
  walk_vy=rnd(3)==0?(int)rnd(9)-4:0;walk_left=8+rnd(30);
 }
 g.px+=walk_vx*16;g.py+=walk_vy*16;
 int maxx=((int)g.w*16-8)*16,maxy=((int)g.h*16-8)*16;
 if(g.px<8*16*16)g.px=8*16*16;if(g.px>maxx)g.px=maxx;if(g.py<8*16*16)g.py=8*16*16;if(g.py>maxy)g.py=maxy;
 g.ticks=f?100+f*3:1;g.face=walk_vx<0?-1:1;g.action=(f/5)%19;g.actiontime=f%30;g.invul=f%7==0?4:0;
 int k=f/9+stage;
 g.hp=(k%6==0?50:100+(k*137)%1900);g.fury=(k*37)%501;g.totalmail=k%3==0?0:k%2?26:4;g.mailleft=k%5;
 memset(progress.hearts,k%2,sizeof progress.hearts);memset(progress.souls,(k/2)%2,sizeof progress.souls);
 progress.rank=k*7;progress.points=k%3?0:25;progress.xp=k*7;
 g.arena=k%4==0?0:-1;g.arenaround=k%5;g.arenatime=300-k*31;
 snprintf(changing_notice,sizeof changing_notice,"Walking notice %d on stage %d",f/17,stage);
 g.notice=changing_notice;g.notice_timer=(f/13)%3==0?0:100;if(f%31==30){memset(changing_notice,'W',90);changing_notice[90]=0;g.notice_timer=100;}
 g.mode=f%29==28?DIALOGUE:f%41==40?PAUSE:PLAY;g.story_event=f%12;g.story_page=0;
 g.carry=f%53==52?0:-1;
 g.enemies=4;
 const uint8_t types[4]={2,39,40,46};
 for(int i=0;i<4;i++)g.enemy[i]=(Enemy){.x=g.px+(((f*(3+i)+i*29)%140)-70)*16,.y=g.py+(((f*(2+i)+i*17)%90)-60)*16,.hp=700-f*19,.maxhp=1000,.active=1,.type=types[i],.face=f&1?-1:1,.fr=f%4,.freeze=f%11==1?10:0,.stun=f%13==2?10:0};
 if(f%37==36){g.enemies=MAX_ENEMIES;for(int i=0;i<MAX_ENEMIES;i++)g.enemy[i]=(Enemy){.active=1,.type=2,.x=g.px+(((i%12)*26)-150)*16,.y=g.py+(((i/12)*24)-90)*16,.hp=100,.maxhp=100,.face=1};}
 g.props=3;
 const uint8_t props[3]={23,15,32};
 for(int i=0;i<3;i++)g.prop[i]=(Prop){.x=g.px/16+i*35-40,.y=g.py/16+((f/16)%5)*6-12,.type=props[i],.active=1,.face=1};
 if(f%5<3){ /* extra scenery that moves relative to the camera as Pedro walks */
  const uint8_t scen[6]={18,20,22,30,31,33};
  for(int i=0;i<6;i++)g.prop[g.props++]=(Prop){.x=g.px/16+i*43-120,.y=g.py/16+10-(i*13)%40,.type=scen[i],.active=1,.face=i&1?-1:1};
 }
 if(f%23==22)for(int i=0;i<24&&g.props<MAX_PROPS;i++)g.prop[g.props++]=(Prop){.x=g.px/16+(i%6)*50-150,.y=g.py/16+(i/6)*30-50,.type=23,.active=1,.face=1};
 memset(g.shot,0,sizeof g.shot);g.shot[0]=(Shot){.x=g.px+50*16,.y=g.py-(f%40)*16,.type=56,.frame=f%6,.active=1,.face=1};
 g.shot[1]=(Shot){.x=g.px-40*16,.y=g.py+(f%30)*16,.type=51,.active=1};
}
static void reset_stage(int stage){
 char name[9];snprintf(name,sizeof name,"PDLV%02d",stage);unsigned size;const uint8_t*p=bundle_find(name,&size);
 memset(&g,0,sizeof g);g.w=p[0]+256*p[1];g.h=p[2]+256*p[3];g.n=g.w*g.h;
 memcpy(g.mapdata,p+4+g.n,g.n);memcpy(g.mapdata+g.n,p+4+3*g.n,g.n);
 g.back=p+4;g.solid=g.mapdata;g.decor=p+4+2*g.n;g.good=g.mapdata+g.n;g.level=stage-1;
 cache_stage_tiles(g.back,g.solid,g.decor,g.n);
 g.px=((int)g.w/3)*16*16;g.py=((int)g.h/2)*16*16;
 memset(progress.hearts,0,sizeof progress.hearts);
 invalidate_scene_cache();
 gfx_SetDrawScreen();gfx_FillScreen(17);gfx_SetDrawBuffer();gfx_FillScreen(17);
}
int main(void){
 gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);
 for(int i=0;i<2;i++){memset(notice_guard[i].before,0xa5,64);memset(notice_guard[i].after,0xa5,64);}
 memset(scene_guard.before,0xa5,64);memset(scene_guard.after,0xa5,64);
 if(!load_resources()){track_diag[0]=2;while(1){}}
 cache_hud();pick_colors();
 static const int stages[]={STAGELIST};
 for(unsigned si=0;si<sizeof stages/sizeof *stages;si++)for(int pass=0;pass<2;pass++){int stage=stages[si];
  reset_stage(stage);rng=1+stage*977+SEED;walk_vx=walk_vy=0;
  for(int f=0;f<FRAMES;f++){
   trajectory(stage,f);
   if(pass)invalidate_scene_cache();
   if(f&1)gfx_SetDrawScreen();else gfx_SetDrawBuffer();
   draw_game();
   uint32_t h[2];frame_hash(h);
   if(!pass){hashes[f][0]=h[0];hashes[f][1]=h[1];}
   else{track_diag[1]++;if(h[0]!=hashes[f][0]||h[1]!=hashes[f][1]){track_diag[2]++;if(!track_diag[4])track_diag[4]=stage*256+f+1;}}
   for(int i=0;i<2;i++)for(int z=0;z<64;z++)if(notice_guard[i].before[z]!=0xa5||notice_guard[i].after[z]!=0xa5)track_diag[3]++;
   for(int z=0;z<64;z++)if(scene_guard.before[z]!=0xa5||scene_guard.after[z]!=0xa5)track_diag[3]++;
  }
 }
 track_diag[5]=(uint16_t)pedro_render_stats[3];
 gfx_SwapDraw();gfx_Wait();track_diag[0]=1;while(1){kb_Scan();}
}
'''.replace('HELPERS',helpers).replace('CANDIDATE',includes(candidate)).replace('NFRAMES',str(FRAMES)).replace('REROLL',str(args.idle or 11)).replace('STAGELIST',','.join(map(str,STAGES))).replace('SEED',str(args.seed))
(OUT/'src/main.c').write_text('\n'.join(line.rstrip() for line in source.splitlines())+'\n')
(OUT/'src/cache.c').write_text(includes((GAME/'src/render_cache.c').read_text()))
(OUT/'src/sky_runtime.c').write_text(includes((GAME/'src/sky_runtime.c').read_text()))
(OUT/'src/small_format.c').write_text((GAME/'src/small_format.c').read_text())
(OUT/'makefile').write_text('NAME = PDSKYTRK\nDESCRIPTION = "Sky skip vs full redraw"\nCOMPRESSED = NO\nHAS_PRINTF = NO\nARCHIVED = NO\nCFLAGS = -Wall -Wextra -Oz -std=c11 -DSKY_FLASH_ROWS\nEXTRA_LDFLAGS += -T ../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
mapping=(OUT/'bin/PDSKYTRK.map').read_text();addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_track_diag\s*$',mapping,re.M)[1],16)
def crc(data):
 v=0xffffffff
 for b in data:
  v^=b
  for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
 return f'{v^0xffffffff:08X}'
lib=ROOT/'local-tools/cemu/clibs/clibs'
files=[lib/(s+'.8xv') for s in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[OUT/'bin/PDSKYTRK.8xp']
expected=[1,len(STAGES)*FRAMES,0,0,0]
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='PDSKYTRK',isASM=True),delay_after_step=0,sequence=['action|launch','delay|1000','hashWait|track'],
 hashes=dict(track=dict(description='tracked scrolling frames equal forced full redraws',start=hex(addr),size=10,expected_CRCs=[crc(struct.pack('<5H',*expected))],timeout=1500000)))
(OUT/'smoke.json').write_text(json.dumps(config,indent=2))
run=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(OUT/'smoke.json')],cwd=OUT,capture_output=True,text=True,timeout=3000,creationflags=0x00000040|0x08000000)
(OUT/'smoke.log').write_text(run.stdout+run.stderr)
ram=(OUT/'native-ram.bin').read_bytes()
values=list(struct.unpack_from('<6H',ram,addr-0xD00000))
stats_addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_pedro_render_stats\s*$',mapping,re.M)[1],16)-0xD00000
stats=list(struct.unpack_from('<4I',ram,stats_addr))
failed=bool(run.returncode or 'NMI' in run.stdout+run.stderr or values[:5]!=expected or not stats[3] or not stats[1])
(OUT/'result.json').write_text(json.dumps(dict(expected=expected,observed=values,full_reused_overflow_skipped=stats,failed=failed,renderer_sha256=candidate_hash,seed=args.seed,frames_per_stage=FRAMES,scope=__doc__),indent=2)+'\n')
print(values,stats);raise SystemExit(failed)
