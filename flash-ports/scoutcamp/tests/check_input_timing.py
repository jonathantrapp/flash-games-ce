"""Production CEmu keypad/throughput matrix; no physical or campaign claims."""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,re,struct,subprocess,sys
HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--bin-dir',default='bin');parser.add_argument('--tag',default='v7_ready500');parser.add_argument('--read-existing',action='store_true');args=parser.parse_args()
mapping=(GAME/args.bin_dir/'SCOUTCE.map').read_text()
def offset(symbol):
 return int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_'+symbol+r'\s*$',mapping,re.M)[1],16)-0xD00000
diag=offset('scout_diag');stats=offset('scout_input_stats')
cases={}
for hold,gap in [(220,150),(80,80),(40,40)]:
 # Enter gameplay with ordinary taps before timing short control taps. Stage
 # loading can take >100 ms and is not a steady-state keypad latency test.
 cases[f'rapid_{hold}_{gap}']=('hold:enter:500 wait:300 hold:enter:500 wait:300 hold:enter:500 wait:300 +*9 0 0 wait:500',hold,gap)
for speed,setting in [('1x',''),('4x','+*9 ')]:
 for span in [1000,7000]:
  cases[f'rate_{speed}_{span}']=('enter enter enter '+setting+'0 wait:500 0 wait:'+str(span)+' 0 wait:500',220,150)
cases['frozen_short']=('enter enter enter 0 wait:500',220,150)
cases['frozen_long']=('enter enter enter 0 wait:6500',220,150)
def run(item):
 name,(keys,hold,gap)=item;scenario=args.tag+'_'+name
 if not args.read_existing:
  result=subprocess.run([sys.executable,str(ROOT/'flash-ports/run_scenario.py'),'scoutcamp',scenario,keys,'--tap',str(hold),'--gap',str(gap),'--bin-dir',args.bin_dir,'--check','scout_diag:1:1'],capture_output=True,text=True,timeout=240)
  if result.returncode:raise RuntimeError(name+'\n'+result.stdout+result.stderr)
 meta=json.loads((ROOT/'flash-ports/verification/scoutcamp'/scenario/'run-metadata.json').read_text())
 assert meta['program_sha256']==hashlib.sha256((GAME/args.bin_dir/'SCOUTCE.8xp').read_bytes()).hexdigest()
 ram=(ROOT/'flash-ports/verification/scoutcamp'/scenario/'native-ram.bin').read_bytes()
 d=ram[diag:diag+16];s=struct.unpack_from('<3I',ram,stats)
 return name,dict(tick=int.from_bytes(d[14:16],'little'),speed_thirds=d[12],max_poll_gap_ms=s[0]*1000/32768,queue_overflows=s[1],transitions=s[2])
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:values=dict(pool.map(run,cases.items()))
failures=[]
for name,value in values.items():
 if value['queue_overflows']:failures.append(name+': input queue overflow')
 if name.startswith('rapid_') and value['speed_thirds']!=12:failures.append(name+': missed speed tap')
if values['frozen_short']['tick']!=values['frozen_long']['tick']:failures.append('frozen simulation advanced')
rates={}
for speed,wanted in [('1x',20),('4x',80)]:
 ticks=(values[f'rate_{speed}_7000']['tick']-values[f'rate_{speed}_1000']['tick'])&65535
 rates[speed]=dict(ticks=ticks,interval_seconds=6,ticks_per_second=ticks/6,requested_ticks_per_second=wanted)
 # This verifies observed forward progress, not achievement of requested rate.
 if ticks<=0:failures.append(speed+': no progression')
report=dict(program_sha256=hashlib.sha256((GAME/args.bin_dir/'SCOUTCE.8xp').read_bytes()).hexdigest(),scenario_tag=args.tag,reused_captures=args.read_existing,snapshots=values,rates=rates,failures=failures,
 scope='CEmu OS5.3/48MHz production binary. Enter gameplay with500ms taps and300ms waits; then nine plus taps and freeze/restore at stated hold/release intervals.40/80ms menu-entry taps failed before this separation, so these results do not establish menu/loading latency. Throughput is the tick difference between otherwise identical7s and1s runs, divided by6 emulated seconds. No physical timing, crowded-battle minimum or campaign claim. Max poll gap includes loading.')
(HERE/'input-timing-results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
raise SystemExit(bool(failures))
