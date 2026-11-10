"""Rebuild a no-inline LTO=NO profiling variant of Pedro, replay the motion scenario in the cycle profiler,
print the top functions and the hottest source-level windows inside one function."""
import argparse, re, struct, subprocess, sys, shutil
from pathlib import Path
ROOT = Path(r'E:\AI Stuff\Calc Stuff'); GAME = ROOT / 'flash-ports/pedrofu'; VER = ROOT / 'flash-ports/verification/pedrofu'
p = argparse.ArgumentParser(); p.add_argument('--tag', required=True); p.add_argument('--func', default='draw_game'); p.add_argument('--top', type=int, default=24)
p.add_argument('--cflags', default='')
p.add_argument('--stage', type=int, default=1)
p.add_argument('--reuse-build', action='store_true')
a = p.parse_args()
bd = 'bin_pf_' + a.tag; od = 'obj_pf_' + a.tag
for d in ((GAME / bd, GAME / od) if not a.reuse_build else ()): shutil.rmtree(d, ignore_errors=True)
cf = '-Wall -Wextra -Oz -std=c11 -DSKY_FLASH_ROWS -fno-inline -fno-inline-functions -fno-inline-functions-called-once ' + a.cflags
r = subprocess.run([str(ROOT / 'local-tools/cedev/CEdev/bin/make.exe'), 'BINDIR=' + bd, 'OBJDIR=' + od, 'LTO=NO', 'CFLAGS=' + cf], cwd=GAME, capture_output=True, text=True)
print([l for l in (r.stdout + r.stderr).splitlines() if 'success' in l or 'rror' in l][-2:])
for f in (GAME / 'bin_v8').glob('*.8xv'):
    if f.name.startswith(('PDB', 'PDU', 'PDTILE', 'PDCOLOR')): shutil.copy(f, GAME / bd / f.name)
import concurrent.futures
def rec(n):
    name = 'pf%s_%ds' % (a.tag, n)
    k = a.stage - 1
    entry = 'enter down:vars ' + ('right*%d ' % k if k else '') + 'enter up:vars ' + ('wait:18000 ' if k == 0 else 'wait:300 ') + 'enter wait:300 enter '
    keys = (entry + 'wait:2500 hold:right:2000 down:up ' if k else 'enter enter wait:30000 enter enter hold:right:4000 down:up ') + ('hold:right:500 hold:left:500 ' * n) + 'up:up'
    subprocess.run([sys.executable, str(ROOT / 'flash-ports/run_scenario.py'), 'pedrofu', name, keys, '--tap', '600', '--bin-dir', bd, '--check', 'pedro_diag:1:1'], capture_output=True, text=True)
with concurrent.futures.ThreadPoolExecutor(2) as pool: list(pool.map(rec, [3, 9]))
out = subprocess.run([sys.executable, str(GAME / 'tests/cemu_profile.py'), 'pf%s_9s' % a.tag, '--base', 'pf%s_3s' % a.tag, '--bin-dir', bd, '--tag', 'pf' + a.tag, '--top', str(a.top)], capture_output=True, text=True, cwd=ROOT)
print(out.stdout[-3000:]); print(out.stderr[-300:])
# hot windows
mp = (GAME / bd / 'PEDROCE.map').read_text()
funcs = sorted({(int(m[2], 16), m[1]) for m in re.finditer(r'^\s*\.text\._?([\w.]+)\s+(0x00d[\da-f]{5})\s', mp, re.M)})
addrs = [f[0] for f in funcs]; names = {n: a_ for a_, n in funcs}
def load(pn):
    raw = open(VER / pn / 'cemu-profile.bin', 'rb').read(); return struct.unpack_from('<%dI' % 0x70000, raw)
h9 = load('prof_pf%s' % a.tag); h3 = load('prof_pf%s_base' % a.tag); h = [max(0, x - y) for x, y in zip(h9, h3)]
dis = subprocess.run([str(ROOT / 'local-tools/cedev/CEdev/binutils/bin/z80-none-elf-objdump.exe'), '-d', '--no-show-raw-insn', str(GAME / bd / 'PEDROCE.obj')], capture_output=True, text=True).stdout.splitlines()
ins = {}
for l in dis:
    m = re.match(r'\s*([0-9a-f]+):\s+(.*)', l)
    if m: ins[int(m.group(1), 16)] = m.group(2).strip()
i = addrs.index(names[a.func]); st, en = addrs[i], addrs[i + 1]
tot = sum(h[x - 0xD00000] for x in range(st, en))
print('%s self cycles %d (%.2f%% of window)' % (a.func, tot, 100 * tot / 374e6))
win = {}
for x in range(st, en):
    c = h[x - 0xD00000]
    if c: win[x // 64] = win.get(x // 64, 0) + c
for w, c in sorted(win.items(), key=lambda kv: -kv[1])[:8]:
    print('  window %x: %.1f%% of function' % (w * 64, 100 * c / tot))
