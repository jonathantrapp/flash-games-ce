"""Check that retained (damage-repair) rendering produces the same pixels as a full redraw.

Uses a -DQA_DAMAGECHECK -DQA_MAXED build (default bin_v10damagemax). In that build every
play/result frame is drawn with the retained path, hashed (FNV-1a over all 76,800 bytes),
redrawn from scratch and hashed again. scout_damage[0] counts compared frames and
scout_damage[1] counts mismatches. Each scenario builds towers, sends waves and then
fuzzes gameplay keys (cursor moves, builds, upgrades, conversions, pause, freeze, speed,
focus). Pass = every scenario ran, compared frames > 0 and mismatches == 0.

Scope: CEmu OS 5.3 only; a hash match is not a byte-for-byte proof but collisions are
very unlikely. It does not cover menus (they always redraw fully).
"""
from pathlib import Path
import argparse, json, re, struct, subprocess, sys
HERE = Path(__file__).resolve().parent; GAME = HERE.parent; ROOT = GAME.parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--bin-dir', default='bin_v10damagemax'); p.add_argument('--tag', default='v10_damage')
p.add_argument('--seconds', type=int, default=40); p.add_argument('--stages', default='1,5,13,16,17')
a = p.parse_args()
KEYS = 'left,right,up,down,2nd,enter,math,apps,graph,1,2,3,4,alpha,0,+,-,stat,vars,del'
mapping = (GAME / a.bin_dir / 'SCOUTCE.map').read_text()
def offset(name): return int(re.search(r'^\s*(0x[\da-f]+)\s+_' + name + r'\s*$', mapping, re.M)[1], 16) - 0xd00000
rows, ok = [], True
for stage in [int(s) for s in a.stages.split(',')]:
    name = '%s_stage%02d' % (a.tag, stage)
    steps = ('enter down:vars ' + ('right*%d ' % (stage - 1) if stage > 1 else '') + 'enter up:vars enter wait:300 '
             '2nd right*2 2nd left*4 4 2nd enter math graph wait:3000 fuzz:%d:%d:%s wait:500' % (a.seconds, stage, KEYS))
    r = subprocess.run([sys.executable, str(ROOT / 'flash-ports/run_scenario.py'), 'scoutcamp', name, steps,
                        '--tap', '300', '--bin-dir', a.bin_dir, '--check', 'scout_damage+4:0:4'],
                       capture_output=True, text=True, timeout=1800)
    passed_check = r.returncode == 0 and 'Autotest passed' in r.stdout + r.stderr
    out = ROOT / 'flash-ports/verification/scoutcamp' / name
    ram = (out / 'native-ram.bin').read_bytes()
    compared, mismatched = struct.unpack_from('<2I', ram, offset('scout_damage'))
    good = passed_check and compared > 0 and mismatched == 0
    ok &= good
    rows.append(dict(stage=stage, compared_frames=compared, mismatched_frames=mismatched, autotest_passed=passed_check, passed=good))
    print(name, 'compared', compared, 'mismatched', mismatched, 'PASS' if good else 'FAIL', flush=True)
(ROOT / 'flash-ports/verification/scoutcamp' / (a.tag + '-results.json')).write_text(
    json.dumps(dict(bin_dir=a.bin_dir, seconds=a.seconds, keys=KEYS, scenarios=rows, passed=bool(ok), scope=__doc__), indent=1) + '\n')
print('PASS' if ok else 'FAIL'); sys.exit(0 if ok else 1)
