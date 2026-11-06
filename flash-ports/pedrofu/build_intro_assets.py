"""Convert original opening-cinematic art without changing the game's palette.

Outputs raw payloads for the shared bundle builder:
PDBLIMP0.bin/PDBLIMP1.bin are the two 160x62 halves of the original 320x62 art.
PDBOOM.bin contains the original fourteen 32x32 explosion animation frames.
"""
from pathlib import Path
import struct
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(ROOT / 'local-tools/plot-libs'))
from PIL import Image

raw_palette = (HERE / 'data/PDCOLOR.bin').read_bytes()
assert len(raw_palette) == 512
palette = []
for i in range(256):
    value = struct.unpack_from('<H', raw_palette, i * 2)[0]
    palette.append((((value >> 10) & 31) * 255 // 31,
                    ((value >> 5) & 31) * 255 // 31,
                    (value & 31) * 255 // 31))
cache = {}

def nearest(rgb):
    if rgb not in cache:
        # Index 0 is reserved for transparency, even for opaque black pixels.
        cache[rgb] = min(range(1, 256), key=lambda i:
            sum((a - b) ** 2 for a, b in zip(rgb, palette[i])))
    return cache[rgb]

def sprite(im):
    im = im.convert('RGBA')
    return bytes(im.size) + bytes(0 if a < 128 else nearest((r, g, b))
                                  for r, g, b, a in im.getdata())

def image(suffix):
    return Image.open(next((HERE / 'assets/images').glob('*' + suffix + '.png')))

blimp = image('Blimp_BlimpImage')
assert blimp.size == (320, 62), blimp.size
for half in range(2):
    payload = sprite(blimp.crop((half * 160, 0, half * 160 + 160, 62)))
    assert len(payload) == 9922
    (HERE / 'data' / f'PDBLIMP{half}.bin').write_bytes(payload)

boom = image('Boom_BoomImage')
assert boom.width % 32 == 0 and boom.height % 32 == 0
columns = boom.width // 32
assert columns * (boom.height // 32) >= 14
payload = b''.join(sprite(boom.crop((i % columns * 32, i // columns * 32,
                                   i % columns * 32 + 32, i // columns * 32 + 32)))
                   for i in range(14))
assert len(payload) == 14364
(HERE / 'data/PDBOOM.bin').write_bytes(payload)
print('Built PDBLIMP0 (9922), PDBLIMP1 (9922), PDBOOM (14364 bytes).')

flame = image('PedroFlame_SmokeImage')
assert flame.width % 20 == 0 and flame.height % 36 == 0
cols = flame.width // 20
assert cols * (flame.height // 36) >= 13
payload = b''.join(sprite(flame.crop((i%cols*20,i//cols*36,i%cols*20+20,i//cols*36+36))) for i in range(13))
assert len(payload) == 13*722
(HERE/'data/PDPFLAME.bin').write_bytes(payload)
print('Built original 13-frame Pedro flame effect (9386 bytes).')
