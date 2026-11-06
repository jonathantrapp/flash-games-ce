"""Record timing counters from a local emulator run without publishing RAM."""
from pathlib import Path
import argparse,hashlib,json,re,struct

HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('scenario');p.add_argument('--bin-dir',default='bin_v4prof')
a=p.parse_args()
out=HERE/'verification/pedrofu'/a.scenario
folder=HERE/'pedrofu'/a.bin_dir
maptext=(folder/'PEDROCE.map').read_text()
ram=(out/'native-ram.bin').read_bytes()
def counters(symbol,n):
 address=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_'+symbol+r'\s*$',maptext,re.M)[1],16)
 offset=address-0xD00000
 assert 0<=offset<=len(ram)-4*n
 return struct.unpack_from('<'+'I'*n,ram,offset)
fps,steps,sim,draw,mode=counters('pedro_profile',5)
phases=counters('pedro_draw_profile',6)
result=dict(frames_per_second=fps,steps_per_second=steps,simulation_ms_per_epoch=sim,draw_ms_per_epoch=draw,mode=mode,
 last_draw_phase_timer_ticks=list(phases),timer_hz=32768,
 profile_binary_sha256=hashlib.sha256((folder/'PEDROCE.8xp').read_bytes()).hexdigest(),
 production_binary_sha256=hashlib.sha256((HERE/'pedrofu/bin/PEDROCE.8xp').read_bytes()).hexdigest(),
 scope='Last one-second diagnostic epoch plus latest draw phases; emulator OS5.3/48MHz, not physical hardware or a scene-wide minimum.')
(out/'performance.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
