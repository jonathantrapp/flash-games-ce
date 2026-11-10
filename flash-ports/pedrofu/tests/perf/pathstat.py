"""Per-draw-path frame period stats from a PEDRO_PATHSTAT build (window = long minus short run)."""
from pathlib import Path
import argparse, concurrent.futures, re, struct, subprocess, sys
ROOT = Path(r'E:\AI Stuff\Calc Stuff')
p = argparse.ArgumentParser(); p.add_argument('--bin-dir', required=True); p.add_argument('--tag', required=True)
p.add_argument('--steps', default=None, help='custom key script template using {n} cycles')
a = p.parse_args()
m = (ROOT / 'flash-ports/pedrofu' / a.bin_dir / 'PEDROCE.map').read_text()
def sym(n): return int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_' + n + r'\s*$', m, re.M)[1], 16) - 0xD00000
prefix = 'enter enter wait:30000 enter enter '
def run(n):
    name = '%s_%d' % (a.tag, n)
    keys = prefix + 'hold:right:4000 down:up ' + ('hold:right:500 hold:left:500 ' * n) + 'up:up'
    r = subprocess.run([sys.executable, str(ROOT / 'flash-ports/run_scenario.py'), 'pedrofu', name, keys, '--tap', '600',
                        '--bin-dir', a.bin_dir, '--check', 'pedro_diag:1:1'], capture_output=True, text=True, timeout=900)
    if r.returncode: raise RuntimeError(r.stdout + r.stderr)
    ram = (ROOT / 'flash-ports/verification/pedrofu' / name / 'native-ram.bin').read_bytes()
    g = lambda s: struct.unpack_from('<4I', ram, sym(s))
    return [g('pedro_path_cnt'), g('pedro_path_period'), g('pedro_path_slow'), g('pedro_path_over'), g('pedro_path_draw'), g('pedro_path_n')]
with concurrent.futures.ThreadPoolExecutor(2) as pool: s, l = list(pool.map(run, [3, 9]))
names = ['reuse', 'tracked+skip', 'tracked', 'untracked']
tot = 0; totp = 0
for i in range(4):
    c, per, slow, over, dr, nn = [(l[k][i] - s[k][i]) & 0xffffffff for k in range(6)]
    tot += c; totp += per
    print('%-13s frames %4d  avg period %5.1f ms  avg draw %5.1f ms  slow %3d (%.0f%%)' % (names[i], c, per * 1000 / 32768 / max(1, c), dr * 1000 / 32768 / max(1, nn), slow, 100 * slow / max(1, c)))
print('overall FPS %.2f over %.1f s' % (tot / (totp / 32768), totp / 32768))
