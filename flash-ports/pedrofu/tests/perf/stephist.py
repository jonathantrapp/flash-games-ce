"""Steps-per-iteration histogram for the motion window (long minus short run). Frames with >=2 steps are dropped draws."""
from pathlib import Path
import argparse, concurrent.futures, re, struct, subprocess, sys
ROOT = Path(r'E:\AI Stuff\Calc Stuff')
p = argparse.ArgumentParser(); p.add_argument('--bin-dir', required=True); p.add_argument('--tag', required=True); a = p.parse_args()
m = (ROOT / 'flash-ports/pedrofu' / a.bin_dir / 'PEDROCE.map').read_text()
def sym(n): return int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_' + n + r'\s*$', m, re.M)[1], 16) - 0xD00000
def run(n):
    name = '%s_%d' % (a.tag, n)
    keys = 'enter enter wait:30000 enter enter hold:right:4000 down:up ' + ('hold:right:500 hold:left:500 ' * n) + 'up:up'
    r = subprocess.run([sys.executable, str(ROOT / 'flash-ports/run_scenario.py'), 'pedrofu', name, keys, '--tap', '600', '--bin-dir', a.bin_dir, '--check', 'pedro_diag:1:1'], capture_output=True, text=True)
    ram = (ROOT / 'flash-ports/verification/pedrofu' / name / 'native-ram.bin').read_bytes()
    return struct.unpack_from('<6I', ram, sym('pedro_step_hist')), struct.unpack_from('<5I', ram, sym('pedro_totals'))
with concurrent.futures.ThreadPoolExecutor(2) as pool: (s, ts), (l, tl) = list(pool.map(run, [3, 9]))
d = [y - x for x, y in zip(s, l)]
it = sum(d[:5]); steps = sum(i * d[i] for i in range(5))
print('iterations %d  steps %d  by steps/iteration 0:%d 1:%d 2:%d 3:%d 4:%d   held L/R iterations %d' % (it, steps, *d[:5], d[5]))
print('dropped-draw iterations (>=2 steps): %d (%.1f%%)   duplicate iterations (0 steps): %d (%.1f%%)' % (sum(d[2:5]), 100 * sum(d[2:5]) / it, d[0], 100 * d[0] / it))
print('draw ms/frame %.2f  sim ms/frame %.2f' % ((tl[3] - ts[3]) * 1000 / 32768 / (tl[0] - ts[0]), (tl[4] - ts[4]) * 1000 / 32768 / (tl[0] - ts[0])))
