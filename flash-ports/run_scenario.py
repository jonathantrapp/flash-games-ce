"""Run a compact key script against a built port in windowless CEmu at idle priority.

Steps are space separated:  enter  2nd  right*5  hold:right:900  down:vars  up:vars  wait:500  fuzz:20:7:left,right,up,2nd,alpha
(a tap = 220 ms hold + 150 ms release; fuzz:SECONDS:SEED:KEYS sends random presses).
Checks look like symbol[+offset]:value:bytes (compared against the program's map symbols).
Example: python run_scenario.py scoutcamp play "enter enter 2nd wait:800" --check scout_diag:1:1
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_ROM = Path(r'C:\Users\jonat\Downloads\ti-84ce.rom')
p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
p.add_argument('game', choices=['scoutcamp', 'pedrofu'])
p.add_argument('scenario')
p.add_argument('steps', help='space separated key script')
p.add_argument('--check', action='append', default=[])
p.add_argument('--rom', type=Path, default=DEFAULT_ROM)
p.add_argument('--tap', type=int, default=220)
p.add_argument('--bin-dir', default='bin')
p.add_argument('--extra', action='append', default=[], help='extra AppVar to transfer, such as a prepared save')
a = p.parse_args()

import random


def fuzz(seconds, seed, keys):
    """Random taps and holds (sometimes two keys together) for `seconds` of emulated time."""
    rng, out, spent = random.Random(seed), [], 0
    while spent < seconds * 1000:
        chosen = rng.sample(keys, 2 if rng.random() < 0.25 else 1)
        hold, gap = rng.randint(60, 420), rng.randint(40, 260)
        out += [f'hold|{k}' for k in chosen] + [f'delay|{hold}'] + [f'release|{k}' for k in chosen] + [f'delay|{gap}']
        spent += hold + gap
    return out


sequence = []
for step in a.steps.split():
    if step.startswith('fuzz:'):
        _, seconds, seed, keys = step.split(':')
        sequence += fuzz(int(seconds), int(seed), keys.split(','))
    elif step.startswith('wait:'):
        sequence.append('delay|' + step[5:])
    elif step.startswith('down:'):
        sequence.append('hold|' + step[5:])
    elif step.startswith('up:'):
        sequence += ['release|' + step[3:], 'delay|150']
    elif step.startswith('hold:'):
        _, key, ms = step.split(':')
        sequence += [f'hold|{key}', f'delay|{ms}', f'release|{key}', 'delay|150']
    else:
        key, _, count = step.partition('*')
        for _ in range(int(count or 1)):
            sequence += [f'hold|{key}', f'delay|{a.tap}', f'release|{key}', 'delay|150']
command = [sys.executable, str(ROOT / 'flash-ports/smoke.py'), a.game, a.scenario, '--rom', str(a.rom),
           '--sequence', json.dumps(sequence)]
for check in a.check:
    command += ['--check', check]
for extra in a.extra:
    command += ['--extra', extra]
command += ['--bin-dir', a.bin_dir]
IDLE_PRIORITY_CLASS, CREATE_NO_WINDOW = 0x00000040, 0x08000000
result = subprocess.run(command, capture_output=True, text=True, creationflags=IDLE_PRIORITY_CLASS | CREATE_NO_WINDOW)
lines = [l for l in (result.stdout + result.stderr).splitlines() if any(k in l for k in ('passed', 'failed', 'Error', 'Missing', 'NMI'))]
print('\n'.join(lines[-6:]) or 'no result lines')
print('screenshot:', ROOT / 'flash-ports/verification' / a.game / a.scenario / 'screen.png')
raise SystemExit(result.returncode)
