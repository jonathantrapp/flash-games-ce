"""Per-draw-phase and per-HUD-phase averages from a PEDRO_PROFILE build (motion or idle).

Runs the production-entry scenario twice (short/long), subtracts the cumulative counters and
divides by the frame delta. Counters are 32768 Hz timer ticks.
"""
from pathlib import Path
import argparse, concurrent.futures, json, re, struct, subprocess, sys
ROOT = Path(r'E:\AI Stuff\Calc Stuff')
GAME = ROOT / 'flash-ports/pedrofu'
p = argparse.ArgumentParser()
p.add_argument('--bin-dir', required=True); p.add_argument('--tag', required=True)
p.add_argument('--idle', action='store_true')
a = p.parse_args()
mapping = (GAME / a.bin_dir / 'PEDROCE.map').read_text()
def sym(name):
    return int(re.search(r'^\s*(0x[\da-fA-F]+)\s+_' + name + r'\s*$', mapping, re.M)[1], 16) - 0xD00000
prefix = 'enter enter wait:30000 enter enter '
def run(seconds):
    name = '%s_%ds' % (a.tag, seconds)
    out = ROOT / 'flash-ports/verification/pedrofu' / name
    if a.idle:
        keys = prefix + 'wait:%d' % (seconds * 1000)
    else:
        keys = prefix + 'hold:right:4000 down:up ' + ('hold:right:500 hold:left:500 ' * seconds) + 'up:up'
    cmd = [sys.executable, str(ROOT / 'flash-ports/run_scenario.py'), 'pedrofu', name, keys, '--tap', '600',
           '--bin-dir', a.bin_dir, '--check', 'pedro_diag:1:1']
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    if r.returncode:
        raise RuntimeError(r.stdout + r.stderr)
    ram = (out / 'native-ram.bin').read_bytes()
    tot = struct.unpack_from('<5I', ram, sym('pedro_totals'))
    ph = struct.unpack_from('<6I', ram, sym('pedro_phase_sum'))
    hud = struct.unpack_from('<9I', ram, sym('pedro_hud_sum'))
    try:
        dbg = tuple(struct.unpack_from('<10I', ram, sym('pedro_sky_dbg')))
        stm = struct.unpack_from('<6I', ram, sym('pedro_sky_time'))
    except TypeError:
        dbg = (0,)*10; stm = (0,)*6
    return tot, ph, hud, dbg + tuple(stm)
secs = [4, 10] if a.idle else [3, 9]
with concurrent.futures.ThreadPoolExecutor(2) as pool:
    (t0, p0, h0, b0), (t1, p1, h1, b1) = list(pool.map(run, secs))
d = lambda x, y: [(v - u) & 0xffffffff for u, v in zip(x, y)]
frames = d(t0, t1)[0]
sc_frames = d(p0, p1)[5]
tt = d(t0, t1); pp = d(p0, p1); hh = d(h0, h1); bb = d(b0, b1)
ms = lambda v: v * 1000 / 32768 / sc_frames
res = dict(frames=frames, scroll_frames=sc_frames, wait=tt[2]*1000/32768/frames, draw=tt[3]*1000/32768/frames, sim=tt[4]*1000/32768/frames,
           sky=ms(pp[0]), map=ms(pp[1]), actors=ms(pp[2]), decor=ms(pp[3]), hud=ms(pp[4]),
           hud_setup=ms(hh[0]), hud_hearts_mail=ms(hh[1]), hud_fury=ms(hh[2]), hud_xp=ms(hh[3]),
           hud_fmt_lv=ms(hh[4]), hud_print_lv=ms(hh[5]), hud_pts=ms(hh[6]), hud_arena=ms(hh[7]), hud_notice=ms(hh[8]))
res.update(plan_rows=bb[0]/frames, lazy_rows=bb[1]/frames, plan_calls=bb[2]/frames, lazy_calls=bb[3]/frames, tracked_frames=bb[4], known_frames=bb[5], tile_rows=bb[6]/max(1,bb[4]), dirty_rows=bb[7]/max(1,bb[4]), span_rows=bb[8]/max(1,bb[4]), first_content=bb[9]/max(1,bb[4]), t_cmp_scenery=ms(bb[10]), t_covered=ms(bb[11]), t_init=ms(bb[12]), t_scan=ms(bb[13]), t_paint=ms(bb[14]))
for k, v in res.items():
    print('%-16s %s' % (k, '%.3f' % v if isinstance(v, float) else v))
Path(ROOT / 'flash-ports/verification/pedrofu' / (a.tag + '-phases.json')).write_text(json.dumps(res, indent=1) + '\n')
