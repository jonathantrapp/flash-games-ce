"""Build a prepared save AppVar so emulator runs can exercise late-game code paths.

  python make_test_save.py scoutcamp maxed verification/saves/SCTSV02.8xv
  python make_test_save.py pedrofu maxed verification/saves/PDPROG2.8xv

'maxed' gives every skill rank 5, every stage passed and a few spare skill points. The layouts mirror
`Save` in scoutcamp/src/engine.h and `Progress` in pedrofu/src/game.h (eZ80 aligns 16-bit fields to 2 bytes).
Pass the result to run_scenario.py with --extra.
"""
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONVBIN = ROOT / 'local-tools/cedev/CEdev/bin/convbin.exe'
game, profile, output = sys.argv[1], sys.argv[2], Path(sys.argv[3])
assert profile == 'maxed', 'only the maxed profile is defined'
if game == 'scoutcamp':
    name = 'SCTSV02'
    data = b'SCV2' + bytes([5] * 48) + bytes([1] * 17) + bytes([30]) + struct.pack('<H', 6) + struct.pack('<I', 0)
    assert len(data) == 76
elif game == 'pedrofu':
    name = 'PDPROG2'
    pad = bytes([0])  # one pad byte before the 16-bit xp field: sizeof(Progress) is 200 on eZ80
    body = (bytes([5] * 45) + bytes([1] * 45) + bytes([1] * 15) + bytes([1] * 15) + bytes([1] * 14 + [0])
            + bytes([50, 6]) + pad + struct.pack('<H', 0) + struct.pack('<15I', *([900] * 15)))
    data = b'PDF2' + body
    assert len(body) == 200
else:
    raise SystemExit('unknown game')
output.parent.mkdir(parents=True, exist_ok=True)
raw = output.with_suffix('.bin')
raw.write_bytes(data)
subprocess.run([str(CONVBIN), '-j', 'bin', '-k', '8xv', '-r', '-n', name, '-i', str(raw), '-o', str(output)], check=True, stdout=subprocess.DEVNULL)
raw.unlink()
print('wrote', output, len(data), 'bytes of save data')
