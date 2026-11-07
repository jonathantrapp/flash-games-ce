"""Drive CEmu through a launcher path (arTIfiCE via Cabri Jr, optionally Cesium)
instead of the autotester's direct Asm(prgm) launch.

The launcher files come from the user's own pre-transfer calculator backup
(backups/2026-10-30-before-first-transfer). Nothing is downloaded.
Steps use run_scenario.py syntax. Taps before the token GAME last 220 ms (launcher
menus auto-repeat on long holds); taps after it use --tap.
and `snap` is implicit at the end (screen.png, native-ram.bin in debug mode).

Example:
  python flash-ports/launcher_scenario.py pedrofu art_probe "apps wait:800 2 wait:3000" --no-game
"""
import argparse
import hashlib
import json
import os
import struct
import subprocess
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BACKUP = ROOT / 'backups/2026-10-30-before-first-transfer'
p = argparse.ArgumentParser()
p.add_argument('game', choices=['scoutcamp', 'pedrofu'])
p.add_argument('scenario')
p.add_argument('steps')
p.add_argument('--rom', type=Path, default=Path(r'C:\Users\jonat\Downloads\ti-84ce.rom'))
p.add_argument('--bin-dir', default='bin')
p.add_argument('--no-game', action='store_true', help='transfer only launcher files (fast navigation probes)')
p.add_argument('--cesium', action='store_true', help='also transfer the backed-up Cesium app')
p.add_argument('--user-libs', action='store_true', help="use the calculator backup's older CE libraries instead of the package libraries")
p.add_argument('--tap', type=int, default=220)
p.add_argument('--gap', type=int, default=150)
p.add_argument('--rom-cabri', action='store_true', help='Cabri Jr is already installed in the ROM image')
p.add_argument('--pkg-dir', type=Path, help='take the program and its data AppVars from this package folder instead')
p.add_argument('--direct', action='store_true', help='control run: launch with the home-screen Asm(prgm) path, no launcher')
p.add_argument('--name', help='program name override (for example PEDRODG)')
p.add_argument('--extra', action='append', default=[])
p.add_argument('--check', action='append', default=[])
a = p.parse_args()
if a.pkg_dir:
    a.pkg_dir = a.pkg_dir.resolve()

name = a.name or {'scoutcamp': 'SCOUTCE', 'pedrofu': 'PEDROCE'}[a.game]
out = ROOT / 'flash-ports/verification' / a.game / a.scenario
out.mkdir(parents=True, exist_ok=True)
program = (a.pkg_dir / (name + '.8xp')) if a.pkg_dir else ROOT / 'flash-ports' / a.game / a.bin_dir / (name + '.8xp')
files = [] if a.direct else ([] if a.rom_cabri else [BACKUP / 'CabriJr.8ek']) + [BACKUP / 'ARTIFICE.8xv']
if a.cesium:
    files += [BACKUP / 'Cesium.8ek', BACKUP / 'Cesium.8xv']
if a.user_libs:
    files += [BACKUP / n for n in ['LibLoad.8xv', 'GRAPHX.8xv', 'KEYPADC.8xv', 'FILEIOC.8xv']]
else:
    lib = ROOT / 'local-tools/cemu/clibs/clibs'
    files += [lib / (n + '.8xv') for n in ['libload', 'graphx', 'keypadc', 'fileioc']]
files += [Path(f).resolve() for f in a.extra]
if not a.no_game:
    files += [program] + sorted(f for f in program.parent.glob('*.8xv') if f.name.upper().startswith(('PD' if a.game == 'pedrofu' else 'SC')))

seq = ['action|launch', 'delay|1200'] if a.direct else []
tap = 220  # launcher navigation always uses ordinary taps; GAME switches to --tap
for step in a.steps.split():
    if step == 'GAME':
        tap = a.tap
        continue
    if step.startswith('wait:'):
        seq.append('delay|' + step[5:])
    elif step.startswith('key:'):
        seq.append('key|' + step[4:])
    elif step.startswith('hold:'):
        _, key, ms = step.split(':')
        seq += [f'hold|{key}', f'delay|{ms}', f'release|{key}', f'delay|{a.gap}']
    elif step.startswith('down:'):
        seq.append('hold|' + step[5:])
    elif step.startswith('up:'):
        seq += ['release|' + step[3:], f'delay|{a.gap}']
    else:
        key, _, count = step.partition('*')
        for _ in range(int(count or 1)):
            seq += [f'hold|{key}', f'delay|{tap}', f'release|{key}', f'delay|{a.gap}']

import re
config = dict(rom=str(a.rom.resolve()), transfer_files=[str(f) for f in files],
              target=dict(name=name, isASM=True), delay_after_step=0, sequence=seq, hashes={})
if not a.no_game and a.check:
    maptext = program.with_suffix('.map').read_text()
    for spec in a.check:
        symbol, value, size = spec.split(':')
        sym, _, off = symbol.partition('+')
        m = re.search(r'^\s*(0x[\da-fA-F]+)\s+_' + re.escape(sym) + r'\s*$', maptext, re.M)
        expected = []
        for alt in value.split(','):
            crc = 0xffffffff
            for byte in int(alt, 0).to_bytes(int(size), 'little'):
                crc ^= byte
                for _ in range(8):
                    crc = (crc >> 1) ^ (0x82f63b78 if crc & 1 else 0)
            expected.append(f'{crc ^ 0xffffffff:08X}')
        key = sym + '_' + (off or '0')
        config['hashes'][key] = dict(description=spec, start=hex(int(m[1], 16) + int(off or '0', 0)), size=int(size),
                                     expected_CRCs=expected, timeout=2000)
        config['sequence'].append('hashWait|' + key)
meta = dict(launcher='direct Asm(prgm) control' if a.direct else 'Cabri Jr + ARTIFICE from user backup' + (' + Cesium' if a.cesium else ''),
            libraries='calculator backup' if a.user_libs else 'package/toolchain',
            steps=a.steps, scope='CEmu OS 5.3 ROM; launcher path only, not OS 5.8.2.29 hardware.')
if not a.no_game:
    meta.update(program_sha256=hashlib.sha256(program.read_bytes()).hexdigest(), program_bytes=program.stat().st_size)
(out / 'run-metadata.json').write_text(json.dumps(meta, indent=2) + '\n')
path = out / 'smoke.json'
path.write_text(json.dumps(config, indent=2))
for stale in ('lcd_frame.rgba', 'native-ram.bin', 'screen.png'):
    (out / stale).unlink(missing_ok=True)
r = subprocess.run([str(ROOT / 'build/cemu-cli/cemu-autotester.exe'), '-d', str(path)], cwd=out,
                   capture_output=True, text=True, timeout=900,
                   creationflags=0x00000040 | 0x08000000 if os.name == 'nt' else 0)
(out / 'smoke.log').write_text(r.stdout + r.stderr)
lines = [l for l in (r.stdout + r.stderr).splitlines() if any(k in l for k in ('passed', 'failed', 'Error', 'NMI', '[CPU]', 'crash', 'reset'))]
print('\n'.join(lines[-8:]))
raw = out / 'lcd_frame.rgba'
if raw.exists():
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data))
    data = bytearray(raw.read_bytes())
    red = data[2::4]; data[2::4] = data[0::4]; data[0::4] = red
    rows = b''.join(b'\0' + data[y*1280:(y+1)*1280] for y in range(240))
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', 320, 240, 8, 6, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(rows)) + chunk(b'IEND', b'')
    (out / 'screen.png').write_bytes(png)
print('screenshot:', out / 'screen.png')
sys.exit(r.returncode)
