"""Exercise native GraphX font/text layout with guarded original text buffers."""
from pathlib import Path
import json, re, subprocess, zlib, struct

HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
NATIVE=HERE/'text-native';(NATIVE/'src').mkdir(parents=True,exist_ok=True)
render=(GAME/'src/render.c').read_text()
def function(name):
 m=re.search(r'void '+name+r'\([^)]*\)\s*\{',render);start=m.start();end=m.end();depth=1
 while depth:depth+=(render[end]=='{')-(render[end]=='}');end+=1
 return render[start:end]
functions='\n'.join(function(n) for n in ['print_fit','center_text','wrap_text'])
functions=functions.replace('char buffer[96] = {0};','char *buffer=(char *)buffer_guard+128;memset(buffer,0,96);').replace('char buffer[96];','char *buffer=(char *)buffer_guard+128;').replace('char line[96];','char *line=(char *)line_guard+128;')
functions=functions.replace('sizeof line','96').replace('sizeof buffer','96')
spec=json.loads((GAME.parent/'pedro-dialogue-spec.json').read_text())
pages=[p['text'] for e in spec['events'] for p in e['initial']+e['followups']]
front=(GAME/'src/frontend.c').read_text().split('void draw_frontend(void)',1)[1]
helpblock=front[front.index('case HELP:'):front.index('case MAP:',front.index('case HELP:'))]
strings=re.findall(r'"((?:\\.|[^"\\])*)"',helpblock[helpblock.index('wrap_text('):helpblock.index('centered(204')])
helptext=''.join(json.loads('"'+s+'"') for s in strings)
source='''#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint8_t line_guard[4096],buffer_guard[4096];
volatile uint8_t text_diag[8]; /* done,dialogue_overflow,help_overflow,stress_overflow,real_bad_coords,stress_bad_coords,pagecount,buffer_overflow */
static int bad_coords;
static void capture_print(const char*s,int x,int y){if(x<0||y<0||x+(int)gfx_GetStringWidth(s)>320||y+8>240)bad_coords++;}
#define gfx_PrintStringXY capture_print
FUNCTIONS
#undef gfx_PrintStringXY
static int corrupted(const uint8_t*a){for(int i=0;i<4096;i++)if((i<128||i>=224)&&a[i]!=0xa5)return 1;return 0;}
static void clear_guards(void){memset(line_guard,0xa5,sizeof line_guard);memset(buffer_guard,0xa5,sizeof buffer_guard);}
static const char *pages[]={PAGES};
int main(void){gfx_Begin();gfx_SetDrawBuffer();gfx_SetTextScale(1,1);uint16_t white=0x7fff,black=0;gfx_SetPalette(&white,2,255);gfx_SetPalette(&black,2,0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);
 for(unsigned i=0;i<sizeof pages/sizeof pages[0];i++){clear_guards();wrap_text(23,47,274,pages[i],11);text_diag[1]+=corrupted(line_guard);text_diag[7]+=corrupted(buffer_guard);}
 clear_guards();wrap_text(8,20,304,HELP,11);text_diag[2]=corrupted(line_guard);text_diag[4]=bad_coords;text_diag[7]+=corrupted(buffer_guard);
 clear_guards();bad_coords=0;char stress[500];for(int i=0;i<490;i++)stress[i]=i%11==10?' ':'i';stress[490]=0;wrap_text(8,20,304,stress,11);text_diag[3]=corrupted(line_guard);text_diag[5]=bad_coords;text_diag[7]+=corrupted(buffer_guard);text_diag[6]=sizeof pages/sizeof pages[0];text_diag[0]=1;
 gfx_FillScreen(0);gfx_SetTextFGColor(255);char text[40];gfx_PrintStringXY("PDTEXT native text diagnostics",8,12);for(int i=0;i<8;i++){snprintf(text,sizeof text,"%d: %d",i,text_diag[i]);gfx_PrintStringXY(text,12,35+i*18);}gfx_SwapDraw();while(1){kb_Scan();if(kb_Data[6]&kb_Clear)break;}gfx_End();return 0;}
'''.replace('FUNCTIONS',functions).replace('PAGES',','.join(json.dumps(p) for p in pages)).replace('HELP',json.dumps(helptext))
(NATIVE/'src/main.c').write_text(source)
(NATIVE/'makefile').write_text('NAME = PDTEXT\nDESCRIPTION = "Native text buffer QA"\nCOMPRESSED = NO\nARCHIVED = YES\nCFLAGS = -Wall -Wextra -Oz -std=c11\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe'),'COMMENT=TextQA'],cwd=NATIVE,check=True)
maptext=(NATIVE/'bin/PDTEXT.map').read_text();addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_text_diag\s*$',maptext,re.M)[1],16)
lib=ROOT/'local-tools/cemu/clibs/clibs'
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=[str(lib/(s+'.8xv')) for s in ['libload','graphx','keypadc']]+[str(NATIVE/'bin/PDTEXT.8xp')],target=dict(name='PDTEXT',isASM=True),delay_after_step=0,
 sequence=['action|launch','delay|4000','hashWait|done','hashWait|buffers'],hashes={})
def crc(data):
 v=0xffffffff
 for byte in data:
  v^=byte
  for i in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
 return f'{v^0xffffffff:08X}'
config['hashes']['done']=dict(description='Native text diagnostic finished',start=hex(addr),size=1,expected_CRCs=[crc([1])],timeout=10000)
config['hashes']['buffers']=dict(description='Actual GraphX font: dialogue/help/stress buffers and print coordinates remain valid',start=hex(addr),size=8,expected_CRCs=[crc([1,0,0,0,0,0,28,0])],timeout=1000)
(NATIVE/'smoke.json').write_text(json.dumps(config,indent=2))
run=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(NATIVE/'smoke.json')],cwd=NATIVE,capture_output=True,text=True,timeout=60)
(NATIVE/'smoke.log').write_text(run.stdout+run.stderr);print(run.stdout+run.stderr)
raw=NATIVE/'lcd_frame.rgba'
if raw.exists():
 data=bytearray(raw.read_bytes());red=data[2::4];data[2::4]=data[0::4];data[0::4]=red
 def chunk(k,d):return struct.pack('>I',len(d))+k+d+struct.pack('>I',zlib.crc32(k+d))
 rows=b''.join(b'\0'+data[y*1280:(y+1)*1280] for y in range(240))
 png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',320,240,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(rows))+chunk(b'IEND',b'')
 (NATIVE/'screen.png').write_bytes(png)
raise SystemExit(run.returncode)
