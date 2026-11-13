"""Cycle profile of a Scouts build in a local profiling CEmu (build/cemu-prof, -DCEMU_PROFILE).

Replays an existing scenario's smoke.json with the program/banks swapped to --bin-dir and
attributes emulated CPU cycles per RAM address to the function section containing it (from
the linker map's .text.<name> input sections). With --base (a shorter run of the same
scenario, e.g. the benchmark's _1 vs _7 pair) the base histogram is subtracted, leaving the
steady-state gameplay window. Cycles outside RAM (OS ROM, boot, interrupt handler) are one
bucket; RAM past the program is the relocated libraries (GraphX, keypadc, fileioc).
Build -fno-inline / LTO=NO for a per-function split. Diagnostic tool only.
"""
from pathlib import Path
import argparse, bisect, concurrent.futures, json, re, struct, subprocess
HERE = Path(__file__).resolve().parent; GAME = HERE.parent; ROOT = GAME.parents[1]
VER = ROOT / 'flash-ports/verification/pedrofu'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('scenario', help='existing verification/scoutcamp/<name> folder with smoke.json')
p.add_argument('--base', help='shorter run of the same scenario to subtract')
p.add_argument('--bin-dir', required=True); p.add_argument('--tag', required=True); p.add_argument('--top', type=int, default=30); p.add_argument('--read-existing', action='store_true')
a = p.parse_args()
mapping = (GAME / a.bin_dir / 'PEDROCE.map').read_text()
def symbol(name):
    return int(re.search(r'^\s*(0x[\da-f]+)\s+_' + re.escape(name) + r'\s*$', mapping, re.M)[1], 16)

def profile(scenario, tag):
    config = json.loads((VER / scenario / 'smoke.json').read_text())
    for h in config.get('hashes', {}).values():  # point diagnostic checks at this build's symbols
        name = h['description'].split(':')[0].split('+'); off = int(name[1], 0) if len(name) > 1 else 0
        h['start'] = hex(symbol(name[0]) + off)
    out = VER / ('prof_' + tag); out.mkdir(parents=True, exist_ok=True)
    (out / 'smoke.json').write_text(json.dumps(config, indent=1))
    if not (a.read_existing and (out / 'cemu-profile.bin').exists()):
     r = subprocess.run([str(ROOT / 'build/cemu-prof/cemu-autotester.exe'), '-d', str(out / 'smoke.json')], cwd=out, capture_output=True, text=True, timeout=1800)
     (out / 'smoke.log').write_text(r.stdout + r.stderr)
    raw = (out / 'cemu-profile.bin').read_bytes()
    return list(struct.unpack_from('<%dI' % 0x70000, raw)), struct.unpack_from('<Q', raw, 0x70000 * 4)[0]

jobs = [(a.scenario, a.tag)] + ([(a.base, a.tag + '_base')] if a.base else [])
with concurrent.futures.ThreadPoolExecutor(2) as pool: results = list(pool.map(lambda j: profile(*j), jobs))
hist, other = results[0]
if a.base:
    bh, bo = results[1]; hist = [max(0, x - y) for x, y in zip(hist, bh)]; other = max(0, other - bo)
sections = {(int(m[2], 16), m[1]) for m in re.finditer(r'^\s*\.text\._?([\w.]+)\s+(0x00d[\da-f]{5})\s', mapping, re.M)}
def assigned(name): return int(re.search(r'^\s*(0x[\da-f]+)\s+' + name + r' = \.', mapping, re.M)[1], 16)
code_end = assigned('___data_low')
globals_ = {(int(m[1], 16), m[2]) for m in re.finditer(r'^\s+(0x00d[\da-f]{5})\s+_([A-Za-z_][\w.]*)\s*$', mapping, re.M) if int(m[1], 16) < code_end}
syms = sorted(sections | globals_); addrs = [s[0] for s in syms]
end = assigned('___data_high')
totals = {}
for i, c in enumerate(hist):
    if not c: continue
    addr = 0xD00000 + i
    if addr >= end: name = 'libraries (GraphX etc.)'
    elif addr >= code_end: name = 'program data (?)'
    else:
        k = bisect.bisect_right(addrs, addr) - 1; name = syms[k][1].lstrip('_') if k >= 0 else 'below program'
    totals[name] = totals.get(name, 0) + c
grand = sum(totals.values()) + other
rows = sorted(totals.items(), key=lambda kv: -kv[1])
report = dict(bin_dir=a.bin_dir, scenario=a.scenario, base=a.base, total_cycles=grand, outside_ram_cycles=other,
              functions=[dict(name=n, cycles=c, share=c / grand) for n, c in rows], scope=__doc__)
(VER / ('prof_' + a.tag) / 'profile.json').write_text(json.dumps(report, indent=1) + '\n')
print('window %d cycles (%.2f s at 48 MHz); outside RAM %.1f%%' % (grand, grand / 48e6, 100 * other / grand))
for n, c in rows[:a.top]: print('%6.2f%%  %s' % (100 * c / grand, n))
