"""Differential test of optimized native move_body against its pre-optimization code.

Uses all15 original solid layers and valid starting boxes, plus an empty-map edge
fixture. This verifies preservation of the previous native collision semantics;
it does not establish original Flixel physics parity.
"""
from pathlib import Path
import hashlib,json,os,re,struct,subprocess,zlib
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
world=(GAME/'src/world.c').read_text()
def extract(name):
 m=re.search(r'(?:static )?(?:int|bool|void) '+name+r'\([^)]*\)\s*\{',world);start=m.start();end=m.end();depth=1
 while depth:depth+=(world[end]=='{')-(world[end]=='}');end+=1
 return world[start:end]
actual='\n'.join(extract(n) for n in ['tile_at','slope','blocked','body_collides','move_body'])
legacy='''static void legacy_move(int *x,int *y,int *v,int dx,int bw,int bh,int *floor){
 int tx=*x/16,ty=*y/16,oldbottom=ty+bh;int step=dx<0?-1:1;
 for(int j=0;j<absi(dx);j++){int nx=*x+step;if(!body_collides(nx/16,ty,bw,bh))*x=nx;else break;}
 *floor=0;tx=*x/16;int dy=*v,ys=dy<0?-1:1;
 for(int j=0;j<absi(dy);j++){int ny=*y+ys;if(body_collides(tx,ny/16,bw,bh)){if(ys>0)*floor=1;*v=0;break;}*y=ny;}
 if(dy>=0){int bot=*y/16+bh;for(int k=0;k<2;k++){int fx=tx+(k?bw-1:0),t=tile_at(fx,bot),s=slope(t),surface=(bot/16)*16;if(s)surface+=s==1?15-(fx&15):(fx&15);if((s||t==55||(t>=62&&t<=66))&&oldbottom<=surface+5&&bot>=surface){*y=(surface-bh)*16;*v=0;*floor=1;}}}
}
'''
source='''#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static struct {unsigned w,h;uint8_t *solid;} g;
int absi(int v){return v<0?-v:v;}
ACTUAL
LEGACY
static uint32_t seed=0x47ab8901;
static uint32_t rng(void){seed^=seed<<13;seed^=seed>>17;seed^=seed<<5;return seed;}
int main(int argc,char**argv){if(argc!=2)return 3;FILE*f=fopen(argv[1],"rb");if(!f)return 4;int maps=fgetc(f),tested=0,failed=0,edge=0,interior=0;uint8_t map[21000];
 for(int m=0;m<maps;m++){uint16_t head[2];if(fread(head,2,2,f)!=2)return 5;g.w=head[0];g.h=head[1];g.solid=map;if(fread(map,1,g.w*g.h,f)!=g.w*g.h)return 6;
  for(int i=0;i<30000;i++){int bw[]={8,11,19,32},bh[]={12,14,19,48},kind=rng()%4,w=bw[kind],h=bh[kind];if(g.w*16<=w||g.h*16<=h)continue;int x=(int)(rng()%((g.w*16-w)*16+16)),y=(int)(rng()%((g.h*16-h)*16+16));if(body_collides(x/16,y/16,w,h))continue;
   int dx=(int)(rng()%401)-200,vy=(int)(rng()%401)-200;if(i%20==0)dx*=8;if(i%33==0)vy*=4;
   int ax=x,ay=y,av=vy,af=-1,bx=x,by=y,bv=vy,bf=-1;legacy_move(&ax,&ay,&av,dx,w,h,&af);move_body(&bx,&by,&bv,dx,w,h,&bf);tested++;
   if(ax!=bx||ay!=by||av!=bv||af!=bf){failed++;if((ax==bx||(ax==-15&&bx==0))&&(ay==by||(ay==-15&&by==0))&&av==bv&&af==bf)edge++;else interior++;if(failed<=25)printf("D %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\\n",m,x,y,vy,dx,w,h,ax,ay,av,af,bx,by,bv,bf);}
  }
 }
 printf("TOTAL %d %d %d %d\\n",tested,failed,edge,interior);return 0;}
'''.replace('ACTUAL',actual).replace('LEGACY',legacy)
(HERE/'collision_dump.c').write_text(source)
blob=bytearray([16])
for level in range(1,16):
 raw=zlib.decompress(next((GAME/'assets/binaryData').glob('*Level%02d.bin'%level)).read_bytes());w,h=struct.unpack('>HH',raw[:4]);n=w*h
 blob+=struct.pack('<HH',w,h)+raw[4+n:4+2*n]
blob+=struct.pack('<HH',20,20)+bytes(400)
(HERE/'collision_maps.bin').write_bytes(blob)
cache=HERE/'compiler-cache';cache.mkdir(exist_ok=True)
env=dict(os.environ,ZIG_LOCAL_CACHE_DIR=str(cache/'local'),ZIG_GLOBAL_CACHE_DIR=str(cache/'global'),TMP=str(cache),TEMP=str(cache))
subprocess.run([str(ROOT/'local-tools/ziglang/zig.exe'),'cc','-O2',str(HERE/'collision_dump.c'),'-o',str(HERE/'collision_dump.exe')],check=True,env=env)
run=subprocess.run([str(HERE/'collision_dump.exe'),str(HERE/'collision_maps.bin')],capture_output=True,text=True,timeout=60)
differences=[];tested=failed=edge=interior=0
for line in run.stdout.splitlines():
 r=line.split()
 if r[0]=='D':
  v=list(map(int,r[1:]));differences.append(dict(map_index=v[0],start=dict(x=v[1],y=v[2],vy=v[3],dx=v[4],bw=v[5],bh=v[6]),legacy=v[7:11],optimized=v[11:15]))
 elif r[0]=='TOTAL':tested,failed,edge,interior=map(int,r[1:])
result=dict(tested=tested,differences=failed,negative_boundary_only=edge,interior_differences=interior,examples=differences,source_sha256=hashlib.sha256(world.encode()).hexdigest(),returncode=run.returncode,
            method='Actual optimized move_body extracted from world.c vs saved pre-optimization native algorithm; all15 original solidmaps plus emptyedgefixture, valid starting cornerboxes only; deterministic xorshift velocities incl high-speed cases.')
(HERE/'collision-results.json').write_text(json.dumps(result,indent=2));print(run.stdout);print(run.stderr)
raise SystemExit(run.returncode or failed>0)
