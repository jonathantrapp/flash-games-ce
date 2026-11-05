"""Check Pedro's generated data against the original files.

1. Arena tables in src/arena.c equal the arrays in Arena.as (enemy class names mapped to map ids).
2. Every conversation page in src/dialogue_data.h equals the recovered original text (pedro-dialogue-spec.json).
3. All 15 stage layouts read back out of the packed AppVar banks equal the decompressed original level
   data, layer for layer (run after build_assets.py and bundle_assets.py).
"""
from pathlib import Path
import json
import re
import struct
import sys
import zlib

HERE = Path(__file__).resolve().parent
GAME = HERE.parent
failures = []

# 1. arena tables
ids = {'Yak': 2, 'Yak_Archer': 17, 'Yak_Archer_Elite': 41, 'Yak_Armor': 16, 'Yakolyte': 45, 'Yak_Bruiser': 38, 'Yak_Ninja': 35, 'Iron_Priest': 47, 'null': 0}
arena_source = (GAME / 'original/scripts/xplor/Arena.as').read_text(encoding='utf-8')
original = [[ids[x.strip()] if x.strip() in ids else int(x) for x in a.split(',')] for a in re.findall(r'new Array\(([^;]*)\);', arena_source)[:6]]
native_source = (GAME / 'src/arena.c').read_text(encoding='utf-8')
names = ['locations', 'locations2', 'rounds', 'rounds2', 'powerPos', 'powerPos2']
native = [[int(x) for x in re.search(r'static const uint8_t ' + n + r'\[\]=\{([^}]*)\}', native_source)[1].split(',')] for n in names]
for n, o, m in zip(names, original, native):
    if o != m:
        failures.append('arena table ' + n)
checks = len(names)

# 2. dialogue text
spec = json.loads((GAME.parent / 'pedro-dialogue-spec.json').read_text(encoding='utf-8'))
header = (GAME / 'src/dialogue_data.h').read_text(encoding='utf-8')
block = header[header.index('dialogue_pages'):header.index('dialogue_lengths')]
events = {}
for m in re.finditer(r'^\[(\d+)\]=\{(.*?)\},$', block, re.S | re.M):
    events[int(m[1])] = [bytes(s, 'utf-8').decode('unicode_escape').encode('latin-1').decode('utf-8') if '\\' in s else s
                         for s in re.findall(r'"((?:[^"\\]|\\.)*)"', m[2])]
pages = 0
for event in spec['events']:
    expected = [p['text'] for p in event['initial']] + [p['text'] for p in event['followups']]
    got = events.get(event['event'], [])
    checks += 1
    pages += len(expected)
    if sorted(expected) != sorted(got):
        failures.append('dialogue event %d: %r != %r' % (event['event'], expected, got))

# 3. stage layouts from the packed banks
bundle = (GAME / 'src/bundle.h').read_text(encoding='utf-8')
entries = {n: (int(b), int(o), int(s)) for n, b, o, s in re.findall(r'\{"(\w+)",(\d+),(\d+),(\d+)\}', bundle)}
banks = {}
for i in range(100):
    path = GAME / 'data' / ('PDB%02d.bin' % i)
    if not path.exists():
        break
    banks[i] = path.read_bytes()
for level in range(1, 16):
    raw = zlib.decompress(next((GAME / 'assets/binaryData').glob('*Level%02d.bin' % level)).read_bytes())
    w, h = struct.unpack('>HH', raw[:4])
    bank, offset, size = entries['PDLV%02d' % level]
    packed = banks[bank][offset:offset + size]
    checks += 1
    if packed != struct.pack('<HH', w, h) + raw[4:]:
        failures.append('stage %d layout differs from the original' % level)

print('%d checks (%d dialogue pages across %d events); %d differences' % (checks, pages, len(spec['events']), len(failures)))
for f in failures:
    print(' ', f)
sys.exit(bool(failures))
