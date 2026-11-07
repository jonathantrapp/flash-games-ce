"""Measure Scouts production frame/tick throughput without a profiling overlay.

Stage16 uses QA only to open its map. Natural first wave; paired intervals
exclude identical startup, loading and warmup. No campaign-unlock claim.
"""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,re,struct,subprocess,sys
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--bin-dir',default='bin_v8play');p.add_argument('--tag',default='v8_production');p.add_argument('--stage',type=int,default=16);p.add_argument('--quiet',action='store_true',help='Stage1 before its first automatic wave; no GRAPH send or20s warmup');p.add_argument('--read-existing',action='store_true');a=p.parse_args()
assert 1<=a.stage<=17
assert not a.quiet or a.stage==1
binary=GAME/a.bin_dir/'SCOUTCE.8xp';sha=hashlib.sha256(binary.read_bytes()).hexdigest();mapping=binary.with_suffix('.map').read_text()
build=json.loads((binary.parent/'build-metadata.json').read_text());assert build['program_sha256']==sha and not build['overlay'];assert 'QA_PERF' not in build['flags'] and 'QA_OVERLAY' not in build['flags']
def offset(n):return int(re.search(r'^\s*(0x[\da-f]+)\s+_'+n+r'\s*$',mapping,re.M)[1],16)-0xd00000
prefix='GAME enter down:vars '+('right*%d '%(a.stage-1) if a.stage>1 else '')+'enter up:vars enter wait:300 alpha +*9 '+('alpha ' if a.quiet else 'graph alpha wait:20000 ')+'0 wait:500 0 '
def run(seconds):
 name=a.tag+'_'+str(seconds);out=ROOT/'flash-ports/verification/scoutcamp'/name
 if not a.read_existing:
  cmd=[sys.executable,str(ROOT/'flash-ports/launcher_scenario.py'),'scoutcamp',name,prefix+'wait:'+str(seconds*1000)+' 0','--direct','--tap','500','--bin-dir',a.bin_dir,'--check','scout_diag:1:1','--check','scout_diag+1:%d:1'%(a.stage-1)]
  r=subprocess.run(cmd,capture_output=True,text=True,timeout=900)
  if r.returncode:raise RuntimeError(r.stdout+r.stderr)
 assert json.loads((out/'run-metadata.json').read_text())['program_sha256']==sha
 ram=(out/'native-ram.bin').read_bytes();diag=list(ram[offset('scout_diag'):offset('scout_diag')+16]);totals=list(struct.unpack_from('<2I',ram,offset('scout_totals')))
 assert diag[12]==0 and diag[6]==0,diag
 if a.stage==16:assert diag[4]>=15,diag
 return dict(diag=diag,frames=totals[0],ticks=totals[1])
with concurrent.futures.ThreadPoolExecutor(max_workers=2)as pool:short,long=list(pool.map(run,[1,7]))
report=dict(program_sha256=sha,stage=a.stage,quiet=a.quiet,requested_ticks_per_second=80,short=short,long=long,interval_seconds=6,fps=((long['frames']-short['frames'])&0xffffffff)/6,ticks_per_second=((long['ticks']-short['ticks'])&0xffffffff)/6,build=build,scope=__doc__)
(ROOT/'flash-ports/verification/scoutcamp'/(a.tag+'-benchmark.json')).write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
