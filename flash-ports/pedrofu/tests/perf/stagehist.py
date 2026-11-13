"""Dropped-draw / duplicate histograms while walking left and right in a chosen stage (PEDRO_STEPHIST build)."""
from pathlib import Path
import argparse, concurrent.futures, re, struct, subprocess, sys
ROOT = Path(r'E:\AI Stuff\Calc Stuff')
p = argparse.ArgumentParser(); p.add_argument('--bin-dir', required=True); p.add_argument('--tag', required=True); p.add_argument('--stages', default='1,3,6,10,13,15'); a = p.parse_args()
m = (ROOT / 'flash-ports/pedrofu' / a.bin_dir / 'PEDROCE.map').read_text()
def sym(n): return int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_' + n + r'\s*$', m, re.M)[1], 16) - 0xD00000
def entry(k):
    return 'enter down:vars ' + ('right*%d ' % k if k else '') + 'enter up:vars ' + ('wait:18000 ' if k == 0 else 'wait:300 ') + 'enter wait:300 enter '
def run(task):
    k, n = task
    name = '%s_s%02d_%d' % (a.tag, k + 1, n)
    keys = entry(k) + 'wait:2500 hold:right:2000 down:up ' + ('hold:right:500 hold:left:500 ' * n) + 'up:up'
    subprocess.run([sys.executable, str(ROOT / 'flash-ports/run_scenario.py'), 'pedrofu', name, keys, '--tap', '500', '--bin-dir', a.bin_dir, '--check', 'pedro_diag:1:1'], capture_output=True, text=True)
    ram = (ROOT / 'flash-ports/verification/pedrofu' / name / 'native-ram.bin').read_bytes()
    return struct.unpack_from('<6I', ram, sym('pedro_step_hist')), struct.unpack_from('<5I', ram, sym('pedro_totals'))
stages = [int(x) - 1 for x in a.stages.split(',')]
tasks = [(k, n) for k in stages for n in (3, 9)]
with concurrent.futures.ThreadPoolExecutor(6) as pool: res = list(pool.map(run, tasks))
for i, k in enumerate(stages):
    (s, ts), (l, tl) = res[2 * i], res[2 * i + 1]
    d = [y - x for x, y in zip(s, l)]; it = sum(d[:5]) or 1
    print('stage %2d: iterations %3d  steps/iter 0:%2d 1:%3d 2:%2d 3+:%d  dropped %.1f%%  duplicates %.1f%%  draw %.1f ms sim %.1f ms' % (
        k + 1, it, d[0], d[1], d[2], d[3] + d[4], 100 * sum(d[2:5]) / it, 100 * d[0] / it,
        (tl[3] - ts[3]) * 1000 / 32768 / max(1, tl[0] - ts[0]), (tl[4] - ts[4]) * 1000 / 32768 / max(1, tl[0] - ts[0])))
