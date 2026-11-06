"""Losslessly pack the original sky for fast RAM-resident rendering.

GraphX reading a 76,800-byte sky from calculator archive each frame dominates
the frame budget. The packed sky lives in the program's resident RAM instead.
"""
from pathlib import Path
import subprocess
import hashlib
from collections import Counter

HERE = Path(__file__).resolve().parent
a = (HERE / 'data/PDU20.bin').read_bytes()
b = (HERE / 'data/PDU21.bin').read_bytes()
assert a[:2] == b[:2] == bytes([160, 240])
pixels = b''.join(a[2+y*160:2+(y+1)*160] + b[2+y*160:2+(y+1)*160] for y in range(240))
packed = bytearray()
i = 0
while i < len(pixels):
    run = 1
    while i+run < len(pixels) and pixels[i+run] == pixels[i] and run < 128:
        run += 1
    if run >= 3:
        packed.extend((127+run, pixels[i]))
        i += run
    else:
        start = i
        i += run
        while i < len(pixels) and i-start < 128:
            run = 1
            while i+run < len(pixels) and pixels[i+run] == pixels[i] and run < 3:
                run += 1
            if run >= 3:
                break
            i += min(run, 128-(i-start))
        packed.append(i-start-1)
        packed.extend(pixels[start:i])

# Independent read-back rejects corrupt output before compiling it into code.
decoded = bytearray()
i = 0
while i < len(packed):
    token = packed[i]; i += 1
    if token >= 128:
        decoded.extend(bytes([packed[i]]) * (token-127)); i += 1
    else:
        decoded.extend(packed[i:i+token+1]); i += token+1
assert bytes(decoded) == pixels
raw = HERE / 'data/sky-original.bin'
compressed = HERE / 'data/sky-original.zx7'
raw.write_bytes(pixels)
subprocess.run([str(HERE.parents[1] / 'local-tools/cedev/CEdev/bin/convbin.exe'),
                '-j','bin','-k','bin','-c','zx7','-i',str(raw),'-o',str(compressed)],check=True)
stream = compressed.read_bytes()
rows = [pixels[y*320:(y+1)*320] for y in range(240)]
base = [Counter(row).most_common(1)[0][0] for row in rows]
groups = []
for y, color in enumerate(base):
    if groups and groups[-1][0] == color:
        groups[-1][2] += 1
    else:
        groups.append([color,y,1])
lines = ['/* Original sky SHA256: '+hashlib.sha256(pixels).hexdigest()+' */',
         'static const uint8_t cached_sky_rows[][3] = {']
lines += ['{' + ','.join(map(str,g)) + '},' for g in groups]
lines += ['};']
for half in range(2):
    rlet = bytearray([160,240])
    for y,row in enumerate(rows):
        row = row[half*160:(half+1)*160]
        x = 0
        while x < 160:
            start = x
            while x < 160 and row[x] == base[y]:
                x += 1
            rlet.append(x-start)
            if x == 160:
                break
            start = x
            while x < 160 and row[x] != base[y]:
                x += 1
            rlet.append(x-start)
            rlet.extend(row[start:x])
    # Decode exactly the GraphX row format and compare every original pixel.
    decoded = bytearray(); p = 2
    for y in range(240):
        row = bytearray([base[y]])*160; x = 0
        while x < 160:
            x += rlet[p]; p += 1
            if x == 160: break
            count = rlet[p]; p += 1
            row[x:x+count] = rlet[p:p+count]; p += count; x += count
        decoded.extend(row)
    assert p == len(rlet)
    assert bytes(decoded) == b''.join(r[half*160:(half+1)*160] for r in rows)
    lines += [f'static const uint8_t cached_sky_overlay{half}[] = {{']
    lines += [','.join(map(str,rlet[i:i+48]))+',' for i in range(0,len(rlet),48)]
    lines += ['};']
lines += ['']
(HERE / 'src/sky_cache.h').write_text('\n'.join(lines))
print(f'PASS: all {len(pixels)} original sky pixels exact in row-fill/RLET representation ({len(groups)} row fills)')
