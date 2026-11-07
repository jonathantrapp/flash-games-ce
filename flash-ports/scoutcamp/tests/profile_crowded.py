"""Profile unchanged Scouts rules/rendering during a natural crowded stage16 wave.

Requires QA_PERF without QA_OVERLAY. Paired intervals exclude common startup.
Counters add overhead; production throughput needs a separate benchmark.
"""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,re,struct,subprocess,sys
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--bin-dir',default='bin_v8prof');p.add_argument('--tag',default='v8_profile');p.add_argument('--read-existing',action='store_true');a=p.parse_args()
mapping=(GAME/a.bin_dir/'SCOUTCE.map').read_text()
def offset(name):return int(re.search(r'^\s*(0x[\da-f]+)\s+_'+name+r'\s*$',mapping,re.M)[1],16)-0xd00000
sha=hashlib.sha256((GAME/a.bin_dir/'SCOUTCE.8xp').read_bytes()).hexdigest()
source_snapshot={n:hashlib.sha256((GAME/'src'/n).read_bytes()).hexdigest()for n in ['main.c','art.c','engine.h','combat.h']}
build_meta=GAME/a.bin_dir/'build-metadata.json'
if build_meta.exists():
 build=json.loads(build_meta.read_text());assert build['program_sha256']==sha;source_snapshot=build['source_sha256']
prefix='GAME enter down:vars right*15 enter up:vars enter wait:300 alpha +*9 graph alpha wait:20000 0 wait:500 0 '
def run(seconds):
 name=a.tag+'_'+str(seconds);out=ROOT/'flash-ports/verification/scoutcamp'/name
 if not a.read_existing:
  c=[sys.executable,str(ROOT/'flash-ports/launcher_scenario.py'),'scoutcamp',name,prefix+'wait:'+str(seconds*1000)+' 0','--direct','--tap','500','--bin-dir',a.bin_dir,'--check','scout_diag:1:1','--check','scout_diag+1:15:1']
  r=subprocess.run(c,capture_output=True,text=True,timeout=900)
  if r.returncode:raise RuntimeError(r.stdout+r.stderr)
 assert json.loads((out/'run-metadata.json').read_text())['program_sha256']==sha
 ram=(out/'native-ram.bin').read_bytes();d=list(ram[offset('scout_diag'):offset('scout_diag')+16])
 assert d[12]==0 and d[4]>=15,d
 return dict(diag=d,tick=d[14]+256*d[15],simulation_ticks=list(struct.unpack_from('<8I',ram,offset('scout_sim_ticks'))),last_render_ms=list(struct.unpack_from('<5H',ram,offset('scout_render_ms'))),last_epoch=list(struct.unpack_from('<4H',ram,offset('scout_perf'))))
with concurrent.futures.ThreadPoolExecutor(max_workers=2)as pool:short,long=list(pool.map(run,[1,7]))
delta=[(y-x)&0xffffffff for x,y in zip(short['simulation_ticks'],long['simulation_ticks'])];steps=(long['tick']-short['tick'])&65535
names=['waves','enemy_physics_specials','food','towers','sprays','bullets','explosions','finish_and_marks']
report=dict(program_sha256=sha,short=short,long=long,steps=steps,interval_seconds=6,ticks_per_second=steps/6,simulation_ms_per_step={n:v*1000/32768/steps for n,v in zip(names,delta)},last_render_fields=['sky','map','actors','effects','hud'],source_sha256=source_snapshot,scope=__doc__)
(ROOT/'flash-ports/verification/scoutcamp'/(a.tag+'-profile.json')).write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
