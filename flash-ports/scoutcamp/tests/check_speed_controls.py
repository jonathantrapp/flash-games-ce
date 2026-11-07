"""Exercise real keypad speed controls and compare native simulation counters.

Uses CEmu/OS5.3, not physical hardware. Target build needs the full signed banks.
No ROM or RAM capture is included in the JSON report.
"""
from pathlib import Path
import argparse,concurrent.futures,json,re,subprocess,sys,hashlib

HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--bin-dir',default='bin');parser.add_argument('--read-existing',action='store_true',help='Analyze existing named native captures without running CEmu again');args=parser.parse_args()
maptext=(GAME/args.bin_dir/'SCOUTCE.map').read_text()
offset=int(re.search(r'^\s*(0x[0-9a-f]+)\s+_scout_diag\s*$',maptext,re.M)[1],16)-0xd00000
previous_offset=int(re.search(r'\.data\._previousSpeedThirds\s+(0x[0-9a-f]+)',maptext)[1],16)-0xd00000
prefix='enter enter enter '
cases={
 'freeze_short':prefix+'0 wait:500',
 'freeze_long':prefix+'0 wait:2500',
 'resume_1x':prefix+'0 0 wait:1000 0',
 'resume_1x_setting':prefix+'0 0 wait:500',
 'freeze_4x':prefix+'+*9 0 wait:500',
 'resume_4x':prefix+'+*9 0 0 wait:1000 0',
 'resume_4x_setting':prefix+'+*9 0 0 wait:500',
 'upper_bound':prefix+'+*15',
 'lower_bound':prefix+'-*15',
}
def run(item):
 name,keys=item;scenario='controls_'+name
 command=[sys.executable,str(ROOT/'flash-ports/run_scenario.py'),'scoutcamp',scenario,keys,'--tap','220','--bin-dir',args.bin_dir,'--check','scout_diag:1:1']
 if not args.read_existing:
  result=subprocess.run(command,capture_output=True,text=True,timeout=180)
  if result.returncode:raise RuntimeError(name+'\n'+result.stdout+result.stderr)
 ram=(ROOT/'flash-ports/verification/scoutcamp'/scenario/'native-ram.bin').read_bytes()
 d=ram[offset:offset+16];assert len(d)==16
 return name,dict(mode=d[0],speed_thirds=d[12],previous_speed_thirds=ram[previous_offset],tick=int.from_bytes(d[14:16],'little'))
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 values=dict(pool.map(run,cases.items()))
assert values['freeze_short']['tick']==values['freeze_long']['tick'],values
assert values['freeze_long']['speed_thirds']==0,values
one=(values['resume_1x']['tick']-values['freeze_short']['tick'])&65535
four=(values['resume_4x']['tick']-values['freeze_4x']['tick'])&65535
# Exact wall-clock rate is not established: renderer/input sampling and CPU
# capacity reduce observed ticks, particularly at the nominal4x setting.
# Check active/resumed progression; retain actual totals instead of treating
# the slider label as proof that hardware sustains the requested speed.
assert one>0,(one,values)
assert four>one,(four,values)
assert values['resume_1x_setting']['speed_thirds']==values['resume_1x_setting']['previous_speed_thirds']==3,values
assert values['resume_4x_setting']['speed_thirds']==values['resume_4x_setting']['previous_speed_thirds']==12,values
assert values['upper_bound']['speed_thirds']==12,values
assert values['lower_bound']['speed_thirds']==0,values
report=dict(checks=8,failures=[],one_x_ticks=one,fast_setting_ticks=four,snapshots=values,reused_captures=args.read_existing,
 program_sha256=hashlib.sha256((GAME/args.bin_dir/'SCOUTCE.8xp').read_bytes()).hexdigest(),
 scope='Actual keypad input in CEmu OS5.3: frozen tick stability, exact restoration of settings3 and12 thirds, forward progress and bounds0..4x. Raw fast-setting totals include control/render overhead; use paired input-timing results for rates. No physical speed or crowded-battle minimum claim.')
(HERE/'speed-controls-results.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
