"""Native GraphX skill-overlay input/print-bound checks and visual capture.

Uses actual frontend.c, generated descriptions and profile.c. Stage loading is
stubbed; UI assets, fonts, description wrapping and skill purchase/refund are real.
"""
from pathlib import Path
import hashlib,json,re,struct,subprocess,zlib

HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
NATIVE=HERE/'skill-native';(NATIVE/'src').mkdir(parents=True,exist_ok=True)
render=(GAME/'src/render.c').read_text()
def function(name):
 match=re.search(r'void '+name+r'\([^)]*\)\s*\{',render)
 start=match.start();end=match.end();depth=1
 while depth:depth+=(render[end]=='{')-(render[end]=='}');end+=1
 return render[start:end]
print_fit=function('print_fit')+'\n'+function('wrap_text')
source=r'''#include "../../../src/game.h"
#include "../../../src/bundle.h"
#include "../../../src/profile.c"
Game g;
const uint8_t *artdata[60],*tiledata[2],*uidata[3][2],*uiimg[UI_COUNT];
uint8_t cBlack=0,cWhite=255,cYellow=254,cGold=252,cRed=254,cGreen=254,cCyan=255,cPanel=1;
volatile uint16_t skill_ui_diag[5]; /* done,assertions,failures,badtext,maxlines */
static const uint8_t *banks[BUNDLE_BANKS];
int absi(int x){return x<0?-x:x;}
int clampi(int v,int lo,int hi){return v<lo?lo:v>hi?hi:v;}
int levels_passed(void){return 0;}
bool load_level(int level){g.level=level;g.mode=PLAY;return true;}
static const uint8_t *resource(const char *name){
 for(unsigned i=0;i<COUNT(bundle);i++)if(!strcmp(bundle[i].name,name))return banks[bundle[i].bank]+bundle[i].offset;
 uint8_t f=ti_Open(name,"r");if(!f)return NULL;const uint8_t*p=ti_GetDataPtr(f);ti_Close(f);return p;
}
static uint8_t nearest(const uint8_t *palette,int r,int g,int b){
 int best=1,distance=0x7fffff;for(int i=1;i<256;i++){
  unsigned p=palette[i*2]|((unsigned)palette[i*2+1]<<8);
  int dr=((p>>10)&31)*255/31-r,dg=((p>>5)&31)*255/31-g,db=(p&31)*255/31-b;
  int d=dr*dr+dg*dg+db*db;if(d<distance){distance=d;best=i;}
 }return best;
}
static bool load(void){
 for(int i=0;i<BUNDLE_BANKS;i++){char name[9];snprintf(name,sizeof name,"PDB%02d",i);uint8_t f=ti_Open(name,"r");if(!f)return false;const uint8_t*p=ti_GetDataPtr(f);bool valid=ti_GetSize(f)==bundle_bank_sizes[i]&&!memcmp(p,bundle_signature,8)&&p[8]==i;ti_Close(f);if(!valid)return false;banks[i]=p;}
 const uint8_t*p=resource("PDCOLOR");if(!p)return false;gfx_SetPalette(p,512,0);
 cBlack=nearest(p,0,0,0);cPanel=nearest(p,24,24,48);cCyan=nearest(p,90,220,255);
 for(int i=0;i<3;i++)for(int half=0;half<2;half++){char name[9];snprintf(name,sizeof name,"PDU%d%d",i,half);uidata[i][half]=resource(name);if(!uidata[i][half])return false;}
 for(int i=0;i<UI_COUNT;i++){uiimg[i]=resource(uidef[i].name);if(!uiimg[i])return false;}
 return true;
}
void draw_ui(int id,int fr,int x,int y){if(id<0||id>=UI_COUNT||!uiimg[id])return;const UiDef*u=&uidef[id];if(fr<0)fr=0;if(fr>=u->frames)fr=u->frames-1;gfx_TransparentSprite((gfx_sprite_t *)(uiimg[id]+fr*u->stride),x,y);}
static void checked_print(const char *s,int x,int y){
 if(x<0||y<0||y>232||x+(int)gfx_GetStringWidth(s)>320)skill_ui_diag[3]++;
 gfx_PrintStringXY(s,x,y);
}
#define gfx_PrintStringXY checked_print
PRINT_FIT
#include "../../../src/frontend.c"
#undef gfx_PrintStringXY
static void expect(bool condition){skill_ui_diag[1]++;if(!condition)skill_ui_diag[2]++;}
static void key(unsigned value){g.tap=value;frontend_update();g.tap=0;}
int main(void){
 gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);
 if(!load()){skill_ui_diag[0]=2;gfx_End();return 1;}
 g.mode=SKILLS;g.previousmode=MAP;progress.points=5;
 key(HITKEY);expect(!skill_details&&g.mode==SKILLS);
 progress.have[0]=1;key(HITKEY);expect(skill_details&&skill_next&&skill_scroll==0);
 key(MENUKEY);expect(!skill_details&&g.mode==SKILLS);
 key(HITKEY);key(ACCEPT);expect(progress.skills[0]==1&&progress.points==4&&skill_details);
 key(RIGHT);expect(skill_next);draw_frontend();expect(skill_detail_total>0&&skill_detail_total<=12);
 key(LEFT);expect(!skill_next);key(DOWN);expect(skill_scroll==0);
 key(FURYKEY);expect(progress.skills[0]==0&&progress.points==5);draw_frontend();expect(skill_next);
 key(HITKEY);expect(!skill_details);key(RIGHT);expect(skill_cursor==1);
 key(MENUKEY);expect(g.mode==MAP);
 g.mode=SKILLS;skill_cursor=5;skill_details=true;skill_next=true;
 memset(progress.have,1,sizeof progress.have);memset(progress.skills,5,sizeof progress.skills);
 for(int id=0;id<45;id++){
  skill_cursor=id;for(int rank=0;rank<=5;rank++){
   progress.skills[id]=rank;skill_next=rank<5;skill_scroll=0;draw_frontend();
   expect(skill_detail_total>0&&skill_detail_total<=12);
   if(skill_detail_total>skill_ui_diag[4])skill_ui_diag[4]=skill_detail_total;
  }progress.skills[id]=5;
 }
 skill_cursor=5;skill_next=true;draw_frontend();expect(!skill_next);
 expect(skill_ui_diag[3]==0);skill_ui_diag[0]=1;
 draw_frontend();gfx_SwapDraw();
 while(1){kb_Scan();if(kb_Data[6]&kb_Clear)break;}
 gfx_End();return 0;
}
'''.replace('PRINT_FIT',print_fit)
(NATIVE/'src/main.c').write_text(source)
(NATIVE/'makefile').write_text('NAME = PDSKILL\nDESCRIPTION = "Native skill UI QA"\nCOMPRESSED = YES\nARCHIVED = YES\nCFLAGS = -Wall -Wextra -Oz -std=c11\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe'),'COMMENT=SKILLQA'],cwd=NATIVE,check=True)
maptext=(NATIVE/'bin/PDSKILL.map').read_text();addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_skill_ui_diag\s*$',maptext,re.M)[1],16)
lib=ROOT/'local-tools/cemu/clibs/clibs'
files=[lib/(name+'.8xv')for name in ['libload','graphx','keypadc','fileioc']]+sorted((GAME/'bin').glob('*.8xv'))+[NATIVE/'bin/PDSKILL.8xp']
def crc(data):
 value=0xffffffff
 for byte in data:
  value^=byte
  for i in range(8):value=(value>>1)^(0x82f63b78 if value&1 else 0)
 return f'{value^0xffffffff:08X}'
expected=[1,285,0,0]
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=[str(f)for f in files],target=dict(name='PDSKILL',isASM=True),delay_after_step=0,
 sequence=['action|launch','delay|90000','hashWait|skillui'],hashes=dict(skillui=dict(description='Skill detail input states, all45 descriptions ranks0..5 and native GraphX print bounds',start=hex(addr),size=8,expected_CRCs=[crc(struct.pack('<4H',*expected))],timeout=30000)))
(NATIVE/'smoke.json').write_text(json.dumps(config,indent=2))
run=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(NATIVE/'smoke.json')],cwd=NATIVE,capture_output=True,text=True,timeout=240)
(NATIVE/'smoke.log').write_text(run.stdout+run.stderr);print(run.stdout+run.stderr)
raw=NATIVE/'lcd_frame.rgba'
if raw.exists():
 data=bytearray(raw.read_bytes());red=data[2::4];data[2::4]=data[0::4];data[0::4]=red
 def chunk(kind,value):return struct.pack('>I',len(value))+kind+value+struct.pack('>I',zlib.crc32(kind+value))
 rows=b''.join(b'\0'+data[y*1280:(y+1)*1280]for y in range(240))
 (NATIVE/'screen.png').write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',320,240,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(rows))+chunk(b'IEND',b''))
result=dict(returncode=run.returncode,expected=expected,frontend_sha256=hashlib.sha256((GAME/'src/frontend.c').read_bytes()).hexdigest(),
 scope='Actual frontend.c/profile.c and GraphX fonts/assets; locked/detail toggle,current-next preview,learn/refund,close/navigation; all45 descriptions ranks0..5 with print bounds; stage load stubbed; emulator OS5.3.')
(NATIVE/'result.json').write_text(json.dumps(result,indent=2))
raise SystemExit(run.returncode)
