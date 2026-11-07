"""Static worst-case stack estimate from the LTO assembly (ez80-clang output).

For each function: frame bytes (return address + saved IX + locals from
__frameset / explicit SP adjustment) plus the deepest pushed-argument depth
seen before any call. Walks the call graph for the deepest path from main.
Indirect calls and library internals are reported, not guessed: library
routines (gfx_, ti_, kb_, OS) add their own unmeasured depth on top.

Usage: python stack_depth.py obj_v6/lto.s [--json out.json]
"""
import json
import re
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_text().splitlines()
funcs, order, cur = {}, [], None
label = re.compile(r'^(_[A-Za-z0-9_.$]+):')
for line in src:
    m = label.match(line)
    if m and not m.group(1).startswith('.L'):
        cur = m.group(1)
        funcs.setdefault(cur, dict(frame=3, push=0, maxpush=0, calls={}, indirect=False, lines=0))
        order.append(cur)
        pending = None
        continue
    if cur is None:
        continue
    f = funcs[cur]
    s = line.strip().split(';')[0].strip()
    if not s or s.startswith('.'):
        continue
    f['lines'] += 1
    op = s.split(None, 1)
    ins, arg = op[0], (op[1] if len(op) > 1 else '')
    if ins == 'ld' and re.match(r'hl,\s*-(\d+)$', arg):
        pending = int(re.match(r'hl,\s*-(\d+)$', arg).group(1))
        continue
    if ins == 'call' and arg == '__frameset':
        f['frame'] = max(f['frame'], 6 + (pending or 0))
    elif ins == 'call' and arg == '__frameset0':
        f['frame'] = max(f['frame'], 6)
    elif ins == 'add' and arg.replace(' ', '') == 'hl,sp' and pending:
        f['spadj'] = pending
    elif ins == 'ld' and arg.replace(' ', '') == 'sp,hl' and f.get('spadj'):
        f['frame'] = max(f['frame'], 6 + f['spadj'])
    elif ins == 'push':
        f['push'] += 3
        f['maxpush'] = max(f['maxpush'], f['push'])
    elif ins == 'pop':
        f['push'] = max(0, f['push'] - 3)
    elif ins == 'inc' and arg == 'sp':
        pass
    elif ins in ('call', 'jp') and arg:
        target = arg.split(',')[-1].strip()
        if target.startswith('(') or target in ('(hl)', '(ix)', '(iy)'):
            if ins == 'call' or target in ('(hl)', '(ix)', '(iy)'):
                f['indirect'] = True
        elif target.startswith('_') and ins == 'call':
            f['calls'][target] = max(f['calls'].get(target, 0), f['push'])
        elif target.startswith('_') and ins == 'jp' and target in funcs or (ins == 'jp' and target.startswith('_') and not target.startswith('.L')):
            # tail call: callee reuses caller's return slot
            f['calls'][target] = max(f['calls'].get(target, 0), f['push'] - 3)
    pending = pending if ins == 'ld' else None

memo, path_of = {}, {}
def depth(name, stack=()):
    if name in stack:
        return 0, [name + ' (RECURSION)']
    if name in memo:
        return memo[name], path_of[name]
    f = funcs.get(name)
    if not f:
        return 0, [name + ' (external)']
    best, bestpath = 0, []
    for callee, pushed in f['calls'].items():
        d, p = depth(callee, stack + (name,))
        if pushed + 3 + d > best:
            best, bestpath = pushed + 3 + d, p
    total = f['frame'] - 3 + best
    memo[name] = total
    path_of[name] = [f"{name} frame={f['frame']}"] + bestpath
    return total, path_of[name]

root = '_main'
total, path = depth(root)
recursive = [n for n in funcs if any(n in p for p in [' '.join(path_of.get(n, []))]) and 'RECURSION' in ' '.join(path_of.get(n, []))]
externals = sorted({c for f in funcs.values() for c in f['calls'] if c not in funcs})
indirect = sorted(n for n, f in funcs.items() if f['indirect'])
biggest = sorted(((f['frame'], n) for n, f in funcs.items()), reverse=True)[:15]
report = dict(root=root, worst_case_bytes_excluding_libraries=total, deepest_path=path,
              largest_frames=[dict(function=n, frame=b) for b, n in biggest],
              functions_with_indirect_calls=indirect, external_callees=externals,
              recursion_detected=[p for p in path if 'RECURSION' in p])
print(json.dumps(report, indent=2))
if '--json' in sys.argv:
    Path(sys.argv[sys.argv.index('--json') + 1]).write_text(json.dumps(report, indent=2) + '\n')
