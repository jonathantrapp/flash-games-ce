"""Paired-interval native frame/step rates, with no timing text overlay."""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,re,struct,subprocess,sys
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--bin-dir',required=True);p.add_argument('--tag',required=True);p.add_argument('--motion',action='store_true');p.add_argument('--production-entry',action='store_true');p.add_argument('--extra',action='append',default=[]);a=p.parse_args()
mapping=(GAME/a.bin_dir/'PEDROCE.map').read_text()
addr=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_pedro_totals\s*$',mapping,re.M)[1],16)-0xD00000
prefix='enter down:vars enter up:vars wait:1500 enter enter '
if a.production_entry:prefix='enter enter wait:30000 enter enter '
def run(seconds):
 name=a.tag+'_'+str(seconds)+'s'
 out=ROOT/'flash-ports/verification/pedrofu'/name
 keys=prefix+'wait:'+str(seconds*1000)
 if a.motion:keys=prefix+'hold:right:4000 down:up '+('hold:right:500 hold:left:500 '*seconds)+'up:up'
 command=[sys.executable,str(ROOT/'flash-ports/run_scenario.py'),'pedrofu',name,keys,'--tap','600','--bin-dir',a.bin_dir,'--check','pedro_diag:1:1']
 for extra in a.extra:command+=['--extra',extra]
 result=subprocess.run(command,capture_output=True,text=True,timeout=240)
 if result.returncode:raise RuntimeError(result.stdout+result.stderr)
 return struct.unpack_from('<5I',(out/'native-ram.bin').read_bytes(),addr)
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:short,long=list(pool.map(run,[3,9] if a.motion else [4,10]))
delta=[(y-x)&0xffffffff for x,y in zip(short,long)]
span=7.8 if a.motion else 6
report=dict(program_sha256=hashlib.sha256((GAME/a.bin_dir/'PEDROCE.8xp').read_bytes()).hexdigest(),short=list(short),long=list(long),interval_seconds=span,motion=a.motion,production_entry=a.production_entry,extra_appvars=a.extra,
 fps=delta[0]/span,steps_per_second=delta[1]/span,wait_ms_per_frame=delta[2]*1000/32768/delta[0],draw_ms_per_frame=delta[3]*1000/32768/delta[0],simulation_ms_per_frame=delta[4]*1000/32768/delta[0],
 scope=('Stage-one production opening entry. ' if a.production_entry else 'Stage-one diagnostic entry. ')+'CEmu OS5.3 at48MHz, no overlay. Idle: matched 10s/4s intervals. Motion: 9 versus3 right/left cycles while holding jump after4s moving right; each cycle1.3s including release gaps. Frame boundaries give sampling error. Not a whole-game minimum, original comparison or physical-calculator result.')
(ROOT/'flash-ports/verification/pedrofu'/(a.tag+'-benchmark.json')).write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
