"""Run the compiled ports in the workspace's windowless CEmu with a local ROM."""
import argparse
import json
import hashlib
import os
from pathlib import Path
import re
import subprocess
import struct
import zlib

ROOT = Path(__file__).resolve().parent.parent
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('game', choices=['scoutcamp', 'pedrofu'])
p.add_argument('scenario')
p.add_argument('--rom', type=Path, required=True)
p.add_argument('--sequence', default='[]', help='JSON list of CEmu sequence commands')
p.add_argument('--check', action='append', default=[], help='symbol:value[,alternative...]:bytecount')
p.add_argument('--bin-dir', default='bin', help='build output folder inside the game directory (default bin)')
p.add_argument('--extra', action='append', default=[], type=Path, help='additional .8xv/.8xp to transfer (for example a prepared save)')
a = p.parse_args()
name = {'scoutcamp': 'SCOUTCE', 'pedrofu': 'PEDROCE'}[a.game]
out = ROOT / 'flash-ports' / 'verification' / a.game / a.scenario
out.mkdir(parents=True, exist_ok=True)
program = ROOT / 'flash-ports' / a.game / a.bin_dir / (name + '.8xp')
(out/'run-metadata.json').write_text(json.dumps(dict(program_sha256=hashlib.sha256(program.read_bytes()).hexdigest(),
    program_bytes=program.stat().st_size,map_sha256=hashlib.sha256(program.with_suffix('.map').read_bytes()).hexdigest(),
    scope='Windowless CEmu, local supplied ROM; no physical hardware or launcher equivalence claim.'),indent=2)+'\n')
lib = ROOT / 'local-tools/cemu/clibs/clibs'
files = [lib / (n + '.8xv') for n in ['libload', 'graphx', 'keypadc', 'fileioc']] + [f.resolve() for f in a.extra] + [program]
files += sorted(program.parent.glob('*.8xv'))
config = dict(rom=str(a.rom.resolve()), transfer_files=[str(f) for f in files],
              target=dict(name=name, isASM=True), delay_after_step=0,
              sequence=['action|launch', 'delay|1200'] + json.loads(a.sequence), hashes={})
maptext = program.with_suffix('.map').read_text()
for spec in a.check:
    symbol, value, size = spec.split(':')
    parts = symbol.split('+')
    symbol = parts[0]
    offset = int(parts[1], 0) if len(parts) > 1 else 0
    address = re.search(r'^\s*(0x[\da-fA-F]+)\s+_' + re.escape(symbol) + r'\s*$', maptext, re.M)
    if not address:
        raise SystemExit('Missing map symbol: ' + symbol)
    expected=[]
    for alternative in value.split(','):
        crc = 0xffffffff
        for byte in int(alternative, 0).to_bytes(int(size), 'little'):
            crc ^= byte
            for _ in range(8):
                crc = (crc >> 1) ^ (0x82f63b78 if crc & 1 else 0)
        expected.append(f'{crc ^ 0xffffffff:08X}')
    key = parts[0] + '_' + str(offset)
    config['hashes'][key] = dict(description=spec, start=hex(int(address[1], 16)+offset), size=int(size),
                                    expected_CRCs=expected, timeout=2000)
    config['sequence'].append('hashWait|' + key)
path = out / 'smoke.json'
path.write_text(json.dumps(config, indent=2))
result = subprocess.run([str(ROOT / 'build/cemu-cli/cemu-autotester.exe'), '-d', str(path)],
                        cwd=out, capture_output=True, text=True, timeout=180,
                        creationflags=0x08000000 if os.name == 'nt' else 0)
(out / 'smoke.log').write_text(result.stdout + result.stderr)
print(result.stdout + result.stderr)
raw = out / 'lcd_frame.rgba'
if raw.exists():
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data))
    data = bytearray(raw.read_bytes())
    # CEmu emits packed 0xAARRGGBB pixels (BGRA bytes on this host).
    red = data[2::4]
    data[2::4] = data[0::4]
    data[0::4] = red
    rows = b''.join(b'\0' + data[y*1280:(y+1)*1280] for y in range(240))
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', 320, 240, 8, 6, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(rows)) + chunk(b'IEND', b'')
    (out / 'screen.png').write_bytes(png)
if result.returncode or 'NMI' in result.stdout + result.stderr or '[Error]' in result.stdout + result.stderr:
    raise SystemExit(result.returncode or 1)
