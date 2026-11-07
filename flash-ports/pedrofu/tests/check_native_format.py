"""Check the formatter on the actual CE 24-bit-int/32-bit-long ABI in CEmu."""
from pathlib import Path
import hashlib,json,re,struct,subprocess
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1];OUT=HERE/'format-native';(OUT/'src').mkdir(parents=True,exist_ok=True)
(OUT/'src/format.c').write_text((GAME/'src/small_format.c').read_text())
(OUT/'src/main.c').write_text(r'''#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <stdio.h>
#include <string.h>
volatile unsigned int format_diag[3];
#define CHECK(expected,fmt,...) do { \
 for(unsigned cap=0;cap<64;cap++){ \
  char buffer[80];memset(buffer,0x6b,sizeof buffer); \
  int n=snprintf(buffer+8,cap,fmt,__VA_ARGS__);unsigned length=strlen(expected); \
  bool bad=n!=(int)length; \
  for(unsigned i=0;i<80;i++){ \
   char wanted=0x6b;if(cap&&i>=8&&i<8+cap){unsigned p=i-8;if(p<cap-1&&p<length)wanted=expected[p];else if(p==(length<cap?length:cap-1))wanted=0;} \
   if(buffer[i]!=wanted)bad=true; \
  } \
  format_diag[1]++;format_diag[2]+=bad; \
 } }while(0)
int main(void){
 gfx_Begin();format_diag[0]=90;
 CHECK("-8388608","%d",(int)(-8388607-1));
 CHECK("8388607","%d",8388607);
 CHECK("16777215","%u",16777215U);
 CHECK("FFFFFF","%06X",16777215U);
 CHECK("D1A87E","%06X",0xD1A87EU);
 CHECK("4294967295","%lu",4294967295UL);
 CHECK("-7","%02d",-7);
 CHECK("07","%02d",7);
 CHECK("Pedro 100%","%s %d%%","Pedro",100);
 CHECK("0.05","%d.%02d",0,5);
 format_diag[0]=1;while(1){kb_Scan();}
}
''')
(OUT/'makefile').write_text('NAME = PDFMT\nDESCRIPTION = "Native formatter ABI"\nCOMPRESSED = NO\nARCHIVED = NO\nHAS_PRINTF = NO\nCFLAGS = -Wall -Wextra -Oz -std=c11\nEXTRA_LDFLAGS += -T ../../ram_guard.ld\nCEDEV_TOOLCHAIN = ../../../../local-tools/cedev/CEdev\ninclude ../../../../local-tools/cedev/CEdev/meta/makefile.mk\n')
subprocess.run([str(ROOT/'local-tools/cedev/CEdev/bin/make.exe')],cwd=OUT,check=True)
mapping=(OUT/'bin/PDFMT.map').read_text();addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_format_diag\s*$',mapping,re.M)[1],16)
data=b''.join(v.to_bytes(3,'little')for v in [1,640,0]);v=0xffffffff
for b in data:
 v^=b
 for _ in range(8):v=(v>>1)^(0x82f63b78 if v&1 else 0)
lib=ROOT/'local-tools/cemu/clibs/clibs';files=[lib/(n+'.8xv')for n in ['libload','graphx','keypadc','fileioc']]+[OUT/'bin/PDFMT.8xp']
config=dict(rom='C:/Users/jonat/Downloads/ti-84ce.rom',transfer_files=list(map(str,files)),target=dict(name='PDFMT',isASM=True),delay_after_step=0,sequence=['action|launch','delay|1000','hashWait|format'],hashes=dict(format=dict(description='640 CE ABI formatter/canary checks',start=hex(addr),size=9,expected_CRCs=[f'{v^0xffffffff:08X}'],timeout=10000)))
(OUT/'smoke.json').write_text(json.dumps(config,indent=2));r=subprocess.run([str(ROOT/'build/cemu-cli/cemu-autotester.exe'),'-d',str(OUT/'smoke.json')],cwd=OUT,capture_output=True,text=True,timeout=120,creationflags=0x08000040)
(OUT/'smoke.log').write_text(r.stdout+r.stderr);print(r.stdout+r.stderr)
ram=(OUT/'native-ram.bin').read_bytes();observed=[int.from_bytes(ram[addr-0xd00000+i:addr-0xd00000+i+3],'little')for i in [0,3,6]];failed=bool(r.returncode or 'NMI' in r.stdout+r.stderr or observed!=[1,640,0])
(OUT/'result.json').write_text(json.dumps(dict(expected=[1,640,0],observed=observed,failed=failed,source_sha256=hashlib.sha256((GAME/'src/small_format.c').read_bytes()).hexdigest(),scope=__doc__),indent=2)+'\n');raise SystemExit(failed)
