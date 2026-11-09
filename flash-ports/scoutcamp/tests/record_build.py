"""Write build-metadata.json for a Scouts bin folder, binding its program hash to the current sources.

Usage: python record_build.py BIN_DIR [--flags "..."]. Run right after building that folder,
before editing sources again; the benchmark refuses folders without this file.
"""
from pathlib import Path
import argparse, hashlib, json
GAME = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('bin_dir'); p.add_argument('--flags', default='-Wall -Wextra -Oz -std=c11; HAS_PRINTF=NO')
a = p.parse_args()
h = lambda f: hashlib.sha256(f.read_bytes()).hexdigest()
names = ['main.c', 'art.c', 'engine.h', 'combat.h', 'input.c', 'small_format.c', '../../pedrofu/src/small_format.c']
meta = dict(program_sha256=h(GAME / a.bin_dir / 'SCOUTCE.8xp'), source_root='src',
            source_sha256={n: h(GAME / 'src' / n) for n in names if (GAME / 'src' / n).exists()},
            flags=a.flags, overlay=False)
(GAME / a.bin_dir / 'build-metadata.json').write_text(json.dumps(meta, indent=2) + '\n')
print(meta['program_sha256'])
