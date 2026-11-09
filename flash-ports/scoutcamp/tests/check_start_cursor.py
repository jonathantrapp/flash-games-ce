"""Host check: the initial building cursor of every stage starts inside the cursor bounds.

Recomputes startLevel()'s cursor (first portal + 4 columns) from the original level
files, applies the same clamp as the in-game cursor movement (1..width-2, 1..height-2),
and confirms src/combat.h contains that clamp. Formula-level check only; it does not
run the game. Exit 0 when every stage is in bounds and the clamp is present.
"""
from pathlib import Path
import json, struct, sys, zlib

root = Path(__file__).resolve().parents[1]
src = (root / 'src/combat.h').read_text(encoding='utf-8')
clamp = 'if(cx>map->width-2)cx=map->width-2;if(cx<1)cx=1;if(cy>map->height-2)cy=map->height-2;if(cy<1)cy=1;'
start = 'cx=map->routes[0].cells[0]%map->width+4;cy=map->routes[0].cells[0]/map->width;'
ok = (start + clamp) in src
rows = []
for level in range(17):
    f = next((root / 'assets/binaryData').glob('*Level%02d.bin' % (level + 1)))
    raw = zlib.decompress(f.read_bytes())
    w, h = struct.unpack('>HH', raw[:4]); n = w * h
    goodies = raw[4 + 3 * n:4 + 4 * n]
    portal = goodies.index(1)
    rx, ry = portal % w + 4, portal // w
    cx, cy = min(max(rx, 1), w - 2), min(max(ry, 1), h - 2)
    inside = 1 <= cx <= w - 2 and 1 <= cy <= h - 2
    ok &= inside
    rows.append({'stage': level + 1, 'width': w, 'height': h, 'raw': [rx, ry],
                 'start': [cx, cy], 'clamped': [rx, ry] != [cx, cy]})
for r in rows:
    print('stage %2d  %3dx%-3d raw (%d,%d) -> start (%d,%d)%s' % (
        r['stage'], r['width'], r['height'], *r['raw'], *r['start'], '  CLAMPED' if r['clamped'] else ''))
print('clamp present in startLevel:', (start + clamp) in src)
(root / 'tests/start-cursor-results.json').write_text(json.dumps(
    {'scope': 'formula check against original level files; not an in-game run', 'pass': bool(ok), 'stages': rows}, indent=1))
print('PASS' if ok else 'FAIL')
sys.exit(0 if ok else 1)
