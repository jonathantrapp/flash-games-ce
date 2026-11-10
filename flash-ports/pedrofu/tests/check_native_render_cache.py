"""Compare the real tile/HUD cache renderer with GraphX reference draws.

Uses both LCD framebuffers, all 15 stage cache selections and clipped HUD
montages. No ROM/RAM image is published. Requires local CEdev and CEmu.
"""
from pathlib import Path
import hashlib,json,re,struct,subprocess,zlib

HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
NATIVE=HERE/'render-native';(NATIVE/'src').mkdir(parents=True,exist_ok=True)
cache=(GAME/'src/render_cache.c').read_text()
assert 'static uint8_t hud_storage[4800];' in cache
cache=cache.replace('static uint8_t hud_storage[4800];',
    'static struct {uint8_t before[64],pixels[4800],after[64];} hud_guard;\n#define hud_storage hud_guard.pixels')
cache=cache.replace('static uint8_t tile_storage[TILE_SLOTS][TILE_BYTES];',
    'static struct {uint8_t before[64],pixels[TILE_SLOTS][TILE_BYTES],after[64];} tile_guard;\n#define tile_storage tile_guard.pixels')
cache=cache.replace('static uint8_t actor_storage[ACTOR_SLOTS][ACTOR_BYTES];',
    'static struct {uint8_t before[64],pixels[ACTOR_BYTES],after[64];} actor_guard[ACTOR_SLOTS];')
cache=cache.replace('actor_storage[i]','actor_guard[i].pixels').replace('actor_storage[slot]','actor_guard[slot].pixels')
source=r'''#include "../../../src/game.h"
#include "../../../src/bundle.h"
const uint8_t *artdata[60],*tiledata[2],*uidata[3][2],*uiimg[UI_COUNT];
CACHE
static const uint8_t *banks[BUNDLE_BANKS];
volatile uint16_t render_diag[8]; /* done,stage_montages,hud_montages,pixel_fail,canary_fail,opaque_selections,actor_montages,visible */
static bool load(void){for(int i=0;i<BUNDLE_BANKS;i++){char n[9];snprintf(n,sizeof n,"PDB%02d",i);uint8_t f=ti_Open(n,"r");if(!f)return false;unsigned sz=ti_GetSize(f);const uint8_t*p=ti_GetDataPtr(f);bool ok=sz==bundle_bank_sizes[i]&&!memcmp(p,bundle_signature,8)&&p[8]==i;ti_Close(f);if(!ok)return false;banks[i]=p;}return true;}
static const uint8_t *resource(const char*n){for(unsigned i=0;i<COUNT(bundle);i++)if(!strcmp(n,bundle[i].name))return banks[bundle[i].bank]+bundle[i].offset;uint8_t f=ti_Open(n,"r");if(!f)return NULL;const uint8_t*p=ti_GetDataPtr(f);ti_Close(f);return p;}
static void clear(void){gfx_SetClipRegion(0,0,320,240);gfx_SetDrawScreen();gfx_FillScreen(7);gfx_SetDrawBuffer();gfx_FillScreen(7);}
static void compare(void){if(memcmp(gfx_vram,gfx_vram+76800,76800))render_diag[3]++;}
static void guards(void){for(unsigned i=0;i<64;i++){if(hud_guard.before[i]!=0xa5||hud_guard.after[i]!=0xa5||tile_guard.before[i]!=0xa5||tile_guard.after[i]!=0xa5){render_diag[4]++;break;}for(unsigned j=0;j<ACTOR_SLOTS;j++)if(actor_guard[j].before[i]!=0xa5||actor_guard[j].after[i]!=0xa5){render_diag[4]++;return;}}}
static void actors(bool cached,int edge){int count=0;for(int id=0;id<60;id++)if(artdata[id])for(int face=0;face<2;face++){
 const ArtDef*a=&artdef[id];unsigned frame=(id+edge)%a->frames;const uint8_t*s=artdata[id]+(face*a->frames+frame)*a->stride;
 int x=(count%8)*40+(edge==1?-20:edge==2?300:0),y=(count/8)*24+(edge==3?-20:edge==4?228:0);count++;
 if(cached)cached_sprite(s,x,y);else gfx_TransparentSprite((gfx_sprite_t*)s,x,y);
}}
static void hud_montage(bool cached,int xoffset){int count=0;for(uint8_t id=0;id<=UI_BADGI;id++)for(uint8_t f=0;f<uidef[id].frames;f++){
 int x=(count%4)*80+xoffset,y=(count/4)*30+2;count++;
 if(cached){if(!cached_hud(id,f,x,y))render_diag[3]++;}
 else gfx_TransparentSprite((gfx_sprite_t *)(uiimg[id]+f*uidef[id].stride),x,y);
}}
int main(void){gfx_Begin();gfx_SetDefaultPalette(gfx_8bpp);gfx_SetDrawBuffer();gfx_SetTransparentColor(0);memset(&hud_guard,0xa5,sizeof hud_guard);memset(&tile_guard,0xa5,sizeof tile_guard);memset(actor_guard,0xa5,sizeof actor_guard);
 if(!load()){render_diag[0]=2;}else{
  tiledata[0]=resource("PDTILE0");tiledata[1]=resource("PDTILE1");for(int id=0;id<=UI_BADGI;id++)uiimg[id]=resource(uidef[id].name);
  for(int id=0;id<60;id++)if(artdef[id].frames){char name[9];snprintf(name,sizeof name,"PDG%02d",id);artdata[id]=resource(name);}
  if(!tiledata[0]||!tiledata[1])render_diag[0]=2;else{
   cache_hud();guards();
   for(int stage=1;stage<=15;stage++){
    char name[9];snprintf(name,sizeof name,"PDLV%02d",stage);const uint8_t*p=resource(name);if(!p){render_diag[0]=2;break;}
    unsigned n=(p[0]+256*p[1])*(p[2]+256*p[3]);cache_stage_tiles(p+4,p+4+n,p+4+n*2,n);guards();
    for(unsigned i=1;i<296;i++)render_diag[5]+=tile_opaque[i]!=0;
    clear();gfx_SetDrawScreen();for(int t=1;t<296;t++)gfx_TransparentSprite((gfx_sprite_t *)(tiledata[t/148]+(t%148)*258),(t%20)*16,(t/20)*16);
    gfx_SetDrawBuffer();for(int t=1;t<296;t++)cached_tile(t,(t%20)*16,(t/20)*16);compare();render_diag[1]++;
   }
   for(int edge=0;edge<4;edge++){
    const int dx[4]={-8,8,-319,319},dy[4]={-8,8,-239,239};
    clear();gfx_SetDrawScreen();for(int t=1;t<296;t++)gfx_TransparentSprite((gfx_sprite_t *)(tiledata[t/148]+(t%148)*258),(t%20)*16+dx[edge],(t/20)*16+dy[edge]);
    gfx_SetDrawBuffer();for(int t=1;t<296;t++)cached_tile(t,(t%20)*16+dx[edge],(t/20)*16+dy[edge]);compare();guards();render_diag[1]++;
   }
   for(int clipped=0;clipped<4;clipped++)for(int shift=0;shift<2;shift++){
    clear();if(clipped==1)gfx_SetClipRegion(17,9,301,173);if(clipped==2)gfx_SetClipRegion(260,0,310,240);if(clipped==3)gfx_SetClipRegion(0,0,320,22);
    gfx_SetDrawScreen();hud_montage(false,shift?-12:0);gfx_SetDrawBuffer();hud_montage(true,shift?-12:0);compare();guards();render_diag[2]++;
   }
   for(int edge=0;edge<5;edge++){
    clear();gfx_SetDrawScreen();actors(false,edge);gfx_SetDrawBuffer();actors(true,edge);compare();guards();render_diag[6]++;
    /* Redraw after cache eviction to exercise both misses and hits. */
    clear();gfx_SetDrawScreen();actors(false,edge);gfx_SetDrawBuffer();actors(true,edge);compare();guards();render_diag[6]++;
   }
   if(!render_diag[0])render_diag[0]=1;
  }
 }
 gfx_SetClipRegion(0,0,320,240);gfx_SetDrawBuffer();gfx_FillScreen(0);gfx_SetTextFGColor(255);char text[48];gfx_PrintStringXY("Native render cache comparison",6,12);for(int i=0;i<7;i++){snprintf(text,sizeof text,"%d: %d",i,render_diag[i]);gfx_PrintStringXY(text,12,35+i*23);}gfx_SwapDraw();gfx_Wait();render_diag[7]=1;while(1){kb_Scan();}
}
'''.replace('CACHE',cache.replace('#include "game.h"','#include "../../../src/game.h"').replace('#include "render_cache.h"','#include "../../../src/render_cache.h"'))
(NATIVE/'src/main.c').write_text(source)
(NATIVE/'src/small_format.c').write_text((GAME/'src/small_format.c').read_text())
(NATIVE/'makefile').write_text('NAME = PDRCACHE\nDESCRIPTION = "Render cache pixel QA"\nCOMPRESSED = YES\nARCHIVED = YES\nCFLAGS = -Wall -Wextra -Oz -std=c11\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
(NATIVE/'makefile').write_text((NATIVE/'makefile').read_text().replace('COMPRESSED = YES','COMPRESSED = NO\nHAS_PRINTF = NO').replace('ARCHIVED = YES','ARCHIVED = NO'))
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=NATIVE,check=True)
maptext=(NATIVE/'bin/PDRCACHE.map').read_text();addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_render_diag\s*$',maptext,re.M)[1],16)
lib=ROOT/'local-tools/cemu/clibs/clibs'
files=[lib/(s+'.8xv') for s in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('PDB[0-9][0-9].8xv'))+[GAME/'bin/PDTILE0.8xv',GAME/'bin/PDTILE1.8xv',NATIVE/'bin/PDRCACHE.8xp']
def crc(data):
 v=0xffffffff
 for byte in data:
  v^=byte
  for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
 return f'{v^0xffffffff:08X}'
expected=[1,19,8,0,0]
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='PDRCACHE',isASM=True),delay_after_step=0,
 sequence=['action|launch','delay|60000','hashWait|pixels','hashWait|visible'],hashes=dict(pixels=dict(description='All stage tile selections and clipped HUD match reference pixels; canaries intact',start=hex(addr),size=10,expected_CRCs=[crc(struct.pack('<5H',*expected))],timeout=5000),visible=dict(description='Result screen has completed its framebuffer swap',start=hex(addr+14),size=2,expected_CRCs=[crc(struct.pack('<H',1))],timeout=5000)))
(NATIVE/'smoke.json').write_text(json.dumps(config,indent=2))
run=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(NATIVE/'smoke.json')],cwd=NATIVE,capture_output=True,text=True,timeout=240,creationflags=0x00000040|0x08000000)
(NATIVE/'smoke.log').write_text(run.stdout+run.stderr);print(run.stdout+run.stderr)
counts=struct.unpack_from('<8H',(NATIVE/'native-ram.bin').read_bytes(),addr-0xD00000)
failed=bool(run.returncode or 'NMI' in run.stdout+run.stderr or list(counts[:5])!=expected or counts[6]!=10 or counts[7]!=1)
(NATIVE/'result.json').write_text(json.dumps(dict(expected=expected,observed=list(counts),returncode=run.returncode,failed=failed,cache_sha256=hashlib.sha256((GAME/'src/render_cache.c').read_bytes()).hexdigest(),scope='Native actual renderer compared with original GraphX transparent sprite draws: all296 tiles under15 stage cache selections,4 screen-edge montages and8 HUD/clip montages, 10 actor/cache-eviction montages in both facings and at screen edges; separate 64-byte guards around every actor slot and tile/HUD storage.'),indent=2))
raw=NATIVE/'lcd_frame.rgba'
if raw.exists():
 data=bytearray(raw.read_bytes());red=data[2::4];data[2::4]=data[0::4];data[0::4]=red
 def chunk(k,d):return struct.pack('>I',len(d))+k+d+struct.pack('>I',zlib.crc32(k+d))
 rows=b''.join(b'\0'+data[y*1280:(y+1)*1280] for y in range(240))
 (NATIVE/'screen.png').write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',320,240,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(rows))+chunk(b'IEND',b''))
raise SystemExit(failed)
