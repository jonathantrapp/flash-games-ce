"""Native exact sky/tile/HUD pixels and cache guards; host map coordinate proof.

Raw original sprites supply the reference. Synthetic fixtures, not campaigns.
"""
from pathlib import Path
import argparse,hashlib,json,re,struct,subprocess
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--debug-fast',action='store_true');parser.add_argument('--stop',type=int,default=92);args=parser.parse_args()
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
snapshot={n:hashlib.sha256((GAME/'src'/n).read_bytes()).hexdigest() for n in ['art.c','main.c','engine.h','combat.h']}
OUT=HERE/'art-native';(OUT/'src').mkdir(parents=True,exist_ok=True)
art=(GAME/'src/art.c').read_text().replace('#include "art.h"','#include "../../../src/art.h"').replace('#include "input.h"','#include "../../../src/input.h"')
art=art.replace('static uint8_t hudCache[2+41*(125+64)]={1};','static struct {uint8_t before[64],pixels[2+41*(125+64)],after[64];} hudGuard={{1}};\n#define hudCache hudGuard.pixels')
art=art.replace('static uint8_t skyCache[13000], tileCache[16][410];','static uint8_t skyCache[13000];\nstatic struct {uint8_t before[64],pixels[16][410],after[64];} tileGuard;\n#define tileCache tileGuard.pixels')
art+='\nunsigned art_guards(void){unsigned n=0;for(unsigned i=0;i<64;i++)n+=hudGuard.before[i]!=(i?0:1)||hudGuard.after[i]!=0||tileGuard.before[i]!=0||tileGuard.after[i]!=0;return n;}\n'
(OUT/'src/art.c').write_text(art)
source=r'''#include <tice.h>
#include <sys/power.h>
#include <graphx.h>
#include <keypadc.h>
#include <string.h>
#include "../../../src/art.h"
void input_poll(void){}
unsigned art_guards(void);
volatile uint16_t render_diag[5];
volatile uint24_t debug_stop __attribute__((section(".data")))=DEBUG_STOP;
volatile uint24_t direct_probe[4];
#define ART_PHASE(n) do{render_diag[0]=(n);if(debug_stop==(n))while(1){kb_Scan();}}while(0)
static void compare(void){
 if(memcmp(gfx_vram,gfx_vram+76800,76800)){render_diag[2]++;if(!render_diag[4])render_diag[4]=render_diag[1]+1;}
 render_diag[3]+=art_guards();render_diag[1]++;
}
static void raw(int id,int frame,int x,int y){
 const Art *a=&artTable[id];
 if(x>=0&&y>=0&&x+a->width<=320&&y+a->height<=240)gfx_TransparentSprite_NoClip(art_sprite(id,frame),x,y);
 else gfx_TransparentSprite(art_sprite(id,frame),x,y);
}
int main(void){
 render_diag[0]=90;boot_Set48MHzMode();
 gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);
 render_diag[0]=91;
 if(!art_open()){render_diag[0]=2;while(1){}}
 render_diag[0]=92;
 int skies[]={ART_SKY_SUNSETIMAGE_LEFT,ART_SKY_DESERTIMAGE_LEFT,ART_SKY_CAVEIMAGE_LEFT};
 for(int surface=0;surface<2;surface++){
  for(int s=0;s<3;s++){
   const ArtFrame *probe=&artFrames[artTable[skies[s]].first];const uint8_t *pixels=artBanks[probe->bank]+probe->offset;
   direct_probe[0]=probe->bank;direct_probe[1]=(uint24_t)pixels;direct_probe[2]=pixels[0];direct_probe[3]=pixels[1];
   render_diag[0]=93;
   if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();gfx_FillScreen(17);
   gfx_Sprite_NoClip(art_sprite(skies[s],0),0,0);
   render_diag[0]=94;
   gfx_Sprite_NoClip(art_sprite(skies[s],1),0,120);
   gfx_Sprite_NoClip(art_sprite(skies[s]+1,0),160,0);
   gfx_Sprite_NoClip(art_sprite(skies[s]+1,1),160,120);
   if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();art_background(skies[s]);render_diag[0]=95;compare();
  }
  for(int theme=0;theme<4;theme++)for(int group=0;group<8;group++){
   uint8_t ids[16];for(int i=0;i<16;i++)ids[i]=group*16+i;
   art_cache_level(ids,ids,ids,16,ART_TILES0+theme);
   for(int edge=0;edge<5;edge++){
    int dx[]={0,-8,300,0,0},dy[]={0,0,0,-8,225};
    if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();gfx_FillScreen(17);
    for(int i=0;i<16;i++)raw(ART_TILES0+theme,ids[i],(i%8)*19+dx[edge],(i/8)*19+dy[edge]);
    if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();gfx_FillScreen(17);
    for(int i=0;i<16;i++)art_draw(ART_TILES0+theme,ids[i],(i%8)*19+dx[edge],(i/8)*19+dy[edge]);compare();
   }
  }
  for(int clip=0;clip<4;clip++)for(int edge=0;edge<4;edge++){
   int dx[]={195,-20,300,120},dy[]={0,10,220,80};
   gfx_SetClipRegion(0,0,320,240);if(clip==1)gfx_SetClipRegion(17,9,301,173);if(clip==2)gfx_SetClipRegion(260,0,310,240);if(clip==3)gfx_SetClipRegion(0,0,320,22);
   if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();gfx_FillScreen(17);raw(ART_HUD,0,dx[edge],dy[edge]);
   if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();gfx_FillScreen(17);art_draw(ART_HUD,0,dx[edge],dy[edge]);compare();
  }
 }
 render_diag[0]=1;while(1){kb_Scan();}
}
'''.replace('DEBUG_STOP',str(args.stop if args.debug_fast else 0))
for phase in range(90,96):source=source.replace('render_diag[0]='+str(phase)+';','ART_PHASE('+str(phase)+');')
(OUT/'src/main.c').write_text(source)
(OUT/'makefile').write_text('NAME = SCART\nOBJDIR = obj_guarded\nDESCRIPTION = "Native art pixels"\nCOMPRESSED = NO\nARCHIVED = NO\nLTO = NO\nCFLAGS = -Wall -Wextra -Oz -std=c11\nEXTRA_LDFLAGS += -T ../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
assert snapshot=={n:hashlib.sha256((GAME/'src'/n).read_bytes()).hexdigest() for n in snapshot}
mapping=(OUT/'bin/SCART.map').read_text();addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_render_diag\s*$',mapping,re.M)[1],16)
def crc(data):
 v=0xffffffff
 for b in data:
  v^=b
  for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
 return f'{v^0xffffffff:08X}'
lib=ROOT/'local-tools/cemu/clibs/clibs'
files=[lib/(s+'.8xv') for s in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[OUT/'bin/SCART.8xp']
expected=[1,358,0,0,0]
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='SCART',isASM=True),delay_after_step=0,sequence=['delay|1500','action|launch','delay|1000','hashWait|pixels'],hashes=dict(pixels=dict(description='358 native art comparisons',start=hex(addr),size=10,expected_CRCs=[crc(struct.pack('<5H',*expected))],timeout=180000)))
(OUT/'smoke.json').write_text(json.dumps(config,indent=2))
if args.debug_fast:
 config['sequence']=['delay|1500','action|launch','delay|1000','hashWait|pixels'];config['hashes']['pixels'].update(timeout=1000,size=2,expected_CRCs=[crc(struct.pack('<H',args.stop))]);(OUT/'smoke.json').write_text(json.dumps(config,indent=2))
r=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(OUT/'smoke.json')],cwd=OUT,capture_output=True,text=True,timeout=650,creationflags=0x08000040)
(OUT/'smoke.log').write_text(r.stdout+r.stderr);print(r.stdout+r.stderr)
ram=(OUT/'native-ram.bin').read_bytes();values=list(struct.unpack_from('<5H',ram,addr-0xd00000))
failed=bool(r.returncode or 'NMI' in r.stdout+r.stderr or (values[0]!=args.stop if args.debug_fast else values!=expected))
coordinates=0
for width in range(1,101):
 for camera in range(max(1,width*16-319)):
  old=[(x,x*16-camera) for x in range(camera//16,width) if x*16-camera<320]
  new=[];screenX=-(camera%16)
  for x in range(camera//16,width):
   if screenX>=320:break
   new.append((x,screenX));screenX+=16
  assert old==new;coordinates+=1
result=dict(expected=([args.stop] if args.debug_fast else expected),debug_only=args.debug_fast,program_sha256=hashlib.sha256((OUT/'bin/SCART.8xp').read_bytes()).hexdigest(),generated_art_sha256=hashlib.sha256((OUT/'src/art.c').read_bytes()).hexdigest(),observed=values,failed=failed,map_coordinate_cases=coordinates,source_sha256=snapshot,scope=__doc__)
(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));raise SystemExit(failed)
